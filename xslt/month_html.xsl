<?xml version="1.0"?>
<!-- $Id: month_html.xsl,v 1.1 2001/03/16 08:33:33 edmundd Exp $ -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  >

<xsl:output indent="yes" encoding="ISO-8859-1" method="html" />

<xsl:template match="last-updated">
<p class="timestamp">last updated at <xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="link">
<div id="{time}" class="item">
<p><span class="title">
<a name="{time}"></a>
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
</span>
<br />
<span class="byline">
posted by <span class="nick"><xsl:value-of select="nick"/></span>
at <span class="time"><xsl:value-of select="time"/></span>
( <a href="#{time}">permalink</a> )
</span>
</p>
<blockquote>
<xsl:for-each select="comment">
<span class="commenter"><xsl:value-of select="@nick"/>: </span>
<span class="comment"><xsl:value-of select="."/></span>
<br />
</xsl:for-each>
</blockquote>
</div>
</xsl:template>

<xsl:template match="recent">
<a href="{@href}"><xsl:value-of select="."/></a><br />
</xsl:template>

<xsl:template match="day">
<li><a href="{@href}"><xsl:value-of select="."/></a></li>
</xsl:template>

<xsl:template match="month/day">
<li><a href="{@href}"><xsl:value-of select="."/></a></li>
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

<xsl:template match="/month">
<html>
<head>
<link type="text/css" href="/churn.css" rel="stylesheet"/>
<title>My First Chump Archive For <xsl:value-of select="@name" /></title>
</head>
<body bgcolor="#ffffff">
<h1>My First Chump -- Archives</h1>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr><td valign="top">
<h4>Archive for <xsl:value-of select="@name"/></h4>
<ul class="archive">
<xsl:apply-templates select="day" />
</ul>
</td><td valign="top" width="16">&#160;&#160;&#160;</td>
<td valign="top" width="100">
<xsl:commment>** update for your location of nav.xml **</xsl:comment>
<xsl:apply-templates select="document('file:///usr/home/edmundd/www/htdocs/rdfig/nav.xml')" />
</td></tr></table>
<hr noshade="noshade"/>
<div class="attribution" align="right">Run by the
<a href="http://usefulinc.com/chump/">Daily Chump</a>.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
