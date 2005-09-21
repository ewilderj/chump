<?xml version='1.0'?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0' 
    xmlns:rss="http://purl.org/rss/1.0/" 
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:admin="http://webself.net/mvcb/" 
	exclude-result-prefixes="rdf dc admin rss"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

<xsl:output indent="yes" encoding="utf-8" method="xml"
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  />

    <xsl:template match="/">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                <link title="Default" type="text/css" href="/nu.css" rel="stylesheet" media="screen" />
                <link rel="alternate" type="application/rss+xml" title="RSS" href="/chumpologica.rdf" />
				<title>chumpologica: the collected writings of the chumps</title>
            </head>
            <body>
                <div id="all">
                    <div id="clogicalogo">
                        <img src="/logica/chumpologica.png"
							width="415" height="69" alt="chumpologica" />
                    </div>
					<div id="main">
                    <xsl:apply-templates select="//rss:channel" />
                    <xsl:apply-templates select="//rss:item" />
					</div>
                </div>
				<div id="attribution">Copyright &#169; The PANTS Collective. Created by the Chump Aggregator. A <a href="http://usefulinc.com">Useful</a> Production. <a href="mailto:chump&#64;heddley&#46;com">Contact us</a>.</div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="rss:channel">
            <xsl:variable name="dcdate" select="dc:date" />
            <xsl:variable name="date" select="substring-before($dcdate,'T')" />
            <xsl:variable name="tmptime" select="substring-after($dcdate,'T')" />
            <xsl:variable name="timehour" select="substring-before($tmptime,':')" />
            <xsl:variable name="timeminute" select="substring-before(substring-after($tmptime,':'),':')" />
        <div id="clogicatimestamp">last updated at <xsl:value-of select="$date" /> <xsl:value-of select="$timehour" />:<xsl:value-of select="$timeminute" /></div>
        <div id="clogicatopic">the collected writings of <a href="/">daily chump</a> regulars</div>
    </xsl:template>

    <xsl:template match="rss:item">
        <div class="item">
            <xsl:variable name="dcdate" select="dc:date" />
            <xsl:variable name="date" select="substring-before($dcdate,'T')" />
            <xsl:variable name="tmptime" select="substring-after($dcdate,'T')" />
            <xsl:variable name="time" select="substring-before($tmptime,'Z')" />
            <xsl:variable name="pos" select="position()-1" />
            <xsl:variable name="prevdcdate" select="../rss:item[$pos]/dc:date" />
            <xsl:variable name="prevdate" select="substring-before($prevdcdate,'T')" />
            <xsl:if test="$date != $prevdate">
                <div class="clogicadate"><xsl:value-of select="$date" /></div>
            </xsl:if>

			<div class="title"><a href="{rss:link}"><xsl:value-of select="rss:title" /></a></div>
			<div class="byline">from <span class="commenter"><a href="{dc:relation}"><xsl:value-of select="dc:source" /></a></span> at <xsl:value-of select="$time" /></div>
			<div class="comments">
                <span class="commenter"><xsl:value-of select="dc:creator" />: </span><span class="comment"><xsl:value-of select="rss:description" /></span>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
