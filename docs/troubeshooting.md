# Troubleshooting

This assumes you are running the demo using docker, most likely in a Vagrant/VirtualBox Virtual Machine (VM).

## VM

To control/access the VM open a terminal window (on Windows a command window) and
change directory to the top-level `fast-performance-demo` directory.

### VM lifecycle

To start the VM:
```
vagrant up
```

To stop the VM:
```
vagrant halt
```

Open the virtual box GUI to check if the VM is actually running or to change its settings.

### VM login

Log into the VM using:
```
vagrant ssh
```

Any comments entered now will be run within the VM itself.

### VM networking/DNS issues

Note: if using virtualbox and you experience unpredictable problems with external
network access (i.e. DNS seems to be unreliable from within the VM) then, 
once after first creating VM, shut down VM (`vagrant halt`) and 
```
vboxmanage list vms
vboxmanage modifyvm "fast-performance-demo_default_XXXX" --natdnshostresolver1 on
vagrant up
```
(where XXXX is the actual ID show by `list vms`)

### VM provisioning problems

The first time `vagrant up` is run it should set up the virtual machine.
If there is a problem during this process (e.g. because the network connection
was lost) then you can get the machine to attempt to set itself up again with:
```
vagrant provision
```

Alternatively you can halt the old version, rename or delete it, unzip a new
copy and try `vagrant up` again.

### Docker in VM

When using a VM, to manage docker you MUST do it in a terminal that is 
connected to the VM, i.e. after
```
vagrant ssh
```
Otherwise you will be trying to control docker on the "host" machine, not inside
the virtual machine.

You should typically also change directory to `/vagrant` to access the
VM's view of the fast-performance-demo files:
```
cd /vagrant
```

## Docker

Note: if you are using a virtual machine (VM) then see the notes above; make sure
you are interacting with docker IN the VM (i.e. after `vagrant ssh`).

### Introduction

[Docker](https://docs.docker.com/) is a system that allows applications to be
packaged up (as "images") and run on other machines (as "containers"), complete
will all their dependencies (e.g. libraries, files, etc.). These images are much
more portable and run more consistently than a standalone application (i.e.
executable file).

This system comprises five processes, each in it own container:
- `musiccodes` - the main musiccodes web server
- `meld` - the MELD web server
- `meld-client` - serves the MELD user interface
- `mpm` - the Music Performance Manager (MPM) web server
- `redis` - runs a Redis database (used by mpm)

The docker configuration is all in [../docker-compose.yml](../docker-compose.yml).
This is a [docker-compose](https://docs.docker.com/compose/) file. It tells docker
to run the five containers listed above.

### Checking processes

You can check which containers are running with 
```
docker ps
```
If the system is running correctly you should see the five processes listed above
(musiccodes, meld, meld-client, mpm, redis).

You can check which containers are either running or have died with
```
docker ps -a
```

If there are processes listed but some have died then there may be a specific
problem with that process - try checking its log output (below).

If there are no processes listed then you need to bring up all the containers 
(below).

### Checking a single process

You can check the log/debug output of a process with
```
docker logs NAME
```
Note that the names used with `docker` (rather than `docker-compose`)
are longer, e.g. `vagrant_musiccodes_1` rather than `musiccodes`.

E.g. `docker logs vagrant_musiccodes_1` should show the log/debug output
of the musiccodes process.

You can get more details about how the process is set up in docker with
```
docker inspect NAME
```
Potentially you can find information here about which network ports are
being used and which file volumes are being shared with the process.

### Permanently starting/stopping all processes

In the `fast-performance-demo` directory (in a Vagrant VM this
will be `/vagrant`) you can create and start all the processes with
```
docker-compose up -d
```
stop and destroy all the processes with
```
docker-compose down
```

### Temporarily starting/stopping processes

Again, in the `fast-performance-demo` directory (in a Vagrant VM this
will be `/vagrant`) you can create and start all the processes with
```
restart all the processes with
```
docker-compose restart
```

stop all the processes (or one process) with
```
docker-compose stop
docker-compose stop NAME
```
or start all the processes (or one process) with
```
docker-compose start
docker-compose start NAME
```
Note that the names used with `docker-compose` are just `musiccodes`, 
`meld`, `meld-client` and `mpm`.

### Checking the network

A simple network check to see if you have Internet access:
see if you can contact (e.g.) a google server:
```
ping 8.8.8.8
```

To see if DNS is working:
```
ping www.google.com
```
check if it prints a line with an IP address (like '1.2.3.4').
If not there is a DNS problem.

## Process-specific checks

### Musiccodes

If there is no experience file visible when you open the musiccodes
editor then check in `volumes/experiences`. 

If the file is there then restart musiccodes (or all processes).

If the file is not there then re-run setup (in the 
`fast-performance-demo` directory, or `/vagrant`):
```
./scripts/setup.sh
```

### MELD

To get the logs out of the MELD container run
```
./scripts/getmeldsessions.sh
```

### Music Performance Manager

If there is no configuration file option in the MPM dashboard
then check in `volumes/templates`.

If the file is there then restart mpm (or all processes).

If the file is not there then re-download it from the music hub
and copy it into that directory. 

Then reload the MPM dashboard in the web browser.
