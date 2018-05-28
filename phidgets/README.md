# Phidget pedal helper

Allow a [Phidget](http://www.phidgets.com/) interface kit to be used to control (e.g.) page turning.

See [install.md](install.md) for installation.

## docker

something like
```
docker run -d -t --restart=always --name=pedal --network=mc-net pedal python pedal.py http://musiccodes:3000/input
```
plus some option to pass in the USB device; not sure what yet!

## non-docker

(sudo on linux unless you have configured USB access)
```
sudo python pedal.py
```

Defaults to URL `http://127.0.0.1:3000/input` and input `pedal`.
First (optional) argument is URL; input name is hard-coded.

## upstart

Autostart with upstart:
```
sudo cp pedal.conf /etc/init/
sudo service pedal start
```
