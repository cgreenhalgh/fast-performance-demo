# Phidgets Install notes


Plug in Phidget interface kit.

If running in VM, in VirtualBox UI open settings for VM, ports, USB, add, select 'Phidgets inc. PhidgetInterfaceKit [...]'

## linux drivers / libraries

Linux see [instructions](http://www.phidgets.com/docs/OS_-_Linux)
```
cd
sudo apt-get install -y libusb-1.0-0-dev 
wget http://www.phidgets.com/downloads/libraries/libphidget.tar.gz
tar zxf libphidget.tar.gz
cd libphidget-*
./configure
make
sudo make install
```

test (only)
```
cd
wget http://www.phidgets.com/downloads/examples/phidget21-c-examples.tar.gz
tar zxf phidget21-c-examples.tar.gz
cd phidget21-c-examples-*
gcc HelloWorld.c -o HelloWorld -lphidget21
sudo ./HelloWorld
```

## Python support

python support [instructions](http://www.phidgets.com/docs/Language_-_Python#Linux)
```
cd
wget http://www.phidgets.com/downloads/libraries/PhidgetsPython.zip
unzip PhidgetsPython.zip
cd PhidgetsPython
sudo python setup.py install
```

python examples
```
cd
wget http://www.phidgets.com/downloads/examples/Python.zip
unzip Python.zip
cd Python
sudo python HelloWorld.py
```


