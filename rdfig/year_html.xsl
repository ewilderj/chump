<?xml version="1.0"?>
<!-- $Id: year_html.xsl,v 1.2 2003/04/11 02:25:08 edmundd Exp $ -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
	  >

	  <xsl:output indent="yes" encoding="ISO-8859-1" method="html" />

<xsl:template match="year">
<html>
<head>
<link type="text/css" href="/churn.css" rel="stylesheet"/>
<title>RDF IG IRC Scratchpad Search</title>
</head>
<body bgcolor="#ffffff">
<h1><a href="/index.html">RDF Interest Group IRC Scratchpad</a></h1>
<p class="topic">Search the archives</p>

<p>
<form method="get" action="http://search.rdfig.xmlhack.com/cgi-bin/htsearch">
Match: <select name="method">
<option value="and">All</option>
<option value="or">Any</option>
<option value="boolean">Boolean</option>
</select>
Format: <select name="format">
<option value="builtin-long">Long</option>
<option value="builtin-short">Short</option>
</select>
Sort by: <select name="sort">
<option value="score">Score</option>
<option value="time">Time</option>
<option value="title">Title</option>
<option value="revscore">Reverse Score</option>
<option value="revtime">Reverse Time</option>
<option value="revtitle">Reverse Title</option>
</select>
<input type="hidden" name="config" value="rdfig" />
<input type="hidden" name="restrict" value="" />
<input type="hidden" name="exclude" value="" />
<br />
Search:
<input type="text" size="30" name="words" value="" />
<input type="submit" value="Search" />
</form>
</p>

<hr noshade="noshade"/>
<div class="attribution" align="right">Created by the
<a href="http://usefulinc.com/chump/">Daily Chump</a> bot. Hosted by
<a href="http://xmlhack.com/">XMLhack</a>.</div>

</body>
</html>
</xsl:template>

</xsl:stylesheet>
