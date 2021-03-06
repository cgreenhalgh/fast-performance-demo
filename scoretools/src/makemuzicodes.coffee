# make muzicodes experience
if process.argv.length != 2 and process.argv.length!=3
  console.log 'Usage: node makemuzicodes [<config.yaml>]'
  process.exit -1

yaml = require 'js-yaml'
fs   = require 'fs'
path = require 'path'
getCodeIds = (require './meiutils').getCodeIds
meiutils = require './meiutils'

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
meldoutfile = relpath config.meldout, configdir

# climbview config generator
viewgen = climbview.generator 'Climbview '+viewoutfile+' from '+configfile, config

xlsx = require 'xlsx'
fs = require 'fs'

console.log 'read template experience '+exinfile
ex = JSON.parse fs.readFileSync exinfile, {encoding:'utf8'}

meldout = []

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
markernames = []
for marker in ex.markers
  if marker.title && (markernames.indexOf marker.title)>=0
    console.log 'WARNING: marker "'+marker.title+'" defined multiple times'
  marker.actions = []
  delete marker.action
  delete marker.precondition
  marker.poststate = {}
  marker.precondition = ''

# state - stage (string), cued (bool)
ex.parameters.initstate = 
  stage: '""'
  stageix: 0
  cued: false
  meldmei: '""'
  meldsession: '""'
  meldsessionpost: '""'
  meldnextmeifile: 'null'
  nextstage: '""'
  nextstageix: 0
  mcserver: JSON.stringify (config.mcserver ? 'http://localhost:3000/input')
  meldscoreuri: JSON.stringify (config.meldscoreuri ? 'http://127.0.0.1:5000/score/')
  meldmeiuri: JSON.stringify (config.meldmeiuri ? 'http://127.0.0.1:3000/content/')
  contenturi: JSON.stringify (config.contenturi ? 'http://localhost:3000/content/')
  performanceid: '""'
  performancename: '""'
  stagecodeflags: 0
  pedalnextpiece: '"no"'

# performances
if config.performances
  for title, guid of config.performances
    ex.controls.push
      inputUrl: 'button:Perform '+title
      actions: []
      poststate:
        performanceid: JSON.stringify guid
        performancename: JSON.stringify title
    ex.controls.push
      inputUrl: 'post:performanceid'
      actions: []
      poststate:
        performanceid: 'params.performanceid'
        performancename: 'params.performancename'
# app end
ex.controls.push
  inputUrl: 'button:Stop app'
  actions: [
    url: 'emit:vStop:mobileapp:{{performanceid}}'
  ]

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
mcs = ['mc1_', 'mc2_', 'mc3_', 'mc4_', 'mc5_']
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

delayid = 0
numstages = 0
BITS_PER_FLAGVAR = 31
numflagvars = 0

add_actions = (control, prefix, data, meldload) ->
  add_immediate_actions control, prefix, data, meldload
  # control has inputUrl or title (if marker)
  # data has stage
  if data[prefix+'delay']?
    try
      delay = Number(data[prefix+'delay'])
      vdelta = if data[prefix+'vdelta']? then Number(data[prefix+'vdelta']) else 0
      delaycontrol = 
        inputUrl: 'delay:'+(delayid++)+':'+data.stage+':'+prefix
        actions: []
      ex.controls.push delaycontrol
      add_delayed_midi delaycontrol, prefix, data, meldload
      if vdelta==0
        add_delayed_visual delaycontrol, prefix, data, meldload
      control.actions.push
        url: delaycontrol.inputUrl
        delay: delay
      if vdelta!=0
        delay += vdelta;
        if delay<0
          console.log 'Warning: negative delay for '+prefix+' visuals in '+data.stage
          delay = 0
        delaycontrol = 
          inputUrl: 'delay:'+(delayid++)+':'+data.stage+':v'+prefix
          actions: []
        ex.controls.push delaycontrol
        add_delayed_visual delaycontrol, prefix, data, meldload
        control.actions.push
          url: delaycontrol.inputUrl
          delay: delay
    catch err
      console.log 'ERROR: adding delay of '+data[prefix+'delay']+' (vdelta '+data[prefix+'vdelta']+') for '+data.stage+' '+prefix+' ('+err.message+')'
  else
    add_delayed_visual control, prefix, data, meldload
    add_delayed_midi control, prefix, data, meldload
  if data[prefix+'v.mc.delay']?
    try
      delay = Number(data[prefix+'v.mc.delay'])
      delaycontrol = 
        inputUrl: 'delay:'+(delayid++)+':'+data.stage+':'+prefix
        actions: []
      ex.controls.push delaycontrol
      add_delayed_mc delaycontrol, prefix, data, meldload
      control.actions.push
        url: delaycontrol.inputUrl
        delay: delay
    catch err
      console.log 'ERROR: adding delay of '+data[prefix+'v.mc.delay']+' for '+data.stage+' '+prefix+' ('+err.message+')'
  else
    add_delayed_mc control, prefix, data, meldload
    
add_immediate_actions = (control, prefix, data, meldload) ->
  # monitor
  control.actions.push 
    channel: ''
    url: content_url data[prefix+'monitor']
  # immediate visual
  for channel in ['v.background','v.mc']
    if data[prefix+channel]?
      if channel=='v.mc' && String(data[prefix+channel])=='1'
        if config.defaultmuzicodeurl?
          control.actions.push 
            channel: channel
            url: content_url config.defaultmuzicodeurl
        else
          console.log 'ERROR: use of undefined defaultmuzicodeurl in '+prefix+channel
      else if not ( channel == 'v.background' and config.forcebackgroundurl? )
        viewgen.add data[prefix+channel]
        control.actions.push 
          channel: channel
          url: content_url data[prefix+channel]
  # immediate midi
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
    if (cuesingle && prefix!='auto_' && control.precondition.indexOf 'cued') < 0
      control.precondition = '!cued'+(if control.precondition.length == 0 then '' else ' && (')+control.precondition+(if control.precondition.length == 0 then '' else ')')

    if data.next? and not stages[data.next]?
      console.log 'ERROR: stage '+data.stage+' has unknown safe next stage '+data.next

    nextstages = ((data[prefix+'cue'].split '/').map (s) => s.trim()).filter (s) => s.length>0
    nomeld = prefix != 'auto_'
    if nomeld and nextstages.length>1
      console.log 'ERROR: stage '+data.stage+' non-auto cue '+prefix+' has multiple next stages; will get out of sync with MELD!'
    text = 'delay:stage'+(if nomeld then '_nomeld' else '')+':{{chooseOne(';
    for nextstage in nextstages
      text = text+(JSON.stringify nextstage)+','
      stagetest = 'true'
      
      # is it OK to go to this stage, or will it cause us to repeat something? if so use next (safe route) instead
      # so have we already played nextstage, or any of the stages on ITS safe route?
      if nextstage? and data.next? and stages[nextstage]? and stages[data.next]? and nextstage!=data.next
        stageflags = []
        for sfi in [1..numflagvars]
          stageflags[sfi-1] = 0
        ns = nextstage
        while ns? && stages[ns]?
          sfi = Math.floor(stages[ns]._index / BITS_PER_FLAGVAR)
          sfbi = stages[ns]._index % BITS_PER_FLAGVAR
          if (stageflags[sfi] & (1<<sfbi))!=0
            console.log 'ERROR: safe route from '+nextstage+' has a loop at '+ns
            break
          stageflags[sfi] = stageflags[sfi] | (1<<sfbi)
          ns = stages[ns].next
        stagetest = ''
        for sfi in [1..numflagvars]
          if stagetest.length>0
            stagetest += ' && '
          stagetest += '(stageflags'+(sfi-1)+' & '+stageflags[sfi-1]+')==0'
          
      text = text+stagetest+','
      
    text = text+(JSON.stringify data.next)+')}}'
    control.actions.push 
        url: text

add_delayed_visual = (control, prefix, data, meldload) ->
  # delayed visual
  for channel in ['v.animate']
    if data[prefix+channel]?
      viewgen.add data[prefix+channel]
      control.actions.push 
        channel: channel
        url: content_url data[prefix+channel]

add_delayed_mc = (control, prefix, data, meldload) ->
  # delayed visual
  for channel in ['v.mc2']
    if data[prefix+channel]?
      if channel=='v.mc2' && String(data[prefix+channel])=='1'
        if config.defaultmuzicodeurl?
          control.actions.push 
            channel: 'v.mc'
            url: content_url config.defaultmuzicodeurl
        else
          console.log 'ERROR: use of undefined defaultmuzicodeurl in '+prefix+channel
      else if not ( channel == 'v.background' and config.forcebackgroundurl? )
        viewgen.add data[prefix+channel]
        control.actions.push 
          channel: if channel=='v.mc2' then 'v.mc' else channel
          url: content_url data[prefix+channel]
  # delayed app event (sync'd with visual) for muzicode
  if data[prefix+'app']?
    control.actions.push
      url: 'emit:vEvent:mobileapp:{{performanceid}}:'+data[prefix+'app']
      
add_delayed_midi = (control, prefix, data, meldload) ->
  # delayed midi
  if data[prefix+'midi2']?
    # multiple 
    msgs = data[prefix+'midi2'].split ','
    for msg in msgs
      msg = msg.trim()
      if msg.length > 0
        control.actions.push
          channel: ''
          url: 'data:text/x-midi-hex,'+msg

add_stage_announcement = (control, stage, next) -> 
  control.actions.push
    channel: 'stageview'
    url: 'data:text/html,<h1>Now: <b>('+(if stage? then (stage._index+1)+')</b> '+stage.stage else '{{stageix}}) {{stage}}')+',<br>Next: ('+(if next? then (next._index+1)+') '+next.stage else '{{nextstageix}}) {{nextstage}}')+'</h1>'

set_stage = (control, data) ->
  control.poststate ?= {}
  control.poststate.cued = "false"
  control.poststate.stage = JSON.stringify data.stage
  control.poststate.stageix = data._index+1
  control.poststate.stagecodeflags = '0'
  add_stage_announcement control, data
  
  # visited stage
  sfi = Math.floor(data._index / BITS_PER_FLAGVAR)
  sfbi = data._index % BITS_PER_FLAGVAR
  control.poststate['stageflags'+sfi] = 'stageflags'+sfi+' | '+(1<<sfbi)
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
  for marker in markers
    if marker.actions.length==0 && marker.precondition.length==0
      return marker
  if markers.length == 0
    console.log 'WARNING: marker  "'+markertitle+'" undefined - adding to output'
    marker = 
      title: markertitle
      description: optdescription
      poststate: {}
      actions: []
      precondition: ''
    ex.markers.push marker
    return marker
  console.log 'NOTE: marker "'+markertitle+'" used more than once; cloning'
  marker = JSON.parse JSON.stringify markers[0]
  marker.poststate = {}
  marker.actions = []
  marker.precondition = ''
  ex.markers.push marker
  return marker
  

# initialise defaults
maxrow = 1
for r in [1..1000]
  cell = sheet[cellid(0,r)]
  if cell == undefined
    break
  data = readrow r
  if not data.stage? 
    console.log 'ignore row without stage name: '+(JSON.stringify data)
    continue
  console.log 'stage '+data.stage
  maxrow = r
  if stages[data.stage]!=undefined
    console.log 'ERROR: more than one entry found for stage '+data.stage
  data._index = numstages
  numstages++
  stages[data.stage] = data
  # defaults for ...-monitor
  for prefix in prefixes
    if not data[prefix+'monitor']?
      if prefix=='auto_'
        data[prefix+'monitor'] = 'data:text/plain,stage '+data.stage+' '+prefix+' triggered!'
      else if data[prefix+'cue']
        data[prefix+'monitor'] = 'data:text/plain,Code played successfully to cue stage '+data[prefix+'cue']
      else if data[prefix+'midi'] or data[prefix+'midi2']
        data[prefix+'monitor'] = 'data:text/plain,Code played to send MIDI (disklavier?)'
      else if data[prefix+'app']
        data[prefix+'monitor'] = 'data:text/plain,Code played to send notification (app)'
      else if data[prefix+'v.mc'] or data[prefix+'v.mc2'] 
        data[prefix+'monitor'] = 'data:text/plain,Code played to trigger visual (approach?)'
      else
        data[prefix+'monitor'] = 'data:text/plain,stage '+data.stage+' '+prefix+' triggered!'
  if not data.meifile? 
    console.log 'WARNING: no meifile specified for stage '+data.stage
    data.meifile = data.stage+'.mei'
  # delayed cue stage events
  control = {inputUrl:'delay:stage:'+data.stage, actions:[], poststate:{}};
  nexturi = encodeURIComponent(data.stage)
  nextexp = JSON.stringify data.meifile
  control.actions.push 
        url: '{{meldsessionpost}}'
        post: true
        contentType: 'application/ld+json'
        body: '{"oa:hasTarget":{ "@id": "{{meldsession}}"}, "oa:motivatedBy": { "@id": "motivation:createNextSession" }, "oa:hasBody":{"@id":"{{meldscoreuri}}'+nexturi+'"} }'
  control.poststate.meldnextmeifile = nextexp
  control.poststate.nextstage = JSON.stringify data.stage
  control.poststate.nextstageix = data._index+1
  add_stage_announcement control, null, data
  control.poststate.cued = "true"
  ex.controls.push control
  # no meld?!
  control = {inputUrl:'delay:stage_nomeld:'+data.stage, actions:[], poststate:{}};
  nexturi = encodeURIComponent(data.stage)
  nextexp = JSON.stringify data.meifile
  control.poststate.meldnextmeifile = nextexp
  control.poststate.nextstage = JSON.stringify data.stage
  control.poststate.nextstageix = data._index+1
  add_stage_announcement control, null, data
  control.poststate.cued = "true"
  ex.controls.push control

numflagvars = Math.ceil numstages/BITS_PER_FLAGVAR
for sfi in [1..numflagvars]
  ex.parameters.initstate['stageflags'+(sfi-1)] = 0

# read mei file, extract IDs associated with possible codes
# map of label (code mei name) -> [ xml:ids ]
readmeifile = (meifile) ->
  meidir = configdir
  if config.meidir
    meidir = relpath config.meidir, configdir
  meifile = relpath meifile, meidir
  mei = null
  #console.log 'Reading mei file '+meifile
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
        return null
    return mei
  catch e 
    console.log 'ERROR: reading mei file '+meifile+': '+e.message
    return null

# read mei file, extract IDs associated with possible codes
# map of label (code mei name) -> [ xml:ids ]
writemeifile = (meifile, text) ->
  meidir = configdir
  if config.meioutdir
    meidir = relpath config.meioutdir, configdir
  meifile = relpath meifile, meidir
  console.log 'Write mei file '+meifile
  try
    mei = fs.writeFileSync meifile, text, 'utf8'
  catch e 
    console.log 'ERROR: writing mei file '+meifile+': '+e.message

readmeiids = (meifile) ->
  mei = readmeifile meifile
  if not mei?
    return {}
  getCodeIds mei

meicolorcue = config.meicolorcue ? ''
meicolormidi = config.meicolormidi ? '#00d'
meicolorapp = config.meicolorapp ? '#080'
meicolorother = config.meicolorother ? '#666'

processmeifile = (meifile, data, meiids) ->
  meitext = readmeifile meifile
  if not meitext?
    return
  mei = meiutils.parse meitext
  if not mei?
    console.log 'Could not parse mei file '+data.mei
    writemeifile meifile, meitext
  for mc, mi in mcs
    if not data[mc+'name']
      continue
    marker = ex.markers.find (m)-> m.title==data[mc+'name']
    if not marker
      console.log 'ERROR: no marker '+data[mc+'name']
      continue
    if not marker.code?
      console.log 'No code for marker '+data[mc+'name']+' in '+meifile
      continue
    if not data[mc]? or ''==data[mc]
      console.log 'No measure for marker '+data[mc+'name']+' in '+meifile
      continue
    fragments = getfragmentids data[mc], meiids
    notes = meiutils.getnotes mei, fragments
    # WARNING: simple hack for sequences only
    pnotes = marker.code.split ','
    pmidis = (pnotes.map meiutils.notetomidi).filter (m) => m?
    pix = 0
    nmidis= []
    for note in notes
      if pix>=pmidis.length
        break
      midi = meiutils.getmidinote note
      if not midi
        #console.log 'no midi note equivalent', note
        continue
      nmidis.push midi
      if midi==pmidis[pix]
        # found!
        #console.log 'note', note
        color = meicolorother
        if data[mc+'cue'] 
          color = meicolorcue # challenge?!
        else if data[mc+'midi'] or data[mc+'midi2']
          color = meicolormidi # disklav?!
        else if data[mc+'app'] or data[mc+'v.mc'] or data[mc+'v.mc2']  
          color = meicolorapp # approach?
        if color? and color!=''
          meiutils.colornote note, color
        pix++
    if pix==0
      console.log 'Warning: did not find notes for code '+data[mc+'name']+' to highlight in '+data.meifile+' at '+data[mc]+' = '+fragments
      console.log 'pattern: '+marker.code+' -> '+pmidis
      console.log 'notes: '+nmidis
    else if pix<pmidis.length
      console.log 'Warning: find only '+pix+'/'+pmidis.length+' notes for code '+data[mc+'name']+' to highlight in '+data.meifile+' at '+data[mc]+' = '+fragments
      console.log 'pattern: '+marker.code+' -> '+pmidis
      console.log 'notes: '+nmidis
  meiout = meiutils.serialize mei
  writemeifile meifile, meiout
  

getfragmentids = (text, meiids) ->
  labels = String(text).split ','
  fragments = []
  for label in labels when label!=''
    if (label.indexOf '#')==0
      fragments.push label
    else
      ids = meiids[label]
      if not ids?
        console.log 'Warning: could not find measure "'+label+'" in meifile' #+data.meifile+' (stage '+data.stage+' mc '+mc+')'
      else
        #console.log 'Measure '+label+' -> '+ids
        for id in ids
          fragments.push '#'+id
  fragments
      
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
  
  meldstage = {stage:data.stage, next:data.next, cue:[], meifile:data.meifile, mcs:[]}
  if data.auto_cue?
    meldstage.cue = data.auto_cue.split '/'
  meldout.push(meldstage)
  
  # cue (test/rehearse) button
  control = {inputUrl:'button:cue '+data.stage, actions:[],poststate:{}}
  ex.controls.push control
  control.actions.push 
        url: '{{meldsessionpost}}'
        post: true
        contentType: 'application/json'
        body: '{"oa:hasTarget": { "@id": "{{meldsession}}"}, "oa:motivatedBy": { "@id": "motivation:createNextSession" }, "oa:hasBody": { "@id": "{{meldscoreuri}}'+encodeURIComponent(data.stage)+'"} }'
  control.poststate.meldnextmeifile = JSON.stringify data.meifile
  control.poststate.nextstage = JSON.stringify data.stage
  control.poststate.nextstageix = data._index+1
  add_stage_announcement control, null, data
  control.poststate.cued = "true"

  # MELD input POST
  control = 
    inputUrl:'post:meld.load'
    actions: []
    poststate: {}
  control.precondition = 'params.meldmei==(meldmeiuri+'+(JSON.stringify encodeURIComponent(data.meifile))+')'
  # may be overriden by auto-cue
  control.poststate.meldnextmeifile = 'null'
  control.poststate.nextstage = JSON.stringify ''
  control.poststate.nextstageix = 0
  add_stage_announcement control, {stage:' ', _index:0}
  ex.controls.push control
  set_stage control, data
  add_actions control, 'auto_', data, true
  control.poststate.meldmei = 'params.meldmei'
  control.poststate.meldsessionpost = 'params.meldcollection.replace("/sessions", "/sessions/bypass")'
  control.poststate.meldsession = 'params.meldcollection'
  # app view events
  if data._index==0
    control.actions.push
      url: 'emit:vStart:mobileapp:{{performanceid}}:'+data.stage
    # and clear stage flags (like reload)
    for sfi in [1..numflagvars]
      control.poststate['stageflags'+(sfi-1)] = if sfi==0 then 1 else 0
  else if data._index==(numstages-1)
    control.actions.push
      url: 'emit:vStop:mobileapp:{{performanceid}}'
  else
    control.actions.push
      url: 'emit:vStageChange:mobileapp:{{performanceid}}:{{stage}}->'+data.stage

  meitext = readmeifile data.meifile
  mei = if meitext?
      meiutils.parse meitext
    else
      null
  # muzicodes
  codetitles = {}
  challengecount = 0
  for mc, mi in mcs
    if not data[mc+'name']
      continue
    meldmc = {name:data[mc+'name'],meielements:[]}
    if data[mc+'cue']?
      meldmc.cue = data[mc+'cue']
      meldmc.type = 'challenge'
      challengecount = challengecount+1
    else if data[mc+'midi'] or data[mc+'midi2']
      meldmc.type = 'disklavier'
    else if data[mc+'app']
      meldmc.type = 'approaching'
    meldstage.mcs.push(meldmc)
    if data[mc+'app']?
      meldmc.app = (data[mc+'app'].split ':')[0]
    # TODO meldmc.type, .narrative, .app
    
    marker = get_marker ex, data[mc+'name'], ('stage '+data.stage+' '+mc+'name')
    # in stage precondition
    # marker should only be used once now!
    if marker.precondition.length>0
      console.log 'ERROR: coding error: marker found with non-empty precondition: '+marker.precondition
    marker.precondition = 'stage=="'+data.stage+'"'
    # once/stage
    marker.precondition += ' && (stagecodeflags & '+(1 << mi)+')==0'
    # once/stage post-update
    marker.poststate.stagecodeflags = 'stagecodeflags | '+(1 << mi)
    # multiple use in stage?
    if codetitles[marker.title] == undefined
      codetitles[marker.title] = []
    else
      # previous code ixs 
      for ct in codetitles[marker.title]
        marker.precondition += ' && (stagecodeflags & '+(1 << ct)+')!=0'
    codetitles[marker.title].push mi

    add_actions marker, mc, data
    # trigger -> mei
    if data[mc]? and data[mc]!=''
      marker.actions.push 
        url: '{{meldsessionpost}}'
        post: true
        contentType: 'application/ld+json'
        body: '{"oa:hasTarget": { "@id": "{{meldscoreuri}}'+data.stage+'#'+data[mc+'name']+'"},"oa:motivatedBy": { "@id": "motivation:muzicodeTriggered" }}'
      
      fragments = getfragmentids data[mc], meiids
      for fragment in fragments
        meldmc.meielements.push(fragment)
        # no separate highlight action in new meld
      if marker.code?
        notes = meiutils.getnotes mei, fragments
        # WARNING: simple hack for sequences only
        pnotes = marker.code.split ','
        pmidis = (pnotes.map meiutils.notetomidi).filter (m) => m?
        pix = 0
        nmidis= []
        for note in notes
          if pix>=pmidis.length
            break
          midi = meiutils.getmidinote note
          if not midi
            #console.log 'no midi note equivalent', note
            continue
          nmidis.push midi
          if midi==pmidis[pix]
            # found!
            pix++
            meldmc.meielements.push '#'+(note.getAttribute 'xml:id')
  
  if challengecount>1
    for meldmc in meldstage.mcs
      if meldmc.type == 'challenge'
        meldmc.type = 'choice'

  # default cue
  if defaultprojection!='' && data['default_cue']?
    control = 
      inputUrl: 'event:end:'+defaultprojection
      actions: []
      precondition: 'stage=='+(JSON.stringify data.stage)+' && !cued'
      poststate: {}
    ex.controls.push control
    add_actions control, 'default_', data
  
  processmeifile data.meifile, data, meiids

# check cross-references
errors = 0;
for stage,data of stages
  for prefix in prefixes
    if data[prefix+'cue']? 
      nextstages = ((data[prefix+'cue'].split '/').map (s) => s.trim()).filter (s) => s.length>0
      for nextstage in nextstages
        if not stages[nextstage]?
          console.log 'ERROR: stage '+stage+' '+prefix+'cue refers to unknown stage "'+nextstage+'"'
          errors++

# clear stage flags
control = {inputUrl:'button:clear flags',actions:[], poststate:{}}
for sfi in [1..numflagvars]
  control.poststate['stageflags'+(sfi-1)] = 0
control.poststate.stagecodeflags = 0

# onload - init state / visuals
control = {inputUrl:'event:load', actions:[], poststate:{}}
ex.controls.push control
control.poststate.stage = '"_loaded"'
# visuals - clear
for channel in ['v.animate', 'v.mc', 'v.background', 'v.weather']
  if not ( channel == 'v.background' and config.forcebackgroundurl? )
    control.actions.push 
      channel: channel
      url: ''

# fake pedal input
control = {inputUrl:'button:next piece',actions:[]}
# not currently supported in MELD?!
ex.controls.push control
control.actions.push 
  url: '{{meldsessionpost}}'
  post: true
  contentType: 'application/ld+json'
  body: '{"oa:hasTarget": { "@id": "{{meldsession}}"},"oa:motivatedBy": { "@id": "motivation:transitionToNextSession" }}'

# fake pedal input
control = {inputUrl:'button:pedal',actions:[]}
ex.controls.push control
control.actions.push 
  url: 'http://localhost:3000/input'
  post: true
  contentType: 'application/x-www-form-urlencoded'
  body: 'name=pedal'

# fake pedal back input
control = {inputUrl:'button:back',actions:[]}
ex.controls.push control
control.actions.push 
  url: '{{meldsessionpost}}'
  post: true
  contentType: 'application/ld+json'
  body: '{"oa:hasTarget": { "@id": "{{meldsession}}"},"oa:motivatedBy": { "@id": "motivation:prevPageOrPiece"} }'

# fake meld input
control = {inputUrl:'button:Fake meld',actions:[],precondition:'!!meldnextmeifile'}
ex.controls.push control
control.actions.push 
  url: 'http://localhost:3000/input'
  post: true
  contentType: 'application/x-www-form-urlencoded'
  body: 'name=meld.load&meldmei={{meldmeiuri}}{{encodeURIComponent(meldnextmeifile)}}&meldcollection='
  # meldmei, meldcollection


# pedal meld action (next page)
control = {inputUrl:'post:pedal',actions:[],precondition:'"yes"!=pedalnextpiece'}
ex.controls.push control
control.actions.push 
  url: '{{meldsessionpost}}'
  post: true
  contentType: 'application/ld+json'
  body: '{"oa:hasTarget": { "@id": "{{meldsession}}"},"oa:motivatedBy": { "@id": "motivation:nextPageOrPiece" }}'

# pedal meld action (next piece)
control = {inputUrl:'post:pedal',actions:[],precondition:'"yes"==pedalnextpiece'}
ex.controls.push control
control.actions.push 
  url: '{{meldsessionpost}}'
  post: true
  contentType: 'application/ld+json'
  body: '{"oa:hasTarget": { "@id": "{{meldsession}}"},"oa:motivatedBy": { "@id": "motivation:transitionToNextSession" }}'

# pedal back meld action
control = {inputUrl:'post:pedal.back',actions:[]}
ex.controls.push control
control.actions.push 
  url: '{{meldsessionpost}}'
  post: true
  contentType: 'application/ld+json'
  body: '{"oa:hasTarget": { "@id": "{{meldsession}}"},"oa:motivatedBy": { "@id": "motivation:prevPageOrPiece" }}'

# unused markers
for marker in ex.markers
  if marker.precondition == '' and marker.actions.length == 0
    unused = true
    for k,v of marker.poststate
      unused = false
      break
    if unused
      console.log 'Note: disabling unused marker "'+marker.title+'"'
      marker.precondition = 'false'

console.log 'write experience '+exoutfile
fs.writeFileSync exoutfile, (JSON.stringify ex, null, '  '), {encoding: 'utf8'}

viewconfig = viewgen.get()
console.log 'write climbview file '+viewoutfile
fs.writeFileSync viewoutfile, (JSON.stringify viewconfig, null, '  '), {encoding: 'utf8'}

console.log 'write meld config file '+meldoutfile
fs.writeFileSync meldoutfile, (JSON.stringify meldout, null, '  '), {encoding: 'utf8'}

console.log 'done'
return errors