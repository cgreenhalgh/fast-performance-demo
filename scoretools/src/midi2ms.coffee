# read midi file and convert timings to ms and write

if process.argv.length != 4
  console.error 'Usage: node readmidi.js MIDIFILEIN MIDIFILEOUT'
  process.exit -1

midiFileParser = require 'midi-file-parser'

# threw an exception
#var parseMidi = require('midi-file').parseMidi
writeMidi = require('midi-file').writeMidi

fs = require 'fs'

midifilein = process.argv[2]
midifileout = process.argv[3]

console.log 'read '+midifilein

file = fs.readFileSync midifilein, 'binary'
midi = midiFileParser file
# midi-file-parser uses event.subtype cf event.type
for track in midi.tracks
  for event in track
    event.type = event.subtype
    delete event.subtype

if !midi.header.ticksPerBeat
  console.error 'File is not beat-based: '+(JSON.stringify midi.header)
  process.exit -2

ticksPerBeat = midi.header.ticksPerBeat
# 120 bpm default
microsecondsPerBeat = 500000
timeMicroseconds = 0

# milliseconds...
delete midi.header.ticksPerBeat
midi.header.ticksPerFrame = 25
midi.header.framesPerSecond = 40

midiout = 
  header: midi.header
  tracks: []

for track in midi.tracks
  trackout = []
  midiout.tracks.push trackout
  for event in track
    # delay
    if event.deltaTime?
      microseconds = Math.round( microsecondsPerBeat * event.deltaTime / ticksPerBeat )
      # carried-forward microsecond remainder
      event.deltaTime = Math.floor(( microseconds + (timeMicroseconds % 1000) ) / 1000)
      # microsecond accurate
      timeMicroseconds += microseconds
    else
      console.log event
    if event.type=='setTempo'
      microsecondsPerBeat = event.microsecondsPerBeat
      console.log 'at '+(timeMicroseconds/1000000)+' tempo now '+microsecondsPerBeat+'us/beat = '+(60000000/microsecondsPerBeat)+' bpm'
    else
      trackout.push event

console.log 'ok'
output = writeMidi(midiout)
outputBuffer = new Buffer(output)

console.log 'writing '+midifileout
fs.writeFileSync midifileout, outputBuffer
console.log 'done'

