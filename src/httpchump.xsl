<?xml version="1.0"?>
<!-- $Id: httpchump.xsl,v 1.1 2001/03/24 13:05:04 mattb Exp $ -->
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
<li><span class="title">
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
<blockquote>
<xsl:for-each select="comment">
<span class="commenter"><xsl:value-of select="@nick"/>: </span>
<span class="comment"><xsl:apply-templates/></span>
<br />
</xsl:for-each>
</blockquote>
</li>
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

<xsl:template match="/churn">
<html>
<head>
<title>My First Chump, last cranked at <xsl:value-of select="last-updated" /></title>
</head>
<body bgcolor="#ffffff">
<h1>
    Offline reading
</h1>
<ul>
<xsl:apply-templates/>
</ul>
<p>
    <h2>How to get an offline version of this page</h2>
</p>
<ul>
    <li>
        Download Plucker from http://plucker.gnu-designs.com and install it.
    </li>
    <li>
    Run the command: <pre>plucker-build -H http://test.picdiary.com:8000/html -M 2 -f chump</pre>
</li>
<li>
    Run the command: <pre>pilot-xfer -i ~/.plucker/chump.pdb</pre>
</li>
</ul>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
