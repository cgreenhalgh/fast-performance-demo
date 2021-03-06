// Generated by CoffeeScript 1.11.1
(function() {
  var ACCIDENTALS, COLOR, DOMParser, ELEMENT_NODE, NOTES, Node, TEXT_NODE, XMLSerializer, getCodeIds, getattribute, getattributemap, getlabelledids, getparentoftype, gettext, select, xpath;

  DOMParser = (require('xmldom')).DOMParser;

  XMLSerializer = (require('xmldom')).XMLSerializer;

  Node = (require('xmldom')).Node;

  xpath = require('xpath');

  select = xpath.useNamespaces({
    "mei": "http://www.music-encoding.org/ns/mei",
    "xml": "http://www.w3.org/XML/1998/namespace"
  });

  TEXT_NODE = 3;

  ELEMENT_NODE = 1;

  gettext = function(node) {
    var child, i, len, ref, results, text;
    text = '';
    ref = node.childNodes;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      child = ref[i];
      if (child.nodeType === TEXT_NODE) {
        results.push(text += child.nodeValue);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  getparentoftype = function(node, type) {
    while (node != null) {
      if (node.nodeType === ELEMENT_NODE && node.nodeName === type) {
        return node;
      }
      node = node.parentNode;
    }
    return null;
  };

  getattributemap = function(node) {
    var att, atts, i, len, ref;
    atts = {};
    ref = node.attributes;
    for (i = 0, len = ref.length; i < len; i++) {
      att = ref[i];
      atts[att.name] = att.value;
    }
    return atts;
  };

  getattribute = function(node, name) {
    var att, atts, i, len, ref;
    atts = {};
    ref = node.attributes;
    for (i = 0, len = ref.length; i < len; i++) {
      att = ref[i];
      if (name === att.name) {
        return att.value;
      }
    }
    return null;
  };

  getlabelledids = function(doc) {
    var atts, i, j, labels, len, len1, measure, measurenodes, n, text, textnodes;
    labels = {};
    textnodes = select("//mei:dir/mei:rend", doc);
    for (i = 0, len = textnodes.length; i < len; i++) {
      n = textnodes[i];
      text = gettext(n);
      measure = getparentoftype(n, 'measure');
      if (measure != null) {
        atts = getattributemap(measure);
        labels[text] = [atts['xml:id']];
      } else {
        console.log('Warning: text with no parent measure: ' + text);
      }
    }
    measurenodes = select("//mei:measure", doc);
    for (j = 0, len1 = measurenodes.length; j < len1; j++) {
      measure = measurenodes[j];
      atts = getattributemap(measure);
      if (atts['n'] != null) {
        if (labels[atts['n']] != null) {
          labels[atts['n']].push(atts['xml:id']);
        } else {
          labels[atts['n']] = [atts['xml:id']];
        }
      }
    }
    return labels;
  };

  getCodeIds = function(meitext) {
    var doc, labels;
    doc = new DOMParser().parseFromString(meitext, 'text/xml');
    labels = getlabelledids(doc);
    return labels;
  };

  module.exports.getCodeIds = getCodeIds;

  module.exports.parse = function(meitext) {
    return new DOMParser().parseFromString(meitext, 'text/xml');
  };

  module.exports.serialize = function(doc) {
    return new XMLSerializer().serializeToString(doc);
  };

  module.exports.getnotes = function(doc, fragmentids) {
    var fid, i, len, notes, path;
    notes = [];
    for (i = 0, len = fragmentids.length; i < len; i++) {
      fid = fragmentids[i];
      if ((fid.indexOf('#')) === 0) {
        fid = fid.substring(1);
      }
      path = "//mei:measure[@xml:id='" + fid + "']//mei:note";
      notes = notes.concat(select(path, doc));
    }
    return notes;
  };

  NOTES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

  ACCIDENTALS = {
    's': 1,
    'f': -1,
    'n': 0,
    'ss': 2,
    'ff': -2,
    'x': 2,
    'xs': 3,
    'sx': 3,
    'ts': 3,
    'tf': -3,
    'nf': -1,
    'ns': 1,
    'su': 1,
    'fd': -1,
    'nu': 0,
    'nd': 0,
    '1qf': 0,
    '3qf': -1,
    '1qs': 0,
    '3qs': 1
  };

  module.exports.getmidinote = function(note) {
    var acc, accid, accids, atts, atts2, i, ix, len, midi, notename, oct, offset, ref;
    atts = getattributemap(note);
    notename = atts['pname'];
    oct = (ref = atts['oct']) != null ? ref : 0;
    acc = atts['accid.ges'];
    accids = select("mei:accid", note);
    for (i = 0, len = accids.length; i < len; i++) {
      accid = accids[i];
      atts2 = getattributemap(accid);
      if (atts2['accid'] != null) {
        acc = atts2['accid'];
      } else if (atts2['accid.ges'] != null) {
        acc = atts2['accid.ges'];
      }
    }
    if ((note == null) || (oct == null)) {
      console.log('Could not find note/octave in note ' + (JSON.stringify(atts)));
      return null;
    }
    notename = notename.toUpperCase();
    ix = NOTES.indexOf(notename);
    if (ix < 0) {
      console.log('Note with unknown pitch: ' + notename + ' ' + (JSON.stringify(atts)));
      return null;
    }
    midi = parseInt(oct) * 12 + 12 + ix;
    if (acc != null) {
      offset = ACCIDENTALS[acc];
      if (offset == null) {
        console.log('Unknown accidental ' + acc + ' in node ' + (JSON.stringify(atts)));
      } else {
        midi += offset;
      }
    }
    return midi;
  };

  module.exports.notetomidi = function(text) {
    var ix, note, oct;
    if ((text.indexOf('*')) >= 0 || (text.indexOf('?')) >= 0) {
      return null;
    }
    note = text[0];
    ix = NOTES.indexOf(note);
    if (ix < 0) {
      console.log('Marker note with unknown pitch: ' + text);
      return null;
    }
    oct = text.substring(1);
    if ((oct.indexOf('#')) === 0) {
      oct = oct.substring(1);
      ix++;
    } else if ((oct.indexOf('b')) === 0) {
      oct = oct.substring(1);
      ix++;
    }
    return (parseInt(oct)) * 12 + 12 + ix;
  };

  COLOR = '#888';

  module.exports.colornote = function(note, color) {
    if (color == null) {
      color = COLOR;
    }
    return note.setAttribute('color', color);
  };

}).call(this);
