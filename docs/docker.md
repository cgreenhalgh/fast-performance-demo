# docker notes

Details of docker set-up...

### Network

User bridge network
```
docker network create mc-net
```

### Containers

The following containers are needed:
- `musiccodes`
- `mpm`
- `redis` - used by MPM
- `meld`
- `meld-client`
- `pedal` - if using Phidgets pedal controller

The scoretools image is also needed.

Note: try to use stretch & node:8.12.2-stretch

#### Musiccodes

See [Musiccodes README](https://github.com/cgreenhalgh/musiccodes)
for docker build info, or (hopefully) use a version from docker hub.

```
docker run --restart always -d -p 3000:3000 --network=mc-net --name=musiccodes cgreenhalgh/musiccodes
```
Volumes:
- `/srv/musiccodes/experiences` => `volumes/experiences`
- `/srv/musiccides/public/content` => `volumes/content`


Note, to copy experiences and content in use 
```
docker cp XXX musiccodes:/srv/musiccodes/experiences/
docker cp XXX musiccodes:/srv/musiccodes/pubic/content/
```
To copy logs out use
```
docker cp musiccodes:/srv/musiccodes/logs logs/
```

#### Meld

See [meld/README.md](meld/README.md) for build info, or (hopefully) use a 
version from docker hub.

```
sudo docker run -d --network=mc-net --name=meld --restart=always -p 5000:5000 cgreenhalgh/meld
```
Volumes:
- `/root/work/score` - score-related files => `volumes/score`
- `/root/work/sessions` (not actually a volume!) - `logs/sessions`

#### Meld-client

See [meld-client/README.md](meld-client/README.md) for build info, 
or (hopefully) use a version from docker hub.

```
sudo docker run -d --network=mc-net --name=meld-client --restart=always -p 8080:8080 cgreenhalgh/meld-client
```
No volumes.

#### Redis

Vanilla redis on internal network:
```
docker run --name redis --network=mc-net -d --restart=always redis:4.0
```

Ports:
- `6379` - standard redis port (note, not exposed outside internal network!)

#### Music Performance Manager

For docker build info see [MPM readme](https://github.com/cgreenhalgh/music-performance-manager),
or (hopefully) use a version from docker hub.

```
docker run -d --restart=always --network=mc-net --name=mpm -p 3003:3003 mpm
```
Volumes:
- `/srv/mpm/logs` => `logs/mpm`

#### Pedal

Build see [phidgets/install.md](phidgets/install.md).

```
something like
```
docker run -d -t --restart=always --name=pedal --network=mc-net cgreenhalgh/pedal python pedal.py http://musiccodes:3000/input
```
plus some option to pass in the USB device; not sure what yet!

#### Scoretools

Image, rather than container... as it is used as a command.

For build see [scoretools/README.md](scoretools/README.md).

Volumes:
- `/srv/scoretools/test` => `scoretools/test`
- `/srv/mei-files` => `mei-files` (and `mei-files/out`)

```
docker run --rm -v `pwd`/scoretools/test:/srv/scoretools/test -v `pwd`/mei-files:/srv/mei-files scoretools
```

### save and load image

```
docker save -o climb-images.tar cgreenhalgh/meld \
 cgreenhalgh/meld-client cgreenhalgh/pedal \
 cgreenhalgh/musiccodes cgreenhalgh/mpm \
 redis scoretools
gzip climb-images.tar
```

