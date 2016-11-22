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
```


## Experience file generator

Whole experience is divided into stages. Each stage is defined by a line in a spreadsheet. Generates experience file, including codes, parameters, etc. from an initial experience file.

Spreadsheet columns:

- `stage` - name
- `meifile` - MEI file name for score for stage
- `rain_effect` - if rain effect allowed (`Y`/`N`)
- `snow_effect`, `wind_effect`, `storm_effect`, `sun_effect` - similar
- `auto:` - followed by initial (automatic) actions - see below
- `mcN:` - followed by muzicode N actions - see below
- `default_cue` - name of next stage to cue if reach end and nothing else cued

Actions/etc. for `auto:` and `mcN:`, i.e. names of following columns can be:

- `name` - esp. muzicode name (title)
- `cue` - name of next stage to cue
- `monitor` - URL to show on monitor (default) channel
- `visual` - URL to show on "visual" channel 
(visual, midinote, midicc, midimsg, effect, mei ids...)
