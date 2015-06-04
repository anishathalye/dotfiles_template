"""
	Wrappers around various ioctl functionality, for use with the
	USB input remapper.
	
	Especially useful top-level functions:
		getInputFiles
		getOutputFile
		grabDevices
"""

import os
import fcntl
import struct

import constants as const


def getInputNodes ():
	"""
		Returns a list of IONode objects for all the filesystem device nodes
		which we could use as input.
	"""
	from glob import glob
	
	devices = []
	for pattern in const.INPUT_PATHS:
		for node in glob(pattern):
			try:
				fd = IONode(node)
			except OSError:
				#info = sys.exc_info()
				#print 'Unable to open %s: %s' % (event, str(info[1]))
				continue
			devices.append(fd)
			
	return devices
	

def matchInputNodes (name=None, bus=None, vendor=None, product=None, version=None):
	"""
		Returns a list of IONode objects for all the device nodes which match
		the given parameters.
	"""
	inputs = []
	for fd in getInputNodes():
		# This is the most readable way of doing this I can think of.
		# We run through checks to see if fd is invalid,
		# rather than checking validity explicitly.
		if name and fd.name != name:
			pass
		elif bus and fd.bus != bus:
			pass
		elif vendor and fd.vendor != vendor:
			pass
		elif product and fd.product != product:
			pass
		elif version and fd.version != version:
			pass
		else:
			# All invalidity checks failed
			inputs.append(fd)
			continue
		
		# Clean up unwanted files
		fd.close()
		
	
	return inputs
	


class IONode (object):
	"""
		Represents an IO device node.
	"""
	def __init__ (self, fd):
		"""
			The fd can either be a string filename, an integer file-number,
			or an object with a fileno method.
		"""
		if isinstance(fd, (int, long)):
			# This is good
			pass
		elif isinstance(fd, basestring):
			fd = self._open(fd)
		else:
			fd = fd.fileno()
		
		self.fd = fd
		
		# Collect various items of information about the node
		self.bus, self.vendor, self.product, self.version = self.getId()
		self.name = self.getName()
		# Which events this node supports
		self.events = {}
		for type in self.getEventSupport():
			self.events[type] = list(self.getEventSupport(type))
		
	
	def _open(self, fd):
		"""
			Opens the given file descriptor with some default arguments:
			os.O_RDWR | os.O_NONBLOCK
		"""
		return os.open(fd, os.O_RDWR | os.O_NONBLOCK)
		
	
	def close(self):
		os.close(self.fd)
	
	def fileno(self):
		return self.fd
	
	def flush(self):
		pass
	
	def read(self, length):
		"""
			Reads (up to) the given number of bytes from the node.
		"""
		try:
			return os.read(self.fd, length)
		except OSError:
			# No data to read - probably...
			return ''
		
	
	def write(self, data):
		"""
			Writes the given string-data to the node.
		"""
		return os.write(self.fd, data)
		
	
	def getId (self):
		"""
			Returns a tuple of device identification information.
			The information returned is a 4-tuple of:
				(busType, vendorId, productId, version)
		"""
		vals = fcntl.ioctl(self.fd, const.EVIOCGID, const.EVIOCGID_BUFFER)
		return struct.unpack(const.EVIOCGID_FORMAT, vals)
		
	
	def getName (self):
		"""
			Returns the textual 'name' of the device node.
		"""
		name = fcntl.ioctl (self.fd, const.EVIOCGNAME_512, const.EVIOCGNAME_512_BUFFER)
		# Even though we remove null characters, some devices
		# (I'm looking at you "Honey Bee  Nostromo SpeedPad2 ")
		# may have trailing spaces in the device name.
		return name.strip('\0')
		
	
	def getAbsStatus (self, code):
		"""
			Returns the current status of the absolute axis identified by
			the given code.
			Returns a tuple of (value, min, max, fuzz, flat). Fuzz is the
			error range for values (where close values can be interpreted
			as the same), and flat is a range of values around the mid-point
			(the 'dead zone').
		"""
		values = fcntl.ioctl(self.fd, const.EVIOCGABS + code, const.EVIOCGABS_BUFFER)
		values = struct.unpack(const.EVIOCGABS_FORMAT)
		return values
		
	
	def getEventSupport(self, type=None):
		"""
			Returns a list of the event codes supported by the this node,
			for the given type. If no type is given (or is zero), the list
			of types supported by the node is returned.
		"""
		if type is None:
			# Not specified, so we use 0
			type = 0
		elif type == 0:
			# A zero-type is EV_SYN, which doesn't have any codes
			return []
		
		try:
			values = fcntl.ioctl(self.fd, const.EVIOCGBIT_512 + type, const.EVIOCGBIT_512_BUFFER)
		except IOError:
			# Probably an unsupported operation for this device!
			return []
		values = struct.unpack(const.EVIOCGBIT_512_FORMAT, values)
		
		codes = []
		valueSize = struct.calcsize(const.EVIOCGBIT_512_FORMAT[0])
		for valueNum, value in enumerate(values):
			if not value:
				continue
			for bit in xrange(valueSize * 8):
				# The smallest bit of the value indicates support for a code.
				if value & 1:
					codes.append(bit + (8 * valueSize * valueNum))
				# Shift so that the next test uses the next bit of the value.
				value >>= 1
			
		return codes
		
	
	def grab (self, grab=1):
		"""
			Grabs all input from this node, so nothing else can read it.
			Using the 'grab' parameter, you can specify whether to grab (1)
			or ungrab (0) the node. The default is to grab.
		"""
		fcntl.ioctl(self.fd, const.EVIOCGRAB, grab)
		
	
	def ungrab (self):
		"""
			Ungrabs input from this node, so other processes can read it.
			This is just a wrapper around grab(0).
		"""
		self.grab(0)
		
	


class OutputNode (IONode):
	"""
		Represents the device node to which events will only be sent.
	"""
	def __init__(self):
		for loc in const.UINPUT_DEVICES:
			try:
				self.fd = self._open(loc)
			except OSError:
				continue
			# Successfully opened, so we use this one
			break
		else:
			raise LookupError ('no uinput device-nodes found')
		
		# The types of events we support outputting
		self.events = [const.EV_KEY, const.EV_REL, const.EV_ABS]
		
		# Init the 'device' we'll output as
		self.createDevice()
		
	
	def _open(self, fd):
		"""
			Opens the given file descriptor with some default arguments:
			OS.O_WRONLY | os.O_NONBLOCK
		"""
		# Is nonblock necessary?
		return os.open(fd, os.O_WRONLY | os.O_NONBLOCK)
		
	
	def close(self):
		self.destroyDevice()
		IONode.close(self)
		
	
	def read(self, length):
		# No reading, thankyou
		pass
		
	
	def createDevice (self):
		"""
			Creates a fake 'device' on the output node, which we will appear
			to be.
		"""
		# Write custom device info
		USER_DEVICE_FORMAT = "80sHHHHi" + 'I'*64*4
		# These are: device name, bus type, vendor, product, version, ff_effects_max
		USER_DEVICE_DATA = [
				"Pystromo Input Remapper",
				const.BUS_USB,
				1,
				1,
				1,
				0,
				]
		# This handles absmax, absmin, absfuzz and absflat
		## I actually don't know why there's so many of them.
		USER_DEVICE_DATA += [0] * 64*4
		
		os.write(self.fd, struct.pack(USER_DEVICE_FORMAT, *USER_DEVICE_DATA))
		
		# Set the event bits
		UI_SET_EVBIT = 0x40045564
		# Register all the event type/codes we may want to output
		for eType in self.events:
			fcntl.ioctl(self.fd, UI_SET_EVBIT, eType)
			# We register all the codes we know
			for code in const.CODES[eType]:
				fcntl.ioctl(self.fd, UI_SET_EVBIT + eType, code)
		
		# Create the device
		UI_DEV_CREATE  = 0x5501
		fcntl.ioctl(self.fd, UI_DEV_CREATE)
		
	
	def destroyDevice (self):
		"""
			"Destroy" the device previously created on a the uinput node.
			NB. I have no idea if this is at all necessary...
		"""
		UI_DEV_DESTROY = 0x5502
		fcntl.ioctl(self.fd, UI_DEV_DESTROY)
	
