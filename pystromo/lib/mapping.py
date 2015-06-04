"""
	Stuff to do with keypresses, and mapping them to others.
"""

import time

from config import _BaseConfig
import constants as const

class Mapper (_BaseConfig):
	"""
		Parses and stores keypress re-mappings loaded from config files.
	"""
	def __contains__ (self, key):
		"""
			Whether or not we have a mapping for the given key or
			key combination.
			The passed-in parameter can be either a string value or a Key
			instance representing a single key, or an iterable of such
			objects. If a an iterable is given only an exact match is
			sought, a single value will match any mapping whose input
			contains that value.
		"""
		if isinstance(key, basestring):
			key = Key(key)
		
		if isinstance(key, Key):
			# Search for any mapping which contains the key
			for modeMaps in self.mappings.itervalues():
				for maps in modeMaps.itervalues():
					for input in maps.iterkeys():
						if key in input:
							return True
			
		else:
			# Search for a mapping for this exact key
			key = KeyChord(key)
			for modeMaps in self.mappings.itervalues():
				for maps in modeMaps.itervalues():
					if key in maps.iterkeys():
						return True
			
		return False
		
	
	def deviceContains (self, key, device=None, modes=None):
		"""
			Returns whether or not we have a mapper for the given key or
			key-chord.
			The passed-in key parameter can be either a string value or
			a Key instance representing the single key, or an iterable of
			such objects. If an iterable is given, only an exact match is
			sought; a single value will match any mapping whose input
			contains that value.
			If modes is specifed, it should be a set of mode key-strings
			and will be required to be a superset of an mapping modes.
		"""
		if isinstance(key, basestring):
			key = Key(key)
		
		if device not in self.mappings:
			# Nothing specific to the device; use generics
			return self.deviceContains(key, device=None, modes=modes)
		
		mappings = self.mappings[device]
		
		if modes is not None:
			# Convert mode-strings to const.*
			modes = set(getattr(const, string) for string in modes)
		
		if isinstance(key, Key):
			# Search the given device for a mapping which contains the key
			for mode, modeMappings in mappings.iteritems():
				if modes is not None and not modes.issuperset(mode):
					continue
				for input in modeMappings.iterkeys():
					if key in input:
						return True
			
		else:
			# Search for a mapping for this exact key
			key = KeyChord(key)
			for mode, modeMappings in mappings.iteritems():
				if modes is not None and not modes.issuperset(mode):
					continue
				if key in modeMappings.iterkeys():
					return True
				
			
		
		if device is not None:
			# Try the generic case
			return self.deviceContains (key, device=None, modes=modes)
		else:
			return False
		
	
	def clear (self):
		_BaseConfig.clear(self)
		
		# This maps device names to the parameters used to match the device.
		self.devices = {}
		# This is firstly indexed by device name (or None),
		# secondly by the tuple of modes
		# and thirdly by the input, or input chord.
		self.mappings = {None:{():{}}}
		
	
	def load (self, filenames):
		"""
			Loads in and parses out configuration and mapping data from the
			given list of filenames.
		"""
		_BaseConfig.load(self, filenames)
		
		for section in self._parser.sections():
			if section.lower().startswith('device:'):
				self._loadDeviceSection(section)
				
			elif section.lower().startswith('map:'):
				# Store (maybe) device-specific mappings
				self._loadMapSection(section)
				
			else:
				raise ValueError ('Invalid section: %s' % section)
			
		
	
	def _loadDeviceSection(self, section):
		"""
			Parses the items in the config section with the given name as
			parameters for matching a device.
		"""
		null, name = section.split(':', 1)
		items = {}
		for key, value in self._parser.items(section):
			try:
				# Convert numerical values to ints
				# The 0 tells int to guess at the numeric base.
				items[key] = int(value, 0)
			except ValueError:
				# Not a numeric value, so use the string
				items[key] = value
		self.devices[name] = dict(items)
		
	
	def _loadMapSection (self, section):
		"""
			Parses the items in the config section with the given name as
			remapping strings; input=output pairs.
		"""
		# We don't care about any spaces.
		null, name = section.replace(' ', '').split(':', 1)
		# Extract applicable mode, if any
		name = name.split('+', 1)
		if len(name) == 1:
			name = name[0]
			modes = ()
		else:
			name, modeString = name
			# Convert modeString into mode-codes
			modes = []
			for mode in modeString.split('+'):
				try:
					modes.append(getattr(const, mode))
				except AttributeError:
					raise ValueError ('Invalid mode: %s' % mode)
			modes = tuple(modes)
		
		if not name:
			# Generic device
			name = None
		
		if name not in self.mappings:
			self.mappings[name] = {}
		if modes not in self.mappings[name]:
			self.mappings[name][modes] = {}
		target = self.mappings[name][modes]
		
		# We convert all the stuff from the file to ReMapping objects
		for input, output in self._parser.items(section):
			# input may be multiple (comma-seperated) values
			for singleInput in input.split(','):
				remap = ReMapping (singleInput, output)
				target[remap.input] = remap
				
		
	
	def remap (self, chord, device=None, modes=set()):
		"""
			Returns the output relevant to the given keys, device and modes.
			Will return None if there is no relevant remapping.
		"""
		mappings = self.mappings
		if device not in mappings:
			# Nothing specific to the device; use generics
			return self.remap(chord, device=None, modes=modes)
		
		chord = KeyChord(chord)
		
		remapping = self._findChord(mappings[device], chord, modes=modes)
		
		if remapping is None:
			if device is not None:
				# Try the generic mapping
				return self.remap(chord, device=None, modes=modes)
			else:
				return None
		
		# Provide an output tailored to the value of the chord, if necessary.
		inMin = remapping.input.min
		inMax = remapping.input.max
		if None not in (inMin, inMax, chord.min) and chord.min == chord.max:
			if inMin == inMax:
				# Would be a zero division
				position = 0
			else:
				position = float(chord.min - inMin) / (inMax - inMin)
			return remapping.output.deepcopy(position=position)
			
		else:
			return remapping.output
		
	
	def _findChord (self, mapDict, chord, modes=set()):
		"""
			Returns the first entry in the given mapDict which matches the
			given key-chord and mode key-strings (default no mode), or None
			if no entry matches.
		"""
		# Work out the order in which to check modes
		mapModes = mapDict.keys()
		mapModes.sort(key=len, reverse=True)
		# Reformat the passed-in list of modes
		modes = set(getattr(const, string) for string in modes)
		for mode in mapModes:
			if modes.issuperset(mode):
				# The required modes are all present
				for input, output in mapDict[mode].iteritems():
					if input == chord:
						return output
		
		return None
		
	


class ReMapping (object):
	"""
		Initialised with an input and output string, likely from a mappings
		file, this class consistently converts the values, and makes them
		available as its input and output attributes.
	"""
	def __init__ (self, input, output=None):
		"""
			If no output is given, the input is used in it's stead.
		"""
		if output is None:
			output = input
		self.input = self.decodeInput(input)
		self.output = self.decode(output)
		
	
	def __repr__ (self):
		return '<%s %s>' % (self.__class__.__name__, str(self))
	
	def __str__ (self):
		# Convert all the lists and tuples and things to strings
		input = '+'.join(repr(key) for key in self.input)
		return '%s:%s' % (input, str(self.output))
		
	
	def decode (self, string):
		"""
			Decodes a configuration string into something more useful.
		"""
		"""
			The resultant data structure is a KeyCycle of
			KeySequence-tuples of KeyCombo-tuples.
			Each combo-tuple represents simultaneous keypresses, or a
			combo-tuple may contain a single integer value representing
			a pause between keypresses, or a single None value representing
			non-action.
		"""
		if isinstance(string, Key):
			# Not actually a string, just a single key
			return KeyCycle([KeySequence([KeyCombo([string])])])
		
		result = []
		cycleStrings = string.upper().split('.')
		for cycle in cycleStrings:
			sequenceStrings = cycle.split(',')
			sequence = []
			for combo in sequenceStrings:
				combo = combo.strip()
				if not combo or combo == 'NONE':
					# Neutralising a keycode/combination
					combo = None
					
				elif combo.isdigit():
					# This is a pause
					combo = int(combo)
					
				else:
					# Break apart the combo
					notes = combo.split('+')
					combo = tuple()
					# Then put it back together
					for note in notes:
						note = note.strip()
						if note.isdigit():
							note = int(note)
						else:
							note = self.stringToKey(note)
						combo += (note,)
						
					combo = KeyCombo(combo)
					
				sequence.append(combo)
			
			result.append(KeySequence(sequence))
		
		return KeyCycle(result)
		
	
	def stringToKey (self, string):
		"""
			Converts the given string to a single Key object.
		"""
		# Check for value-matching character
		minValue = None
		maxValue = None
		if '@' in string:
			# A value, or range of values, has been specified.
			string, values = string.split('@')
			values = values.split('~')
			if len(values) == 1:
				minValue = maxValue = int(values[0])
				
			else:
				minValue = int(values[0])
				maxValue = int(values[1])
			
		elif '>' in string:
			# Minimum value
			string, minValue = string.split('>')
			if minValue.isdigit():
				minValue = int(minValue) + 1
			else:
				minValue = 1
			
		elif '<' in string:
			# Maximum value
			string, maxValue = string.split('<')
			if maxValue.isdigit():
				maxValue = int(maxValue) - 1
			else:
				maxValue = -1
			
		if not hasattr(const, string):
			# A code we don't understand
			raise ValueError ('"%s" is an invalid code' % string)
		
		return Key(string, min=minValue, max=maxValue)
		
	
	def decodeInput (self, string):
		"""
			Decodes an *input* string into something more useful. This
			is different from the standard (output) decode because there
			are more restrictions on inputs (eg. no sequences).
		"""
		if isinstance(string, Key):
			# Not actually a string, just a single key
			return KeyCombo([string])
		
		# Inputs can't have sequences in them
		if ',' in string:
			raise ValueError ('invalid input mapping: "%s"' % string)
		
		# Standard decode always returns a cycle of sequences.
		# We're only interested in the very first value.
		result = KeyChord(self.decode(string)[0][0])
		return result
		
	



class Key (object):
	"""
		Represents a single input key with a value-range parameters.
	"""
	def _getString(self):
		return self._string
	string = property(fget=_getString)
	
	def _getMin(self):
		return self._min
	min = property(fget=_getMin)
	
	def _getMax(self):
		return self._max
	max = property(fget=_getMax)
	
	
	def __init__(self, string, min=None, max=None):
		if isinstance(string, Key):
			if min is None:
				min = string.min
			if max is None:
				max = string.max
			string = string.string
			
		self._string = string
		self._min = min
		self._max = max
		if min == max:
			self.value = min
		else:
			self.value = None
		self.type, self.code = getattr(const, string)
		
	
	def __hash__ (self):
		return hash((self._string, self._min, self._max))
	
	def __repr__ (self):
		return '%s@%s~%s' % (str(self._string), str(self._min), str(self._max))
	
	def __str__ (self):
		return self.string
	
	def __eq__ (self, other):
		if self is other:
			return True
		try:
			return (self._string == other._string) \
					and (self._min == other._min) \
					and (self._max == other._max)
			
		except AttributeError:
			return NotImplemented
		
	
	def __contains__ (self, other):
		"""
			Checks for string equality, and whether the other Key's range
			is *entirely* within this key's range.
		"""
		try:
			if self._string != other._string:
				return False
			
			if self._min is None and self._max is None:
				# Anything goes
				return True
			
			# We don't know what to do if the other's value/range is unspecified!
			if other._min is None or other._max is None:
				raise ValueError ("Can't check for containment of unlimited Key: %s" % repr(other))
			
			if (self._min is None or self._min <= other._min) \
					and (self._max is None or self._max >= other._max):
				return True
				
			else:
				return False	
			
		except AttributeError:
			return NotImplemented
		
	
	def copy(self, position=None):
		"""
			Returns a new copy of the Key.
			The position parameter, if given, determines how far into this
			key's min-max range the new Key object should be. This Key
			*must* have numeric min and max attributes to utilise the
			position parameter.
		"""
		if None in (position, self.max, self.min):
			return Key(self)
		# Given a position, we need to work out where
		# in the original key's range the new key should be.
		value = int((self.max - self.min) * position) + self.min
		return Key(string=self.string, min=value, max=value)
		
	


class KeyChord (tuple):
	"""
		Represents a non-ordered combination of keypresses.
		Intended primarily for matching input against mappings.
	"""
	def __new__ (cls, chord):
		return tuple.__new__(cls, sorted(chord))
	
	def __init__ (self, *args, **kwargs):
		tuple.__init__(self, *args, **kwargs)
		
		self.min = None
		self.max = None
		self.value = None
		
		# Work out the range of values for this chord
		min = 0
		max = 0
		hasRange = False
		for note in self:
			if note.min is not None and note.max is not None:
				hasRange = True
				min += note.min
				max += note.max
		if hasRange:
			self.min = min
			self.max = max
			if min == max:
				self.value = min
		
	
	def __contains__ (self, other):
		# Key objects implement __contains__ for other Key objects.
		for note in self:
			if other in note:
				return True
		return False
		
	
	def __eq__ (self, other):
		if not isinstance(other, KeyChord):
			return NotImplemented
		if len(self) != len(other):
			return False
		# Make sure each in other is in self
		for key in other:
			if key not in self:
				return False
		return True
		
	
	def deepcopy(self, *args, **kwargs):
		# Chords only contain keys
		return KeyChord(item.copy(*args, **kwargs) for item in self)
	

class KeyCombo (tuple):
	"""
		Represents a combination of simultaneous (though ordered) keypresses.
		This is for output combinations, rather than input chords.
	"""
	def __init__ (self, *args, **kwargs):
		tuple.__init__(self, *args, **kwargs)
		
		self.min = None
		self.max = None
		self.value = None
		
		# Work out the range of values for this combo
		min = 0
		max = 0
		hasRange = False
		for key in self:
			if not isinstance(key, Key):
				continue
			if key.min is not None and key.max is not None:
				hasRange = True
				min += key.min
				max += key.max
		if hasRange:
			self.min = min
			self.max = max
			if min == max:
				self.value = min
		
	
	def __nonzero__ (self):
		# We are zero only if we contain no Keys
		for key in tuple.__iter__(self):
			if isinstance(key, Key):
				return True
		return False
		
	
	def deepcopy(self, *args, **kwargs):
		# We can contain keys or integers
		newCopy = []
		for item in self:
			if isinstance(item, Key):
				item = item.copy(*args, **kwargs)
			newCopy.append(item)
			
		return KeyCombo(newCopy)
		
	


class KeySequence (tuple):
	"""
		Represents a sequence of keypresses and/or pauses.
		Uses a SequenceIterator.
	"""
	def __str__ (self):
		output = []
		for combo in tuple.__iter__(self):
			if combo is None or isinstance(combo, (int, long)):
				output.append(str(combo))
			else:
				output.append('+'.join(str(key) for key in combo))
			
		return ','.join(output)
		
	
	def __nonzero__ (self):
		# We are zero only if all our KeyCombo members are also zero.
		for combo in tuple.__iter__(self):
			if isinstance(combo, KeyCombo) and combo:
				return True
		return False
		
	
	def __iter__ (self):
		"""
			Iterates through the output, yielding one entry at a time.
			If we are in a state of pausation, None is yielded.
		"""
		return SequenceIterator(self)
	
	def deepcopy(self, *args, **kwargs):
		# We can contain KeyCombos, integers and Nones
		newCopy = []
		for item in tuple.__iter__(self):
			if isinstance(item, KeyCombo):
				item = item.deepcopy(*args, **kwargs)
			newCopy.append(item)
			
		return KeySequence(newCopy)
		
	


class KeyCycle (tuple):
	"""
		Represents a cycle of key sequences, which repeats indefinitely.
	"""
	def __init__ (self, *args, **kwargs):
		tuple.__init__(self, *args, **kwargs)
		
		self.current = -1
		
	
	def __nonzero__ (self):
		# We are zero only if all our KeySequence members are also zero.
		for sequence in tuple.__iter__(self):
			if isinstance(sequence, KeySequence) and sequence:
				return True
		return False
		
	
	def getIter (self):
		"""
			Returns an iterator for the current sequence in the cycle
			(as determined by the 'current' attribute).
		"""
		try:
			iterator = iter(self[self.current])
		except IndexError:
			self.current = 0
			# If this one errors, just let the exception raise
			iterator = iter(self[0])
		
		return iterator
		
	
	def deepcopy (self, *args, **kwargs):
		# We can only contain KeySequences
		return KeyCycle(item.deepcopy(*args, **kwargs) for item in self)
	


class SequenceIterator (object):
	"""
		A custom iterator for KeySequence objects.
		Will iterate through the given sequence repeatedly (until the repeat
		attribute evaluates to False). Numerical values will be treated as
		a delay which causes, until the relevant number of milliseconds have
		passed, the iterator not to progress, and only return None.
	"""
	def __init__ (self, sequence):
		# This is what we iterate over
		self.sequence = sequence
		# This determines whether we should loop the iterator
		self.repeat = True
		# This is the number of the loop we're on
		self.count = 0
		
		# Make our next method the generator's next!
		## There must be a better way of making an iterator's next method!
		self.next = self.next().next
		
	
	def __iter__ (self):
		return self
		
	
	def next (self):
		getTime = time.time
		sequence = self.sequence
		
		# We do this, rather than while self.repeat, to loop at least once.
		while True:
			self.count += 1
			## BUG: If we are a tuple of only very small (~1) numerical
			## values, we may loop forever without yielding anything!
			for item in tuple.__iter__(sequence):
				if isinstance(item, (int, long)):
					# Pause for the desired amount of time before moving on.
					nextTime = getTime() + (item / 1000.0)
					while getTime() < nextTime:
						yield None
				else:
					yield item
				
			
			if not self.repeat:
				break
			
		raise StopIteration
		
	
