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
			<span class="clbyline">from <span class="clsource"><a href="{dc:relation}"><xsl:value-of select="dc:creator" /></a></span></span></div>
	</div>
</xsl:template>

<xsl:template match="last-updated">
<div id="timestamp">last updated at <xsl:value-of select="."/></div>
</xsl:template>

<xsl:template match="topic">
<div id="topic"><xsl:value-of select="."/></div>
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
<div id="cgraph">
<div id="clogo"><a href="/photos/" title="selected photos taken by the chumps"><img src="/photos/chumpographica125.png"
   height="18" width="125"
   alt="chumpographica: photos from the chumps" class="clogo" /></a></div>
<xsl:apply-templates select="document('file:///home/pants/public_html/photos.xml')" />
<div class="carchive"><a class="carchive" href="/photos/">more photos</a></div>
</div>

<div class="shadowbox">
<div id="clogica">
<div id="cllogo"><a href="/logica/" title="read the collected writings of the chumps"><img src="/logica/chumpologica125.png"
   height="18" width="125"
   alt="chumpologica: the collected writings of the chumps" class="cllogo" /></a></div>
<xsl:apply-templates select="document('file:///home/pants/public_html/chumpologica.rdf')" />
<div class="clarchive"><a class="clarchive" href="/logica/">more blogs</a></div>
</div><!-- clogica -->
</div>

<div class="shadowbox">
<div id="nav">
<h1 id="search">search</h1>
<form method="post" action="http://pants.heddley.com/search">
<div id="searchform">
    <input class="txt" type="text" size="8" name="query" value="ocntrol" />
<input class="btn" type="submit" value="Go" />
    </div>
</form>
<h1>recent chumps</h1>
<div class="archive">
<xsl:apply-templates select="recent"/>
</div>
<h1>older chumps</h1>
<form method="get" action="http://pants.heddley.com/archive">
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

<xsl:template match="month">
<li><a href="{@href}"><xsl:value-of select="."/></a></li>
</xsl:template>

<xsl:template match="/year">
<html>
<head>
<link title="nuskool" type="text/css" href="http://pants.heddley.com/nu.css" rel="stylesheet" media="screen" />
<title>The PANTS Daily Chump Archive For <xsl:value-of select="@name" /></title></head>
<body>
<div id="all">
<div id="logo">
<a href="/"><img src="/newchumplogo.png" alt="The Daily Chump"/></a>
</div>
<div id="side">
<xsl:apply-templates select="document('file:///home/pants/public_html/nav.xml')" />
</div> <!-- /side -->
<div id="main">
<h4>Archive for <xsl:value-of select="@name"/></h4>
<ul class="monthindex">
<xsl:apply-templates select="month" />
</ul>
</div> <!-- /main -->
</div> <!-- /all -->
<div id="attribution">Copyright &#169; The PANTS Collective. Created by the <a href="http://usefulinc.com/chump/">Chump Bot</a>. A <a href="http://usefulinc.com">Useful</a> Production. <a href="mailto:chump&#64;heddley&#46;com">Contact us</a>.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
