#!/usr/bin/python

import os
import stat
import re
import string
from xmllib import *

class TopicExtractor(XMLParser):
	def __init__(self, defaultTopic):
		XMLParser.__init__(self)
		self.topic=defaultTopic
		self.processingTopic=0

	def start_topic(self, attrs):
		self.processingTopic=1
		self.topic=self.topic+" - "

	def end_topic(self):
		self.processingTopic=0

	def get_topic(self):
		return self.topic

	def handle_data(self, data):
		if self.processingTopic:
			self.topic=self.topic+data

class Indexer:
	def __init__(self, tDir):
		self.theDict={}
		self.topDir=tDir
		self.depth=0
		self.files={}

	def process(self):
		self.processAux("")

	def compoundDir(self, tDir, stub):
		if stub == "":
			return tDir
		elif tDir == "":
			return stub
		else:
			return tDir+os.sep+stub

	def handleXML(self, theDir, dfrag, fname):
		self.files[self.depth].append(self.compoundDir(dfrag,fname))
		self.theDict[theDir]['xml'].append(fname)

	def handleBinary(self, theDir, fname):
		self.theDict[theDir]['bin'].append(fname)

	def handleDir(self, theDir, fname):
		self.theDict[theDir]['dir'].append(fname)

	def processAux(self, dFrag):
		self.depth=self.depth+1
		if not self.files.has_key(self.depth):
			self.files[self.depth]=[]
		thisDir=self.compoundDir(self.topDir, dFrag)
		os.chdir(thisDir)
		self.theDict[thisDir]={'xml': [], 'bin': [], 'dir': []}
		# print "Processing",thisDir," Depth",self.depth
		thisDirContents=os.listdir(thisDir)
		for fname in thisDirContents:
			if stat.S_ISDIR(os.stat(fname)[stat.ST_MODE]):
				if not re.match("^(CVS|images|htdig|\.)", fname) and self.depth<4:
					self.processAux(self.compoundDir(dFrag,fname))
					self.handleDir(thisDir, fname)
					os.chdir(thisDir)
			else:
				# print "File",fname
				if re.match(".*\.xml$", fname):
					self.handleXML(thisDir, dFrag, fname)
				elif re.match(".*\.(jpe?g|JPG|gif|png|html)$",
							  fname):
					self.handleBinary(thisDir, fname)

		self.writeIndex(dFrag)
		self.depth=self.depth-1

	def grabTopic(self, dir, f, deftopic):
		xt=TopicExtractor(deftopic)
		fh=open("%s/%s" % (dir, f), "r")
		xt.feed(fh.read())
		fh.close()
		return xt.get_topic()

	def writeIndex(self,dFrag):
		thisDir=self.compoundDir(self.topDir, dFrag)
		if self.depth==3:
			# for each day link to that day
			mh=open("index.xml", "w")
			mh.write("<?xml version='1.0' encoding='iso-8859-1'?>\n")
			mh.write("<!DOCTYPE month>\n")
			mh.write("<month name=\"%s\">\n" % (dFrag))
			self.theDict[thisDir]['dir'].sort()
			for d in self.theDict[thisDir]['dir']:
				nd=self.compoundDir(thisDir, d)
				for f in self.theDict[nd]['xml']:
					topic=self.grabTopic(nd, f, d)
					mh.write("<day href=\"/%s/%s/%s\">" % \
									 (dFrag, d,	string.replace(f, "xml", "html")) \
									 + topic + "</day>\n")
			mh.write("</month>\n")
			mh.close()
		elif self.depth==2:
			mh=open("index.xml", "w")
			mh.write("<?xml version='1.0' encoding='iso-8859-1'?>\n")
			mh.write("<!DOCTYPE year>\n")
			mh.write( "<year name=\"%s\">\n" % (dFrag))
			for d in self.theDict[thisDir]['dir']:
				mh.write( "<month href=\"/%s/%s/index.html\">" % \
									(dFrag, d) + d + "</month>\n")
			mh.write("</year>\n")
			mh.close()
		elif self.depth==1:
			mh=open("nav.xml", "w")
			mh.write("<?xml version='1.0' encoding='iso-8859-1'?>\n")
			mh.write("<!DOCTYPE nav>\n<nav>\n")
			l=m.files[4]
			l.sort( lambda x, y: cmp(y, x) )
			for j in l[0:4]:
				mh.write( "<recent href=\"/%s\">%s</recent>\n" % \
							(string.replace(j, "xml", "html"),
							 j[0:(string.rfind(j, os.sep))]))

			self.theDict[thisDir]['dir'].sort( lambda x, y: cmp(y, x) )
			for d in self.theDict[thisDir]['dir']:
				mh.write("<year name=\"%s\">\n" % (d))
				nd=self.compoundDir(thisDir, d)
				self.theDict[nd]['dir'].sort( lambda x, y: cmp(y, x) )
				for f in self.theDict[nd]['dir']:
					mh.write( "<month href=\"/%s/%s/index.html\">" % (d, f) + d + \
										"/" + f	+ "</month>\n")
				mh.write( "</year>\n")
			mh.write("</nav>\n")
			mh.close()

if __name__ == '__main__':
	m=Indexer("/home/rdfig/public_html")
	m.process()
	
