"""
	Stuff specific to devices
"""

import time
import ioctl
import select

import events
import mapping
import constants as const

# This is a list of all the devices which have been created.
# We use this for the receive() function.
# It is populated by the __init__ of InputDevice instances.
_allInputNodes = {}


def read (timeout=None):
	"""
		Reads all the Devices' device nodes for input.
		If the timeout parameter is None or absent, the read will block
		until it receives something. Otherwise it will block only for a
		maximum of the specified number of seconds. Use a timeout of 0 for
		an immediate return.
	"""
	global _allInputNodes
	devices = _allInputNodes
	try:
		readable, writable, exceptional = select.select(devices.keys(), [], [], timeout)
	except select.error:
		# Quite likely an interrupting signal
		readable, writable, exceptional = [], [], []
	
	events = []
	for dev in readable:
		events.extend(devices[dev].read(dev))
	
	return events
	



class InputDevice (object):
	"""
		An input device.
		Any ol' input device.
		Go on, pick one.
	"""
	
	Event = events.Event
	
	def _getBusy(self):
		"""
			Whether or not this device still has events queued.
		"""
		return bool(self._queue)
		
	busy = property(fget=_getBusy)
	
	
	def __init__ (self, keymap, id=None, output=None, **params):
		"""
			If not specified, the id will be populated by the device's
			detected 'name' parameter (if any).
			The keymap argument should be an instance of mapping.Mapper.
			The keyword arguments are used to determine which device node/s
			to use for this device, and are matched against the information
			gleaned from the nodes themselves. Hence valid kwargs are:
			bus, name, vendor, product, and version.
		"""
		global _allInputNodes
		
		# This is a record of all currently 'down' keystrings, against the
		# Key instance that started it all off.
		self._pressed = {}
		# This is a record of the last-recorded positions of all ABS inputs.
		# The entries are of the same form as self._pressed; string:Key.
		self._absolute = {}
		# This is a set of all the 'on' feedback event key-strings:
		# "LED_*"s, etc.
		self._modes = set()
		# This is a dict of cycles of keypresses which need to be sent
		# out, against an iterator over the relevant sequence in the cycle.
		self._queue = {}
		# This is the set of all cycles which are due to end.
		self._ending = set()
		# This is the set of all cycles which have yet to start
		# This is needed because, for example, EV_REL events start and end
		# at the same time...
		self._starting = set()
		
		
		# Do stuff with device nodes
		nodes = ioctl.matchInputNodes (**params)
		self._nodes = nodes
		for node in nodes:
			# Gimme gimme gimme!
			node.grab()
			# Add our nodes to the module's collection
			_allInputNodes[node] = self
			
			# Zero all the LEDs on this node
			## We will receive events for every LED affected. Problem?
			if const.EV_LED in node.events:
				for led in node.events[const.EV_LED]:
					node.write(str(events.Event(type=const.EV_LED, code=led, value=0)))
			
		# Make room for any partial data we get from our nodes
		self._partialReadData = dict(zip(nodes, [''] * len(nodes)))
		
		if nodes and id is None:
			# Use the name of the first node.
			id = nodes[0].name
		
		# Work out which events should go where
		self._targetDevices = targets = {}
		for evType in const.TYPES:
			if evType in output.node.events:
				targets[evType] = output
			else:
				targets[evType] = self
			
		
		self.keymap = keymap
		self.id = id
		self._outputNode = output
		
		# Shortcuts
		self._remap = lambda chord, **kwargs: self.keymap.remap(chord, device=self.id, **kwargs)
		self._inMap = lambda chord: self.keymap.deviceContains(chord, device=self.id)
		
	
	def __repr__ (self):
		params = (self.__class__.__name__, str(self.id), len(self._nodes))
		return '<%s "%s" on %d device nodes>' % params
		
	
	def nodes (self):
		"""
			Returns a list of all the device nodes associated with this object.
		"""
		return self._nodes
		
	
	def read (self, node=None):
		"""
			Check device node/s for any new input. Uses either the passed-in
			node, or the object's list of relevant nodes if none is given.
			Returns a list of event objects for the received inputs.
		"""
		if node is not None:
			# Only need to return the given event
			return self.readNode(node)
		
		events = []
		for node in self._nodes:
			events.append(self.readNode(node))
		return events
		
	
	def readNode (self, node):
		"""
			Reads all queued events from the given node (file descriptor),
			and sends them for processing.
			Returns a list of event objects for the received inputs.
		"""
		partials = self._partialReadData
		data = partials[node]
		eventSize = self.Event.size
		
		events = []
		bytesToRead = eventSize - len(data)
		while bytesToRead:
			try:
				data = data + node.read(bytesToRead)
			except OSError:
				# Nothing to read, probably
				pass
			
			if len(data) < eventSize:
				partials[node] = data
				bytesToRead = 0
				
			else:
				event = self.Event(data)
				if self.receive (event):
					events.append(event)
				
				bytesToRead = eventSize
				data = ''
				
			
		return events
		
	
	def receive (self, event):
		"""
			Will process the given event (most likely, but not necessarily,
			from a device node) in the most suitable manner.
			Returns whether or not the event was processed
		"""
		try:
			stringCode = const.CODES[event.type][event.code]
			key = mapping.Key(stringCode, event.value, event.value)
		except KeyError:
			# A value we don't know anything about!
			## Most likely a SYN packet. We see a lot of those.
			return False
		
		if event.type == const.EV_KEY and self._inMap(key):
			if event.value == const.KEYDOWN:
				self._startEvent (key)
				
			elif event.value == const.KEYUP:
				self._stopEvent (key)
				
			
		elif event.type == const.EV_REL and self._inMap(key):
			# A remapped relative event
			self._startEvent (key)
			self._stopEvent (key)
			
		elif event.type == const.EV_ABS:
			# Absolute events are 'held down' until an event with a
			# different (or no) remapping is encountered.
			if key.string in self._absolute:
				activeKey = self._absolute[key.string]
			else:
				activeKey = None
			
			if activeKey or self._inMap(key):
				# A new or change in value
				self._startEvent(key)
				
			else:
				# Don't have any instructions for this one
				self._relayEvent(event)
				
			
		elif event.type == const.EV_LED:
			# We've received a notification of a change in LED status
			self._changeMode (key)
			
		else:
			# Don't have any specific rules for this type
			self._relayEvent(event)
			
		
		return True
		
	
	def _enqueue (self, cycle):
		"""
			Puts the given KeyCycle instance into the queue.
		"""
		queue = self._queue
		if cycle not in queue:
			queue[cycle] = cycle.getIter()
		
	
	def _startEvent (self, key, modes=None):
		"""
			Starts whatever needs to be started with the additional
			key given.
			A list of modes (eg. const.LED_*s) can be supplied, otherwise
			the current mode-state of the device will be used.
		"""
		remap = self._remap
		if modes is None:
			modes = self._modes
		
		# Output from the single key
		output = remap([key], modes=modes)
		if output is None:
			output = mapping.ReMapping(key.string).output
		
		oldKey = None
		if key.string in self._pressed:
			oldKey = self._pressed[key.string]
		elif key.string in self._absolute:
			oldKey = self._absolute[key.string]
		
		if oldKey:
			# This key is/was already doing something
			oldOutput = remap([oldKey], modes=modes)
			
			if oldOutput and output != oldOutput:
				# The old output is over
				self._stopEvent(oldKey)
				
			
			if output and output != oldOutput:
				# Something new and different!
				self._startOutput(output)
				
			
		elif output:
			if output in self._queue:
				# We're still processing from this key's last press
				self._continueOutput(output)
			else:
				# This is completely new output
				self._startOutput(output)
			
		
		# And the chord of all pressed keys
		withPressed = self._pressed.copy()
		withPressed[key.string] = key
		if len(withPressed) > 1:
			if key.string in self._pressed:
				oldCombo = remap(self._pressed.values(), modes=modes)
				
			elif key.string in self._absolute:
				withAbs = self._pressed.values()
				withAbs.append (self._absolute[key.string])
				oldCombo = remap(withAbs, modes=modes)
				
			else:
				oldCombo = None
			
			newCombo = remap(withPressed.values(), modes=modes)
			if oldCombo != newCombo:
				if oldCombo:
					self._stopOutput(oldCombo)
				if newCombo:
					self._startOutput(newCombo)
			
		
		# Store the state of this key
		if key.type == const.EV_ABS:
			self._absolute[key.string] = key
		else:
			# Absolute values don't get stored as 'pressed'
			self._pressed[key.string] = key
		
	
	def _startOutput (self, output):
		"""
			Does whatever needs to be done to start outputting the given
			uhh.. output.
		"""
		# Advance to the next sequence in the cycle.
		output.current += 1
		self._enqueue(output)
		self._starting.add(output)
		self._ending.discard(output)
		
	
	def _continueOutput (self, output):
		"""
			Allows continuation of an output, which may have been marked
			for stopping.
		"""
		self._enqueue(output)
		self._startRepeat(output)
		self._ending.discard(output)
		
	
	def _stopEvent (self, key, modes=None):
		"""
			Stops, or rather stops repeating, events which rely on the
			given key being active.
			A list of modes (eg. const.LED_*s) can be supplied, otherwise
			the current mode-state of the device will be used.
		"""
		remap = self._remap
		if modes is None:
			modes = self._modes
		
		# ABS values aren't kept in _pressed, so make sure the key's in there.
		self._pressed[key.string] = key
		# Stop any chording relying on this key
		if len(self._pressed) > 1:
			withKey = remap(self._pressed.values(), modes=modes)
			del(self._pressed[key.string])
			if withKey:
				withoutKey = remap(self._pressed.values(), modes=modes)
				if not withoutKey or withKey != withoutKey:
					# This key was a part of a chord; no longer
					self._stopOutput(withKey)
			
		else:
			del(self._pressed[key.string])
			
		
		# Now we stop the key's own output
		output = remap([key], modes=modes)
		if output is None:
			output = mapping.ReMapping(key.string).output
		self._stopOutput(output)
		
	
	def _stopOutput (self, output):
		# We add the output to the queue, even though we're stopping it,
		# because single-event outputs will have removed it, and need it back.
		self._enqueue(output)
		self._stopRepeat(output)
		self._ending.add(output)
		
	
	def _changeMode (self, key):
		"""
			Switches on or off the mode indicated by the given key.
		"""
		remap = self._remap
		oldModes = self._modes
		newModes = oldModes.copy()
		if key.value:
			if key.string in oldModes:
				# Mode already set, nothing to do
				return
			newModes.add(key.string)
			
		if not key.value:
			if key.string not in oldModes:
				# Nothing to do here, either
				return
			newModes.discard(key.string)
			
		
		# We need to go through all the currently pressed keys, and check if
		# any output needs to be changed for the new mode.
		for key in self._pressed.values():
			oldMapping = remap([key], modes=oldModes)
			newMapping = remap([key], modes=newModes)
			if oldMapping == newMapping:
				# No change
				continue
			
			# Something's changed, so we need to stop the old output...
			if oldMapping is None:
				# We use key.string because key will probably have a value
				# which we don't want.
				oldMapping = mapping.ReMapping(key.string).output
			self._stopOutput(oldMapping)
			
			# ...and start the new
			if newMapping is None:
				newMapping = mapping.ReMapping(key.string).output
			self._startOutput(newMapping)
			
		
		# Now the chord of all keys
		oldMapping = remap(self._pressed.values(), modes=oldModes)
		newMapping = remap(self._pressed.values(), modes=newModes)
		if oldMapping != newMapping:
			if oldMapping:
				self._stopOutput(oldMapping)
			if newMapping:
				self._startOutput(newMapping)
		
		self._modes = newModes
		
	
	def _startRepeat (self, output):
		"""
			Makes the active iterator for the given output repeat.
		"""
		try:
			self._queue[output].repeat = True
		except IndexError:
			# No such output
			pass
		
	
	def _stopRepeat (self, output):
		"""
			Stops the active iterator of the given output.
		"""
		try:
			self._queue[output].repeat = False
		except IndexError:
			# No such output so.. uhh.. yeah...
			pass
		
	
	def _removeComboDelays (self, combo):
		"""
			Returns a replica of the given combo, with any numeric enties
			removed.
		"""
		newCombo = tuple()
		for key in combo:
			if isinstance(key, (int, long)):
				continue
			newCombo += (key,)
			
		return newCombo
		
	
	def process (self):
		"""
			Relay queued-up input events to this Device's output object.
			Returns a list of the event objects which were sent.
		"""
		relay = self._relayCombo
		
		events = []
		for cycle, iterator in self._queue.items():
			if len(iterator.sequence) == 1:
				combo = iterator.next()
				
				if combo:
					if cycle in self._starting:
						# We haven't started with this key yet, or it has
						# a specific value (eg. KEYUP!)
						# Combo timings are only relevent to implicit KEYUPs
						downCombo = self._removeComboDelays(combo)
						value = combo.value
						if value is None:
							value = const.KEYDOWN
						events.extend(relay(downCombo, value))
						
					
					# This isn't an elif because, for example,
					# remaps from EV_REL are instantaneous.
					# We don't KEYUP if the combo has a specific value.
					if combo.value is None and cycle in self._ending:
						events.extend(relay(tuple(reversed(combo)), const.KEYUP))
					
					# These are done with, whatever
					self._starting.discard(cycle)
					self._ending.discard(cycle)
					
				
				# Unitary sequences don't repeat
				del(self._queue[cycle])
				
			else:
				# If a sequence is more than one element long, we loop it.
				try:
					combo = iterator.next()
				except StopIteration:
					# It's over. Let it go. Move on.
					del(self._queue[cycle])
					self._ending.discard(cycle)
					continue
				
				if combo:
					# combo (when it's not None) is a tuple of keypresses,
					# Combo timings are only relevent to KEYUPs
					downCombo = self._removeComboDelays(combo)
					value = combo.value
					if value is None:
						value = const.KEYDOWN
					events.extend(relay(downCombo, value))
					if combo.value is None:
						# Unvalued combos are KEYUPped
						events.extend(relay(tuple(reversed(combo)), const.KEYUP))
					
			
		return events
		
	
	def _relayCombo (self, combo, value=0):
		"""
			Relays all the events in the given combo to whichever device
			is destined to process them (either an output node, or one of
			this object's own nodes for feedback events).
			If delay is set, the events will be delayed by that many
			*milli*seconds.
		"""
		# Check for, and then remove, any delays in the combo
		# Only the last delay is used,
		# though we could make it cumulative.
		delay = 0
		newCombo = tuple()
		for index in xrange(0, len(combo)):
			key = combo[index]
			if isinstance(key, (int, long)):
				delay = key / 1000.0
			else:
				newCombo += (key,)
		combo = newCombo
		
		
		# Send out all the keys in the combo
		events = []
		for key in combo:
			evType, evCode = getattr(const, str(key), (None, None))
			if not evType:
				continue
			
			if key.min is not None and key.max == key.min:
				# Use the value from the key if we can
				keyValue = key.min
			else:
				keyValue = value
			timestamp = time.time() + delay
			event = self.Event(type=evType, code=evCode, value=keyValue, timestamp=timestamp)
			self._relayEvent(event)
			events.append(event)
		
		return events
		
	
	def _relayEvent (self, event):
		"""
			Relays a pre-packaged event to another device, either this
			object's output or, for feedback events, one of this object's
			input nodes.
		"""
		try:
			self._targetDevices[event.type].write(event)
		except KeyError:
			# No node will accept this kind of event!
			pass
		
	
	def write (self, event):
		"""
			Writes the given event to the whichever of the device's nodes
			has been set to receive the events of this type.
		"""
		for node in self._nodes:
			if event.type not in node.events:
				continue
			if event.code not in node.events[event.type]:
				continue
			# Found the right node for the job
			node.write(str(event))
			break
		else:
			# No nodes will accept this event
			raise LookupError ('unsupported event: %s' % repr(event))
		
	
	def close (self):
		"""
			Stops receiving new inputs and makes sure to tidily finish off
			any queued events.
		"""
		global _allInputNodes
		
		for node in self._nodes:
			node.close()
			del(_allInputNodes[node])
		
		# Make sure any queued cycles will end nicely
		for iterator in self._queue.values():
			iterator.repeat = False
		
		# Make sure any held-down keys are 'released'
		for key in self._pressed.values():
			self._stopEvent(key)
		
	

class OutputDevice (object):
	"""
		An output device.
	"""
	Event = events.Event
	
	def _getBusy(self):
		"""
			Whether or not this object is busy.
		"""
		return bool(self._queue)
	busy = property(fget=_getBusy)
	
	
	def __init__ (self):
		self.node = ioctl.OutputNode()
		# This is for events which are scheduled for the future(!)
		self._queue = []
		
	
	def write (self, event):
		"""
			Queues up the event for sending.
		"""
		self._queue.append(event)
		
	
	def process (self):
		"""
			Processes any events which are queued but are ready to go.
		"""
		# Send any ripe events from the queue
		now = time.time()
		for event in list(self._queue):
			if event.timestamp < now:
				self.node.write(str(event))
				# Send a SYN event with each one too
				# This is needed for EV_REL events, at the very least.
				self.node.write(str(self.Event(type=const.EV_SYN)))
				self._queue.remove(event)
				
		
	
	def close (self):
		"""
			Closes the output node.
		"""
		self.node.destroyDevice ()
		self.node.close()
		
	

