# Performance Demo Design Notes

## Overview

[Muzicodes](https://github.com/cgreenhalgh/musiccodes) server runs on port 3000.

Muzicodes has a single experience file for the complete performance.

[MELD](https://github.com/oerc-music/meld) server runs on port 5000.

MELD has a separate MEI file and initial metadata for each section/piece within the performance.

MELD displays score and allows player to page through score and progress to next cued section. MELD may also display highlights for successfully triggered scores.

Muzicodes controls sequencer and effects via MIDI messages. These are triggered by MELD opening a new section of the score and by the pianist playing muzicodes successfully. Muzicodes also controls the visuals via HTTP requests (muzicodes simple channel view or Ivy's visualisation system).

A MIDI sequencer (perhaps part of MAX?) plays the disclavier parts from standard MIDI files. It is triggered by Muzicodes over MIDI.

MAX performs effects on the sampled piano audio, controlled by Muzicodes over MIDI.

There may be a separate process to interface to a physical pedal for page turn/next piece.

## Interactions

### Muzicodes -> MELD interactions

Muzicodes can cue the next piece/section to play (by adding a MELD annotation). It will identify the piece/section by URI specifically including its filename.

(Details...)

Muzicodes can highlight a muzicode as successfully played (by adding a MELD annotation). At least initially it will identify the muzicode by a custom URI hand-authored in the initial metadata for the section, which in turn identifies the specific measures/notes of the score corresponding to the code.

(Details...)

### MELD -> Muzicodes interactions

MELD will signal Muzicodes (via HTTP) when its loads a (new) section of the music, e.g. on initial load on when the pianist pages to the next cued piece. This will be caused by a hand-authored annotation in the initial metadata for the section, whose action specifies the corresponding HTTP operation.

(Details...)

V0.1:
- HTTP POST
- muzicodes server (default port 5000), path "/input"
- URL-encoded form-style parameters - in URL or POST body
  - room: room name (default "default")
  - pin: room pin/password (default "")
  - name: control input name (required)
  - client: optional client identification

Note: the corresponding control input URL in muzicodes is "post:" concatenated with the specified name.

### Pedal -> MELD interactions

The foot pedal for page turn/next section needs to link to MELD. How...?? A separate pedal driver won't know which piece is current so won't know which piece to add page turn/progress annotation to. So probably a separate more direct connection to the MELD client, e.g. over socket.io, mapped directly to screen button press handler. Would still need some kind of scoping/namespacing to link that particular pedal to this particular MELD client. Alternatively could be indirect via Muzicodes, but that would require a relatively complex mapping from pedal action to output event (at least templating/demultiplexing on current piece).

