# Install

This information deals with building/running the individual applications.
In general this has been superceded by the use of docker,
see [docker.md](docker.md).

## vagrant dns

Note vagrant DNS resolution MIGHT be more reliable if you halt the VM and set
```
vboxmanage list vms
vboxmanage modifyvm "fast-performance-demo_default_XXXX" --natdnshostresolver1 on
```
and start it again.

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

## docker

See [docs](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository)
```
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
```
Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, 
```
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
```
Optional,
```
sudo docker run hello-world
```

## meld server

```
cd meld
git clone https://github.com/oerc-music/meld
sudo docker build -t meld .
sudo docker run -d --name=meld --restart=always -v `pwd`/meld/server/score/:/root/work/score/ -p 5000:5000 meld
cd ..
```
(not -v `pwd`/meld/server/sessions:/root/work/sessions/ )

(note: update score files - done from setup.sh)
```
sudo docker cp meld/meld/server/mkGameEngine-meld.json meld:/root/work/
sudo docker exec meld python generate_climb_scores.py mkGameEngine-meld.json score
```

## meld	 client

```
cd meld-client
git clone https://github.com/oerc-music/meld-client
sudo docker build -t meld-client .
sudo docker run -d --name=meld-client --restart=always -p 8080:8080 meld-client
cd ..
```

(depending on vagrant port mapping:)
Open [http://127.0.0.1:8081/startTheClimb](http://127.0.0.1:8081/startTheClimb)

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
sudo service mpm start
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
