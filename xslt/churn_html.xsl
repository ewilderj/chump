<?xml version="1.0"?>
<!-- $Id: churn_html.xsl,v 1.2 2002/11/06 11:16:43 edmundd Exp $ -->
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
<!-- ( <a href="#{time}">permalink</a> ) -->
</span>
</p>
<blockquote>
<xsl:for-each select="comment">
<xsl:choose>
<xsl:when test="starts-with(.,'/me ')"> 
<span class="commenter"><xsl:value-of select="@nick"/>
<xsl:text> </xsl:text>
<xsl:value-of select="substring-after(., '/me ')"/></span>
</xsl:when>
<xsl:otherwise>
<span class="commenter"><xsl:value-of select="@nick"/>: </span>
<span class="comment"><xsl:apply-templates/></span>
</xsl:otherwise>
</xsl:choose>
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
<h4>Older Pages</h4>
<p class="archive"><b><a href="/search/">Search</a></b></p>
<div class="archive">
<xsl:apply-templates select="year/month"/>
</div>
</xsl:template>

<xsl:template match="/churn">
<html>
<head>
<link type="text/css" href="/churn.css" rel="stylesheet"/>
<title>My First Chump, last cranked at <xsl:value-of select="last-updated" /></title>
</head>
<body bgcolor="#ffffff">
<h1>
My First Chump
</h1>
<table width="100%"><tr><td valign="top">
<xsl:apply-templates/>
</td><td valign="top">&#160;&#160;&#160;</td>
<td valign="top">
<xsl:comment>** change the path below to where your nav.xml files lives</xsl:comment>
<xsl:apply-templates select="document('file:///usr/home/edmundd/www/htdocs/rdfig/nav.xml')" />
</td></tr></table>
<hr noshade="noshade"/>
<div class="attribution" align="right">Run by the
<a href="http://usefulinc.com/chump/">Daily Chump</a> bot.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
