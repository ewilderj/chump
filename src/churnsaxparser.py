
import string
import time
import xml.sax
from xml.sax.handler import ContentHandler

class LastUpdatedParser(ContentHandler):
    def __init__(self):
        ContentHandler.__init__(self)
        self._last_updated = 0.0;

    def get_last_updated(self):
        return self._last_updated;

    def startElement(self, name, attrs):
        if name == 'last-updated':
            self._last_updated = string.atof(attrs['value'])

    def feed(self, data):
        xml.sax.parseString(data, self)


class ChurnParser(ContentHandler):
    def __init__(self):
        ContentHandler.__init__(self)
        self._data = ''
        self._in_a = 0
        self._a_title = ''
        self._a_href = ''
        self._entries = []
        self._current_entry = {}
        self._dict=self.__class__.__dict__;
        self._last_updated = 0.0;

    def set_churn(self,churn):
        self.churn = churn

    def get_churn(self):
        return self.churn

    ### SAX ADAPTERS ###

    def startDocument(self):
        pass

    def endDocument(self):
        pass

    def startElement(self, name, attrs):
        if self._dict.has_key("start_"+name):
            self._dict["start_"+name](self, attrs)
        else:
            self.unknown_starttag(name, attrs)

    def endElement(self, name):
        if self._dict.has_key("end_"+name):
            self._dict["end_"+name](self)
        else:
            self.unknown_endtag(name)

    def characters(self, content):
        self.handle_data(content)

    def feed(self, data):
        xml.sax.parseString(data, self)

    def close(self):
        pass

    ### MAIN METHODS ###

    def unknown_endtag(self, name):
        pass

    def start_link(self,attrs):
        self._current_entry['title'] = u''
        self._current_entry['time'] = 0
        self._current_entry['nick'] = u''
        self._current_entry['item'] = u''
        self._current_entry['keywords'] = u''
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
                self._a_href = u''
            self._a_title = u''
            self._in_a = 1

    def start_img(self,attrs):
        if self._in_comment == 1:

            if(attrs.has_key('src')):
                self._img_src = attrs['src']
            else:
                self._img_src = u''

            if(attrs.has_key('alt')):
                self._img_title = attrs['alt']
            else:
                self._img_title = u''

    def start_i(self,attrs):
        self._data = self._data + u'*'

    def end_i(self):
        self._data = self._data + u'*'

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

    def start_comment(self, attrs):
        self._data = u''
        self._current_entry['comment_nick'] = attrs['nick']
        self._in_comment = 1

    def start_time(self, attrs):
        if attrs.has_key('value'):
            self._current_entry['time'] = string.atof(attrs['value'])
        else:
            self._current_entry['time'] = time.time()

    def unknown_starttag(self,tag,attrs):
        self._data = u''
        if tag == 'last-updated':
            if attrs.has_key('value'):
                self._last_updated = string.atof(attrs['value'])
            else:
                self._last_updated = time.time()

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

if __name__ == "__main__":
    from dailychump import Churn;
    c=ChurnParser()
    c.set_churn(Churn(''))
    xml.sax.parse("/home/fez/edmundd/tmp/chump/index.xml", c)
