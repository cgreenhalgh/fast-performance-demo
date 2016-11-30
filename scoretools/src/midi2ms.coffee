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

# milliseconds...
delete midi.header.ticksPerBeat
#midi.header.ticksPerFrame = 25
#midi.header.framesPerSecond = 40
midi.header.ticksPerBeat = 500

midiout = 
  header: midi.header
  tracks: []

# tempo should be in first track - build tempo map
tempomap = []
# default
tempomap.push 
  timeTicks: 0
  timeMicroseconds: 0
  microsecondsPerBeat: microsecondsPerBeat

if midi.tracks.length==0
  console.error 'ERROR: file contains no tracks'
else
  console.log 'reading tempo information from first track'
  timeMicroseconds = 0
  timeTicks = 0
  for event in midi.tracks[0]
    # delay
    if event.deltaTime?
      timeTicks += event.deltaTime
      microseconds = Math.round( microsecondsPerBeat * event.deltaTime / ticksPerBeat )
      # carried-forward microsecond remainder
      #event.deltaTime = Math.floor(( microseconds + (timeMicroseconds % 1000) ) / 1000)
      # microsecond accurate
      timeMicroseconds += microseconds
    else
      console.log event
    if event.type=='setTempo'
      microsecondsPerBeat = event.microsecondsPerBeat
      console.log 'at '+(timeMicroseconds/1000000)+' tempo now '+microsecondsPerBeat+'us/beat = '+(60000000/microsecondsPerBeat)+' bpm'
      tempomap.push
        timeTicks: timeTicks
        timeMicroseconds: timeMicroseconds
        microsecondsPerBeat: microsecondsPerBeat

for track in midi.tracks
  trackout = []
  midiout.tracks.push trackout
  mapi = 0
  timeTicks = 0
  timeMicroseconds = 0
  microsecondsPerBeat = tempomap[mapi++].microsecondsPerBeat
  writtenTempo = false
  for event in track
    # delay
    if event.deltaTime?
      #console.log 'event at '+timeTicks+'/'+timeMicroseconds+' dt='+event.deltaTime
      deltaTime = event.deltaTime
      microseconds = 0
      while deltaTime > 0
        #console.log '  deltaTime='+deltaTime+', mapi='+mapi+', timeTicks='+timeTicks+', timeMicroseconds='+timeMicroseconds
        if mapi < tempomap.length and timeTicks+deltaTime >= tempomap[mapi].timeTicks
          dt = tempomap[mapi].timeTicks - timeTicks
          if dt > 0
            microseconds += microsecondsPerBeat * dt / ticksPerBeat
            deltaTime -= dt
            timeTicks += dt
          microsecondsPerBeat = tempomap[mapi++].microsecondsPerBeat
          continue
        microseconds += microsecondsPerBeat * deltaTime / ticksPerBeat      
        timeTicks += deltaTime
        break
      microseconds = Math.round( microseconds )
      # carried-forward microsecond remainder
      event.deltaTime = Math.floor(( microseconds + (timeMicroseconds % 1000) ) / 1000)
      # microsecond accurate
      timeMicroseconds += microseconds
    else
      console.log 'no deltaTime: '+event
    if event.type=='setTempo'
      microsecondsPerBeat = event.microsecondsPerBeat
      console.log 'check: at '+(timeMicroseconds/1000000)+' tempo now '+microsecondsPerBeat+'us/beat = '+(60000000/microsecondsPerBeat)+' bpm'
      if not writtenTempo
        writtenTempo = true
        event.microsecondsPerBeat = 500000
        trackout.push event
    else
      trackout.push event
    if event.type=='endOfTrack'
      console.log 'end of track: at '+(timeMicroseconds/1000000)+' s = '+timeTicks+' ticks, average '+(60*timeTicks/ticksPerBeat*1000000/timeMicroseconds)+' bpm'

console.log 'ok'
output = writeMidi(midiout)
outputBuffer = new Buffer(output)

console.log 'writing '+midifileout
fs.writeFileSync midifileout, outputBuffer
console.log 'done'

