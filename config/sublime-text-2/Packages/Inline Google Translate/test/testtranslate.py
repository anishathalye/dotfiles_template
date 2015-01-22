# -*- coding: utf-8 -*-
# Sublime Text 3 test
__version__ = "2.0"

try:
    from urllib import urlopen, urlencode, quote
except:
    from urllib.request import urlopen, HTTPHandler, HTTPSHandler, build_opener, Request
    from urllib.parse import urlencode, quote
from json import loads
import re
import http.client
import socks
import ssl


class GoogleTranslateException(Exception):
    """
    Default GoogleTranslate exception
    >>> GoogleTranslateException("DoctestError")
    GoogleTranslateException('DoctestError',)
    """
    pass


class GoogleTranslate(object):
    string_pattern = r"\"(([^\"\\]|\\.)*)\""
    match_string =re.compile(
                        r"\,?\[" 
                           + string_pattern + r"\," 
                           + string_pattern + r"\," 
                           + string_pattern + r"\," 
                           + string_pattern
                        +r"\]")

    error_codes = {
        401: "ERR_Target_Language_NOT_SPECIFIED",
        501: "ERR_VALUE_ERROR",
        503: "ERR_SERVICE_NOT_AVAIBLE_TRY_AGAIN_OR_USE_RPOXY",
    }

    def __init__(self, source_lang='en', target_lang='zh-CN'):
        self.cache = {
            'languages': None,
        }
        self.api_urls = {
            'translate': 'https://translate.google.com/translate_a/t?client=t&ie=UTF-8&oe=UTF-8',
        }
        if not target_lang:
            raise GoogleTranslateException(self.error_codes[401])
        self.source = source_lang
        self.target = target_lang

    @property
    def langs(self, cache=True):
        try:
            if not self.cache['languages'] and cache:
                self.cache['languages'] = loads('{"langs":{"af":"Afrikaans","sq":"Albanian","ar":"Arabic","az":"Azerbaijani","eu":"Basque","bn":"Bengali","be":"Belarusian","bg":"Bulgarian","ca":"Catalan","zh-CN":"Chinese Simplified","zh-TW":"Chinese Traditional","hr":"Croatian","cs":"Czech","da":"Danish","nl":"Dutch","en":"English","eo":"Esperanto","et":"Estonian","tl":"Filipino","fi":"Finnish","fr":"French","gl":"Galician","ka":"Georgian","de":"German","el":"Greek","gu":"Gujarati","ht":"Haitian Creole","iw":"Hebrew","hi":"Hindi","hu":"Hungarian","is":"Icelandic","id":"Indonesian","ga":"Irish","it":"Italian","ja":"Japanese","kn":"Kannada","ko":"Korean","la":"Latin","lv":"Latvian","lt":"Lithuanian","mk":"Macedonian","ms":"Malay","mt":"Maltese","no":"Norwegian","fa":"Persian","pl":"Polish","pt":"Portuguese","ro":"Romanian","ru":"Russian","sr":"Serbian","sk":"Slovak","sl":"Slovenian","es":"Spanish","sw":"Swahili","sv":"Swedish","ta":"Tamil","te":"Telugu","th":"Thai","tr":"Turkish","uk":"Ukrainian","ur":"Urdu","vi":"Vietnamese","cy":"Welsh","yi":"Yiddish"}}')
        except IOError:
            raise GoogleTranslateException(self.error_codes[503])
        except ValueError:
            raise GoogleTranslateException(self.error_codes[501])
        return self.cache['languages']

    def translate(self, text, format='html'):
        data = self._get_translation_from_google(text)
        #if (format == 'plain')
            #data = 
        return data

    def _get_translation_from_google(self, text):
        try:
            json5 = self._get_json5_from_google(text).decode('utf-8')
        except IOError:
            raise GoogleTranslateException(self.error_codes[503])
        except ValueError:
            raise GoogleTranslateException(self.error_codes[501])
        return self._unescape(self._get_translation_from_json5(json5.encode('utf-8')))

    def _get_json5_from_google(self, text):
        escaped_source = quote(text, '')
        headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20100101 Firefox/23.0'}
        enable_proxy = True
        if enable_proxy:
            opener = build_opener(SocksiPyHandler(socks.PROXY_TYPE_SOCKS5, "127.0.0.1", 9050))
            req = Request(self.api_urls['translate']+"&sl=%s&tl=%s&text=%s" % (self.source, self.target, escaped_source), headers = headers)
            result = opener.open(req, timeout = 5).read()
            json = result

        else:
            try:
                result = urlopen(self.api_urls['translate']
                         +"&sl=%s&tl=%s&text=%s" % (self.source, self.target, escaped_source), timeout = 5, headers = headers).read()
                json = loads(result.decode('utf-8'))
            except IOError:
                raise GoogleTranslateException(self.error_codes[503])
            except ValueError:
                raise GoogleTranslateException(result)
        return json

    def _get_translation_from_json5(self, content):
        result = ""
        pos = 2
        while True:
            m = self.match_string.match(content.decode('utf-8'), pos)
            if not m:
                break
            result += m.group(1)
            pos = m.end()
        return result

    def _unescape(self, text):
        return loads('"%s"' % text)

class SocksiPyConnection(http.client.HTTPConnection):
    def __init__(self, proxytype, proxyaddr, proxyport=None, rdns=True, username=None, password=None, *args, **kwargs):
        self.proxyargs = (proxytype, proxyaddr, proxyport, rdns, username, password)
        http.client.HTTPConnection.__init__(self, *args, **kwargs)

    def connect(self):
        self.sock = socks.socksocket()
        self.sock.setproxy(*self.proxyargs)
        if type(self.timeout) in (int, float):
            self.sock.settimeout(self.timeout)
        self.sock.connect((self.host, self.port))

class SocksiPyConnectionS(http.client.HTTPSConnection):
    def __init__(self, proxytype, proxyaddr, proxyport=None, rdns=True, username=None, password=None, *args, **kwargs):
        self.proxyargs = (proxytype, proxyaddr, proxyport, rdns, username, password)
        http.client.HTTPSConnection.__init__(self, *args, **kwargs)

    def connect(self):
        sock = socks.socksocket()
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
        def build(host, port=None, strict=None, timeout=0):    
            conn = SocksiPyConnection(*self.args, host=host, port=port, strict=strict, timeout=timeout, **self.kw)
            return conn
        return self.do_open(build, req)

    def https_open(self, req):
        def build(host, port=None, strict=None, timeout=0):    
            conn = SocksiPyConnectionS(*self.args, host=host, port=port, strict=strict, timeout=timeout, **self.kw)
            return conn
        return self.do_open(build, req)
        
if __name__ == "__main__":
    translate = GoogleTranslate('en', 'zh-CN')
    result = translate.translate('Hello, Beijing', 'html')