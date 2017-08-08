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
meioutdir: ../mei-files/out
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
videourl: "video:{\"width\":1280,\"height\":720}"
videolayer: 0
videoInsetTop: 0.1
videoInsetBottom: 0.1
videoInsetLeft: 0.1
videoInsetRight: 0.1
videoCropTop: 0.1
videoCropBottom: 0.1
videoCropLeft: 0.1
videoCropRight: 0.1

performances:
  test: 9333e7a2-16a9-4352-a45a-f6f42d848cde
  first: be418821-436d-41c2-880c-058dffb57d91
  second: 13a7fa70-ae91-4541-9526-fd3b332b585d
```
Note:

- XX_effect - action to trigger associated effect
- videourl adds extra video layer
- videolayer index of video layer, e.g. 0 at back
- videoInsetTop/Bottom/Left/Right - fraction to inset edges of video layer
- videoCropTop/Bottom/Left/Right - fraction to inset edges of video layer
- videoMirror - mirror flag for video layer
- videoRotate - rotate 180 flag for video layer

End of note stream for default projection drives cueing of default next stage.


## Experience file generator

Whole experience is divided into stages. Each stage is defined by a line in a spreadsheet. Generates experience file, including codes, parameters, etc. from an initial experience file.

Spreadsheet columns:

- `stage` - name
- `next` - "safe" next stage (always an option)
- `meifile` - MEI file name for score for stage
- `rain_effect` - if rain effect allowed (`Y`/`N`)
- `snow_effect`, `wind_effect`, `storm_effect`, `sun_effect`, `no_effect` - similar
- `auto:` - followed by initial (automatic) actions - see below
- `mcN:` - followed by muzicode N actions - see below (only triggered once per stage)
- `default_cue` - name of next stage to cue if reach end and nothing else cued

It is assumed that the first row is the start and the last row is the end.

Following columns are divided into blocks specifying response to (either) start of stage (`auto:`) or successful triggering of a muzicode ( `mc1:`, `mc2:`, `mc3:`, `mc4:` or `mc5:`).

Actions/etc. for `auto:` and `mcN:` blocks, i.e. names of following columns can be:

- `name` - esp. muzicode name (title) (two mcNs with same muzicode => trigger on consecutive triggerings)
- `cue` - name of next stage to cue, or list of next stage names separated by '/' between which to choose randomly (e.g. 's1/s2/s3')
- `monitor` - URL to show on monitor (default) channel
- `v.mc` - "1" (use config defaultmuzicodeurl) or URL to show on muzicode visual channel
- `v.mc.delay` - optional delay for muzicode action
- `app` - value to emit to mobile app in a `vEvent` message (message will be prefixed with performance ID and ':'). Sending is delayed by `v.mc.delay`.
- `v.background` - URL to show on background "visual" channel 
- `midi` - hex of midi message to send (can be list, comma-separated)
- `delay` - optional delay in seconds before remaining actions are performed
- `vdelta` - optional adjustment to `delay` for `v.animation` compared to `midi2`, e.g. to make animation later use a positive value; earlier use a negative value
- `v.animation` - URL to show on animation "visual" channel (i.e. disklavier part visualisation)
- `midi2` - hex of midi message to send after delay (if any) (can be list, comma-separated)
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
   