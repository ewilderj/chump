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

<xsl:param name="searchphrase" />
<xsl:param name="mode" />

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

<xsl:template name="searchbox">
<form  method="get" action="http://pants.heddley.com/search">
<div id="mainsearch">
    <input tabindex="1" class="txt" type="text" size="20" name="query" value="{$searchphrase}"/>
    <input tabindex="2" class="btn" type="submit" value="Search" />
</div>
</form>
</xsl:template>

<xsl:template match="result">
<xsl:variable name="unixtime" select="field[@name='unixtime']" />

<xsl:choose>
<xsl:when test="field[@name='uristub']">
<xsl:apply-templates select="document(concat(concat('file:///home/pants/public_html/', field[@name='uristub']),'.xml'))/churn/link[string(time/@value)=$unixtime]" />
</xsl:when>

<xsl:otherwise>
<xsl:apply-templates select="document(concat(concat('file:///home/pants/public_html/', concat (translate(substring-before(field[@name='time'], ' '), '-', '/'), concat ('/', substring-before(field[@name='time'], ' ')))), '.xml'))/churn/link[string(time/@value)=$unixtime]" />
</xsl:otherwise>
</xsl:choose>

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
(<a href="{translate(substring-before(time, ' '), '-', '/')}/{substring-before(time, ' ')}.html#{time/@value}">+</a>)
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
<form method="get" action="http://pants.heddley.com/search">
<div id="searchform">
    <input class="txt" type="text" size="8" name="query" value="{$searchphrase}" />
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

<xsl:template match="/results|/error|/noterms">
<html>
<head>
<link title="nuskool" type="text/css" href="/nu.css" rel="stylesheet" media="screen" />
<link type="text/css" href="/cake.css" rel="stylesheet" media="screen" />
<link title="dogs in hats" type="text/css" href="/doghat.css" rel="alternate stylesheet" media="screen" />
<link rel="icon" href="/favicon.ico" type="image/x-icon"/>
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon"/>
<script type="text/javascript" src="/cake.js" language="JavaScript">/* */</script>
<xsl:choose>
	<xsl:when test="$mode = 'keywords'">
		<title>The PANTS Daily Chump: fauxonomic tagspace<xsl:if test="$searchphrase"> for '<xsl:value-of select="$searchphrase"/>'</xsl:if></title>
	</xsl:when>
	<xsl:otherwise>
		<title>The PANTS Daily Chump: Search Results</title>
	</xsl:otherwise>
</xsl:choose>
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
	<xsl:choose>
		<xsl:when test="/results">
			<xsl:choose>
				<xsl:when test="$mode = 'keywords'">
					<div id="timestamp">hot from the pantsphere fauxonomy</div>
					<div id="topic">found <xsl:value-of select="@count"/><xsl:text> </xsl:text>
						<xsl:choose>
							<xsl:when test="@count = '1'">item</xsl:when>
							<xsl:otherwise>items</xsl:otherwise>
						</xsl:choose>
						tagged with '<xsl:value-of select="$searchphrase"/>'
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div id="timestamp">your search found <xsl:value-of select="@count"/><xsl:text> </xsl:text>
						<xsl:choose>
							<xsl:when test="@count = '1'">result</xsl:when>
							<xsl:otherwise>results</xsl:otherwise>
						</xsl:choose>
					</div>
					<div id="topic">coming up... those search results in full</div>
					<xsl:call-template name="searchbox" />
					<br />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates/>
		</xsl:when> <!-- end of results -->
		<xsl:when test="/noterms">
			<xsl:choose>
				<xsl:when test="$mode = 'keywords'">
					<div id="timestamp">no tag supplied. pecans to you.</div>
					<div id="topic">sit down, and we'll tell you all about it</div>
					<div class="item">
					<div class="title"><a id="howto">Chump tagsearch instructinos</a></div>
					<div class="byline">posted by <span class="nick">phl</span>
					at <span class="time">2005-03-08 01:26</span>
					(<a href="/tag/#howto">+</a>)
					<xsl:call-template name="keyword">
						<xsl:with-param name="unixtime" select="0"/>
						<xsl:with-param name="kw"/>
						<xsl:with-param name="tail">chump,meta,tagging</xsl:with-param>
					</xsl:call-template>
					</div>
					<div class="comments">
					<span class="commenter nick-phl">phl: </span><span class="comment">You can search for items tagged with keywords by typing stuff into the address-bar.</span><br/>
					<span class="commenter nick-phl">phl: </span><span class="comment">For instance, if you go to <a href="/tag/cat">/tag/cat</a>, you can see all the items with "cat" as a keyword.</span><br/>
					<span class="commenter nick-phl">phl: </span><span class="comment">To search with multiple terms, use a comma between each keyword:</span><br/>
					<span class="commenter nick-phl">phl: </span><span class="comment"><a href="/tag/photos,cat">/tag/photos,cat</a> will probably find photos of cats.</span><br/>
					<span class="commenter nick-phl">phl: </span><span class="comment">You can also use | to search for one thing or another:</span><br/>
					<span class="commenter nick-phl">phl: </span><span class="comment"><a href="/tag/beards|cheese|drumnbass">/tag/beards|cheese|drumnbass</a> finds items to do with beards, cheese, or drum'n'bass.</span><br/>
					<span class="commenter nick-phl">phl: </span><span class="comment">Finally, you can use parentheses to group terms:</span><br/>
					<span class="commenter nick-phl">phl: </span><span class="comment"><a href="/tag/photos,(cat|dog)">/tag/photos,(cat|dog)</a> looks for items that are tagged with photos, and either cat or dog.</span><br/>
					</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div id="topic">You need to search for something, silly.</div>
					<xsl:call-template name="searchbox" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<p>Sorry, an error occurred while searching.</p>
			<xsl:comment>
				<xsl:value-of select="/error" />
			</xsl:comment>
		</xsl:otherwise>
	</xsl:choose>
</div> <!-- /main -->
</div> <!-- /all -->
<div id="attribution">Copyright &#169; The PANTS Collective. Created by the <a href="http://usefulinc.com/chump/">Chump Bot</a>. A <a href="http://usefulinc.com">Useful</a> Production. <a href="mailto:chump&#64;heddley&#46;com">Contact us</a>.</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
