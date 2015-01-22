import os
import sys

import sublime

from package_control import sys_path
from package_control.unicode import unicode_from_os
from package_control.console_write import console_write



if sublime.platform() == 'linux':
    dep_paths = sys_path.generate_dependency_paths(u'ssl-linux')

    sys_path.add(dep_paths['plat'], first=True)

    for ssl_ver in [u'1.0.0', u'10', u'0.9.8']:
        lib_path = os.path.join(dep_paths['arch'], u'libssl-%s' % ssl_ver)

        try:
            sys_path.add(lib_path, first=True)
            import _ssl
            console_write(u'Linux SSL: successfully loaded _ssl module for libssl.so.%s' % ssl_ver)

        except (ImportError):
            console_write(u'Linux SSL: _ssl module import error - %s' % unicode_from_os(e))
            sys_path.remove(lib_path)
            continue

        try:
            import ssl

        except (ImportError):
            console_write(u'Linux SSL: ssl module import error - %s' % unicode_from_os(e))
            sys_path.remove(lib_path)
            continue

        break

    if sys.version_info < (3,):
        if 'httplib' in sys.modules:
            console_write(u'Linux SSL: unloading httplib module so ssl will be available')
            del sys.modules['httplib']
    else:
        if 'http' in sys.modules:
            console_write(u'Linux SSL: unloading http module so ssl will be available')
            del sys.modules['http']
            del sys.modules['http.client']
        if 'urllib' in sys.modules:
            console_write(u'Linux SSL: unloading urllib module so ssl will be available')
            del sys.modules['urllib']
            del sys.modules['urllib.request']
