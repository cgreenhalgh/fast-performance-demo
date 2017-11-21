# Install

assumes you have set up pre-reqs as per ../Vagrantfile!

## musiccodes

Clone musiccodes
```
git clone https://github.com/cgreenhalgh/musiccodes.git
```
Pre-reqs and build...
```
cd musiccodes
./scripts/install.sh PATH-TO-MUSICODES-SERVER
```
E.g. in vagrant `PATH-TO-MUSICODES-SERVER` could be `/vagrant/musiccodes/server`

Should start musiccodes as service on port 3000. If not try
```
./scripts/run.sh
```

## meld

Clone meld (note, currently a branch integrating support for music-performance-manager)
```
git clone https://github.com/cgreenhalgh/meld.git
git checkout mpm
```
Pre-reqs
```
sudo pip install -r requirements.txt
```
set up MELD for upstart:
```
sudo cp scripts/meld.upstart.conf /etc/init/meld.conf
sudo service meld start
```

Or run manually...

There are scripts to run meld in [./scripts/runmeld.sh](./scripts/runmeld.sh), so 
the following internal details should be necessary.

See [meldnotes.md](meldmotes.md) for more on setting up MELD...
Note, to run Meld within vm use `--host==0.0.0.0` option, e.g.
```
python manage.py runserver --host=0.0.0.0
```

## music performance manager

Clone music performance manager
```
git clone https://github.com/cgreenhalgh/music-performance-manager.git
```
pre-reqs and build
```
cd music-performance-manager
./scripts/install.sh
npm install --no-bin-links
bower install
```

Should start mpm as service on port 3003.

## Proxying

On host, if proxying for public web address install nginx.

E.g. Max OS X using homebrew
```
brew install nginx
```
Optional (or run explicitly)
```
brew services start nginx
```
```
sudo nginx -s stop
sudo nginx
```
edit `/usr/local/etc/nginx/nginx.conf`

change `listen 8080` to `listen 80`
add
```
    server {
        listen       80;
        server_name  muzicodes;
        location / {
            proxy_pass   http://127.0.0.1:3000;
        }
	}
    server {
        listen       80;
        server_name  mpm;
        location / {
            proxy_pass   http://127.0.0.1:3003;
        }
	}
    server {
        listen       80;
        server_name  meld.linkedmusic.org;
        location / {
            proxy_pass   http://127.0.0.1:5000;
        }
	}

```
(Note: need to do a bit more to proxy websockets for muzicodes and mpm performance - TODO)

edit `/etc/hosts`
add entry(s)
```
127.0.0.1       muzicodes
127.0.0.1       mpm
127.0.0.1		meld.linkedmusic.org
```

```
sudo killall -HUP mDNSResponder
```

See also [android](android.md) notes.

## Phidgets - buttons etc

see [phidgets](../phidgets/install.md)

Provisionally replaced by use of AirTurn bluetooth pedal, which emulates keyboard input.
