<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="html xsl">
	<xsl:output method="text" version="1.0" encoding="utf-8"/>
	
	<!-- ==========================================================
		  =                 MODÈLE DES FICHES PAR TERME           =
		  =                 (début)                               =
		  =========================================================
	-->
	<xsl:template match="/">
		<xsl:apply-templates select="//img"/>
	</xsl:template>
	
	<xsl:template match="img">
		<xsl:value-of select="concat('https://wiki.umontreal.ca', substring-before(@src,'?'))"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>
