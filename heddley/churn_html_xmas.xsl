<?xml version="1.0"?>
<!-- $Id: churn_html_xmas.xsl,v 1.2 2003/02/22 12:31:55 edmundd Exp $ -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  >

<xsl:output indent="yes" encoding="utf-8" method="html"
  doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" />

<xsl:template match="last-updated">
<p class="timestamp">last updated at <xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="topic">
<p class="topic"><xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="link">
<div id="d{time/@value}" class="item">
<p><span class="title">
<a name="{time}"></a>
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

<xsl:template match="pic/a/img">
<img class="ppic" src="{@src}" height="{@height}" width="{@width}" alt="{@alt}" />
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

<xsl:template match="pic">
<div class="pframe">
<a href="{a/@href}"><img class="ppic" src="/photos/{a/img/@src}"
    height="{a/img/@height}" width="{a/img/@width}" alt="{a/img/@alt}" /></a>
</div>
</xsl:template>

<xsl:template match="nav">
<div class="cgraph">
<div><a href="/photos/"><img src="/photos/chumpographica125.png"
   height="18" width="125"
   alt="chumpographica: photos from the chumps" class="clogo" /></a></div>
<div class="photos">
<xsl:apply-templates select="document('file:///home/pants/public_html/photos.xml')" />
<div class="carchive"><a class="carchivel" href="/photos/">more photos</a></div>
</div>
</div>
<h4>Search</h4>
<form method="get" action="http://search.pants.heddley.com/cgi-bin/htsearch">
    <input type="hidden" name="config" value="chump" />
    <input type="hidden" name="restrict" value="" />
    <input type="hidden" name="exclude" value="" />
    <input type="hidden" name="method" value="or" />
    <input type="hidden" name="format" value="long" />
    <input type="hidden" name="sort" value="score" />
    <input type="text" size="8" name="words" value="ocntrol" /> <input type="submit" value="Go" />
</form>
<h4>Recent Chumps</h4>
<div class="archive">
<xsl:apply-templates select="recent"/>
</div>
<h4>Older Chumps</h4>
<div class="archive">
<xsl:apply-templates select="year/month"/>
</div>
</xsl:template>

<xsl:template match="/churn">
<html>
<head>
<!-- <link title="England" type="text/css" href="/england.css" rel="stylesheet" media="screen" /> -->
<link title="Christmas (Default)" type="text/css" href="/xmas.css" rel="stylesheet" media="screen" />
<link title="Chump-o-Google" type="text/css" href="/googlechump.css" rel="alternate stylesheet" media="screen" />
<link title="Monkie Special" type="text/css" href="/phil.css" rel="alternate stylesheet" media="screen" />
<link title="Classic Beige" type="text/css" href="/churn-classic.css" rel="alternate stylesheet" media="screen" />
<title>The PANTS Daily Chump, last cranked at <xsl:value-of select="last-updated" /></title>
</head>
<body bgcolor="#ffffff">
<p>
<a href="/"><img border="0" src="/xmaschump.png" width="469" height="72" alt="The Festive Daily Chump" /></a>
<img src="/xmasmascot.png" hspace="16" width="52" height="59" alt="Our Merry Own Chump" vspace="9" />
</p>
<table width="100%"><tr><td valign="top">
<xsl:apply-templates/>
</td><td valign="top" width="40"> </td>
<td valign="top">
<xsl:apply-templates select="document('file:///home/pants/public_html/nav.xml')" />
</td></tr></table>
<hr noshade="noshade"/>
<div class="attribution" align="right">Copyright &#169; The PANTS Collective. Created by the <a href="http://usefulinc.com/chump/">Chump Bot</a>. A <a href="http://usefulinc.com">Useful</a> Production. <a href="mailto:chump&#64;heddley&#46;com">Contact us</a>.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
