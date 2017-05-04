# Archive and Souvenir notes

## structure / content

Archive site facets:
- *performances*
- pieces
- composers
- performers
- venues

Performance:
- metadata - where, when, who, what, etc.
- programme notes
- live performance link(s) (pre/during)
- stages/sub-events: stages played, codes triggered (codes missed?), weather
- souvenir (post)
- photos
- audio recording(s)
- video recording(s)
- logs: musiccodes, meld, mpm
- midi files??
- comments
- interviews, etc.?
- system configuration files
- content/asset files?
- version information
- executables, etc.??

### Views

- home page: coming soon/ now on
- index of performances
- performance/ID: details, links

## implemnentation notes

static files? 

client-generated views from JSON data? or (e.g.) Jekyll-based static generated site?

### config files

- featured: -> coming soon / now on / featured - maybe generated from performance files?
- performances: index - maybe generated from performance files?
- performance/ID: details, links...

## types / ontologies

### URIs

music brainz??

### Music ontology

see [music ontology](http://musicontology.com/docs/getting-started.html#example-performance)
see [FRBR](http://vocab.org/frbr/core)

```
mo: http://purl.org/ontology/mo/
dc: http://purl.org/dc/elements/1.1/
xsd: http://www.w3.org/2001/XMLSchema#
tl: http://purl.org/NET/c4dm/timeline.owl#
event: http://purl.org/NET/c4dm/event.owl#
foaf: http://xmlns.com/foaf/0.1/
rdfs: http://www.w3.org/2000/01/rdf-schema#
```

#### Summary:

`mo:Performance` 
- `mo:performance_of`: `mo:MusicalWork`
- `mo:recorded_as`: `mo:Signal` ((logical) event stream? trace?) (won't be majorly transformed after this?!) 
`mo:Signal`
- `mo:published_as`: `mo:Track` (on a particular record/release... - note intentionality) (log? encoding?)
`mo:Track`
- `mo:available_as`: `mo:AudioFile` | `mo:Stream` (log file? path, url...)

#### More detail:

`mo:Performance` (parent class `http://purl.org/NET/c4dm/event.owl#Event`)
- `mo:performance_of` `mo:MusicalWork`
- `mo:performer` `foaf:Agent`
- `rdfs:label` (why? - from MO example)
- `dc:date` (xsd:date)
- `event:place` (geo:SpatialThing)
- `event:sub_event`
- `event:time` (time:TemporalEntity)
- `mo:recorded_as` (mo:Signal)
- ? `

`mo:MusicalWork` (parent class `http://purl.org/vocab/frbr/core#Work`)
- `dc:title`
- `frbr:creator` (ResponsibleEntity, e.g. Person)
- `mo:movement` (mo:Movement)
- `mo:homepage`
- `mo:image`
- `mo:performed_in` (opp. `mo:performance_of` -> `mo:Performance`)

`mo:Movement` (parent class `mo:MusicalWork) ?!

`mo:MusicalExpression` (parent class `frbr:Expression`)
(childrem `mo:Signal` (roughly musicbrainz Recording?), `mo:Sound`)
- `mo:published_as` (`mo:MusicalManifestation`)

`mo:MusicalManifestation` (parent class `frbr:Manifestation`)
(children: `mo:Record` (musicbrainz Release?), `mo:Track` (usually on a particular `mo:Record`), `mo:PublishedScore`, `mo:Release`, ...)
- `mo:media_type` (`dc:MediaType`)
- `mo:publication_of` (`mo:MusicalExpression`) 
- `mo:available_as` (`mo:MusicalItem`)

`mo:MusicalItem`
(children `mo:Medium` (children `mo:AudioFile`, `mo:Stream`))
- `mo:encodes` (`mo:Signal`)

`foaf:Agent`:
- `foaf:name` name

`foaf:Person` (= `frbr:Person`) (parent class `foaf:Agent`)

`tl:UTInstant`:
- `tl:atDateTime` (xsd:dateTime)

`tl:Interval`:
- `tl:at` (xsd:dateTime)
- `tl:duration` (xsd:duration)

`geo:SpatialThing`
- ??
