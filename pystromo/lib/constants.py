"""
	Holds the scancodes, keycodes, barcodes, etc.
"""

import struct


# System settings
# You can customise, or preferably add to, these to work on distros
# with different filesystem layouts.

# This is a list of all glob() paths to all the input-event device nodes.
INPUT_PATHS = ['/dev/input/event*']
# A list of all the possible locations for the uinput device.
# The first one which exists is the one which is used.
UINPUT_DEVICES = ['/dev/uinput', '/dev/input/uinput', '/dev/misc/uinput']



## I don't know any other bus values!
## I don't really care ATM either. :)
BUS_USB = 0x03

##############################
# DO NOT CHANGE THESE!
BUFFER_512 = '\0' * 512
# This will grab all input on a specific device.
EVIOCGRAB = 0x40044590
# These are used to get info about a device
EVIOCGID = ~int(~0x80084502L & 0xFFFFFFFFL)
EVIOCGID_FORMAT = 'HHHH'
EVIOCGID_BUFFER = "\0" * struct.calcsize(EVIOCGID_FORMAT)
# This is used to get the textual name of a device (eg. "Honey Bee  Nostromo SpeedPad2 ")
EVIOCGNAME_512 = ~int(~0x82004506L & 0xFFFFFFFFL)
EVIOCGNAME_512_BUFFER = BUFFER_512
# This if for getting information about what events a device supports
EVIOCGBIT_512 = ~int(~0x81fe4520L & 0xFFFFFFFFL)
EVIOCGBIT_512_FORMAT = 'I' * (512 / struct.calcsize('I'))
EVIOCGBIT_512_BUFFER = BUFFER_512
# This is for getting information about an absolute axis
EVIOCGABS = ~int(~0x80144540L & 0xFFFFFFFFL)
EVIOCGABS_FORMAT = 'iiiii'
EVIOCGABS_BUFFER = '\0' * struct.calcsize(EVIOCGABS_FORMAT)


# These were *ahem* borrowed from:
# http://svn.navi.cx/misc/trunk/wasabi/devices/unicone/PyUnicone/LinuxInput.py
TYPES = {
		0x00: 'EV_SYN',
		0x01: 'EV_KEY',
		0x02: 'EV_REL',
		0x03: 'EV_ABS',
		0x04: 'EV_MSC',
		0x11: 'EV_LED',
		0x12: 'EV_SND',
		0x14: 'EV_REP',
		0x15: 'EV_FF',
		}


CODES = {
		# EV_SYN doesn't have any codes. Poor thing.
		# EV_KEY
		0x01: {
				0: 'KEY_RESERVED',
				1: 'KEY_ESC',
				2: 'KEY_1',
				3: 'KEY_2',
				4: 'KEY_3',
				5: 'KEY_4',
				6: 'KEY_5',
				7: 'KEY_6',
				8: 'KEY_7',
				9: 'KEY_8',
				10: 'KEY_9',
				11: 'KEY_0',
				12: 'KEY_MINUS',
				13: 'KEY_EQUAL',
				14: 'KEY_BACKSPACE',
				15: 'KEY_TAB',
				16: 'KEY_Q',
				17: 'KEY_W',
				18: 'KEY_E',
				19: 'KEY_R',
				20: 'KEY_T',
				21: 'KEY_Y',
				22: 'KEY_U',
				23: 'KEY_I',
				24: 'KEY_O',
				25: 'KEY_P',
				26: 'KEY_LEFTBRACE',
				27: 'KEY_RIGHTBRACE',
				28: 'KEY_ENTER',
				29: 'KEY_LEFTCTRL',
				30: 'KEY_A',
				31: 'KEY_S',
				32: 'KEY_D',
				33: 'KEY_F',
				34: 'KEY_G',
				35: 'KEY_H',
				36: 'KEY_J',
				37: 'KEY_K',
				38: 'KEY_L',
				39: 'KEY_SEMICOLON',
				40: 'KEY_APOSTROPHE',
				41: 'KEY_GRAVE',
				42: 'KEY_LEFTSHIFT',
				43: 'KEY_BACKSLASH',
				44: 'KEY_Z',
				45: 'KEY_X',
				46: 'KEY_C',
				47: 'KEY_V',
				48: 'KEY_B',
				49: 'KEY_N',
				50: 'KEY_M',
				51: 'KEY_COMMA',
				52: 'KEY_DOT',
				53: 'KEY_SLASH',
				54: 'KEY_RIGHTSHIFT',
				55: 'KEY_KPASTERISK',
				56: 'KEY_LEFTALT',
				57: 'KEY_SPACE',
				58: 'KEY_CAPSLOCK',
				59: 'KEY_F1',
				60: 'KEY_F2',
				61: 'KEY_F3',
				62: 'KEY_F4',
				63: 'KEY_F5',
				64: 'KEY_F6',
				65: 'KEY_F7',
				66: 'KEY_F8',
				67: 'KEY_F9',
				68: 'KEY_F10',
				69: 'KEY_NUMLOCK',
				70: 'KEY_SCROLLLOCK',
				71: 'KEY_KP7',
				72: 'KEY_KP8',
				73: 'KEY_KP9',
				74: 'KEY_KPMINUS',
				75: 'KEY_KP4',
				76: 'KEY_KP5',
				77: 'KEY_KP6',
				78: 'KEY_KPPLUS',
				79: 'KEY_KP1',
				80: 'KEY_KP2',
				81: 'KEY_KP3',
				82: 'KEY_KP0',
				83: 'KEY_KPDOT',
				84: 'KEY_103RD',
				85: 'KEY_F13',
				86: 'KEY_102ND',
				87: 'KEY_F11',
				88: 'KEY_F12',
				89: 'KEY_F14',
				90: 'KEY_F15',
				91: 'KEY_F16',
				92: 'KEY_F17',
				93: 'KEY_F18',
				94: 'KEY_F19',
				95: 'KEY_F20',
				96: 'KEY_KPENTER',
				97: 'KEY_RIGHTCTRL',
				98: 'KEY_KPSLASH',
				99: 'KEY_SYSRQ',
				100: 'KEY_RIGHTALT',
				101: 'KEY_LINEFEED',
				102: 'KEY_HOME',
				103: 'KEY_UP',
				104: 'KEY_PAGEUP',
				105: 'KEY_LEFT',
				106: 'KEY_RIGHT',
				107: 'KEY_END',
				108: 'KEY_DOWN',
				109: 'KEY_PAGEDOWN',
				110: 'KEY_INSERT',
				111: 'KEY_DELETE',
				112: 'KEY_MACRO',
				113: 'KEY_MUTE',
				114: 'KEY_VOLUMEDOWN',
				115: 'KEY_VOLUMEUP',
				116: 'KEY_POWER',
				117: 'KEY_KPEQUAL',
				118: 'KEY_KPPLUSMINUS',
				119: 'KEY_PAUSE',
				120: 'KEY_F21',
				121: 'KEY_F22',
				122: 'KEY_F23',
				123: 'KEY_F24',
				124: 'KEY_KPCOMMA',
				125: 'KEY_LEFTMETA',
				126: 'KEY_RIGHTMETA',
				127: 'KEY_COMPOSE',
				128: 'KEY_STOP',
				129: 'KEY_AGAIN',
				130: 'KEY_PROPS',
				131: 'KEY_UNDO',
				132: 'KEY_FRONT',
				133: 'KEY_COPY',
				134: 'KEY_OPEN',
				135: 'KEY_PASTE',
				136: 'KEY_FIND',
				137: 'KEY_CUT',
				138: 'KEY_HELP',
				139: 'KEY_MENU',
				140: 'KEY_CALC',
				141: 'KEY_SETUP',
				142: 'KEY_SLEEP',
				143: 'KEY_WAKEUP',
				144: 'KEY_FILE',
				145: 'KEY_SENDFILE',
				146: 'KEY_DELETEFILE',
				147: 'KEY_XFER',
				148: 'KEY_PROG1',
				149: 'KEY_PROG2',
				150: 'KEY_WWW',
				151: 'KEY_MSDOS',
				152: 'KEY_COFFEE',
				153: 'KEY_DIRECTION',
				154: 'KEY_CYCLEWINDOWS',
				155: 'KEY_MAIL',
				156: 'KEY_BOOKMARKS',
				157: 'KEY_COMPUTER',
				158: 'KEY_BACK',
				159: 'KEY_FORWARD',
				160: 'KEY_CLOSECD',
				161: 'KEY_EJECTCD',
				162: 'KEY_EJECTCLOSECD',
				163: 'KEY_NEXTSONG',
				164: 'KEY_PLAYPAUSE',
				165: 'KEY_PREVIOUSSONG',
				166: 'KEY_STOPCD',
				167: 'KEY_RECORD',
				168: 'KEY_REWIND',
				169: 'KEY_PHONE',
				170: 'KEY_ISO',
				171: 'KEY_CONFIG',
				172: 'KEY_HOMEPAGE',
				173: 'KEY_REFRESH',
				174: 'KEY_EXIT',
				175: 'KEY_MOVE',
				176: 'KEY_EDIT',
				177: 'KEY_SCROLLUP',
				178: 'KEY_SCROLLDOWN',
				179: 'KEY_KPLEFTPAREN',
				180: 'KEY_KPRIGHTPAREN',
				181: 'KEY_INTL1',
				182: 'KEY_INTL2',
				183: 'KEY_INTL3',
				184: 'KEY_INTL4',
				185: 'KEY_INTL5',
				186: 'KEY_INTL6',
				187: 'KEY_INTL7',
				188: 'KEY_INTL8',
				189: 'KEY_INTL9',
				190: 'KEY_LANG1',
				191: 'KEY_LANG2',
				192: 'KEY_LANG3',
				193: 'KEY_LANG4',
				194: 'KEY_LANG5',
				195: 'KEY_LANG6',
				196: 'KEY_LANG7',
				197: 'KEY_LANG8',
				198: 'KEY_LANG9',
				200: 'KEY_PLAYCD',
				201: 'KEY_PAUSECD',
				202: 'KEY_PROG3',
				203: 'KEY_PROG4',
				205: 'KEY_SUSPEND',
				206: 'KEY_CLOSE',
				220: 'KEY_UNKNOWN',
				224: 'KEY_BRIGHTNESSDOWN',
				225: 'KEY_BRIGHTNESSUP',
				0x100: 'BTN_0',
				0x101: 'BTN_1',
				0x102: 'BTN_2',
				0x103: 'BTN_3',
				0x104: 'BTN_4',
				0x105: 'BTN_5',
				0x106: 'BTN_6',
				0x107: 'BTN_7',
				0x108: 'BTN_8',
				0x109: 'BTN_9',
				0x110: 'BTN_LEFT',
				0x111: 'BTN_RIGHT',
				0x112: 'BTN_MIDDLE',
				0x113: 'BTN_SIDE',
				0x114: 'BTN_EXTRA',
				0x115: 'BTN_FORWARD',
				0x116: 'BTN_BACK',
				0x120: 'BTN_TRIGGER',
				0x121: 'BTN_THUMB',
				0x122: 'BTN_THUMB2',
				0x123: 'BTN_TOP',
				0x124: 'BTN_TOP2',
				0x125: 'BTN_PINKIE',
				0x126: 'BTN_BASE',
				0x127: 'BTN_BASE2',
				0x128: 'BTN_BASE3',
				0x129: 'BTN_BASE4',
				0x12a: 'BTN_BASE5',
				0x12b: 'BTN_BASE6',
				0x12f: 'BTN_DEAD',
				0x130: 'BTN_A',
				0x131: 'BTN_B',
				0x132: 'BTN_C',
				0x133: 'BTN_X',
				0x134: 'BTN_Y',
				0x135: 'BTN_Z',
				0x136: 'BTN_TL',
				0x137: 'BTN_TR',
				0x138: 'BTN_TL2',
				0x139: 'BTN_TR2',
				0x13a: 'BTN_SELECT',
				0x13b: 'BTN_START',
				0x13c: 'BTN_MODE',
				0x13d: 'BTN_THUMBL',
				0x13e: 'BTN_THUMBR',
				0x140: 'BTN_TOOL_PEN',
				0x141: 'BTN_TOOL_RUBBER',
				0x142: 'BTN_TOOL_BRUSH',
				0x143: 'BTN_TOOL_PENCIL',
				0x144: 'BTN_TOOL_AIRBRUSH',
				0x145: 'BTN_TOOL_FINGER',
				0x146: 'BTN_TOOL_MOUSE',
				0x147: 'BTN_TOOL_LENS',
				0x14a: 'BTN_TOUCH',
				0x14b: 'BTN_STYLUS',
				0x14c: 'BTN_STYLUS2',
				},
		# EV_REL
		0x02: {
				0x00: 'REL_X',
				0x01: 'REL_Y',
				0x02: 'REL_Z',
				0x06: 'REL_HWHEEL',
				0x07: 'REL_DIAL',
				0x08: 'REL_WHEEL',
				0x09: 'REL_MISC',
				},
		# EV_ABS
		0x03: {
				0x00: "ABS_X",
				0x01: "ABS_Y",
				0x02: "ABS_Z",
				0x03: "ABS_RX",
				0x04: "ABS_RY",
				0x05: "ABS_RZ",
				0x06: "ABS_THROTTLE",
				0x07: "ABS_RUDDER",
				0x08: "ABS_WHEEL",
				0x09: "ABS_GAS",
				0x0a: "ABS_BRAKE",
				0x10: "ABS_HAT0X",
				0x11: "ABS_HAT0Y",
				0x12: "ABS_HAT1X",
				0x13: "ABS_HAT1Y",
				0x14: "ABS_HAT2X",
				0x15: "ABS_HAT2Y",
				0x16: "ABS_HAT3X",
				0x17: "ABS_HAT3Y",
				0x18: "ABS_PRESSURE",
				0x19: "ABS_DISTANCE",
				0x1a: "ABS_TILT_X",
				0x1b: "ABS_TILT_Y",
				0x1c: "ABS_MISC",
				},
		# EV_MSC
		0x04: {
				0x00: 'MSC_SERIAL',
				0x01: 'MSC_PULSELED',
				},
		# EV_LED
		0x11: {
				0x00: 'LED_NUML',
				0x01: 'LED_CAPSL',
				0x02: 'LED_SCROLLL',
				0x03: 'LED_COMPOSE',
				0x04: 'LED_KANA',
				0x05: 'LED_SLEEP',
				0x06: 'LED_SUSPEND',
				0x07: 'LED_MUTE',
				0x08: 'LED_MISC',
				},
		# EV_SND
		0x12: {
				0x00: 'SND_CLICK',
				0x01: 'SND_BELL',
				},
		# EV_REP
		0x14: {
				0x00: 'REP_DELAY',
				0x01: 'REP_PERIOD',
				},
		# EV_FF
		0x15: {
				0x50: 'FF_RUMBLE',
				0x51: 'FF_PERIODIC',
				0x52: 'FF_CONSTANT',
				0x53: 'FF_SPRING',
				0x54: 'FF_FRICTION',
				0x58: 'FF_SQUARE',
				0x59: 'FF_TRIANGLE',
				0x5a: 'FF_SINE',
				0x5b: 'FF_SAW_UP',
				0x5c: 'FF_SAW_DOWN',
				0x5d: 'FF_CUSTOM',
				0x60: 'FF_GAIN',
				0x61: 'FF_AUTOCENTER',
				},
		}

# Values
KEYDOWN = 1
KEYUP = 0
# KEYPRESSED events occur while a key remains pressed.
# NB. This is not what is used by X11, for example, for key repeats.
KEYPRESSED = 2

# Amalgamation of all the above pairs, reversed
globals().update((string, num) for num, string in TYPES.items())
for typeCode, data in CODES.items():
	globals().update((string, (typeCode, num)) for num, string in data.items())

# Cleanup
del(typeCode, data, struct)
