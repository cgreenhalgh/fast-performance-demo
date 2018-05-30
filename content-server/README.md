# Content server

simple content server.

```
vagrant up
```
Note: if using virtualbox, DNS can be more reliable if, once after first creating VM, you shut down VM (`sudo halt`) and 
```
vboxmanage list vms
vboxmanage modifyvm "fast-performance-demo_default_XXXX" --natdnshostresolver1 on
vagrant up
```

(to stop again, `vagrant halt`)

Content is served from `content-server/html/` on port 3000.

Typically images/video should be copied in `content-server/html/content`, i.e. URLs
`http://localhost:3000/content/...`

## potential problems

Note, if after restart of vagrant VM you get permission denied for http request 
try restarting the docker container:
```
vagrant ssh
docker restart frontend
```

You can check if the process is running with
```
docker ps -a
```

You can check process logs with 
```
docker logs frontend
```

## by hand (no vagrant)

Or if running directly in docker (done in shell provision in Vagrantfile)
```
cd nginx
docker build -t frontend .
cd ..
docker run --name frontend -d --restart=always \
  -p :80:80 -v `pwd`/html:/usr/share/nginx/html frontend
```

Check with 
```
docker logs frontend
```

C