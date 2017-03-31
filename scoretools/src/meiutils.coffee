# read an mei file and look for musicodes
# they seem to be div / rend text() 
# although other things are too...

DOMParser = (require 'xmldom').DOMParser
Node = (require 'xmldom').Node
xpath = require 'xpath'
select = xpath.useNamespaces "mei": "http://www.music-encoding.org/ns/mei"

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
