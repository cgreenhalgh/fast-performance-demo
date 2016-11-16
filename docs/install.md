# Install

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
