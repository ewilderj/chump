<?xml version="1.0"?>
<!-- $Id: churn_mini_html.xsl,v 1.1 2002/06/12 09:48:39 edmundd Exp $ -->
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
<a name="{time/@value}"></a>
<xsl:choose>
<xsl:when test="@type='blurb'">
<xsl:value-of select="title" />
</xsl:when>
<xsl:otherwise>
<a href="{url}" target="_blank">
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
(<a href="#{time}" target="_blank">+</a>)
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
<xsl:choose>
<xsl:when test="@alt">
<span class="imagelink">image: <a href="{@src}" target="_blank"><xsl:value-of select="@alt"/></a></span>
</xsl:when>
<xsl:otherwise>
<span class="imagelink"><a href="{@src}" target="_blank">image</a></span>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="i">
<span class="emph"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="a">
<a href="{@href}" target="_blank"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="topic" />

<xsl:template match="/churn">
<html>
<head>
<meta http-equiv="Refresh" content="300" />
<link type="text/css" href="/mini.css" rel="stylesheet"/>
<title>The Daily Chump Mini</title>
</head>
<body bgcolor="#ffffff">
<span class="chumpheader">The Daily Chump</span>&#160;<img src="htdig/star.gif" alt="mascot"/>
<xsl:apply-templates/>
<div class="attribution" align="left">Run by the
<a href="http://usefulinc.com/chump/" target="_blank">Daily Chump</a> bot.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
