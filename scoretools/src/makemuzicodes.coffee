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
  marker.precondition = ''

# state - stage (string), cued (bool)
ex.parameters.initstate = 
  stage: '""'
  cued: false
  meldmei: '""'
  meldcollection: '""'
  meldnextstage: 'null'
  meldserver: JSON.stringify (config.meldserver ? 'http://localhost:5000/annotations/')
  mcserver: JSON.stringify (config.mcserver ? 'http://localhost:3000/input')

defaultprojection = String(config.defaultprojection ? '')
if defaultprojection == ''
  console.log "WARNING: defaultprojection is not defined in "+configfile
else
  if ((p for p in (ex.projections ? []) when p.id==defaultprojection) ? []).length == 0
    console.log 'WARNING: cannot find default projection "'+defaultprojection+'"'
  else
    console.log 'using default projection "'+defaultprojection+'"'

stages = {}

prefixes = ['auto_', 'mc1_', 'mc2_', 'mc3_', 'default_']
mcs = ['mc1_', 'mc2_', 'mc3_']
weathers = ['no', 'wind', 'rain', 'snow', 'sun', 'storm']

# effect urls
effects = '['
for w,wi in weathers
  if not config[w+'_effect']?
    console.log 'ERROR: '+w+'_effect not defined in '+configfile
  if wi>0
    effects += ','
  effects+= JSON.stringify config[w+'_effect'] 
effects += ']'
ex.parameters.initstate.effects = effects 

add_actions = (control, prefix, data) ->
  # monitor
  control.actions.push 
    channel: ''
    url: data[prefix+'monitor']
  # visual
  if data[prefix+'visual']?
    control.actions.push 
      channel: 'visual'
      url: data[prefix+'visual']
  # midi
  if data[prefix+'midi']?
    # multiple 
    msgs = data[prefix+'midi'].split ','
    for msg in msgs
      msg = msg.trim()
      if msg.length > 0
        control.actions.push
          channel: ''
          url: 'data:text/x-midi-hex,'+msg
  # stage state
  control.poststate ?= {}
  control.precondition ?= ''
  # cue next stage
  if data[prefix+'cue']?
    # if it cues, can it only happen if not already cued?!
    if (prefix!='auto_' && control.precondition.indexOf 'cued') < 0
      control.precondition = '!cued'+(if control.precondition.length == 0 then '' else ' && (')+control.precondition+(if control.precondition.length == 0 then '' else ')')
    control.actions.push 
      url: '{{meldserver}}{{encodeURIComponent(meldcollection)}}'
      post: true
      contentType: 'application/json'
      body: '{"name":'+(JSON.stringify 'meld.load:'+data[prefix+'cue'])+','+
        '"callback":"{{mcserver}}"}'
    control.poststate.meldnextstage = JSON.stringify data[prefix+'cue']
    control.poststate.cued = "true"
    # TODO proper MELD request

set_stage = (control, data) ->
  control.poststate ?= {}
  control.poststate.cued = "false"
  control.poststate.stage = JSON.stringify data.stage;
  # weather
  ws = []
  for w,wi in weathers
    if data[w+'_effect']? and data[w+'_effect'].length>0 and data[w+'_effect'].substring(0,1).toLowerCase()=='y'
      ws.push wi
  if ws.length == 0
    ws.push 0
  control.actions.push 
    url: '{{effects[(['+(ws.join ',')+'])[Math.floor(Math.random()*'+ws.length+')]]}}'

# find/make named marker
get_marker = (ex, markertitle, optdescription) ->
  markers = (marker for marker in ex.markers when marker.title == markertitle) ? []
  if markers.length > 1
    console.log 'WARNING: marker "'+markertitle+'" defined '+markers.length+' times; using first'
  else if markers.length == 0
    console.log 'WARNING: marker  "'+markertitle+'" undefined - adding to output'
    marker = 
      title: markertitle
      description: optdescription
      poststate: {}
      actions: []
      precondition: ''
    ex.markers.push marker
    markers = [marker]
  return markers[0]

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
    data[prefix+'monitor'] ?= 'data:text/plain,stage '+data.stage+' '+prefix+' triggered!' 

  # TODO default-cue
  if r==1
    # default stage
    ex.parameters.initstate.stage = JSON.stringify data.stage
    # auto on event:load
    control = {inputUrl:'event:load', actions:[]}
    ex.controls.push control
    set_stage control, data
    add_actions control, 'auto_', data
    # MELD input POST
    control = 
      inputUrl:'post:meld.load'
      actions: []
    ex.controls.push control
    set_stage control, data
    add_actions control, 'auto_', data
    control.poststate.meldmei = 'params.meldmei'
    control.poststate.meldcollection = 'params.meldcollection'
    control.poststate.meldnextstage = 'null';
  else
    # non-default stage
    # test button
    control = {inputUrl:'button:'+data.stage, actions:[]}
    ex.controls.push control
    set_stage control, data
    add_actions control, 'auto_', data
    # MELD input POST
    control = 
      inputUrl:'post:'+encodeURIComponent('meld.load:'+data.stage)
      actions: []
    ex.controls.push control
    set_stage control, data
    add_actions control, 'auto_', data
    control.poststate.meldmei = 'params.meldmei'
    control.poststate.meldcollection = 'params.meldcollection'
    control.poststate.meldnextstage = 'null';

  # muzicodes
  for mc in mcs
    if not data[mc+'name']
      continue
    marker = get_marker ex, data[mc+'name'], ('stage '+data.stage+' '+mc+'name')
    # in stage precondition
    suffix = ''
    if marker.precondition.length > 0
      if marker.precondition.substring(marker.precondition.length-1) == ')'
        suffix = ')'
        marker.precondition = marker.precondition.substring(0, marker.precondition.length-1)
      marker.precondition += ' || '
    marker.precondition += 'stage=="'+data.stage+'"'+suffix
    add_actions marker, mc, data
    
  # default cue
  if defaultprojection!='' && data['default_cue']?
    control = 
      inputUrl: 'event:end:'+defaultprojection
      actions: []
      precondition: 'stage=='+(JSON.stringify data.stage)
      poststate: {}
    ex.controls.push control
    add_actions control, 'default_', data

# check cross-references
errors = 0;
for stage,data of stages
  for prefix in prefixes
    if data[prefix+'cue']? and not stages[data[prefix+'cue']]?
      console.log 'ERROR: stage '+stage+' '+prefix+'cue refers to unknown stage "'+data[prefix+'cue']+'"'
      errors++

# fake meld input
control = {inputUrl:'button:Force Next',actions:[],precondition:'!!meldnextstage'}
ex.controls.push control
control.actions.push 
  url: 'http://localhost:3000/input'
  post: true
  contentType: 'application/x-www-form-urlencoded'
  body: 'name={{encodeURIComponent("meld.load:"+meldnextstage)}}&meldmei=&meldcollection='
  # meldmei, meldcollection

console.log 'write experience '+exoutfile
fs.writeFileSync exoutfile, (JSON.stringify ex, null, '  '), {encoding: 'utf8'}
console.log 'done'
return errors