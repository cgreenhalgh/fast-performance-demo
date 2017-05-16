# Mobile App Notes

The mobile app has been created by Mengdie Lin. The source is [https://github.com/littlebugivy/muzivisual](https://github.com/littlebugivy/muzivisual).

## Current operation

(Chris' working notes - may contain errors :-)

It is written in Node.js and uses socket.io. The server uses socket.io's redis adapter to share socket.io messages with the muzicodes server. 

The server reads config from `maps/climb.csv` and returns in json form to the client when GETting `maps/`. This includes stage id (string), name, map x/y, cue, img, state (initially `hidden`).

Clients are joined to the room `visualRoom`. If a client sends a `vTimer` message with data >0 this is emitted to the `visualRoom` (why??).

Client responds to the following (`visualRoom`) messages:
- `vStageChange` (mapCtrl, /map), data (string) stage `->` stage
- `vStop` (mapCtrl, /map)
- `vStart` (menuCtrl, /)

Hard-coded stage name `begin` and `end` for first and last.

In the client, node (stage) states can be `hidden`, `revealed`, `missed`, `active`, `rev_succ` (previously visited), `rev_fail` (not used?!)

In musicodes server, clients are joined to `visualRoom` (unclear why). Client messages are relayed to `visualRoom`:
- `vStageChange` - copies data ("stagename->stagename")
- `vStart` -> `vStart` `"start visual"`

Musicodes player:
- emits `vStart` on first load (before experience loaded)
- on `vTimer` copies data to `$scope.vTimer` (feedback??)
- emits `vStageChange` if action starts `data:text/plain`(,) and includes `->` with the text value

## Proposed Interface

### From Musicodes

Musicodes will send messages to socket.io room `mobileapp`:
- `vStart`, data is a string  of the form `{{performanceid}}:{{stagename}}`
- `vStop`, data is a string of the form `{{performanceid}}` (GUID)
- `vStageChange`, data is string of the form `{{performanceid}}:{{fromstagename}}->{{tostagename}}`

### From experience / authoring

The performance IDs will be random but defined in advance. There will be at least three:
- test/rehearsal
- first performance
- second performance

There will be a set of performance configuration files, named `<performanceid>.json`, JSON objects with properties:
- `performanceid` (string, GUID)
- `title` (string), e.g. title of piece (first / second) - for display in the app
- `description` (string), e.g. short description of performance- for display in the app
- `map` (string), identify specific map/map file to use (not needed for initial performances as both will be Climb!)

To be determined if this will be generated from the master spreadsheet or (more likely) by hand for now.

## Requirements

The server should serve different URLs for each performance, e.g. `.../performance/<performanceid>`

Each performance should use its own socket.io room to propagate events to app clients.

The server should persist the state of each performance based on the events received (this could be done in the same redis instance use for socket.io).

Whenever a client starts it should immediately receive the current state of the performance and change its display accordingly. E.g. pre, during and post performance; current stage and history of transitions.

The server should work behind a reverse proxy on a sub-path, e.g. `http://music-mrl.nott.ac.uk/1/guide/*` -> `/...` 

The view (and configuration) for each stage should show an image, stage title and also a stage description (HTML-formatted). This description will be in the map configuration file.

To confirm: exactly what information and navigation is available in each app mode.

It should not be possible to use the browser back button to old states of the app. 

If bookmarked at any point and reloaded it should always load and show the appriate current state (e.g. during performance, post performance).

Need complete map for performance. Needs to be consistent with master spreadsheet, esp. possible transitions, stage ids.

Need updated images for stages matched to video (ask Adrian).

Need updated map backdrop / other app images matched to video (ask Adrian).

## Musicodes issues

Experience generator must define and allow setting of performance id (buttons for testing, input for live?).

Experience generator must produce actions for `vStart` (start of performance), `vStop` (end of performance - blank stage at end??), `vStageChange` (change of stage).

Musicodes must support actions which will result in server emitting corresponding messages to a specified room.
