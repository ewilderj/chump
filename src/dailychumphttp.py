import BaseHTTPServer
import re
import urllib
import string
from xml.xslt.Processor import Processor
from dailychump import DailyChump

BaseClass = BaseHTTPServer.BaseHTTPRequestHandler
chump = DailyChump("/tmp");

# code from
# http://www.faqts.com/knowledge_base/view.phtml/aid/4373
def urlParse(url):
    """ return path as list and query string as dictionary
        strip / from path
        ignore empty values in query string
        for example:
            if url is: /xyz?a1=&a2=0%3A1
            then result is: (['xyz'], { 'a2' : '0:1' } )
            if url is: /a/b/c/
            then result is: (['a', 'b', 'c'], None )
            if url is: /?
            then result is: ([], {} )
    """
    print "Parsing: "+url
    #x = string.split(url, '?')
    query_split = re.compile("([^?]*)\?(.*)")
    var_split = re.compile("([^=]*)=(.*)")
    match = query_split.match(url)
    if match != None:
        x = []
        x.append(match.group(1)) # path
        x.append(match.group(2)) # query string
    else:
        x = [url]
    pathlist = filter(None, string.split(x[0], '/'))
    d = {}
    if len(x) > 1:
        q = x[-1]                  # eval query string
        x = string.split(q, '&')
        for kv in x:
            y = []
            match = var_split.match(kv)
            y.append(match.group(1)) # key
            y.append(match.group(2)) # value
            k = y[0]
            try:
                v = urllib.unquote_plus(y[1])
                if v:               # ignore empty values
                    d[k] = v
            except:
                pass
    return (pathlist, d)


class ChumpRequestHandler(BaseClass):
    def do_GET(self):
        global chump
        commandre = re.compile("/chump/(.*)")
        match = commandre.match(self.path)
        if match != None:
            input = urllib.unquote_plus(match.group(1))
            text = chump.process_input("http",input)
            self.send_text(text)
        elif string.find(self.path,"/link") == 0:
            pathlist, d = urlParse(self.path)
            url = d['url']
            title = d['title']
            print "link url: " + url
            print "title: " + title
            text = chump.process_input("http",url)
            labelre = re.compile("([A-Z]+):")
            match = labelre.match(text)
            if match != None:
                label = match.group(1)
                print "label: "+label
                text = text + "\n" + chump.process_input("http",label + ":|" + title)
            self.send_text(text)
        elif self.path == "/view":
            self.send_text(chump.view_recent_items())
        elif self.path == "/xml":
            self.send_xml(chump.get_database())
        elif self.path == "/html":
            self.send_html(chump.get_database())
        else:
            return self.send_empty()

    def do_POST(self):
        # handy POST code taken from:
        # http://www.faqts.com/knowledge_base/view.phtml/aid/4373
        ctyp = self.headers.getheader('content-type')
        if ctyp != 'application/x-www-form-urlencoded':
            print 'POST ERROR: unexpected content-tpye:', ctyp
            return
        clen = self.headers.getheader('content-length')
        if clen:
            clen = string.atoi(clen)
        else:
            print 'POST ERROR: missing content-length'
            return
        data = self.rfile.read(clen)
        dummy = self.rfile.read(2)
        self.path = '%s?%s' % (self.path, data)
        self.do_GET()

    def send_empty(self):
        self.send_error(404)

    def send_xml(self,xml):
        self.send_response(200)
        self.send_header("Content-type", "text/xml") 
        self.end_headers() 
        self.wfile.write(xml)

    def send_html(self,xml):
        self.send_xsl(xml,"httpchump.xsl")

    def send_xsl(self,xml,xsl):
        self.send_response(200)
        self.send_header("Content-type", "text/html") 
        self.end_headers() 
        sheetfile = open(xsl,"r")
        sheet = sheetfile.read()

        proc = Processor()
        proc.appendStylesheetString(sheet)
        self.wfile.write(proc.runString(xml))

    def send_text(self,text):
        self.send_response(200)
        self.send_header("Content-type", "text/plain") 
        self.end_headers() 
        self.wfile.write(text)

def test():
    BaseHTTPServer.test(ChumpRequestHandler)

test() 
