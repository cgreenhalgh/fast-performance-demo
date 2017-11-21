# FAST IMPACt project Performance Demonstrator

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

MELD is run as
```
./scripts/runmeld.sh
```
Or set up MELD for upstart:
```
sudo cp scripts/meld.upstart.conf /etc/init/meld.conf
sudo service meld start
```



MELD is then accessible as [http://127.0.0.1:5000/startTheClimb](http://127.0.0.1:5000/startTheClimb).

The Music performance manager dashboard as [http://localhost:3003/dashboard.html](http://localhost:3003/dashboard.html)
