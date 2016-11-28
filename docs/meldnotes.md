# Meld Notes

## General

Latest code is on github (https://github.com/oerc-music/meld)

## Configuration

The following four environment variables need to be set prior to running it:
- `MELD_BASE_URI` <--- base URI of the MELD server, e.g. `http://127.0.0.1:5000`
- `MELD_MEI_URI` <-- URI to the directory containing the MEI files (e.g. `http://127.0.0.1/mei/TheClimb`).. n.b. these are not currently served by MELD
- `MELD_MUZICODES_URI` <- URI of the muzicodes server, e.g. `http://127.0.0.1:3000`
- `MELD_BASECAMP_MEI_FILE` <- URI to the first MEI file of the performance, e.g. `http://127.0.0.1/mei/TheClimb/BaseCamp.mei`

## Use

Run the server using:
```
python manage.py runserver
```

To start a new session of the game (from scratch, i.e. using a new collection of annotations): 
- point your browser to $MELD_BASE_URI/startTheClimb (we should bookmark this on the tablet)
- click the button there to begin

MELD will now POST to $MELD_MUZICODES_URI/input whenever a new piece is loaded, supplying:
- name 
- meldcollection
- meldmei
- meldannostate ** Note, NEW parameter that needs to be implemented on the Muzicodes side

The following curl commands simulates the annotation MELD is expecting to receive from Muzicodes. The bolded variables need to be filled by Muzicodes; $meldannostate and $meldcollection as supplied by MELD on page load.

Queue the next piece (in response to a Muzicode triggering)
```
curl -X POST -H "Content-Type: application/json" -d '{"oa:hasTarget":["$meldannostate"], "oa:hasBody":[{"@type":"meldterm:CreateNextCollection", "resourcesToQueue":["$uri_of_next_mei_file"], "annotationsToQueue":[]}] }' -v $meldcollection
```

When the foot pedal is pressed, go to next page, or if at last page, load the next queued piece:

```
curl -X POST -H "Content-Type: application/json" -d '{"oa:hasTarget":[$meldannostate], "oa:hasBody":[{"@type":"meldterm:NextPageOrPiece"}] }' -v $meldcollection
```

The JavaScript client currently polls for new state every 50 ms; that's running smoothly on my laptop, however if sluggish on the tablet, it can be adjusted.

## Page Size

Page width and height will want adjusting for the tablet. 

This can be done in the options JSON object inside `app/static/meldrest.js` (line 454), using the keys `pageHeight` and `pageWidth` (currently not specified). Values are number of pixels. 

Verovio will take these values into account when generating the notation layout. See e.g. [http://www.verovio.org/tutorial.xhtml?id=topic01](http://www.verovio.org/tutorial.xhtml?id=topic01)

