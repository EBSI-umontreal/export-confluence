<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf" exclude-result-prefixes="opf">
	<xsl:output method="xml" version="1.0" indent="yes" encoding="utf-8" omit-xml-declaration="no" />
	
	
	<xsl:template match="guide">
		<package version="2.0" unique-identifier="bookid">
			<metadata>
				<dc:title>Guide EBSI</dc:title> 
				<dc:creator>EBSI</dc:creator>
				<dc:language>fr-ca</dc:language> 
				<dc:rights></dc:rights> 
				<dc:publisher>EBSI</dc:publisher> 
				<dc:identifier id="bookid">https://wiki.umontreal.ca/display/EBSI/Guide+du+personnel</dc:identifier>
			</metadata>
			
			<xsl:call-template name="manifest"/>
			<xsl:call-template name="spine"/>
		</package>
	</xsl:template>
	
	<xsl:template name="manifest">
		<manifest>
			<item id="style" href="stylesheet.css" media-type="text/css"/>
			<item id="pagetemplate" href="page-template.xpgt" media-type="application/vnd.adobe-page-template+xml"/>
			
			<xsl:for-each select="page">
				<xsl:variable name="id" select="./url"/>
				<xsl:variable name="pageid" select="substring-after($id, 'pageId=')"/>
				<item xmlns="http://www.idpf.org/2007/opf" id="{concat('p', $pageid)}" href="{concat($pageid, '.xhtml')}" media-type="application/xhtml+xml" />
			</xsl:for-each>
			
			<xsl:for-each select="//img">
				<xsl:variable name="urlImg" select="@src"/>
				<xsl:variable name="imgFile" select="substring-before(tokenize($urlImg, '/')[last()], '?')"/>
				<xsl:variable name="imgFileExt" select="substring-after($imgFile, '.')"/>
				<item xmlns="http://www.idpf.org/2007/opf" id="{concat('i', $imgFile)}" href="{concat('images/', $imgFile)}" media-type="{concat('image/', $imgFileExt)}" />
			</xsl:for-each>
			
		</manifest>
	</xsl:template>
	
	<xsl:template name="spine">
		<spine toc="ncx">
			<xsl:for-each select="page">
				<xsl:variable name="id" select="./url"/>
				<xsl:variable name="pageid" select="substring-after($id, 'pageId=')"/>
				<itemref idref="{concat('p', $pageid)}"/>
			</xsl:for-each>
		</spine>
	</xsl:template>
	
</xsl:stylesheet>
