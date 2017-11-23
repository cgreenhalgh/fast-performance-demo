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

New meld...

### Meld server

Clone meld server
```
git clone https://github.com/oerc-music/meld.git
```
Pre-reqs
```
cd meld/server
sudo pip install -r requirements.txt
```
run manually
```
source set_env.sh
python manage.py runserver --host=0.0.0.0 --threaded
```
Or

set up MELD for upstart:
```
sudo cp scripts/meld.upstart.conf /etc/init/meld.conf
sudo service meld start
```

### Meld muzicode config

Update meld/server/mkGameEngine-meld.json
```
cd /vagrant/meld/server
export MELD_BASE_URI=http://${IP}:5000
export MELD_MEI_URI=http://${IP}:3000/content
export MELD_SCORE_URI="http://${IP}:5000/score"
python generate_climb_scores.py mkGameEngine-meld.json /vagrant/meld/server/score/
```

### Meld client

Clone meld client
```
git clone https://github.com/oerc-music/meld-client.git
```
Build
```
cd meld-client
npm install --no-bin-links
```

Upstart...


Run manually (port 8080 default)
```
node ./node_modules/webpack-dev-server/bin/webpack-dev-server.js --host=0.0.0.0
```

Open [http://127.0.0.1:8080/startTheClimb](http://127.0.0.1:8080/startTheClimb)

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


## Score tools

See [../scoretools/README.md](../scoretools/README.md)

```
sudo npm install -g coffee-script
cd scoretools
npm install --no-bin-links
```
