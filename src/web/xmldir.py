import libxml2,libxslt,re,datetime,os,os.path
from glob import glob
from rfc822 import formatdate
from quixote.util import StaticFile

mimetypes = {
  "html":"text/html",
  "rdf":"text/xml",
  "rss":"text/xml",
}

class XmlFile(object):
    _q_exports = []

    def __init__(self,path,format,xsldir):
        self.path = path
        self.xsldir = xsldir
        self.format = format

    def xslt(self,xslfile,xmldoc):
        styledoc = libxml2.parseFile(xslfile)
        style = libxslt.parseStylesheetDoc(styledoc)

        result = style.applyStylesheet(xmldoc, None)
        out = result.serialize()
	style.freeStylesheet()
        result.freeDoc()
        return out

    def __call__(self,request):
        return self._q_index(request)

    def _q_index(self,request):
        stat = os.stat(self.path)
	last_modified = formatdate(stat.st_mtime)
	if last_modified == request.get_header('If-Modified-Since'):
	    request.response.set_status(304)
	    return ''

        request.response.set_header('Last-Modified', last_modified)
	request.response.cache = None

        if self.format in mimetypes:
            request.response.set_header('content-type', mimetypes[self.format])

        doc = libxml2.parseFile(self.path)
        type = doc.getRootElement().name
        result = self.xslt(self.xsldir+os.path.sep+type+"_"+self.format+".xsl",doc)
        doc.freeDoc()
        return result

class XmlDir(object):
    _q_exports = []

    def __init__(self,path,xsldir):
        self.path = path
        self.xsldir = xsldir

    def _q_index(self,request):
        for file in glob(self.path+os.path.sep+"????-??-??.xml")+glob(self.path+os.path.sep+"index.xml"):
            file = re.sub("(.*)\..*","\\1.html",file)
            resolver = self._q_lookup(request,os.path.basename(file))
            if resolver is not None:
                return resolver(request)

    def _q_lookup(self,request,name):
        filename = self.path+os.path.sep+name
        if os.path.isdir(filename):
            return self.__class__(filename,self.xsldir)
        if os.path.isfile(filename):
            match = re.match(".*\.(.*)",name)
            if match is not None:
                if match.group(1) == 'xml':
                    return StaticFile(filename,mime_type="text/xml",encoding="UTF-8")
            return StaticFile(filename)
        else:
            match = re.match("(.*)\.(.*)",name)
            if match is not None:
                xmlfile = self.path+os.path.sep+match.group(1)+".xml"
                if os.path.isfile(xmlfile):
                    return XmlFile(xmlfile,match.group(2),self.xsldir)
