# Spider, adapted from that found in:
#  Twisted, (C) 2001-2002 Matthew W. Lefkowitz
#
# (C) 2003-5 Edd Dumbill 


import htmllib, formatter, os, urlparse
from twisted.internet import app, reactor
from twisted.web import client
from twisted.python import log
from twisted.protocols.policies import TimeoutMixin
import twisted.application.service

def _parse(url):
    parsed = urlparse.urlparse(url)
    url = urlparse.urlunparse(('','')+parsed[2:])
    host, port = parsed[1], 80
    if ':' in host:
        host, port = host.split(':')
        port = int(port)
    return host, port, url

# TODO: set the user agent to a custom value
class TimeOutHTTPPageDownloader(client.HTTPPageDownloader,TimeoutMixin):
    def connectionMade (self):
        self.setTimeout (30)
        client.HTTPPageDownloader.connectionMade (self)

class HTTPDownloader(client.HTTPDownloader):

    protocol = TimeOutHTTPPageDownloader
    
    def gotHeaders(self, headers):
        type = headers.get('content-type', [''])[0]
        # TODO: store etags and last modified

    def pagePart(self, s):
        client.HTTPDownloader.pagePart(self, s)

    def pageEnd(self):
        client.HTTPDownloader.pageEnd(self)

    def startFactory(self):
        client.HTTPDownloader.startFactory(self)
        
    def stopFactory(self):
        client.HTTPDownloader.stopFactory(self)

class SpiderSender(twisted.application.service.Service):

    maxDownloaders = 1

    def __init__(self):
        self.downloaders = {}
        self.queue = []

    def __getstate__(self):
        """Return state for pickling: ensure that no active spiders
        are actually saved."""
        d = self.__dict__.copy()
        d['downloaders'] = {}
        return d

    def startService(self):
        twisted.application.service.Service.startService(self)
        self.tryDownload()

    def stopService(self):
        app.ApplicationService.stopService(self)
        for transport in self.downloaders.values():
            transport.disconnect()

    # TODO: add support for specifying referrer
    def addTargets(self, targets):
        for target in targets:
            self.queue.append((target, 0))
        self.tryDownload()

    def reportStatus(self):
        return "%d spiders active (max. %d), %d URLs in queue." % (
                len (self.downloaders), self.maxDownloaders,
                len (self.queue))

    def tryDownload(self):
        while self.queue and (len(self.downloaders) < self.maxDownloaders):
            self.download()

    # TODO: implement a 'read from cache only' mode where
    # a successful download is simulated from the local cache
    # we already have
    def download(self):
        uri, depth = self.queue.pop(0)
        host, port, url = _parse(uri)

        # this version throws away the file.
        f = HTTPDownloader(uri, "/dev/null")
        f.deferred.addCallbacks(callback=self.downloadFinished,
                                callbackArgs=(uri,),
                                errback=self.downloadFailed,
                                errbackArgs=(uri,))
        f.deferred.addErrback(log.err)
        self.downloaders[uri] = reactor.connectTCP(host, port, f, timeout=30)
        self.notifyDownloadStart(uri)

    def notifyDownloadStart(self, uri):
        pass
                                                                                
    def notifyDownloadEnd(self, uri):
        pass

    def notifyDownloadFailed(self, uri, reasons):
        pass

    def downloadFinished(self, dloader, uri):
        self.notifyDownloadEnd(uri)
        del self.downloaders[uri]
        self.tryDownload()

    def downloadFailed(self, reasons, uri):
        log.err (reasons)
        self.notifyDownloadFailed(uri, reasons)
        del self.downloaders[uri]
        self.tryDownload()


# To use this spider:
#  subclass and override notifyDownloadEnd and notifyDownloadFailed

if __name__ == '__main__':
    from twisted.internet import app
    from twisted.python.util import println
 
    a = app.Application("spider")
    s = SpiderSender("spider", a)
    s.addTargets(['http://heddley.com/edd/foaf.rdf'])
    s.fileTemplate = os.path.join("/tmp", s.fileTemplate)
    s.notifyDownloadStart = lambda uri: println('starting', uri)
    s.notifyDownloadEnd = lambda uri: println('stopping', uri)
    a.run(save=0)

