# Copyright (c) 2001-2003 by Matt Biddulph and Edd Dumbill,
# Useful Information Company
# All rights reserved.
#
# License is granted to use or modify this software ("Daily Chump") for
# commercial or non-commercial use provided the copyright of the author is
# preserved in any distributed or derivative work.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESSED OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# daily chump v 1.1

# $Id: churnparser.py,v 1.1 2003/05/14 11:09:30 edmundd Exp $

import string
import re
import time
import tempfile
import shutil
import os
import os.path
from xmllib import XMLParser, procclose, illegal, tagfind


class StyleSheetAwareXMLParser(XMLParser):
    """ This class is needed to override a bug in Py 1.5.2's xmllib
    which meant it would reject an xml-stylesheet PI """
    def parse_proc(self, i):
        rawdata = self.rawdata
        end = procclose.search(rawdata, i)
        if end is None:
            return -1
        j = end.start(0)
        if illegal.search(rawdata, i+2, j):
            self.syntax_error('illegal character in processing instruction')
        res = tagfind.match(rawdata, i+2)
        if res is None:
            raise RuntimeError, 'unexpected call to parse_proc'
        k = res.end(0)
        name = res.group(0)
        if name == 'xml:namespace':
            self.syntax_error('old-fashioned namespace declaration')
            self.__use_namespaces = -1
            # namespace declaration
            # this must come after the <?xml?> declaration (if any)
            # and before the <!DOCTYPE> (if any).
            if self.__seen_doctype or self.__seen_starttag:
                self.syntax_error('xml:namespace declaration too late in document')
            attrdict, namespace, k = self.parse_attributes(name, k, j)
            if namespace:
                self.syntax_error('namespace declaration inside namespace declaration')
            for attrname in attrdict.keys():
                if not self.__xml_namespace_attributes.has_key(attrname):
                    self.syntax_error("unknown attribute `%s' in xml:namespace tag" % attrname)
            if not attrdict.has_key('ns') or not attrdict.has_key('prefix'):
                self.syntax_error('xml:namespace without required attributes')
            prefix = attrdict.get('prefix')
            if ncname.match(prefix) is None:
                self.syntax_error('xml:namespace illegal prefix value')
                return end.end(0)
            if self.__namespaces.has_key(prefix):
                self.syntax_error('xml:namespace prefix not unique')
            self.__namespaces[prefix] = attrdict['ns']
        else:
            if string.find(string.lower(name), 'xml ') >= 0:
                self.syntax_error('illegal processing instruction target name')
            self.handle_proc(name, rawdata[k:j])
        return end.end(0)

class ChurnParser(StyleSheetAwareXMLParser):
    def __init__(self):
        XMLParser.__init__(self)
        self._data = ''
        self._in_a = 0
        self._a_title = ''
        self._a_href = ''
        self._entries = []
        self._current_entry = {}

    def set_churn(self,churn):
        self.churn = churn

    def get_churn(self):
        return self.churn

    def start_link(self,attrs):
        self._current_entry['title'] = ''
        self._current_entry['time'] = 0
        self._current_entry['nick'] = ''
        self._current_entry['item'] = ''
        self._current_entry['keywords'] = ''
        self._current_entry['comments'] = []
        if attrs.has_key('type'):
            type = attrs['type']
            if type == 'blurb':
                self._current_entry['blurb'] = 1
        else:
            self._current_entry['blurb'] = 0

    def start_a(self,attrs):
        if self._in_comment == 1:
            if(attrs.has_key('href')):
                self._a_href = attrs['href']
            else:
                self._a_href = ''
            self._a_title = ''
            self._in_a = 1

    def start_img(self,attrs):
        if self._in_comment == 1:

            if(attrs.has_key('src')):
                self._img_src = attrs['src']
            else:
                self._img_src = ''

            if(attrs.has_key('alt')):
                self._img_title = attrs['alt']
            else:
                self._img_title = ''

    def start_i(self,attrs):
        self._data = self._data + '*'

    def end_i(self):
        self._data = self._data + '*'

    def end_img(self):
        if self._img_title != '' and self._img_src != '' and self._img_src != self._img_title:
            self._data = self._data + '+[' + self._img_title + '|' + self._img_src + ']'
        elif self._img_src != '':
            self._data = self._data + '+[' + self._img_src + ']'

    def end_a(self):
        if self._a_title != '' and self._a_href != '' and self._a_href != self._a_title:
            self._data = self._data + '[' + self._a_title + '|' + self._a_href + ']'
        elif self._a_href != '':
            self._data = self._data + '[' + self._a_href + ']'
        self._in_a = 0

    def start_itemcount(self,attrs):
        if attrs.has_key('value'):
            self._itemcount = string.atoi(attrs['value'])

    def unknown_starttag(self,tag,attrs):
        self._tag_name = tag
        self._data = ''
        if tag == 'last-updated':
            if attrs.has_key('value'):
                self._last_updated = string.atof(attrs['value'])
            else:
                self._last_updated = time.time()
        if tag == 'comment':
            self._current_entry['comment_nick'] = attrs['nick']
            self._in_comment = 1
        if tag == 'time':
            if attrs.has_key('value'):
                self._current_entry['time'] = string.atof(attrs['value'])
            else:
                self._current_entry['time'] = time.time()

    def end_title(self):
        self._current_entry['title'] = self._data

    def end_keywords(self):
        self._current_entry['keywords'] = self._data

    def end_url(self):
        self._current_entry['item'] = self._data

    def end_nick(self):
        self._current_entry['nick'] = self._data

    def end_comment(self):
        self._in_comment = 0
        self._current_entry['comments'].append([self._data,self._current_entry['comment_nick']])

    def end_link(self):
        self._entries.append(self._current_entry)
        self._current_entry = {}

    def end_churn(self):
        self._entries.reverse()

        for a in self._entries:
            if a['blurb'] == 1:
                a['item'] = "blurb"
            label = self.churn.add_item(a['item'],a['nick'],0)
            if a['title'] != '':
                self.churn.title_item(label,a['title'],0)
            if a['keywords'] != '':
                self.churn.keywords_item(label,a['keywords'],0)
            for c in a['comments']:
                self.churn.comment_item(label,c[0],c[1],0)
            self.churn.set_time_item(label,a['time'],0)

        self.churn.set_update_time(self._last_updated)

    def handle_data(self,text):
        if self._in_a == 1:
            self._a_title = self._a_title + text
        else:
            self._data = self._data + text


class LastUpdatedParser(StyleSheetAwareXMLParser):
    def unknown_starttag(self,tag,attrs):
        if tag == 'last-updated':
            self.lu = attrs['value']

    def get_last_updated(self):
        return string.atof(self.lu)
