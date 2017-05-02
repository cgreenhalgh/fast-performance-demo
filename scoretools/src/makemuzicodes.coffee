# make muzicodes experience
if process.argv.length != 2 and process.argv.length!=3
  console.log 'Usage: node makemuzicodes [<config.yaml>]'
  process.exit -1

yaml = require 'js-yaml'
fs   = require 'fs'
path = require 'path'
getCodeIds = (require './meiutils').getCodeIds

climbview = require './climbview'

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
viewoutfile = relpath config.climbviewout, configdir

# climbview config generator
viewgen = climbview.generator 'Climbview '+viewoutfile+' from '+configfile, config

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
  meldannostate: '""'
  meldnextmeifile: 'null'
  mcserver: JSON.stringify (config.mcserver ? 'http://localhost:3000/input')
  meldmeiuri: JSON.stringify (config.meldmeiuri ? 'http://localhost:3000/content/')
  contenturi: JSON.stringify (config.contenturi ? 'http://localhost:3000/content/')

defaultprojection = String(config.defaultprojection ? '')
if defaultprojection == ''
  console.log "WARNING: defaultprojection is not defined in "+configfile
else
  if ((p for p in (ex.projections ? []) when p.id==defaultprojection) ? []).length == 0
    console.log 'WARNING: cannot find default projection "'+defaultprojection+'"'
  else
    console.log 'using default projection "'+defaultprojection+'"'

# allow only one cued piece?
cuesingle = config.cuesingle ? false

stages = {}

prefixes = ['auto_', 'mc1_', 'mc2_', 'mc3_', 'mc4_', 'mc5_', 'default_']
mcs = ['mc1_', 'mc2_', 'mc3_']
weathers = ['no', 'wind', 'rain', 'snow', 'sun', 'storm']

# effect urls
effects = '['
weather_urls = '['
sweathers = '['
for w,wi in weathers

  if wi>0
    sweathers += ','
  sweathers +=  JSON.stringify w
  if not config[w+'_effect']?
    console.log 'ERROR: '+w+'_effect not defined in '+configfile
  if wi>0
    effects += ','
  effects+= JSON.stringify config[w+'_effect'] 
  if not config[w+'_url']?
    console.log 'ERROR: '+w+'_url not defined in '+configfile
  if wi>0
    weather_urls += ','
  weather_urls += JSON.stringify config[w+'_url'] 

  control = {inputUrl:'delay:'+w, actions:[]};
  control.actions.push
    channel: ''
    url: config[w+'_effect']
  control.actions.push
    channel: 'v.weather'
    url: config[w+'_url']
  ex.controls.push control

effects += ']'
weather_urls += ']'
sweathers += ']'
ex.parameters.initstate.effects = effects 
ex.parameters.initstate.weather_urls = weather_urls
ex.parameters.initstate.weathers = sweathers

# effect/weather delay controls
mindelay = Number( config.weatherdelaymin ? 0 )
maxdelay = Number( config.weatherdelaymax ? 0 )
weatherdelay = ''+mindelay+'+Math.random()*'+(maxdelay-mindelay)
if (maxdelay<mindelay)
	maxdelay = mindelay;

content_url = (url) ->
  if (url.indexOf ':') < 0 and (url.substring 0,1) != '/'
    return '{{contenturi}}'+url
  else
     return url

add_actions = (control, prefix, data, meldload) ->
  # monitor
  control.actions.push 
    channel: ''
    url: content_url data[prefix+'monitor']
  # visual
  for channel in ['v.background', 'v.animate', 'v.mc']
    if data[prefix+channel]?
      if channel=='v.mc' && String(data[prefix+channel])=='1'
        if config.defaultmuzicodeurl?
          control.actions.push 
            channel: channel
            url: content_url config.defaultmuzicodeurl
        else
          console.log 'ERROR: use of undefined defaultmuzicodeurl in '+prefix+channel
      else
        viewgen.add data[prefix+channel]
        control.actions.push 
          channel: channel
          url: content_url data[prefix+channel]
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
    nextstage = data[prefix+'cue']
    # if it cues, can it only happen if not already cued?!
    if (cuesingle && prefix!='auto_' && control.precondition.indexOf 'cued') < 0
      control.precondition = '!cued'+(if control.precondition.length == 0 then '' else ' && (')+control.precondition+(if control.precondition.length == 0 then '' else ')')
    if not stages[nextstage] ?
      console.log 'ERROR: stage '+data.stage+' '+prefix+' cue to unknown stage: '+nextstage
    else
      meldprefix = if meldload then 'params.' else ''
      control.actions.push 
        url: '{{'+meldprefix+'meldcollection}}'
        post: true
        contentType: 'application/json'
        body: '{"oa:hasTarget":["{{'+meldprefix+'meldannostate}}"], "oa:hasBody":[{"@type":"meldterm:CreateNextCollection", "resourcesToQueue":["{{meldmeiuri}}'+encodeURIComponent(stages[nextstage].meifile)+'"], "annotationsToQueue":[]}] }'
      control.poststate.meldnextmeifile = JSON.stringify stages[nextstage].meifile
      control.poststate.cued = "true"

set_stage = (control, data) ->
  control.poststate ?= {}
  control.poststate.cued = "false"
  control.poststate.stage = JSON.stringify data.stage;
  # weather
  ws = []
  for w,wi in weathers
    if data[w+'_effect']? and data[w+'_effect'].length>0
      if data[w+'_effect'].substring(0,1).toLowerCase()=='y'
        ws.push wi
      else if data[w+'_effect'].substring(0,1).toLowerCase()!='n'
        n = parseInt data[w+'_effect']
        if isNaN n 
          console.log 'WARNING: error in weather '+w+' value '+ data[w+'_effect']+' (should be Y, N or count)'
        if !(isNaN n) and n>0
          for ni in [1..n]
            ws.push wi
  if ws.length > 0
    control.actions.push 
      url: 'delay:{{weathers[(['+(ws.join ',')+'])[Math.floor(Math.random()*'+ws.length+')]]}}'
      delay: weatherdelay

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

# initialise defaults
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
  if not data.meifile? 
    console.log 'WARNING: no meifile specified for stage '+data.stage
    data.meifile = data.stage+'.mei'

# read mei file, extract IDs associated with possible codes
# map of label (code mei name) -> [ xml:ids ]
readmeiids = (meifile) ->
  meidir = configdir
  if config.meidir
    meidir = relpath config.meidir, configdir
  meifile = relpath meifile, meidir
  mei = null
  console.log 'Processing mei file '+meifile
  try
    mei = fs.readFileSync meifile, 'utf8'
    #console.log 'read '+mei.charCodeAt(0)+','+mei.charCodeAt(1)+','+mei.charCodeAt(2)
    # could be utf8 BEM
    if mei.length>0 && mei.charCodeAt(0)!=60 && mei.charCodeAt(0)!=65279
      #console.log 'trying file as utf16 '+meifile
      mei = fs.readFileSync meifile, 'ucs2'
      #console.log 'read ucs2 '+mei.charCodeAt(0)+','+mei.charCodeAt(1)+','+mei.charCodeAt(2)
      # could be utf16 BEM
      if mei.length>0 && mei.charCodeAt(0)!=60 && mei.charCodeAt(0)!=65279
        console.log 'ERROR: file does not seem to be utf16 or utf8 XML: '+meifile
        return {}
  catch e 
    console.log 'ERROR: reading mei file '+meifile+': '+e.message
    return {}
  getCodeIds mei

# process rows / stages
for r in [1..1000]
  cell = sheet[cellid(0,r)]
  if cell == undefined
    break
  if not cell.v? 
    continue
  # restore
  data = stages[cell.v]

  meiids = readmeiids data.meifile

  if r==1
    # default stage
    ex.parameters.initstate.stage = JSON.stringify data.stage
    # auto on event:load
    control = {inputUrl:'event:load', actions:[]}
    ex.controls.push control
    set_stage control, data
    add_actions control, 'auto_', data
  else
    # non-default stage
    # test button
    control = {inputUrl:'button:'+data.stage, actions:[]}
    ex.controls.push control
    set_stage control, data
    add_actions control, 'auto_', data
  # MELD input POST
  control = 
    inputUrl:'post:meld.load'
    actions: []
  control.precondition = 'params.meldmei==(meldmeiuri+'+(JSON.stringify encodeURIComponent(data.meifile))+')'
  ex.controls.push control
  set_stage control, data
  add_actions control, 'auto_', data, true
  control.poststate.meldmei = 'params.meldmei'
  control.poststate.meldannostate = 'params.meldannostate'
  control.poststate.meldcollection = 'params.meldcollection'
  control.poststate.meldnextmeifile = 'null';

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
    # trigger -> mei
    if data[mc]? and data[mc]!=''
      labels = String(data[mc]).split ','
      fragments = []
      for label in labels when label!=''
        if (label.indexOf '#')==0
          fragments.push label
        else
          ids = meiids[label]
          if not ids?
            console.log 'Warning: could not find code "'+data[mc]+'" in meifile '+data.meifile+' (stage '+data.stage+' mc '+mc+')'
          else
            console.log 'Code '+data[mc]+' -> '+ids
            for id in ids
              fragments.push '#'+id
      for fragment in fragments
        # MELD highlight action 
        # curl -X POST -H "Content-Type: application/json" -d '{"oa:hasTarget":[{"@id":"$MEI_ELEMENT"}], "oa:hasBody":[{"@type":"meldterm:Emphasis"}] }' -v $COLLECTION_URI
        marker.actions.push 
          url: '{{meldcollection}}'
          post: true
          contentType: 'application/json'
          body: '{"oa:hasTarget":[{"@id":"{{meldmei}}'+fragment+'"}], "oa:hasBody":[{"@type":"meldterm:Emphasis"}] }'
    
  # default cue
  if defaultprojection!='' && data['default_cue']?
    control = 
      inputUrl: 'event:end:'+defaultprojection
      actions: []
      precondition: 'stage=='+(JSON.stringify data.stage)+' && !cued'
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
control = {inputUrl:'button:Force Next',actions:[],precondition:'!!meldnextmeifile'}
ex.controls.push control
control.actions.push 
  url: 'http://localhost:3000/input'
  post: true
  contentType: 'application/x-www-form-urlencoded'
  body: 'name=meld.load&meldmei={{meldmeiuri}}{{encodeURIComponent(meldnextmeifile)}}&meldcollection=&meldannostate='
  # meldmei, meldcollection

# fake pedal input
control = {inputUrl:'button:pedal',actions:[]}
ex.controls.push control
control.actions.push 
  url: 'http://localhost:3000/input'
  post: true
  contentType: 'application/x-www-form-urlencoded'
  body: 'name=pedal'

# pedal meld action
control = {inputUrl:'post:pedal',actions:[]}
ex.controls.push control
control.actions.push 
  url: '{{meldcollection}}'
  post: true
  contentType: 'application/json'
  body: '{"oa:hasTarget":["{{meldannostate}}"], "oa:hasBody":[{"@type":"meldterm:NextPageOrPiece"}] }'

console.log 'write experience '+exoutfile
fs.writeFileSync exoutfile, (JSON.stringify ex, null, '  '), {encoding: 'utf8'}

viewconfig = viewgen.get()
console.log 'write climbview file '+viewoutfile
fs.writeFileSync viewoutfile, (JSON.stringify viewconfig, null, '  '), {encoding: 'utf8'}

console.log 'done'
return errors