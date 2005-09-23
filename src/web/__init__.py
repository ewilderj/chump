import re,glob,datetime,os.path

from quixote.util import StaticFile
from xmldir import XmlDir,XmlFile

_q_exports = [('index.rss','index_rss')]

def index_rss(request):
    return XmlFile(chumproot+os.path.sep+datetime.datetime.now().strftime("%Y/%02m/%02d/%Y-%02m-%02d.xml"),"rss",xsldir)._q_index(request)

def _q_index(request):
    return XmlFile(chumproot+os.path.sep+"index.xml","html",xsldir)._q_index(request)

def _q_lookup(request,component):
    if re.match('2\d\d\d',component):
        return XmlDir(chumproot+os.path.sep+component,xsldir)
    else:
        return StaticFile(chumproot+os.path.sep+component)
