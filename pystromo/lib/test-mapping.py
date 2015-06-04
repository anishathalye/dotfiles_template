#!/usr/bin/env python
# Some unit tests for stuff

import mapping

def test(expression, message=None):
	if not message:
		message = expression
	if not eval(expression):
		print 'FAILED: %s' % message


# Key objects
key_a = mapping.Key('KEY_A')
key_b = mapping.Key('KEY_B')
key_bigx = mapping.Key('ABS_X', 0, 200)
key_midx = mapping.Key('ABS_X', 120, 136)
key_outerx = mapping.Key('ABS_X', 180, 255)
# Chord objects
chord_ab = mapping.KeyChord((key_a, key_b))
chord_ba = mapping.KeyChord((key_b, key_a))
chord_bigx = mapping.KeyChord((key_bigx,))

def runTests():
	print 'Testing Pystromo:'
	# Key containment
	test('key_midx in key_bigx')
	test('key_midx in key_midx')
	test('key_midx not in key_outerx')
	test('key_outerx not in key_bigx')
	test('key_outerx not in key_midx')
	test('key_bigx not in key_midx')
	test('key_bigx not in key_outerx')
	# Chords
	test('chord_ab == chord_ba')
	test('hash(chord_ab) == hash(chord_ba)')
	test('key_midx in chord_bigx')
	test('key_bigx in chord_bigx')
	test('key_outerx not in chord_bigx')
	
	print 'Done'
	


if __name__ == '__main__':
	runTests()
