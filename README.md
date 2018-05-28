# FAST IMPACt project Performance Demonstrator

## Docker runtime

Note: 20180529 converting to use docker.

### Pre-Requisites

Needs [docker](https://docs.docker.com/install/) and 
[docker-compose](https://docs.docker.com/compose/install/#install-compose).
E.g. install docker-for-windows / docker-for-mac and docker-compose. 

Or run in a VM, for example...

#### Running in Vagrant/VirtualBox VM

Can be run in Vagrant/virtualbox with (e.g.) an ubuntu 16.04 image.
```
vagrant up
```
Note: if using virtualbox, DNS can be more reliable if, once after first creating VM, you shut down VM (`sudo halt`) and 
```
vboxmanage list vms
vboxmanage modifyvm "fast-performance-demo_default_XXXX" --natdnshostresolver1 on
vagrant up
```
(where XXXX is the actual ID show by `list vms`)

Note, the following ports are forwarded to the VM:
- `3000` - musiccodes server
- `3003` - music-performance-manager server
- `5000` - MELD server
- `8081` (-> `8080`) - MELD client (server)

### docker-compose

Get images if necessary, e.g.
```
docker load -i climb-docker-images.tar.bz2
```

One-shot set-up... 

```
docker-compose up -d
```

And that should be it.

Then
```
./scripts/setup.sh
```

More details of docker stuff in [docs/docker.md](docs/docker.md).


## previous stuff...

Files and resources for the EPSRC-funded [FAST IMPACt](http://www.semanticaudio.ac.uk/) project Performance Demonstrator, 2016/2017.

At least initially this comprises an integration of [Muzicodes](https://github.com/cgreenhalgh/musiccodes), [MELD](https://github.com/oerc-music/meld) and the [Music Performance Manager (MPM)](https://github.com/cgreenhalgh/music-performance-manager) to support a new composition/performance by [Maria Kallionpaa](https://uk.linkedin.com/in/mariakallionpaa).

See [docs/install.md](docs/install.md) for initial installation. See also [docs/](docs/) for other design/technical documentation.

## set up

See [docs/install.md](docs/install.md)

The experience is configured by editing:
- [scoretools/test/mkGameEngine-config.yml](scoretools/test/mkGameEngine-config.yml) - general config
- [scoretools/test/mkGameEngine.xlsx](scoretools/test/mkGameEngine.xlsx) - stage structure and associated actions
- [scoretools/test/mkGameEngine-in.json](scoretools/test/mkGameEngine-in.json) - template muzicode experience file with muzicodes and inputs/output defined (but not actions/controls)

MEI files for scores should be in [mei-files/](mei-files/)

Content files for the visuals should be in [images/](images/)

After any changes the files are regenerated and copied into the appropriate (musiccodes) sub-directories using
```
./scripts/setup.sh
```

In particular this creates the muzicodes experience file [musiccodes/server/experience/mkGameEngine-out.json](musiccodes/server/experience/mkGameEngine-out.json)

## running

Once installed, muzicodes should be running (as a background service) on part 3000. Open url [http://localhost:3000/](http://localhost:3000/) to access the initial muzicodes interface.

The editor view for the final experience files is accessible as [http://localhost:3000/edit/#/mkGameEngine-out.json](http://localhost:3000/edit/#/mkGameEngine-out.json).

The player view is accessible from the editor or as [http://localhost:3000/player.html#?f=%2Fexperiences%2FmkGameEngine-out.json](http://localhost:3000/player.html#?f=%2Fexperiences%2FmkGameEngine-out.json)

The climb visual view is accessible as [http://localhost:3000/climbview.html#?config=%2Fassets%2FmkGameEngine-view.json&test=1](http://localhost:3000/climbview.html#?config=%2Fassets%2FmkGameEngine-view.json&test=1) or
[http://localhost:3000/climbview.html#?config=%2Fassets%2FmkGameEngine-view.json](http://localhost:3000/climbview.html#?config=%2Fassets%2FmkGameEngine-view.json) (no testing) 

MELD client should be  accessible as [http://127.0.0.1:8080/startTheClimb](http://127.0.0.1:8080/startTheClimb) (NB, NOT localhost!; also note change of port from old meld (5000, now just used by the meld server)).

The Music performance manager dashboard as [http://localhost:3003/dashboard.html](http://localhost:3003/dashboard.html)
