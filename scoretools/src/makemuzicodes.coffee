# make muzicodes experience
if process.argv.length != 2 and process.argv.length!=3
  console.log 'Usage: node makemuzicodes [<config.yaml>]'
  process.exit -1

yaml = require 'js-yaml'
fs   = require 'fs'
path = require 'path'

# Get document, or throw exception on error 
configfile = process.argv[2] ? 'config.yml'
configfile = path.normalize configfile
configdir = if path.isAbsolute configfile then path.dirname configfile else path.join process.cwd(), (path.dirname configfile) 
console.log 'read config '+configfile+' from '+configdir

config = {}
try 
  config = yaml.safeLoad fs.readFileSync configfile, 'utf8'
  console.log config
catch e 
  console.log 'error reading config '+configfile+': '+e.message
  process.exit -2

relpath = (p, base) ->
  if path.isAbsolute p then p else path.normalize (path.join base, p)

xlfile = relpath config.spreadsheet, configdir
exinfile = relpath config.experiencein, configdir
exoutfile = relpath config.experienceout, configdir

xlsx = require 'xlsx'
fs = require 'fs'

console.log 'read template experience '+exinfile
ex = JSON.parse fs.readFileSync exinfile, {encoding:'utf8'}

console.log 'read spreadsheet '+xlfile
workbook = xlsx.readFile xlfile
sheet = workbook.Sheets[workbook.SheetNames[0]]
cellid = (c,r) -> 
  p = String(r+1)
  rec = (c) ->
    p = (String.fromCharCode 'A'.charCodeAt(0)+(c % 26)) + p
    c = Math.floor (c/26)
    if c!=0
      rec c-1
  rec c
  p 
#console.log 'A1 = '+cellid(0,0)+' '+(JSON.stringify sheet[cellid(0,0)]) 

readrow = (r) ->
  data = {}
  prefix = ''
  for c in [0..1000]
    head = sheet[cellid(c,0)]?.v?.toLowerCase()
    if not head?
      break
    if (head.indexOf ':') >= 0
      prefix = (head.substring 0, head.indexOf ':')+'_'
      head = head.substring (head.indexOf ':')+1
    key = prefix+head
    val = sheet[cellid(c,r)]?.v
    if val?
      data[key] = sheet[cellid(c,r)]?.v
  data

# clean up template
ex.markers ?= []
ex.controls = []
ex.parameters ?= {}
for marker in ex.markers
  marker.actions = []
  delete marker.action
  delete marker.precondition
  marker.poststate = {}

# state - stage (string), cued (bool)
ex.parameters.initstate = 
  stage: '""'
  cued: false
  meldmei: '""'
  meldcollection: '""'

stages = {}

prefixes = ['auto_', 'mc1_', 'mc2_', 'mc3_']
mcs = ['mc1_', 'mc2_', 'mc3_']

add_actions = (actions, prefix, data) ->
  # monitor
  control.actions.push 
    channel: ''
    url: data[prefix+'monitor']
  # visual
  if data[prefix+'visual']?
    control.actions.push 
      channel: 'visual'
      url: data[prefix+'visual']
  # stage state
  control.poststate ?= {}
  control.poststate.cued = "false"
  control.poststate.stage = JSON.stringify data.stage;
  # TODO ...
  #if data[prefix+'cue']?

for r in [1..1000]
  cell = sheet[cellid(0,r)]
  if cell == undefined
    break
  data = readrow r
  if not data.stage? 
    console.log 'ignore row without stage name: '+(JSON.stringify data)
    continue
  console.log 'stage '+data.stage
  stages[data.stage] = data
  # defaults for ...-monitor
  for prefix in prefixes
    data[prefix+'monitor'] ?= 'data:text/plain,stage '+data.stage+' '+prefix+'monitor' 

  # TODO default-cue
  if r==1
    # default stage
    ex.parameters.initstate.stage = JSON.stringify data.stage
    # auto on event:load
    control = {inputUrl:'event:load', actions:[]}
    ex.controls.push control
    add_actions control.actions, 'auto_', data
    # MELD input POST
    control = 
      inputUrl:'post:meld.load'
      actions: []
    ex.controls.push control
    add_actions control.actions, 'auto_', data
    control.poststate.meldmei = '"{{params.meldmei}}"'
    control.poststate.meldcollection = '"{{params.meldcollection}}"'
  else
    # non-default stage
    # test button
    control = {inputUrl:'button:'+data.stage, actions:[]}
    ex.controls.push control
    add_actions control.actions, 'auto_', data
    # MELD input POST
    control = 
      inputUrl:'post:meld.load:'+data.stage
      actions: []
    ex.controls.push control
    add_actions control.actions, 'auto_', data
    control.poststate.meldmei = '"{{params.meldmei}}"'
    control.poststate.meldcollection = '"{{params.meldcollection}}"'

  # muzicodes
  # TODO

console.log 'write experience '+exoutfile
fs.writeFileSync exoutfile, (JSON.stringify ex), {encoding: 'utf8'}
console.log 'done'
return 0