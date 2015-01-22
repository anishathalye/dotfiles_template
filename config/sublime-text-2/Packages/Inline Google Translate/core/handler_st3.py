#!/usr/bin/python
# coding:utf-8
# https://github.com/MtimerCMS/SublimeText-Google-Translate-Plugin

from urllib.request import HTTPHandler, HTTPSHandler
from http.client import HTTPConnection, HTTPSConnection
import ssl
from .socks_st3 import *

class SocksiPyConnection(HTTPConnection):
    def __init__(self, proxytype, proxyaddr, proxyport=None, rdns=True, username=None, password=None, *args, **kwargs):
        self.proxyargs = (proxytype, proxyaddr, proxyport, rdns, username, password)
        HTTPConnection.__init__(self, *args, **kwargs)

    def connect(self):
        self.sock = socksocket()
        self.sock.setproxy(*self.proxyargs)
        if type(self.timeout) in (int, float):
            self.sock.settimeout(self.timeout)
        self.sock.connect((self.host, self.port))

class SocksiPyConnectionS(HTTPSConnection):
    def __init__(self, proxytype, proxyaddr, proxyport=None, rdns=True, username=None, password=None, *args, **kwargs):
        self.proxyargs = (proxytype, proxyaddr, proxyport, rdns, username, password)
        HTTPSConnection.__init__(self, *args, **kwargs)

    def connect(self):
        sock = socksocket()
        sock.setproxy(*self.proxyargs)
        if type(self.timeout) in (int, float):
            sock.settimeout(self.timeout)
        sock.connect((self.host, self.port))
        self.sock = ssl.wrap_socket(sock, self.key_file, self.cert_file)
            
class SocksiPyHandler(HTTPHandler, HTTPSHandler):
    def __init__(self, *args, **kwargs):
        self.args = args
        self.kw = kwargs
        HTTPHandler.__init__(self)

    def http_open(self, req):
        def build(host, port=None, strict=None, timeout=5):    
            conn = SocksiPyConnection(*self.args, host=host, port=port, strict=strict, timeout=timeout, **self.kw)
            return conn
        return self.do_open(build, req)

    def https_open(self, req):
        def build(host, port=None, strict=None, timeout=5):    
            conn = SocksiPyConnectionS(*self.args, host=host, port=port, strict=strict, timeout=timeout, **self.kw)
            return conn
        return self.do_open(build, req)