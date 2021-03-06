<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rss="http://purl.org/rss/1.0/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:admin="http://webself.net/mvcb/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="rdf dc admin rss"
  version="1.0"
  >
<xsl:import href="keywords.xsl"/>

<xsl:output indent="yes" encoding="utf-8" method="xml"
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  />

<xsl:template match="rdf:RDF">
<xsl:apply-templates select="rss:item[1]" />
<xsl:apply-templates select="rss:item[2]" />
<xsl:apply-templates select="rss:item[3]" />
<xsl:apply-templates select="rss:item[4]" />
</xsl:template>

<xsl:template match="rss:item">
		<xsl:variable name="dcdate" select="dc:date" />
		<xsl:variable name="date" select="substring-before($dcdate,'T')" />
		<xsl:variable name="time" select="substring-after($dcdate,'T')" />
		<xsl:variable name="pos" select="position()-1" />
		<xsl:variable name="prevdcdate" select="../rss:item[$pos]/dc:date" />
		<xsl:variable name="prevdate" select="substring-before($prevdcdate,'T')" />
	<div class="clentry">
			<div><span class="cltitle"><a href="{rss:link}"><xsl:value-of select="rss:title" /></a></span>
			<span class="clbyline"> from <span class="clsource"><a href="{dc:relation}"><xsl:value-of select="dc:creator" /></a></span></span></div>
	</div>
</xsl:template>

<xsl:template match="last-updated">
<div id="timestamp">last updated at <xsl:value-of select="."/></div>
</xsl:template>

<xsl:template match="topic">
<div id="topic"><xsl:value-of select="."/></div>
</xsl:template>

<xsl:template match="link">
<div id="d{time/@value}" class="item">
<div class="title">
<a name="{time/@value}" id="a{time/@value}"></a>
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
</div>
<div class="byline">
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
<xsl:apply-templates select="keywords">
<xsl:with-param name="unixtime" select="time/@value"/>
</xsl:apply-templates>
</div>
<div class="comments">
<xsl:for-each select="comment">
<xsl:choose>
<xsl:when test="starts-with(.,'/me ')">
<span class="commenter nick-{@nick}"><xsl:value-of select="@nick"/>
<xsl:text> </xsl:text>
<xsl:value-of select="substring-after(., '/me ')"/></span>
</xsl:when>
<xsl:otherwise>
<span class="commenter nick-{@nick}"><xsl:value-of select="@nick"/>: </span>
<span class="comment"><xsl:apply-templates/></span>
</xsl:otherwise>
</xsl:choose>
<br />
</xsl:for-each>
</div><!-- /comments -->
</div><!-- /item -->
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
<option value="{concat(substring-before(., '/'), substring-after(., '/'))}"><xsl:value-of select="."/></option>
</xsl:template>

<xsl:template match="pic">
<div class="pframe">
<div class="plink">
<a href="{a/@href}"><img class="ppic" src="/photos/{a/img/@src}"
    height="{a/img/@height}" width="{a/img/@width}" alt="{a/img/@alt}" /></a>
</div>
</div>
</xsl:template>

<xsl:template match="nav">

<div id="cllogo"><a href="/logica/" title="read the collected writings of the chumps"><img src="/logica/chumpologica125.png"
   height="18" width="125"
      alt="chumpologica: the collected writings of the chumps" class="cllogo" /></a></div>

<div class="shadowbox">
<div id="clogica">
	  <xsl:apply-templates select="document('file:///home/pants/public_html/chumpologica.rdf')" />
	  <div class="clarchive"><a class="clarchive" href="/logica/">more blogs</a></div></div><!-- clogica -->
</div>

<div id="cgraph">
<div id="clogo"><a href="/photos/" title="selected photos taken by the chumps"><img src="/photos/chumpographica125.png"
   height="18" width="125"
   alt="chumpographica: photos from the chumps" class="clogo" /></a></div>
<xsl:apply-templates select="document('file:///home/pants/public_html/photos.xml')" />
<div class="carchive"><a class="carchive" href="/photos/">more photos</a></div>
</div>

<div class="shadowbox">
<div id="nav">
<h1 id="search">search</h1>
<form method="get" action="http://dailychump.org/search">
<div id="searchform">
    <input class="txt" type="text" size="8" name="query" value="ocntrol" onfocus="if(this.value=='ocntrol')this.value=''"/>
<input class="btn" type="submit" value="Go" />
    </div>
</form>
<h1>recent chumps</h1>
<div class="archive">
<xsl:apply-templates select="recent"/>
</div>
<h1>older chumps</h1>
<form method="get" action="http://dailychump.org/archive">
<div class="archive">
<select name="month">
<xsl:apply-templates select="year/month"/>
</select>
<input class="btn" type="submit" name="go" value="Go" />
</div>
</form>
</div><!-- /nav -->
</div>

</xsl:template>

<xsl:template match="/churn">
<html>
<head>
<link title="nuskool" type="text/css" href="/nu.css" rel="stylesheet" media="screen" />
<link type="text/css" href="/cake.css" rel="stylesheet" media="screen" />
<link title="dogs in hats" type="text/css" href="/doghat.css" rel="alternate stylesheet" media="screen" />
<link rel="icon" href="/favicon.ico" type="image/x-icon"/>
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon"/>
<link rel="alternate" type="application/rss+xml" title="The RSS of the Pants Daily Chump" href="http://dailychump.org/index.rss"/>
<script type="text/javascript" src="/cake.js">/* */</script>
<title>The PANTS Daily Chump, last cranked at <xsl:value-of select="last-updated" /></title>
</head>
<body>
<div id="all">
<div id="logo">
<a href="/"><img src="/newchumplogo.png" alt="The Daily Chump"/></a>
</div>
<div id="side">
<xsl:apply-templates select="document('file:///home/pants/public_html/nav.xml')" />
</div> <!-- /side -->
<div id="main">
<xsl:apply-templates/>
<!-- <xsl:if test="count(link)&lt;5">
	<xsl:variable name="yesterdaypath" select="document('file:///home/pants/public_html/nav.xml')/nav/recent[2]" />
	<xsl:variable name="yesterday" select="translate($yesterdaypath,'/','-')" />
	<xsl:variable name="makeup" select="5-count(link)" />
	<xsl:variable name="filename" select="concat('file:///home/pants/public_html/',concat($yesterdaypath,concat('/',concat($yesterday,'.xml'))))" />
	<xsl:variable name="yesterdayxml" select="document($filename)/churn/link[position()&lt;=$makeup]"/>
	<xsl:apply-templates select="$yesterdayxml"/>
</xsl:if> -->

</div> <!-- /main -->
</div> <!-- /all -->
<div id="attribution">Copyright &#169; The PANTS Collective. Created by the <a href="http://usefulinc.com/chump/">Chump Bot</a>. A <a href="http://usefulinc.com">Useful</a> Production. <a href="mailto:chump&#64;heddley&#46;com">Contact us</a>. <a href="http://dailychump.org/index.rss">Grab our RSS</a>.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
