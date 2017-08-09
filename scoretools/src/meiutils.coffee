# read an mei file and look for musicodes
# they seem to be div / rend text() 
# although other things are too...

DOMParser = (require 'xmldom').DOMParser
XMLSerializer = (require 'xmldom').XMLSerializer
Node = (require 'xmldom').Node
xpath = require 'xpath'
select = xpath.useNamespaces 
  "mei": "http://www.music-encoding.org/ns/mei"
  "xml": "http://www.w3.org/XML/1998/namespace"

# DOM Node types
TEXT_NODE = 3
ELEMENT_NODE = 1

gettext = (node) ->
  text = ''
  for child in node.childNodes
    #console.log ' - '+child.nodeType+' '+child.nodeName+' '+child.nodeValue
    if child.nodeType==TEXT_NODE
	    text += child.nodeValue

# no namespace
getparentoftype = (node, type) ->
  while node?
    if node.nodeType==ELEMENT_NODE and node.nodeName==type
      return node
    node = node.parentNode
  null

getattributemap = (node) ->
  atts = {}
  for att in node.attributes
    atts[att.name] = att.value
  atts

getattribute = (node,name) ->
  atts = {}
  for att in node.attributes
    if name==att.name
      return att.value
  null

# map of label -> [ xml:ids ]
getlabelledids = (doc) ->
  labels = {}

  textnodes = select "//mei:dir/mei:rend", doc
  #console.log 'found '+textnodes.length+' dir/rend nodes'
  for n in textnodes
    #console.log 'found '+n.nodeType+' '+n.nodeName+' '+n.nodeValue
    text = gettext n
    measure = getparentoftype n, 'measure'
    if measure?
      # just the parent measure for now
      atts = getattributemap measure
      #console.log text+': measure #'+atts['xml:id']+' (n='+atts.n+')'
      #+(JSON.stringify atts)
      labels[text] = [ atts['xml:id'] ]
    else
      console.log 'Warning: text with no parent measure: '+text
      
  measurenodes = select "//mei:measure", doc
  for measure in measurenodes
  	atts = getattributemap measure
  	if atts['n']?  
  	  if labels[atts['n']]?
        labels[atts['n']].push atts['xml:id']
      else
        labels[atts['n']] = [ atts['xml:id'] ]
  labels

getCodeIds = (meitext) ->
  
  doc = new DOMParser().parseFromString meitext,'text/xml'
  #console.log 'read: '+doc

  labels = getlabelledids doc

  #console.log JSON.stringify labels
  labels
  
module.exports.getCodeIds = getCodeIds

module.exports.parse = (meitext) ->
  new DOMParser().parseFromString meitext,'text/xml'

module.exports.serialize = (doc) ->
  new XMLSerializer().serializeToString doc

module.exports.getnotes = (doc, fragmentids) ->
	notes = []
	# fragments are probably measures
	for fid in fragmentids
		if (fid.indexOf '#')==0
			fid = fid.substring(1)
		# hack - ignoring staffs and layers at the moment!!
		path = "//mei:measure[@xml:id='"+fid+"']//mei:note"
		#console.log 'xpath '+path
		notes = notes.concat (select path, doc)
		#console.log 'path:'+path, notes
	notes

# C4 = middle C = midi note 60
NOTES = [ 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B' ]
ACCIDENTALS = 
	's': 1
	'f': -1
	'n': 0
	'ss': 2
	'ff': -2
	'x': 2
	'xs': 3
	'sx': 3
	'ts': 3
	'tf': -3
	'nf': -1
	'ns': 1
	'su': 1 # quarter tone
	'fd': -1 # qt
	'nu': 0
	'nd': 0
	'1qf': 0
	'3qf': -1
	'1qs': 0
	'3qs': 1

module.exports.getmidinote = (note) ->
	atts = getattributemap note
	notename = atts['pname']
	oct = atts['oct'] ? 0
	acc = atts['accid.ges']
	accids = select "mei:accid", note
	for accid in accids
		atts2 = getattributemap accid
		#console.log 'found accid child '+(JSON.stringify atts2)
		if atts2['accid']?
			acc= atts2['accid']
		else if atts2['accid.ges']?
			acc= atts2['accid.ges']
	#console.log notename+', '+oct+', '+acc
	if not note? or not oct?
		console.log 'Could not find note/octave in note '+(JSON.stringify atts)
		return null
	notename = notename.toUpperCase()
	ix = NOTES.indexOf notename
	if ix<0
		console.log 'Note with unknown pitch: '+notename+' '+(JSON.stringify atts)
		return null
	midi = parseInt(oct)*12+12+ix
	if acc? 
		offset = ACCIDENTALS[acc]
		#console.log 'accidental '+acc+' -> '+offset
		if not offset?
			console.log 'Unknown accidental '+acc+' in node '+(JSON.stringify atts)
		else
			midi += offset
	return midi

module.exports.notetomidi = (text) ->
	# hack - ignore * and ?
	if (text.indexOf '*')>=0 || (text.indexOf '?')>=0
		return null
	note = text[0]
	ix = NOTES.indexOf note
	if ix<0
		console.log 'Marker note with unknown pitch: '+text
		return null
	oct = text.substring(1)
	if (oct.indexOf '#')==0
		oct = oct.substring 1
		ix++
	else if (oct.indexOf 'b')==0
		oct = oct.substring 1
		ix++
	return (parseInt oct)*12+12+ix

COLOR = '#888'

module.exports.colornote = (note, color) ->
	color ?= COLOR
	note.setAttribute 'color', color
