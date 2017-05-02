# FAST Performance Demo Score Tools

Utilities for working with score and building/processing experience files.

New...

Note: install muzicodes first to get npm, etc.

(--no-bin-links for windows only)
```
npm install --no-bin-links
```

Config file in YAML, `config.yml`:
```
spreadsheet: FILE.xlsx
experiencein: FILE.json
experienceout: FILE.json
meidir: ../mei-files
mcserver: http://localhost:3000/input
meldserver: http://localhost:5000/addannotation/
meldmeiuri: http://localhost:3000/content/
contenturi: http://localhost:3000/content/
cuesingle:false
defaultprojection: 1
weatherdelaymin: 
weatherdelaymax: 
no_effect: data:text/x-midi-hex,903a7f
rain_effect: data:text/x-midi-hex,903b7f
snow_effect: data:text/x-midi-hex,903c7f
wind_effect: data:text/x-midi-hex,903d7f
storm_effect: data:text/x-midi-hex,903e7f
sun_effect: data:text/x-midi-hex,903f7f

climbviewout: climbview-config.json
no_url:
rain_url:
snow_url:
wind_url:
storm_url:
sun_url:
weatherfadein: 2
weatherfadeout: 3
noanimationurl: 
defaultmuzicodeurl:
muzicodefadein: 0.5
muzicodefadeout: 1
muzicodeholdtime: 0.2
backgroundfadein: 2
backgroundfadeout: 2
```
Note:

- XX_effect - action to trigger associated effect

End of note stream for default projection drives cueing of default next stage.


## Experience file generator

Whole experience is divided into stages. Each stage is defined by a line in a spreadsheet. Generates experience file, including codes, parameters, etc. from an initial experience file.

Spreadsheet columns:

- `stage` - name
- `meifile` - MEI file name for score for stage
- `rain_effect` - if rain effect allowed (`Y`/`N`)
- `snow_effect`, `wind_effect`, `storm_effect`, `sun_effect`, `no_effect` - similar
- `auto:` - followed by initial (automatic) actions - see below
- `mcN:` - followed by muzicode N actions - see below
- `default_cue` - name of next stage to cue if reach end and nothing else cued

Actions/etc. for `auto:` and `mcN:`, i.e. names of following columns can be:

- `name` - esp. muzicode name (title)
- `cue` - name of next stage to cue
- `monitor` - URL to show on monitor (default) channel
- `v.background` - URL to show on background "visual" channel 
- `v.animation` - URL to show on animation "visual" channel (i.e. disklavier part visualisation)
- `v.mc` - "1" (use config defaultmuzicodeurl) or URL to show on muzicode visual channel
- `midi` - hex of midi message to send (can be list, comma-separated)
(visual, midinote, midicc, midimsg, effect, mei ids...)

The optional value in the `mcN:` column specifies a score element to highlight if the code triggered. The value is a comma-separated list of any of:
- The (complete case-sensitive) text of a score direction at the measure of the code
- A xml:id of a score element (starting with `#`)
- a measure number

## MIDI files

## convert to ms time code

Tried to do this...
```
node lib/midi2ms.js test/Echo1c_Disklavier.mid test/Echo1c_Disklavier_ms.mid 
```

But reporting times at which tempo changes occur in files doesn't seem to match the music. E.g. the stones should be 100 bpm from the start, but the files starts at 60 bpm and the change seems to be in the file after 28 seconds. 

### testing

initial test `readmidi.coffee` reads `test/TheStones_1b_Disklavier.mid`:
```
header: {"formatType":0,"trackCount":1,"ticksPerBeat":480}
1 tracks
track:
  {"deltaTime":0,"type":"meta","subtype":"trackName","text":"Piano"}
  {"deltaTime":0,"type":"meta","subtype":"instrumentName","text":"Steinway Grand Piano"}
  {"deltaTime":0,"type":"meta","subtype":"timeSignature","numerator":4,"denominator":4,"metronome":24,"thirtyseconds":8}
  {"deltaTime":0,"type":"meta","subtype":"keySignature","key":0,"scale":0}
  {"deltaTime":0,"type":"meta","subtype":"smpteOffset","frameRate":25,"hour":0,"min":0,"sec":0,"frame":0,"subframe":0}
  {"deltaTime":0,"type":"meta","subtype":"setTempo","microsecondsPerBeat":1000000}
...
  {"deltaTime":2,"type":"meta","subtype":"setTempo","microsecondsPerBeat":600000}
...
  {"deltaTime":0,"type":"meta","subtype":"endOfTrack"}
```
or
```
read test/Echo1c_Disklavier.mid
header: {"formatType":0,"trackCount":1,"ticksPerBeat":480}
...  
  {"deltaTime":0,"type":"meta","subtype":"setTempo","microsecondsPerBeat":1000000}
...
  {"deltaTime":17042,"type":"meta","subtype":"setTempo","microsecondsPerBeat":507462}
...
  {"deltaTime":112,"type":"meta","subtype":"setTempo","microsecondsPerBeat":515151}
```

Note, library won't read SMPTE-based times (i.e. throws exception).

   "midi-file": "git+https://github.com/cgreenhalgh/midi-file.git",
   "midi-file": "file:../midi-file",
   