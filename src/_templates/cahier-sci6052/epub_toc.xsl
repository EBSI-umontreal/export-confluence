<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/" xmlns="http://www.daisy.org/z3986/2005/ncx/" exclude-result-prefixes="ncx">
	<xsl:output method="xml" version="1.0" indent="yes" encoding="utf-8" omit-xml-declaration="no" />
	
	
	<xsl:template match="guide">
		<ncx version="2005-1" xml:lang="{normalize-space(//span[@id = 'metadonnées-langue'])}">
			<xsl:call-template name="metadata"/>
			<xsl:call-template name="title"/>
			<xsl:call-template name="navigation"/>
		</ncx>
	</xsl:template>
	
	<xsl:template name="metadata">
		<head>
			<meta name="dtb:uid" content="{normalize-space(//span[@id = 'metadonnées-uuid'])}"/>
			<meta name="dtb:depth" content="1" />
			<meta name="dtb:totalPageCount" content="0"/>
			<meta name="dtb:maxPageNumber" content="0"/>
		</head>
	</xsl:template>
	
	<xsl:template name="title">
		<docTitle>
			<text><xsl:value-of select="normalize-space(//span[@id = 'metadonnées-titre'])"/> : <xsl:value-of select="normalize-space(//span[@id = 'metadonnées-date'])"/></text>
		</docTitle>
	</xsl:template>
	
	<xsl:template name="navigation">
		<navMap>
			<!-- Couverture -->
			<navPoint id="navpoint1" playOrder="1">
				<navLabel>
					<text>Couverture</text>
				</navLabel>
				<content src="cover.xhtml"/>
			</navPoint>
			<navPoint id="navpoint2" playOrder="2">
				<navLabel>
					<text>Table des matières</text>
				</navLabel>
				<content src="toc.xhtml"/>
			</navPoint>
			
			<xsl:for-each select="page">
				<xsl:if test="position()>1"><!--exclure la page de la TdM -->
					<xsl:variable name="id" select="./url"/>
					<xsl:variable name="pageid" select="substring-after($id, 'pageId=')"/>
					<xsl:variable name="position" select="position()+1"/>
					<navPoint id="{concat('navpoint', $position)}" playOrder="{$position}">
						<navLabel>
							<text><xsl:value-of select="normalize-space(./titre)"/></text>
						</navLabel>
						<content src="{concat($pageid, '.xhtml')}"/>
					</navPoint>
				</xsl:if>
			</xsl:for-each>
		</navMap>
	</xsl:template>
	
</xsl:stylesheet>
