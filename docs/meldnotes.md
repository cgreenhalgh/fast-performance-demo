# Meld Notes

## General

Latest code is on github (https://github.com/oerc-music/meld)

## Configuration

The following four environment variables need to be set prior to running it:
- `MELD_BASE_URI` <--- base URI of the MELD server, e.g. `http://127.0.0.1:5000`
- `MELD_MEI_URI` <-- URI to the directory containing the MEI files (e.g. `http://127.0.0.1/mei/TheClimb`).. n.b. these are not currently served by MELD
- `MELD_MUZICODES_URI` <- URI of the muzicodes server, e.g. `http://127.0.0.1:3000`
- `MELD_BASECAMP_MEI_FILE` <- URI to the first MEI file of the performance, e.g. `http://127.0.0.1/mei/TheClimb/BaseCamp.mei`

## Page Size

Page width and height will want adjusting for the tablet. 

This can be done in the options JSON object inside `app/static/meldrest.js` (line 556), using the keys `pageHeight` and `pageWidth` (currently not specified). Values are number of pixels. 

Verovio will take these values into account when generating the notation layout. See e.g. [http://www.verovio.org/tutorial.xhtml?id=topic01](http://www.verovio.org/tutorial.xhtml?id=topic01)

e.g.
```
var zoom = 40;
$(document).ready(function() { 
    var options = JSON.stringify({
    	pageHeight: 1200*100/zoom,
    	pageWidth: 750*100/zoom,
    	ignoreLayout: 1,
        adjustPageHeight: 1,
        scale:zoom
    });
```


## Use

Run the server using:
```
python manage.py runserver
```

To start a new session of the game (from scratch, i.e. using a new collection of annotations): 
- point your browser to `$MELD_BASE_URI/startTheClimb`, e.g. `http://127.0.0.1:5000/startTheClimb` (we should bookmark this on the tablet)
- click the button there to begin

## Implementation Details

After browsing to `$MELD_BASE_URI/startTheClimb` and pressing start...

the `startTheClimb` script POSTs to `/collection` with parameter `topLevelTargets` = base camp MEI URL. This returns something like:
```
<html><head><link rel="monitor" href="http://127.0.0.1:5000/collection/bdXw4LJ3DaxMmK8ECQp6nK/createAnnoState"></head></html>
```
from which it extracts the URL. It then POSTs to that URL, and extracts the Location field from the response, which is something like:
```
Location: http://127.0.0.1:5000/annostate/RctywXmrxKTXQw9BJ49pKe
```
It then loads the page `<baseuri>/viewer?annostate=<returnedURL>` (where <baseuri> is typically empty).

MELD (client) will now POST to $MELD_MUZICODES_URI/input whenever a new piece is loaded (including this first load), supplying:
- name 
- meldcollection
- meldmei
- meldannostate 

The following curl commands simulates the annotation MELD is expecting to receive from Muzicodes. The bolded variables need to be filled by Muzicodes; $meldannostate and $meldcollection as supplied by MELD on page load.

Queue the next piece (in response to a Muzicode triggering)
```
curl -X POST -H "Content-Type: application/json" -d '{"oa:hasTarget":["$meldannostate"], "oa:hasBody":[{"@type":"meldterm:CreateNextCollection", "resourcesToQueue":["$uri_of_next_mei_file"], "annotationsToQueue":[]}] }' -v $meldcollection
```
Note that this first creates a new collection and annostate for the next score and then sends itself a QueueAnnoState annotation, which causes the UI to change to show the next piece and to set up the internal state used by the NextPageOrPiece handler.

When the foot pedal is pressed, go to next page, or if at last page, load the next queued piece:
```
curl -X POST -H "Content-Type: application/json" -d '{"oa:hasTarget":[$meldannostate], "oa:hasBody":[{"@type":"meldterm:NextPageOrPiece"}] }' -v $meldcollection
```
Note that handling of the viewer next/prev buttons also works by creating the same annotations; the actual transitions are performed in the annotation handlers. (The annotation for previous page is `meldterm:PreviousPageOrPiece`.)

Note: intending to add additional parameter `forceNextPiece`, boolean, which will load next piece even if not on last page.

The JavaScript client currently polls for new state every 50 ms; that's running smoothly on my laptop, however if sluggish on the tablet, it can be adjusted.

To highlight something within the score (e.g. a measure, a note)
```
curl -X POST -H "Content-Type: application/json" -d '{"oa:hasTarget":[{"@id":"$MEI_ELEMENT"}], "oa:hasBody":[{"@type":"meldterm:Emphasis"}] }' -v $COLLECTION_URI
```
$MEI_ELEMENT is the full URI of the MEI element to be highlighted (including '#' and fragment id). You should be able to supply multiple oa:hasTargets in the list, e.g. if you want to highlight the last few notes of a measure, plus the entire next measure (currently untested). 
