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

# $Id: dailychump.py,v 1.19 2003/05/14 12:21:25 edmundd Exp $

import string
import re
import time
import tempfile
import shutil
import os
import os.path
from EntityEncoder import EntityEncoder
from EntityEncoderU import EntityEncoderU
from churnsaxparser import ChurnParser, LastUpdatedParser;


blurbmatch = re.compile("BLURB:\s*(.*)")
urlmatch = re.compile(r'((http://|https://|ftp://|news://|irc://)[^ ]+)',
                      re.IGNORECASE)
titlematch = re.compile("([A-Z]+):\|\s*(.*)")
commentmatch = re.compile("([A-Z]+):\s*(.*)")
destmatch = re.compile("([A-Z]+):\->\s*(.*)")
comrepmatch = re.compile("([A-Z]+)(\d+):\s*(.*)")
urlrepmatch = re.compile("([A-Z]+):=\s*(.*)")

class TimeFormatter:
    def format_time(self,formattime):
        return time.strftime("%Y-%m-%d %H:%M",time.gmtime(formattime))

class ChumpResponse:
    def __init__(self,str):
        self._str=str

    def __str__(self):
        return self._str

class ChumpErrorResponse(ChumpResponse):
    pass

class ChumpInfoResponse(ChumpResponse):
    pass

class Churn:
    def __init__(self,directory,use_unicode=0):
        self.database = {}
        self.directory = directory
        self.labelcount = 0
        self.set_update_time(time.time())
        self.topic=""
        self.stylesheet=""
        self.sheettype="text/css"
        self.archive_filename=""
        self._day = 0
        self._relative_uri=""
        self.use_utf8 = use_unicode

    def set_update_time(self,time):
        self.updatetime = time

    def get_update_time(self):
        return self.updatetime

    def set_relative_uri(self,uri):
        self._relative_uri=uri

    def get_relative_uri(self):
        return self._relative_uri

    def get_topic(self):
        return self.topic

    def set_topic(self,topic,savenow=1):
        self.topic = topic
        if savenow:
            self.save()
        self.update_timestamp()

    def get_stylesheet(self):
        return self.stylesheet

    def get_stylesheettype(self):
        return self.sheettype

    def set_stylesheet(self,sheet):
        self.stylesheet=sheet
        if sheet[-3:] == "xsl":
            self.sheettype="text/xsl"
        else:
            self.sheettype="text/css"

    def view_item(self, label):
        entry = self.get_entry(label)
        if entry != None:
            if entry.title == u'':
                return ChumpResponse(label + ": " + entry.item)
            else:
                return ChumpResponse(label + ": " + entry.title +
                                     " (" + entry.item + ")")
        else:
            return ChumpErrorResponse('Label '+label+' not found.')

    def view_recent_items(self, count=5):
        labels = self._timesorted_labels()
        labels = labels[0:count]
        labels.reverse()
        message = u''
        for l in labels:
            message = message + self.view_item(l)._str + "\n"
        return ChumpResponse(message)

    def add_item(self, item, nick, savenow=1):
        entry = ChurnEntry(item, nick, self.use_utf8)
        label = self.get_next_label()
        self.set_entry(label, entry)
        if savenow:
            self.save()
        self.update_timestamp()
        return label

    def _filename(self):
        return self.directory + "/index.xml"

    def _timesorted_labels(self):
        labels = self.database.keys()
        times = []
        for l in labels:
            times.append(self.get_entry(l).time)

        # sort list of labels by the respective time entry 
        # from the times list
        pairs = map(None,times,labels)
        pairs.sort()
        result = pairs[:]
        for i in xrange(len(result)):
            result[i] = result[i][1]
        result.reverse()
        return result

    def set_time_item(self,label,time,savenow=1):
        entry = self.get_entry(label)
        if entry != None:
            entry.set_time(time)
            if savenow:
                self.save()
            self.update_timestamp()

    def set_entry(self,label,entry):
        self.database[label] = entry

    def get_entry_count(self):
        return len(self.database.keys())

    def get_entry(self,label):
        if self.database.has_key(label):
            return self.database[label]
        else:
            return None

    def title_item(self,label,title,savenow=1):
        entry = self.get_entry(label)
        if entry != None:
            entry.set_title(title)
            if savenow:
                self.save()
            return ChumpInfoResponse("Titled item "+label+".")
        else:
            return ChumpErrorResponse('Label '+label+' not found.')

    def replace_url(self,label,url,savenow=1):
        entry = self.get_entry(label)
        if entry != None:
            if entry.item!= "blurb":
                entry.item=url
                if savenow:
                    self.save()
                    return ChumpInfoResponse("Replaced URL of "+label+".")
            else:
                return ChumpErrorResponse("Can't replace a BLURB with a URL.")
        else:
            return ChumpErrorResponse('Label '+label+' not found.')
 
    def keywords_item(self,label,dest,savenow=1):
        entry = self.get_entry(label)
        if entry != None:
            entry.set_keywords(dest)
            if savenow:
                self.save()
            return ChumpInfoResponse("Set keywords for "+label+".")
        else:
            return ChumpErrorResponse('Label '+label+' not found.')

    def get_comments(self,label):
        entry = self.get_entry(label)
        if entry != None:
            r=entry.item + "\n"
            if entry.title != '':
                r=r+entry.title+"\n"
            if entry.keywords != '':
                r=r+"-> "+entry.keywords+"\n"
            r=r+entry.get_comments()
            return ChumpResponse(r)
        else:
            return ChumpErrorResponse('Label '+label+' not found.')

    def get_comment_n(self,label,commentno):
        entry = self.get_entry(label)
        if entry != None:
            comment = entry.get_comment_n(commentno-1)
            if comment != None:
                return ChumpResponse(comment)
            else:
                return ChumpErrorResponse('Comment '+label+str(commentno)+
                                          ' not found.')
        else:
            return ChumpErrorResponse('Label '+label+' not found.')

    def comment_item(self,label,comment,nick,savenow=1):
        entry = self.get_entry(label)
        if entry != None:
            entry.add_comment(comment,nick)
            if savenow:
                self.save()
            return ChumpInfoResponse("Added comment "+label+
                                     str(entry.num_comments())+".")
        else:
            return ChumpErrorResponse('Label '+label+' not found.')

    def replace_comment_n(self,label,comment,commentno,nick):
        entry = self.get_entry(label)
        if entry != None:
            oldcomment = entry.get_comment_n(commentno-1)
            if oldcomment != None:
                entry.replace_comment_n(commentno-1,comment,nick)
                self.save()
                return ChumpInfoResponse("Replaced comment "+label+
                                         str(commentno)+".")
            else:
                return ChumpErrorResponse('Comment '+label+
                                          str(commentno)+' not found.')
        else:
            return ChumpErrorResponse('Label '+label+' not found.')

    def delete_comment_n(self,label,commentno,nick):
        entry = self.get_entry(label)
        if entry != None:
            comment = entry.get_comment_n(commentno-1)
            if comment != None:
                entry.delete_comment_n(commentno-1,nick)
                self.save()
                return ChumpInfoResponse("Deleted comment "+label+
                                         str(commentno)+".")
            else:
                return ChumpErrorResponse('Comment '+label+
                                          str(commentno)+' not found.')
        else:
            return ChumpErrorResponse('Label '+label+' not found.')

    def save(self):
        name = tempfile.mktemp()
        out_file = open(name,"w")
        out_file.write(self.serialize())
        out_file.write("\n")
        out_file.close()
        if os.path.isfile(self._filename()):
            os.remove(self._filename())
        shutil.copy(name,self._filename())
        shutil.copy(name,self.get_archive_filename())
        os.unlink(name)

    def set_archive_filename(self,fname):
        self.archive_filename=fname

    def get_archive_filename(self):
        return self.archive_filename

    def deserialize(self,data):
        c = ChurnParser()
        c.set_churn(self)
        c.feed(data)
        c.close()

    def serialize(self):
        if self.use_utf8:
            encoder = EntityEncoderU()
            serialized=u'<?xml version="1.0" encoding="utf-8"?>\n<!DOCTYPE churn>\n'
        else:
            encoder = EntityEncoder()
            serialized=u'<?xml version="1.0" encoding="iso-8859-1"?>\n<!DOCTYPE churn>\n'

        if self.get_stylesheet()!="":
            serialized = serialized + '<?xml-stylesheet href="'+\
                         encoder.encode_chars(self.get_stylesheet())+\
                         '" type="'+\
                         self.get_stylesheettype()+'"?>'+"\n"
        serialized = serialized + "<churn>\n"

        serialized = serialized + '<last-updated value="'
        serialized = serialized + "%f" % self.updatetime
        serialized = serialized + '">'
        serialized = serialized + encoder.encode_chars(TimeFormatter().format_time(self.updatetime))+"</last-updated>\n"

        serialized = serialized + '<relative-uri-stub value="' + encoder.encode_chars(self.get_relative_uri()) + '"/>'+"\n"
        serialized = serialized + '<itemcount value="'
        serialized = serialized + "%d" % self.get_entry_count()
        serialized = serialized + '" />\n'

        serialized = serialized + "<topic>"+encoder.encode_chars(self.topic)+"</topic>\n"

        for x in self._timesorted_labels():
            entry = self.get_entry(x)
            serialized = serialized + entry.serialize()
        serialized = serialized + "</churn>"

        if self.use_utf8:
            return serialized.encode('utf-8')
        else:
            return serialized.encode('latin-1')

    def get_next_label(self):
        label = self.number_to_label(self.labelcount)
        self.labelcount = self.labelcount + 1
        return label

    def number_to_label(self,number):
        if number < 26:
            return chr(number + 65)

        if number == 26:
            return 'AA'

        count = number - 26
        label = ''
        while count > 0:
            label = chr((count % 26) + 65) + label
            count = count / 26

        if number < 52:
            return 'A' + label
        else:
            return label

    def update_timestamp(self):
        self.set_update_time(time.time())

class ChurnEntry:
    def __init__(self,item,nick,use_unicode):
        self.item = item
        self.nick = nick
        self.comments = []
        self.set_time(time.time())
        self.title = ''
        self.keywords = ''
        self.use_utf8 = use_unicode

    def serialize(self):
        if self.use_utf8:
            encoder = EntityEncoderU()
        else:
            encoder = EntityEncoder()

        serialized = u''
        serialized = serialized + "<link"
        if self.item == 'blurb':
           serialized = serialized + ' type="blurb"'
        serialized = serialized + ">\n"
        serialized = serialized + '<time value="'
        serialized = serialized + "%f" % self.time
        serialized = serialized + '">'
        serialized = serialized + encoder.encode_chars(TimeFormatter().format_time(self.time))
        serialized = serialized + "</time>\n"
        serialized = serialized + "<keywords>" + encoder.encode_chars(self.keywords) + "</keywords>\n"
        if not self.item == 'blurb':
           serialized = serialized + "<url>"+encoder.encode_chars(self.item)+"</url>\n"
        serialized = serialized + "<nick>"+encoder.encode_chars(self.nick)+"</nick>\n"
        if self.title != '':
            serialized = serialized + "<title>"+encoder.encode_chars(self.title)+"</title>\n"
        for c in self.comments:
            nick = c[0]
            comment = c[1]
            serialized = serialized + self.serialize_comment(nick,comment,encoder)
        serialized = serialized + "</link>\n"
        return serialized


    def serialize_comment(self,nick,comment,encoder):
        comment_html = encoder.encode_chars(comment)

        italic_search = re.compile('\*([^*]+)\*')
        while italic_search.search(comment_html) != None:
            match = italic_search.search(comment_html)
            comment_html = comment_html[0:match.start(1) - 1] + '<i>' + comment_html[match.start(1):match.end(1)] + '</i>' + comment_html[match.end(1) + 1:]

        img_search = re.compile('\+\[(http[^|\]]+)\]')
        while img_search.search(comment_html) != None:
            match = img_search.search(comment_html)
            comment_html = comment_html[0:match.start(1) - 2] + '<img src="' + match.group(1) + '" />' + comment_html[match.end(1) + 1:]

        titled_img_search = re.compile('\+\[([^|]+)\|([^\]]+)\]')
        while titled_img_search.search(comment_html) != None:
            match = titled_img_search.search(comment_html)
            if string.find(match.group(1),"http") == 0: # begins with http
                url_index = 1
                title_index = 2
            else:
                url_index = 2
                title_index = 1

            comment_html = comment_html[0:match.start(1) - 2] + '<img src="' + match.group(url_index) + '" alt="' + match.group(title_index) + '" />' + comment_html[match.end(2) + 1:]

        url_search = re.compile('\[(http[^|\]]+)\]')
        while url_search.search(comment_html) != None:
            match = url_search.search(comment_html)
            comment_html = comment_html[0:match.start(1) - 1] + '<a href="' + match.group(1) + '">' + match.group(1) + '</a>' + comment_html[match.end(1) + 1:]

        titled_url_search = re.compile('\[([^|]+)\|([^\]]+)\]')
        while titled_url_search.search(comment_html) != None:
            match = titled_url_search.search(comment_html)
            if string.find(match.group(1),"http") == 0: # begins with http
                url_index = 1
                title_index = 2
            else:
                url_index = 2
                title_index = 1

            comment_html = comment_html[0:match.start(1) - 1] + '<a href="' + match.group(url_index) + '">' + match.group(title_index) + '</a>' + comment_html[match.end(2) + 1:]

        serialized = u''
        serialized = serialized + u'<comment nick="' + nick+ u'">'
        serialized = serialized + comment_html
        serialized = serialized + u"</comment>\n"
        return serialized

    def set_time(self,time):
        self.time = time

    def add_comment(self,comment,nick):
        self.comments.append([nick,comment])

    def set_title(self,title):
        self.title = title

    def set_keywords(self,keywords):
        self.keywords = keywords

    def get_comments(self):
        comments = u""
        cno=1
        for c in self.comments:
            nick = c[0]
            comment = c[1]
            comments = comments + u'(' +str(cno)+u':' + nick+ u') '
            comments = comments + comment
            comments = comments + u"\n"
            cno=cno+1
        return comments

    def get_comment_n(self,commentno):
        if commentno < len(self.comments) and commentno >= 0:
            return "(" + self.comments[commentno][0] + ") " + self.comments[commentno][1]
        else:
            return None

    def replace_comment_n(self,commentno,comment,nick):
        if commentno < len(self.comments) and commentno >= 0:
            self.comments[commentno]=[nick,comment]

    def num_comments(self):
        return len(self.comments)

    def delete_comment_n(self,commentno,nick):
        if commentno < len(self.comments) and commentno >= 0:
            self.comments.remove(self.comments[commentno])

class DailyChump:
    def __init__(self, directory, use_unicode=0):
        self.archiver = FileArchiver(directory)
        self.churn = self.archiver.retrieve_churn(use_unicode)

    def set_topic(self,topic):
        self.churn = self.archiver.archive_if_necessary(self.churn)
        self.churn.set_topic(topic)

    def view_recent_items(self,count=5):
        return self.churn.view_recent_items(count)

    def get_database(self):
        return self.churn.serialize()

    def set_stylesheet(self, sheet):
        self.churn.set_stylesheet(sheet)

    def process_input(self,nick,msg):
        um = urlmatch.match(msg)
        bm = blurbmatch.match(msg)
        tm = titlematch.match(msg)
        cm = commentmatch.match(msg)
        dm = destmatch.match(msg)
        rm = comrepmatch.match(msg)
        em = urlrepmatch.match(msg)

        if um:
            self.churn = self.archiver.archive_if_necessary(self.churn)
            url = um.group(1)
            label = self.churn.add_item(url,nick)
            return ChumpResponse(label+": "+url+" from "+nick)

        elif bm:
            self.churn = self.archiver.archive_if_necessary(self.churn)
            item = "blurb"
            title = bm.group(1)
            label = self.churn.add_item(item,nick)
            msg = self.churn.title_item(label,title)
            return ChumpResponse(label+": "+title+" from "+nick)

        elif tm:
            label = tm.group(1)
            title = tm.group(2)
            return self.churn.title_item(label,title)

        elif dm:
            label = dm.group(1)
            dest = dm.group(2)
            return self.churn.keywords_item(label, dest)

        elif em:
            label = em.group(1)
            newurl = em.group(2)
            um = urlmatch.match(newurl)
            if um:
                return self.churn.replace_url(label, um.group(1))
            else:
                return ChumpErrorResponse("Replacement must be a valid URL.")

        elif cm:
            label = cm.group(1)
            comment = cm.group(2)
            if comment == '':
                return self.churn.get_comments(label)
            else:
                return self.churn.comment_item(label,comment,nick)
        elif rm:
            label = rm.group(1)
            commentno = int(rm.group(2))
            comment = rm.group(3)
            if comment == '':
                return self.churn.get_comment_n(label,commentno)
            elif comment == '""':
                return self.churn.delete_comment_n(label,commentno,nick)
            else:
                return self.churn.replace_comment_n(label,comment,commentno,nick)

        else:
            return None

class FileArchiver:
    def __init__(self, directory):
        self.filename = directory + os.sep + "index.xml"
        self.directory = directory

    def archive_if_necessary(self,churn):
        date = churn.updatetime
        oldsheet = churn.get_stylesheet()
        if self.should_archive(date):
            # create a new churn
            churn = Churn(self.directory, churn.use_utf8)
            churn.set_archive_filename(self.prepare_filename(time.time()))
            churn.set_relative_uri(self.prepare_relative_uri(time.time()))
            if oldsheet!="":
                churn.set_stylesheet(oldsheet)
        return churn

    def retrieve_churn(self, use_unicode=0):
        churn = Churn(self.directory, use_unicode)

        if os.path.isfile(self.filename):
            date = self.get_date(self.filename)
            if self.should_archive(date):
                #print "Archiving current file"
                destination = self.prepare_filename(date)
                os.rename(self.filename,destination)
            else:
                #print "Reading current file"
                file = open(self.filename,'r')
                data = file.read()
                file.close()
                churn.deserialize(data)

        churn.set_archive_filename(self.prepare_filename(time.time()))
        churn.set_relative_uri(self.prepare_relative_uri(time.time()))
        churn.save()
        return churn

    def should_archive(self,date):
        date_components = time.gmtime(date)
        file_year = date_components[0]
        file_month = date_components[1]
        file_day = date_components[2]

        date_components = time.gmtime(time.time())
        year = date_components[0]
        month = date_components[1]
        day = date_components[2]

        if(year == file_year and month == file_month and day == file_day):
            return 0
        else:
            return 1

    def prepare_filename(self,date):
        date_components = time.gmtime(date)
        year = "%d" % date_components[0]
        month = "%02d" % date_components[1]
        day = "%02d" % date_components[2]
        dir = self.directory + os.sep + string.join([year, month, day],os.sep)
        if not os.path.isdir(dir):
            os.makedirs(dir)

        filename = string.join([year, month, day],"-")
        filename = dir + os.sep + filename
        filename = filename + ".xml"
        return filename

    def prepare_relative_uri(self,date):
        date_components = time.gmtime(date)
        year = "%d" % date_components[0]
        month = "%02d" % date_components[1]
        day = "%02d" % date_components[2]
        dir = string.join([year, month, day],os.sep)
        filename = string.join([year, month, day],"-")
        filename = dir + os.sep + filename
        return filename

    def get_date(self,filename):
        file = open(filename,'r')
        contents = file.read()
        file.close()

        parser = LastUpdatedParser()
        parser.feed(contents)

        return parser.get_last_updated()
