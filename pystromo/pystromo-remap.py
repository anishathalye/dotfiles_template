#!/usr/bin/env python
"""
	Takes input from items of (USB) hardware,
	and remaps the keystrokes to something else.
"""
"""
	Copyright 2007; Mel Collins <mel@raumkraut.net>
	This program is distributed under the terms of the GPL
	(I'll put the proper header in here later)
"""

import os
import time
import signal
from optparse import OptionParser

from lib import mapping
from lib import devices


############################################################
# Initialisation

## Ideally, I'd like an arbitrary number of values allowable
## for map arguments, but the feature isn't in optparse (yet?).

optParser = OptionParser()
## Previous conf functionality has been subsumed into mapping files.
## I'm leaving this here so that I don't have to re-write it if/when
## non-mapping configurations rear their heads.
#optParser.add_option('-c', '--conf',
#		dest='confs', metavar="FILE", action='append',
#		help='Use settings from the given file',
#		)
optParser.add_option('-m', '--map',
		dest='maps', metavar="FILE", action='append',
		help="Use mappings from the given file",
		)
optParser.add_option('-v', '--verbose', dest='verbose', action='count',
		help="Will print out some information about found devices, etc. Use this option twice to print information about all incoming events, and three times (!) to display outgoing events.",
		)
optParser.add_option('-R', '--reload', dest='reload', action='store_true',
		help="Tells the program to monitor the mapping file/s for changes (based on the files' ctime), and reload them if they have been modified. Checks will only be made while the program is otherwise idle.",
		)
optParser.set_defaults(verbose=False, reload=False)

options, args = optParser.parse_args()


# Set up output device
output = devices.OutputDevice()
if options.verbose:
	print 'Using output: %s' % str(output)

# Grabbing the input devices are handled on the first main-loop iteration.

def loadMappings ():
	"""
		Loads and returns the Mapper object.
	"""
	global options
	if options.verbose:
		print 'Loading mappings'
		if options.verbose > 1:
			print '; '.join(options.maps)
	
	if options.maps:
		return mapping.Mapper(*options.maps)
	else:
		# Empty (pass-through) mapper
		return mapping.Mapper()

def getFileTimes():
	"""
		Returns a tuple of last-modification times for each of the used
		mapping-config files.
	"""
	global options
	result = []
	for filename in options.maps:
		if os.path.exists(filename):
			result.append(os.stat(filename).st_ctime)
		else:
			# File doesn't exist, or we can't access it
			result.append(None)
	
	return tuple(result)


def getInputs(keymap, output):
	"""
		Acquires all the input devices for the given keymap, and returns
		them in a list.
		The output parameter will be passed through to the InputDevice.
	"""
	inputs = []
	for device, params in keymap.devices.iteritems():
		dev = devices.InputDevice(id=device, keymap=keymap, output=output, **params)
		inputs.append(dev)
		
		if options.verbose:
			print 'Using device: %s' % str(dev)
	return inputs

def releaseInputs(inputs):
	"""
		Releases control (ie. closes) all the passed-in inputs
	"""
	for device in inputs:
		device.close()


############################################################
# Signal handling setup

def shutdown (sigNo=None, frame=None):
	"""
		Initiates the shutdown process.
	"""
	global inputs, quitting
	if not quitting:
		quitting = True
		releaseInputs(inputs)
	

def quit (sigNo=None, frame=None):
	"""
		Stops the main loop at the end of this iteration,
		even if some devices are in the middle of a sequence.
	"""
	global looping, quitting
	looping = False
	quitting = True
	

def reloadConfig (sigNo=None, frame=None):
	"""
		Sets flags to make the config be reloaded on the next loop.
	"""
	global loadConfig
	loadConfig = True
	

signal.signal(signal.SIGINT, shutdown)
signal.signal(signal.SIGQUIT, quit)
signal.signal(signal.SIGHUP, reloadConfig)


############################################################
# Main

if options.reload:
	# Time between checks for file changes.
	blockTime = 2.0
	fileTimes = getFileTimes()
else:
	blockTime = None
	fileTimes = None

looping = True
quitting = False
loadConfig = True
inputs = []
while looping:
	if loadConfig:
		# We release all inputs, then reaquire them.
		# This could be replaced with a more efficient mechanism.
		releaseInputs(inputs)
		keymap = loadMappings()
		inputs = getInputs(keymap, output)
		loadConfig = False
	
	busyDevices = list(device for device in inputs if device.busy)
	# Crude way of cutting down on CPU usage :/
	## This also prevents some events being interpreted (by X11) out of
	## sequence, I guess because of small timestamp differentials.
	if busyDevices:
		time.sleep(0.01)
	
	# Process those events!
	# We should only do a blocking read if no device has anything in it's queue.
	if not (output.busy or busyDevices):
		timeout = blockTime
	else:
		timeout = 0
	
	events = devices.read(timeout)
	if options.reload and timeout and not events:
		# Nothing to do, so check if we need to reload mapping files.
		newTimes = getFileTimes()
		if fileTimes != newTimes:
			fileTimes = newTimes
			loadConfig = True
	
	if options.verbose > 1:
		for event in events:
			print 'Incoming event: %s' % repr(event)
	
	for device in busyDevices:
		events = device.process()
		
		if options.verbose > 2:
			for event in events:
				print 'Outgoing event: %s' % repr(event)
		
	
	# Actually push the events to the uinput device
	output.process()
	
	if quitting:
		# End the loop only if all the devices have finished.
		if not len(busyDevices):
			looping = False
	

# Destroy and close our output
output.close()

