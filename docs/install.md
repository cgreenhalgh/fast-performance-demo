# Install

assumes you have set up pre-reqs as per ../Vagrantfile!

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

Clone meld
```
git clone https://github.com/oerc-music/meld.git
```
Pre-reqs
```
pip install -r requirements.txt
```

Note, to run Meld within vm use `--host==0.0.0.0` option
```
python manage.py runserver --host=0.0.0.0
```

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
        server_name  meld.linkedmusic.org;
        location / {
            proxy_pass   http://127.0.0.1:5000;
        }
	}

```

edit `/etc/hosts`
add entry(s)
```
127.0.0.1       muzicodes
127.0.0.1		meld.linkedmusic.org
```

```
sudo killall -HUP mDNSResponder
```

See also [android](android.md) notes.

## Phidgets - buttons etc

see [phidgets](../phidgets/install.md)
