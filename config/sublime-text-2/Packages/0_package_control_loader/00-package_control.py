
import sys
import os
from os.path import dirname


# This file adds the package_control subdirectory of Package Control
# to first in the sys.path so that all other packages may rely on
# PC for utility functions, such as event helpers, adding things to
# sys.path, downloading files from the internet, etc


if sys.version_info >= (3,):
    def decode(path):
        return path

    def encode(path):
        return path

    loader_dir = dirname(__file__)

else:
    def decode(path):
        if not isinstance(path, unicode):
            path = path.decode(sys.getfilesystemencoding())
        return path

    def encode(path):
        if isinstance(path, unicode):
            path = path.encode(sys.getfilesystemencoding())
        return path

    loader_dir = decode(os.getcwd())


st_dir = dirname(dirname(loader_dir))

found = False
if sys.version_info >= (3,):
    installed_packages_dir = os.path.join(st_dir, u'Installed Packages')
    pc_package_path = os.path.join(installed_packages_dir, u'Package Control.sublime-package')
    if os.path.exists(encode(pc_package_path)):
        found = True

if not found:
    packages_dir = os.path.join(st_dir, u'Packages')
    pc_package_path = os.path.join(packages_dir, u'Package Control')
    if os.path.exists(encode(pc_package_path)):
        found = True

if found:
    if os.name == 'nt':
        from ctypes import windll, create_unicode_buffer
        buf = create_unicode_buffer(512)
        if windll.kernel32.GetShortPathNameW(pc_package_path, buf, len(buf)):
            pc_package_path = buf.value

    sys.path.insert(0, encode(pc_package_path))
    import package_control
    # We remove the import path right away so as not to screw up
    # Sublime Text and its import machinery
    sys.path.remove(encode(pc_package_path))

else:
    print(u'Package Control: Error finding main directory from loader')
