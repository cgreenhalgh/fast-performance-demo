# read midi file - checking out tempo and timing stuff

if process.argv.length != 3
  console.error 'Usage: node readmidi.js MIDIFILE'
  process.exit -1

midiFileParser = require 'midi-file-parser'

# threw an exception
#var parseMidi = require('midi-file').parseMidi
writeMidi = require('midi-file').writeMidi

fs = require 'fs'

midifile = process.argv[2]

console.log 'read '+midifile

file = fs.readFileSync midifile, 'binary'
midi = midiFileParser file
# midi-file-parser uses event.subtype cf event.type
for track in midi.tracks
  for event in track
    event.type = event.subtype

console.log 'ok'
output = writeMidi(midi)
outputBuffer = new Buffer(output)
fs.writeFileSync('tmp.mid', outputBuffer)

console.log 'header: '+(JSON.stringify midi.header)
console.log ''+midi.tracks.length+' tracks'
for track in midi.tracks
  console.log 'track:'
  for event in track
    console.log '  '+(JSON.stringify event)
