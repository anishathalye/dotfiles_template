#!/usr/bin/python
# coding:utf-8
# https://github.com/MtimerCMS/SublimeText-Google-Translate-Plugin

__version__ = "2.0.0"

import sublime
try:
    from urllib import urlopen, urlencode, quote
except:
    from urllib.request import urlopen, build_opener, Request
    from urllib.parse import urlencode, quote
from json import loads
import re
if sublime.version() < '3':
    from urllib2 import urlopen, build_opener, Request
    from handler_st2 import *
    from socks_st2 import *
else:
    from .handler_st3 import *
    from .socks_st3 import *


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
        501: "ERR_SERVICE_NOT_AVAIBLE_TRY_AGAIN_OR_USE_RPOXY",
        503: "ERR_VALUE_ERROR",
        504: "ERR_PROXY_NOT_SPECIFIED",
    }

    def __init__(self, proxy_enable, proxy_type, proxy_host, proxy_port, source_lang, target_lang):
        self.cache = {
            'languages': None,
        }
        self.api_urls = {
            'translate': 'https://translate.google.com/translate_a/t?client=t&ie=UTF-8&oe=UTF-8',
        }
        if not source_lang:
            source_lang = 'auto'
        if not target_lang:
            target_lang = 'en'
        if proxy_enable == 'yes':
            if not proxy_type or not proxy_host or not proxy_port:
                raise GoogleTranslateException(self.error_codes[504])
        self.source = source_lang
        self.target = target_lang
        self.proxyok = proxy_enable
        self.proxytp = proxy_type
        self.proxyho = proxy_host
        self.proxypo = proxy_port

    @property
    def langs(self, cache=True):
        try:
            if not self.cache['languages'] and cache:
                self.cache['languages'] = loads('{"langs":{"af":"Afrikaans","sq":"Albanian","ar":"Arabic","az":"Azerbaijani","eu":"Basque","bn":"Bengali","be":"Belarusian","bg":"Bulgarian","ca":"Catalan","zh-CN":"Chinese Simplified","zh-TW":"Chinese Traditional","hr":"Croatian","cs":"Czech","da":"Danish","nl":"Dutch","en":"English","eo":"Esperanto","et":"Estonian","tl":"Filipino","fi":"Finnish","fr":"French","gl":"Galician","ka":"Georgian","de":"German","el":"Greek","gu":"Gujarati","ht":"Haitian Creole","iw":"Hebrew","hi":"Hindi","hu":"Hungarian","is":"Icelandic","id":"Indonesian","ga":"Irish","it":"Italian","ja":"Japanese","kn":"Kannada","ko":"Korean","la":"Latin","lv":"Latvian","lt":"Lithuanian","mk":"Macedonian","ms":"Malay","mt":"Maltese","no":"Norwegian","fa":"Persian","pl":"Polish","pt":"Portuguese","ro":"Romanian","ru":"Russian","sr":"Serbian","sk":"Slovak","sl":"Slovenian","es":"Spanish","sw":"Swahili","sv":"Swedish","ta":"Tamil","te":"Telugu","th":"Thai","tr":"Turkish","uk":"Ukrainian","ur":"Urdu","vi":"Vietnamese","cy":"Welsh","yi":"Yiddish"}}')
        except IOError:
            raise GoogleTranslateException(self.error_codes[501])
        except ValueError:
            raise GoogleTranslateException(self.error_codes[503])
        return self.cache['languages']

    def translate(self, text, format='html'):
        data = self._get_translation_from_google(text)
        if (format == 'plain'):
            data = self.filter_tags(data)
        else:
            data = self.fix_google(data)
        return data

    def _get_translation_from_google(self, text):
        try:
            json5 = self._get_json5_from_google(text).decode('utf-8')
        except IOError:
            raise GoogleTranslateException(self.error_codes[501])
        except ValueError:
            raise GoogleTranslateException(self.error_codes[503])
        return self._unescape(self._get_translation_from_json5(json5.encode('utf-8')))

    def _get_json5_from_google(self, text):
        escaped_source = quote(text, '')
        headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20100101 Firefox/23.0'}

        if self.proxyok == 'yes':
            if self.proxytp == 'socks5':
                opener = build_opener(SocksiPyHandler(PROXY_TYPE_SOCKS5, self.proxyho, int(self.proxypo)))
            else:
                if self.proxytp == 'socks4':
                    opener = build_opener(SocksiPyHandler(PROXY_TYPE_SOCKS4, self.proxyho, int(self.proxypo)))
                else:
                    opener = build_opener(SocksiPyHandler(PROXY_TYPE_HTTP, self.proxyho, int(self.proxypo)))
            req = Request(self.api_urls['translate']+"&sl=%s&tl=%s&text=%s" % (self.source, self.target, escaped_source), headers = headers)
            result = opener.open(req, timeout = 2).read()
            json = result

        else:
            try:
                req = Request(self.api_urls['translate']+"&sl=%s&tl=%s&text=%s" % (self.source, self.target, escaped_source), headers = headers)
                result = urlopen(req, timeout = 2).read()
                json = result
            except IOError:
                raise GoogleTranslateException(self.error_codes[501])
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

    def filter_tags(self, htmlstr):
        re_cdata=re.compile('//<!\[CDATA\[[^>]*//\]\]>',re.I)
        re_script=re.compile('<\s*script[^>]*>[^<]*<\s*/\s*script\s*>',re.I)
        re_style=re.compile('<\s*style[^>]*>[^<]*<\s*/\s*style\s*>',re.I)
        re_br=re.compile('<br\s*?/?>')
        re_h=re.compile('</?\w+[^>]*>')
        re_comment=re.compile('<!--[^>]*-->')
        s=re_cdata.sub('',htmlstr)
        s=re_script.sub('',s)
        s=re_style.sub('',s)
        s=re_br.sub('\n',s)
        s=re_h.sub('',s)
        s=re_comment.sub('',s)

        blank_line=re.compile('\n+')
        s=blank_line.sub('\n',s)
        s=self.re_exp(s)
        s=self.replaceCharEntity(s)
        return s

    def re_exp(self, htmlstr):
        s = re.compile(r'<[^<]+?>')
        return s.sub('', htmlstr)

    def replaceCharEntity(self, htmlstr):
        CHAR_ENTITIES={'nbsp':' ','160':' ',
                    'lt':'<','60':'<',
                    'gt':'>','62':'>',
                    'amp':'&','38':'&',
                    'quot':'"','34':'"',}
        
        re_charEntity=re.compile(r'&#?(?P<name>\w+);')
        sz=re_charEntity.search(htmlstr)
        while sz:
            entity=sz.group()
            key=sz.group('name')
            try:
                htmlstr=re_charEntity.sub(CHAR_ENTITIES[key],htmlstr,1)
                sz=re_charEntity.search(htmlstr)
            except KeyError:
                htmlstr=re_charEntity.sub('',htmlstr,1)
                sz=re_charEntity.search(htmlstr)
        return htmlstr

    def fix_google(self, htmlstr):
        s=re.compile(r'<[ ]{0,1}/ (?P<name>[a-zA-Z ]{1,})>')
        sz=s.search(htmlstr)
        while sz:
            entity=sz.group()
            #print (entity)
            key=sz.group('name')
            try:
                htmlstr=s.sub(r'</'+key.lower().strip()+'>',htmlstr,1)
                sz=s.search(htmlstr)
            except KeyError:
                sz=s.search(htmlstr)
        return htmlstr

if __name__ == "__main__":
    import doctest
    doctest.testmod()