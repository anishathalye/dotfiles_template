# github.com/justbuchanan/i3scripts

import re
import logging
import subprocess as proc
from collections import namedtuple, Counter

# A type that represents a parsed workspace "name".
NameParts = namedtuple('NameParts', ['num', 'shortname', 'icons'])


def focused_workspace(i3):
    return [w for w in i3.get_workspaces() if w.focused][0]


# Takes a workspace 'name' from i3 and splits it into three parts:
# * 'num'
# * 'shortname' - the workspace's name, assumed to have no spaces
# * 'icons' - the string that comes after the
# Any field that's missing will be None in the returned dict
def parse_workspace_name(name):
    m = re.match('(?P<num>\d+):?(?P<shortname>\w+)? ?(?P<icons>.+)?',
                 name).groupdict()
    return NameParts(**m)


# Given a NameParts object, returns the formatted name
# by concatenating them together.
def construct_workspace_name(parts):
    new_name = str(parts.num)
    if parts.shortname or parts.icons:
        new_name += ':'

        if parts.shortname:
            new_name += parts.shortname

        if parts.icons:
            new_name += ' ' + parts.icons

    return new_name


# Return an array of values for the X property on the given window.
# Requires xorg-xprop to be installed.
def xprop(win_id, property):
    try:
        prop = proc.check_output(
            ['xprop', '-id', str(win_id), property], stderr=proc.DEVNULL)
        prop = prop.decode('utf-8')
        return re.findall('"([^"]*)"', prop)
    except proc.CalledProcessError as e:
        logging.warn("Unable to get property for window '%d'" % win_id)
        return None


# Unicode subscript and superscript numbers
_superscript = "⁰¹²³⁴⁵⁶⁷⁸⁹"
_subscript = "₀₁₂₃₄₅₆₇₈₉"


def _encode_base_10_number(n: int, symbols: str) -> str:
    """Write a number in base 10 using symbols from a given string.

    Examples:
    >>> _encode_base_10_number(42, "0123456789")
    "42"
    >>> _encode_base_10_number(42, "abcdefghij")
    "eb"
    >>> _encode_base_10_number(42, "₀₁₂₃₄₅₆₇₈₉")
    "₄₂"
    """
    return ''.join([symbols[int(digit)] for digit in str(n)])


def format_icon_list(icon_list, icon_list_format='default'):
    if icon_list_format.lower() == 'default':
        # Default (no formatting)
        return ' '.join(icon_list)

    elif icon_list_format.lower() == 'mathematician':
        # Mathematician mode
        # aababa -> a⁴b²
        new_list = []
        for icon, count in Counter(icon_list).items():
            if count > 1:
                new_list.append(icon +
                                _encode_base_10_number(count, _superscript))
            else:
                new_list.append(icon)
        return ' '.join(new_list)

    elif icon_list_format.lower() == 'chemist':
        # Chemist mode
        # aababa -> a₄b₂
        new_list = []
        for icon, count in Counter(icon_list).items():
            if count > 1:
                new_list.append(icon +
                                _encode_base_10_number(count, _subscript))
            else:
                new_list.append(icon)
        return ' '.join(new_list)

    else:
        raise ValueError("Unknown format name for the list of icons: ",
                         icon_list_format)
