<?xml version="1.0"?>
<!-- $Id: churn_html.xsl,v 1.9 2003/04/11 02:25:07 edmundd Exp $ -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  >

<xsl:output indent="yes" encoding="ISO-8859-1" method="html" />

<xsl:template match="last-updated">
<p class="timestamp">last updated at <xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="topic">
<p class="topic"><xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="link">
<div id="{time}" class="item">
<p><span class="title">
<a name="{time/@value}"></a>
<xsl:choose>
<xsl:when test="@type='blurb'">
<xsl:value-of select="title" />
</xsl:when>
<xsl:otherwise>
<a href="{url}">
<xsl:choose>
<xsl:when test="title">
<xsl:value-of select="title" />
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="url" />
</xsl:otherwise>
</xsl:choose>
</a>
</xsl:otherwise>
</xsl:choose>
</span>
<br />
<span class="byline">
posted by <span class="nick"><xsl:value-of select="nick"/></span>
at <span class="time"><xsl:value-of select="time"/></span>
<xsl:choose>
<xsl:when test="//relative-uri-stub">
<xsl:value-of select="//relative-uri-stub" />
(<a href="/{//relative-uri-stub/@value}.html#{time/@value}">+</a>)
</xsl:when>
<xsl:otherwise>
(<a href="#{time/@value}">+</a>)
</xsl:otherwise>
</xsl:choose>
</span>
</p>
<blockquote>
<xsl:for-each select="comment">
<span class="commenter"><xsl:value-of select="@nick"/>: </span>
<span class="comment"><xsl:apply-templates/></span>
<br />
</xsl:for-each>
</blockquote>
</div>
</xsl:template>

<xsl:template match="img">
<img src="{@src}" alt="{@alt}" />
</xsl:template>

<xsl:template match="i">
<i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="a">
<a href="{@href}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="recent">
<a href="{@href}"><xsl:value-of select="."/></a><br />
</xsl:template>

<xsl:template match="month">
<a href="{@href}"><xsl:value-of select="."/></a><br />
</xsl:template>

<xsl:template match="nav">
<h4>Recent Pages</h4>
<div class="archive">
<a href="/index.html">Today's page</a><br /><br />
<xsl:apply-templates select="recent"/>
</div>
<h4>Semantic Web community</h4>
<div class="archive">
<a href="http://www.w3.org/RDF/Interest/">RDF Interest Group</a><br />
<a href="http://www.w3.org/2002/12/cal/">RDF Calendar taskforce</a>
(<a href="http://esw.w3.org/topic/RdfCalendar">wiki</a>)<br />
<a href="http://esw.w3.org/topic/GeoInfo">RDF Geo wiki</a><br />
<a href="http://lists.w3.org/Archives/Public/www-rdf-rules/">RDF Query and Rules</a><br />
<a href="http://lists.w3.org/Archives/Public/www-rdf-logic/">RDF Logic</a> for OWL<br />
</div>
<h4>IRC Events</h4>
<div class="archive">
<a href="http://esw.w3.org/topic/ScheduledTopicChat">Scheduling tips</a>
</div>
<h4>Syndicate</h4>
<div class="archive">
<a href="/index.rss" title="RSS 1.0 version of the RDF Interest Group IRC Scratchpad" type="application/rdf+xml">RSS 1.0</a>
</div>
<h4>Older Pages</h4>
<p class="archive"><b><a href="/search/">Search</a></b></p>
<p>
<form method="get" action="http://search.rdfig.xmlhack.com/cgi-bin/htsearch">
    <input type="hidden" name="config" value="rdfig" />
    <input type="hidden" name="restrict" value="" />
    <input type="hidden" name="exclude" value="" />
    <input type="hidden" name="method" value="or" />
    <input type="hidden" name="format" value="long" />
    <input type="hidden" name="sort" value="score" />
    <input type="text" size="8" name="words" value="" /> <input type="submit" value="Go" />
</form>
</p>
<div class="archive">
<xsl:apply-templates select="year/month"/>
</div>
</xsl:template>

<xsl:template match="/churn">
<html>
<head>
<link type="text/css" href="/churn.css" rel="stylesheet"/>
<title>RDF Interest Group IRC Scratchpad, last cranked at <xsl:value-of select="last-updated" /></title>
</head>
<body bgcolor="#ffffff">
<h1>
<a href="/">RDF Interest Group IRC Scratchpad</a>
</h1>
<h3><a href="http://www.w3.org/RDF/Interest/">RDF Interest Group Home Page</a></h3>
<p><a href="http://esw.w3.org/topic/InternetRelayChat">IRC</a> <a href="irc://irc.freenode.net:6667/rdfig">irc.freenode.net port 6667 channel #rdfig</a>.
<a href="http://ilrt.org/discovery/chatlogs/rdfig/">IRC logs</a> maintained by Dave Beckett. <a href="http://ilrt.org/discovery/chatlogs/rdfig/latest">Latest logs</a>.<br />
<a href="http://www.w3.org/2001/sw/">Semantic Web</a> developer collaborations are made at the
<a href="http://esw.w3.org/topic/FrontPage">ESW Wiki</a>.<br />
This page is created by the <a href="http://usefulinc.com/chump/">chump bot</a> -- <a href="http://usefulinc.com/chump/MANUAL.txt">instructions for use</a>.</p>
<table width="100%"><tr><td valign="top">
<xsl:apply-templates/>
</td><td valign="top">&#160;&#160;&#160;</td>
<td valign="top">
<xsl:apply-templates select="document('file:///home/rdfig/public_html/nav.xml')" />
</td></tr></table>
<hr noshade="noshade"/>
<div class="attribution" align="right">Created by the
<a href="http://usefulinc.com/chump/">Daily Chump</a> bot. Hosted by
<a href="http://xmlhack.com/">XMLhack</a>.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
