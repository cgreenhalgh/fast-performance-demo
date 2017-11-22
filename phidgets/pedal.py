#!/usr/bin/env python

"""Copyright 2010 Phidgets Inc.
This work is licensed under the Creative Commons Attribution 2.5 Canada License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by/2.5/ca/
"""

__author__ = 'Adam Stelmack'
__version__ = '2.1.8'
__date__ = 'May 17 2010'

URL = "http://127.0.0.1:3000/input"
INPUTNAME = "pedal"
INPUT2NAME = "pedal.back"

#Basic imports
from ctypes import *
import sys
import random
import httplib
import urllib
import urllib2
import datetime
import time

#Phidget specific imports
from Phidget22.PhidgetException import *
#from Phidget22.Events import *
from Phidget22.Devices.DigitalInput import *
from Phidget22.Phidget import *

#Create an interfacekit object
try:
    interfaceKit = DigitalInput()
except RuntimeError as e:
    print("Runtime Exception: %s" % e.details)
    print("Exiting....")
    exit(1)

#Event Handler Callback Functions
def interfaceKitAttached(e):
    #attached = e.device
    print("Pedal Attached!")

def interfaceKitDetached(e):
    #detached = e.device
    print("Pedal Detached!")

def interfaceKitError(e):
    try:
        source = e.device
        print("InterfaceKit %i: Phidget Error %i: %s" % (source.getSerialNum(), e.eCode, e.description))
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))

lastpress = {}

def dopost(url, inputname):
    global lastpress
    now = datetime.datetime.now()
    if inputname in lastpress.keys():
        delta = (now - lastpress[inputname]).total_seconds()
        if (delta < 0.5):
            print "Suppress post of %s after %f seconds" % ( inputname, delta )
            return
    lastpress[inputname] = now
    try:
        body = urllib.urlencode({ 'name': inputname })
        res = urllib2.urlopen(url, body)
        print "Post %s to %s - %d" % (inputname, url, res.getcode())
    except urllib2.URLError as e:
        print "Error doing post! url error %s %s" % (url, e.reason)
    except urllib2.HTTPError as e:
        print "Error doing post! http error %s %d:%s" % (url, e.code, e.reason)
    except Exception as e:
        print "Error doing post!"
        print e



def interfaceKitInputChanged(dd, state):
    global URL
    #source = e.device
    print("Input %d", state)
    if (state == True ):
        print("Press!")
        dopost(URL, INPUTNAME)
    #if (e.index == 1 and e.state == True ):
    #    print("Back!")
    #    dopost(URL, INPUT2NAME)

if (len(sys.argv)>=2):
    URL = sys.argv[1];
print "Posting to URL %s" % (URL)

#Main Program Code
try:
	#logging example, uncomment to generate a log file
    #interfaceKit.enableLogging(PhidgetLogLevel.PHIDGET_LOG_VERBOSE, "phidgetlog.log")
	
    interfaceKit.setOnAttachHandler(interfaceKitAttached)
    interfaceKit.setOnDetachHandler(interfaceKitDetached)
    interfaceKit.setOnErrorHandler(interfaceKitError)
    interfaceKit.setOnStateChangeHandler(interfaceKitInputChanged)
    # 0 -> press 
    # TODO: 1 -> back
    interfaceKit.setChannel(0)

    #interfaceKit.setOnOutputChangeHandler(interfaceKitOutputChanged)
    #interfaceKit.setOnSensorChangeHandler(interfaceKitSensorChanged)
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    print("Exiting....")
    exit(1)

print("Opening phidget object....")
print("Waiting for InterfaceKit to attach....")

try:
    interfaceKit.openWaitForAttachment(1000*60*60*24)
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    try:
        interfaceKit.closePhidget()
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))
        print("Exiting....")
        exit(1)
    print("Exiting....")
    exit(1)

print("Running....")

while True:
    time.sleep(10)

print("Closing...")

try:
    interfaceKit.closePhidget()
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    print("Exiting....")
    exit(1)

print("Done.")
exit(0)
