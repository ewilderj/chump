<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:chump="http://usefulinc.com/ns/chump#" 
      xmlns:foaf="http://xmlns.com/foaf/0.1/" 
      xmlns:dcterms="http://purl.org/dc/terms/"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:xhtml="http://www.w3.org/1999/xhtml"
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <rdf:RDF xmlns:chump="http://usefulinc.com/ns/chump#" 
      xmlns:foaf="http://xmlns.com/foaf/0.1/" 
      xmlns:dcterms="http://purl.org/dc/terms/"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
      <xsl:apply-templates select="churn" />
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="churn">
      <chump:Churn rdf:about="http://pants.heddley.com/{/churn/relative-uri-stub/@value}">
      <dcterms:modified><xsl:value-of select="translate(last-updated,' ','T')" />Z</dcterms:modified>
      <dc:title><xsl:value-of select="topic" /></dc:title>
    </chump:Churn>
    <xsl:apply-templates select="link" />
  </xsl:template>

  <xsl:template match="link">
    <xsl:variable name="churndate" select="substring(../last-updated,0,11)" />
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="url">
          <xsl:choose>
            <xsl:when test="contains(keywords,'photos:')">Photo</xsl:when>
            <xsl:otherwise>Link</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>Blurb</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$type}" namespace="http://usefulinc.com/ns/chump#">
        <xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">http://pants.heddley.com/<xsl:value-of select="/churn/relative-uri-stub/@value" />#<xsl:value-of select="time/@value" /></xsl:attribute>
      <xsl:if test="url"><chump:url rdf:resource="{url}" /></xsl:if>
      <chump:churn rdf:resource="http://pants.heddley.com/{/churn/relative-uri-stub/@value}" />
      <dc:date><xsl:value-of select="translate(time,' ','T')" />Z</dc:date>
      <dc:title><xsl:value-of select="title" /></dc:title>
      <xsl:call-template name="do-keywords">
        <xsl:with-param name="keywords" select="keywords" />
      </xsl:call-template>
      <chump:contributor>
        <foaf:Person>
          <foaf:nick><xsl:value-of select="nick" /></foaf:nick>
        </foaf:Person>
      </chump:contributor>
      <chump:comments rdf:parseType="Collection">
        <xsl:apply-templates select="comment" />
      </chump:comments>
    </xsl:element>
  </xsl:template>

  <xsl:template match="comment">
    <chump:Comment>
      <chump:contributor>
        <foaf:Person>
          <foaf:nick><xsl:value-of select="@nick" /></foaf:nick>
        </foaf:Person>
      </chump:contributor>
      <dc:description rdf:parseType="Literal"><xsl:apply-templates select="*|text()" mode="xhtml"/></dc:description>
    </chump:Comment>
  </xsl:template>

  <xsl:template match="@*" mode="xhtml">
    <xsl:attribute name="{name(.)}" namespace="http://www.w3.org/1999/xhtml"><xsl:value-of select="." /></xsl:attribute>
  </xsl:template>

  <xsl:template match="text()" mode="xhtml">
    <xsl:copy select="." />
  </xsl:template>

  <xsl:template match="*" mode="xhtml">
    <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml"><xsl:apply-templates select="@*|text()" mode="xhtml" /></xsl:element>
  </xsl:template>

  <xsl:template name="do-keywords">
    <xsl:param name="keywords" />
    <xsl:choose>
      <xsl:when test="contains($keywords,':')">
        <xsl:call-template name="do-keywords">
          <xsl:with-param name="keywords" select="substring-after($keywords,':')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="substring-before($keywords,',')">
        <dc:subject><xsl:value-of select="substring-before($keywords,',')" /></dc:subject>
        <xsl:call-template name="do-keywords">
          <xsl:with-param name="keywords" select="substring-after($keywords,',')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="string-length($keywords)">
          <dc:subject><xsl:value-of select="$keywords" /></dc:subject>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
