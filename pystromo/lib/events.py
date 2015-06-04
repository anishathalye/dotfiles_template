"""
	Stuff specific to input events.
"""

import time
import struct

import constants as const


class Event (object):
	"""
		Represents a single input event, as received from /dev/input/event*
	"""
	# Event parts: seconds, useconds, type, code, value
	format = 'LLHHi'
	size = struct.calcsize(format)
	## This should probably be in the device object
	buff = '\0' * size
	
	def _getTimestamp(self):
		return self.seconds + (self.useconds / 1000000.0)
	def _setTimestamp(self, stamp):
		self.seconds = int(stamp)
		self.useconds = int((stamp - self.seconds) * 1000000)
	timestamp = property(fget=_getTimestamp, fset=_setTimestamp)
	
	
	def __init__ (self, raw=None, type=None, code=0, value=0, timestamp=None):
		"""
			Accepts either unpacked parameters,
			or raw data direct from the IO stream.
		"""
		if raw is not None:
			self.raw = raw
			self.unpack(raw)
		else:
			if timestamp is None:
				timestamp = time.time()
			self.timestamp = timestamp
			self.type = type
			self.code = code
			self.value = value
			self.pack()
			
		
	
	def __repr__ (self):
		# Don't want to crap out just because we don't have
		# prettification values for some things.
		try:
			type = const.TYPES[self.type]
		except KeyError:
			type = self.type
		try:
			code = const.CODES[self.type][self.code]
		except KeyError:
			code = self.code
		
		params = (
				self.__class__.__name__,
				self.seconds + (self.useconds / 1000000.0),
				type,
				code,
				self.value,
				)
		return '<%s timestamp=%r, type=%r, code=%r, value=%r>' % params
		
	
	def __str__ (self):
		return self.raw
	
	def pack (self):
		"""
			Converts the object's attributes into raw data. The data
			is then both stored as the object's 'raw' attribute, and
			returned.
		"""
		raw = struct.pack(self.format, self.seconds, self.useconds, self.type, self.code, self.value)
		self.raw = raw
		return raw
		
	
	def unpack (self, raw=None):
		"""
			Extracts information from a raw event data string, and stores
			it in relevant attributes. Also returns a tuple of this
			information: (seconds, useconds, type, code, value).
			If the data is not given, the object's own 'raw' attribute
			is used to extract the information from.
		"""
		if not raw:
			raw = self.raw
		tup = struct.unpack(self.format, raw)
		self.seconds, self.useconds, self.type, self.code, self.value = tup
		return tup
		
	
