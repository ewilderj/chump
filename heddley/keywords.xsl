<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  version="1.0"
  >

<xsl:output indent="yes" encoding="utf-8" method="xml"
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  />

<xsl:template match="keywords">
	<!-- unixtime of the entry -->
	<xsl:param name="unixtime"/>
	<!-- If there are any keywords -->
	<xsl:if test="./text()">
		<!-- Strip off any 'photos:' prefix -->
		<xsl:variable name="kws">
			<!-- <xsl:choose>
			<xsl:when test="starts-with(./text(),'photos:')">
			<xsl:value-of select="substring-after(./text(),'photos:')"/>
			</xsl:when>
			<xsl:otherwise>
			<xsl:value-of select="./text()"/>
			</xsl:otherwise>
			</xsl:choose>
			-->
			<xsl:value-of select="translate(./text(),':',',')"/>
		</xsl:variable>
		<!-- Call keyword output template with CSV keyword string as tail -->
		<xsl:call-template name="keyword">
			<xsl:with-param name="unixtime" select="$unixtime"/>
			<xsl:with-param name="kw"/>
			<xsl:with-param name="tail">
				<xsl:value-of select="$kws"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Recursively outputs keyword search links from a CSV keyword string -->
<xsl:template name="keyword">
	<!-- unixtime of this entry -->
	<xsl:param name="unixtime"/>
	<!-- The keyword to output -->
	<xsl:param name="kw"/>
	<!-- Remainder of csv keyword string, no leading comma -->
	<xsl:param name="tail"/>

	<!-- Normalize space in the input keyword -->
	<xsl:variable name="nkw" select="normalize-space($kw)"/>
	<xsl:if test="$nkw">
		<a href="/tag/{$nkw}"><xsl:value-of select="$nkw"/></a><xsl:text> </xsl:text>
	</xsl:if>
	<xsl:if test="$tail">
		<xsl:choose>
			<xsl:when test="contains($tail,',')">
				<xsl:call-template name="keyword">
					<xsl:with-param name="unixtime">
						<xsl:value-of select="$unixtime"/>
					</xsl:with-param>
					<xsl:with-param name="kw">
						<xsl:value-of select="substring-before($tail,',')"/>
					</xsl:with-param>
					<xsl:with-param name="tail">
						<xsl:value-of select="substring-after($tail,',')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="keyword">
					<xsl:with-param name="unixtime">
						<xsl:value-of select="$unixtime"/>
					</xsl:with-param>
					<xsl:with-param name="kw">
						<xsl:value-of select="$tail"/>
					</xsl:with-param>
					<xsl:with-param name="tail"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
