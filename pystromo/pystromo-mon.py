#!/usr/bin/env python
"""
	Script which monitors the state of the system's running processes,
	starting and stopping the input-remapper script when needed.
"""

import os, sys
import time
import signal
import subprocess
from optparse import OptionParser

from lib import config


# Constants
DAEMON = os.path.abspath(os.path.join(sys.path[0], 'pystromo-remap.py'))
# ~/.config/* is the new hotness.
DEFAULT_CONF = os.path.join(os.path.expanduser('~'), '.config', 'pystromo', 'monitor.conf')


# Set up CLI options.
optParser = OptionParser()
optParser.add_option('-c', '--conf',
		dest='confs', metavar="FILE", action='append',
		help='Use configuration settings from the given file',
		)
optParser.add_option('-a', '--all-users', dest='allUsers', action='store_true',
		help='Check processes for all users, not just the current one.',
		)
optParser.add_option('-v', '--verbose', dest='verbose', action='count',
		help='In verbose mode, will output a status line whenever the input-remapper changes state.',
		)
optParser.add_option('-r', '--reload', dest='reload', action='store_true',
		help="Tells the program to monitor the config file/s for changes (based on the files' ctime), and reload them if they have been modified.",
		)
optParser.add_option('-R', '--reload-remapper', dest='reloadRemapper', action='store_true',
		help="Tells the program to pass the --reload argument to any remapper processes spawned by the monitor.",
		)
optParser.set_defaults(allUsers=False, verbose=False, reload=False, reloadRemapper=False)

options, args = optParser.parse_args()


# Signals
def stopLoop (sigNo=None, frame=None):
	global looping
	looping = False
def reloadConfig (sigNo=None, frame=None):
	global loadConf
	loadConf = True
signal.signal(signal.SIGINT, stopLoop)
signal.signal(signal.SIGQUIT, stopLoop)
signal.signal(signal.SIGHUP, reloadConfig)


def loadConfig ():
	"""
		Loads and returns the config settings object.
	"""
	global options
	if options.confs:
		conf = config.MonitorConfig(*options.confs)
	else:
		conf = config.MonitorConfig(DEFAULT_CONF)
	
	return conf
	

def getConfTimes():
	"""
		Returns a tuple of last-modification times for each of the used
		mapping-config files.
	"""
	global options
	confs = options.confs or [DEFAULT_CONF]
	result = []
	for filename in confs:
		if os.path.exists(filename):
			result.append(os.stat(filename).st_ctime)
		else:
			# File doesn't exist, or we can't access it
			result.append(None)
	
	return tuple(result)
	

def getProcesses (processes, allUsers=False):
	"""
		Returns a dict of; {proc:(PID, command)}, of all running
		processes which match an entry in the given processes list.
		The key, proc, is the entry in the processes list which matched,
		PID is the process ID of the running process, and command is the
		full name of the running process.
		If allUsers is true, will return a list of processes for all
		users, rather than just the current user.
	"""
	if not processes:
		return {}
	
	command = ['ps', '--no-headers', 'x', 'o', 'pid,cmd']
	if allUsers:
		command.append('a')
	ps = subprocess.Popen(command, stdout=subprocess.PIPE).communicate()[0]
	
	running = {}
	for line in ps.split('\n'):
		line = line.strip()
		if not line:
			continue
		
		pid, cmd = line.split(' ', 1)
		
		# Each entry in the processes list is a *subpattern*.
		for proc in processes:
			if proc in cmd:
				running[proc] = (pid, cmd)
		
	return running
	


looping = True
lastProcs = None
daemonProcess = None
# Determines if we need to (re)load the config file/s.
loadConf = True
confTimes = getConfTimes()

while looping:
	# Load the config file if needed
	if loadConf:
		if options.verbose:
			print 'Loading configuration file'
		conf = loadConfig()
		# Update what to look out for
		processes = set(proc for proc, filename in conf.mappings)
		processes.discard(None)
		lastProcs = None
		
		loadConf = False
	
	# Check the running processes
	running = getProcesses (processes=processes, allUsers=options.allUsers)
	running = running.keys()
	if running != lastProcs:
		# Work out all the files we're going to use
		files = []
		for mapping in conf.mappings:
			proc, filename = mapping
			filename = os.path.expanduser(filename)
			
			if proc is None or proc in running:
				files.append(filename)
			
		
		
		# Stop the daemon with the previous settings
		if daemonProcess:
			# Stop the current daemon process
			os.kill(daemonProcess.pid, signal.SIGINT)
			daemonProcess.wait()
			
			# Notify of stoppage only if there's no imminent startage.
			if options.verbose and not files:
				print 'STOPPED'
		
		
		# We only start the daemon if we've got some mapping files.
		if files:
			command = [DAEMON]
			for filename in files:
				command.extend(['-m', '%s' % filename])
			if options.reloadRemapper:
				command.append('-R')
			
			if options.verbose:
				print ' '.join(command)
			
			daemonProcess = subprocess.Popen(command)
			
		else:
			daemonProcess = None
		
		lastProcs = running
	
	if options.reload:
		# Check for config-file modifications
		newTimes = getConfTimes()
		if confTimes != newTimes:
			confTimes = newTimes
			loadConf = True
	
	try:
		time.sleep(1)
	except KeyboardInterrupt:
		looping = False
	

# Cleanup
if daemonProcess:
	os.kill(daemonProcess.pid, signal.SIGINT)
	daemonProcess.wait()
