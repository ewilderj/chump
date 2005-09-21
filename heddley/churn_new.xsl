<?xml version="1.0"?>    
<!-- $Id: churn_rss.xsl,v 1.2 2002/07/30 21:30:06 edmundd Exp $ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         version="1.0"
         xmlns:foaf="http://xmlns.com/foaf/0.1/"
         xmlns:chump="http://usefulinc.com/ns/chump#"
		 xmlns:content="http://purl.org/rss/1.0/modules/content/"
		 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

<xsl:output method="xml" indent="yes" />

<xsl:template>
        <xsl:apply-templates/>
</xsl:template>                 

<xsl:template match="churn">


<rdf:RDF
	 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	 xmlns:foaf="http://xmlns.com/foaf/0.1/"
     xmlns:chump="http://usefulinc.com/ns/chump#"
 	 xmlns="http://purl.org/rss/1.0/">

<channel rdf:about="http://pants.heddley.com/index.rss">
<link>http://pants.heddley.com/</link>

<title>The Daily Chump</title>
<description>
<xsl:if test="topic">
<xsl:value-of select="topic"/> --
</xsl:if>
last modified <xsl:value-of select="last-updated"/>
</description>

<items>

<rdf:Seq>

<xsl:for-each select="link">
<xsl:choose>
<xsl:when test="@type='blurb'">
<xsl:variable name="tdate" 
   select="substring-before(string(/churn/last-updated), ' ')" />
<xsl:variable name="tdir" select="translate($tdate, '-', '/')" />
<xsl:variable name="uri" select="concat('http://pants.heddley.com/', $tdir, '/', $tdate, '.html#', string(time/@value))" />
<rdf:li rdf:resource="{$uri}" />
</xsl:when>
<xsl:otherwise>
<rdf:li rdf:resource="{string(url)}" />
</xsl:otherwise>
</xsl:choose>
<xsl:text>
</xsl:text>
</xsl:for-each>
</rdf:Seq>
</items>
</channel>

<xsl:apply-templates select="link" />   

</rdf:RDF>

</xsl:template>


<xsl:template match="topic">
<title><xsl:value-of select="."/></title>


</xsl:template>




<xsl:template match="link">

<xsl:choose>
<xsl:when test="@type='blurb'">
<xsl:variable name="tdate" 
   select="substring-before(string(/churn/last-updated), ' ')" />
<xsl:variable name="tdir" select="translate($tdate, '-', '/')" />
<xsl:variable name="uri" select="concat('http://pants.heddley.com/', $tdir, '/', $tdate, '.html#', string(time/@value))" />
<item rdf:about="{$uri}">
<link><xsl:value-of select="$uri" /></link>
<chump:contributor>
    <foaf:Person>
        <foaf:nick><xsl:value-of select="nick"/></foaf:nick>
    </foaf:Person>
</chump:contributor>
<chump:contributedAt><xsl:value-of select="time" /></chump:contributedAt>
<title><xsl:value-of select="title" /></title>
<description>
 <xsl:apply-templates select="comment" mode="plain" />   
 (<xsl:value-of select="time" />)
</description>     
<content:encoded rdf:datatype="http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral">
<xsl:apply-templates select="comment" mode="encoded" />
</content:encoded>
</item>
</xsl:when>

<xsl:otherwise>
<item rdf:about="{./url}">
<link><xsl:value-of select="url" /></link>
<chump:contributor>
    <foaf:Person>
        <foaf:nick><xsl:value-of select="nick"/></foaf:nick>
    </foaf:Person>
</chump:contributor>
<chump:contributedAt><xsl:value-of select="time" /></chump:contributedAt>

<xsl:if test="count(title)=0"> 
    <title><xsl:value-of select="url" /></title>
    <description><xsl:value-of select="url" /></description>     
</xsl:if>

<xsl:if test="count(title)!=0">           

<title><xsl:value-of select="title" /></title>
<description>
 <xsl:apply-templates select="comment" mode="plain" />   
 (<xsl:value-of select="time" />)
</description>
<content:encoded rdf:datatype="http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral">
<xsl:apply-templates select="comment" mode="encoded" />
</content:encoded>

</xsl:if>

</item>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="comment" mode="encoded">     
<xsl:value-of select="@nick" /><xsl:text>: </xsl:text> 
<xsl:apply-templates select="text()|*" mode="encoded" />&lt;br /&gt;
</xsl:template>

<xsl:template match="img" mode="encoded">
&lt;img src="<xsl:value-of select="@src" />"&gt;<xsl:apply-templates select="text()|*" mode="encoded" />&lt;/img&gt;
</xsl:template>

<xsl:template match="a" mode="encoded">
&lt;a href="<xsl:value-of select="@href" />"&gt;<xsl:apply-templates select="text()|*" mode="encoded" />&lt;/a&gt;
</xsl:template>

<xsl:template match="i" mode="encoded">
&lt;i&gt;<xsl:apply-templates select="text()|*" mode="encoded" />&lt;/i&gt;
</xsl:template>

<xsl:template match="comment" mode="plain">     
<xsl:value-of select="@nick" /><xsl:text>: </xsl:text> 
<xsl:value-of select="." /><xsl:text>; 
</xsl:text>
</xsl:template>

</xsl:stylesheet>
