<?xml version="1.0"?>
<!-- $Id: month_html_xmas.xsl,v 1.2 2003/02/22 12:31:55 edmundd Exp $ -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  >

<xsl:output indent="yes" encoding="utf-8"
    doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
	method="html" />

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
<h4>Recent Chumps</h4>
<div class="archive">
<a href="/index.html">Current issue</a><br /><br />
<xsl:apply-templates select="recent"/>
</div>
<h4>Older Chumps</h4>
<p class="archive"><b><a href="/search/">Search</a></b></p>
<div class="archive">
<xsl:apply-templates select="year/month"/>
</div>
</xsl:template>

<xsl:template match="/month">
<html>
<head>
<link type="text/css" href="/xmas.css" rel="stylesheet"/>
<title>The PANTS Daily Chump Archive For <xsl:value-of select="@name" /></title>
</head>
<body bgcolor="#ffffff">
<p>
<a href="/index.html"><img src="/xmaschump.png" width="469" height="72" alt="The Festive Daily Chump" border="0" /></a>
<img src="/xmasmascot.png" width="52" height="59" alt="Our Merry Own Chump" vspace="9" hspace="16" />
</p>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr><td valign="top">
<h4>Archive for <xsl:value-of select="@name"/></h4>
<ul class="archive">
<xsl:apply-templates select="day" />
</ul>
</td><td valign="top" width="16">&#160;&#160;&#160;</td>
<td valign="top" width="100">
<xsl:apply-templates select="document('file:///home/pants/public_html/nav.xml')" />
</td></tr></table>
<hr noshade="noshade"/>
<div class="attribution" align="right">Copyright &#169; The PANTS Collective. Created by the <a href="http://usefulinc.com/chump/">Chump Bot</a>. A <a href="http://usefulinc.com">Useful</a> Production. <a href="mailto:chump&#64;heddley&#46;com">Contact us</a>.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
