<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:opf="http://www.idpf.org/2007/opf"
	xmlns="http://www.idpf.org/2007/opf">
	<xsl:output method="xml" version="1.0" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>


	<xsl:template match="guide">
		<package version="3.0" unique-identifier="BookId" xml:lang="fr-ca">
			<xsl:call-template name="metadata"/>
			<xsl:call-template name="manifest"/>
			<xsl:call-template name="spine"/>
		</package>
	</xsl:template>

	<xsl:template name="metadata">
		<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
			<dc:title>Guide EBSI</dc:title> 
			<dc:creator>EBSI</dc:creator>
			<dc:language>fr-ca</dc:language> 
			<dc:date>2018-2019</dc:date>
			<dc:rights></dc:rights> 
			<dc:publisher>EBSI</dc:publisher> 
			<dc:identifier id="bookid">https://wiki.umontreal.ca/display/EBSI/Guide+du+personnel</dc:identifier>
			<meta property="dcterms:modified">
				<xsl:value-of select="concat(format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]'), 'Z')"/>
			</meta>
		</metadata>
	</xsl:template>

	<xsl:template name="manifest">
		<manifest>
			<!-- items inclus dans le templates -->
			<item id="style" href="styles/stylesheet.css" media-type="text/css"/>
			
			<item id="fonts_Charlotte-Std-Book" href="fonts/Charlotte-Std-Book.otf" media-type="application/x-font-opentype"/>
			<item id="fonts_Charlotte-Std-Book-Italic" href="fonts/Charlotte-Std-Book-Italic.otf" media-type="application/x-font-opentype"/>
			<item id="fonts_Charlotte-Std-Book-Bold" href="fonts/Charlotte-Std-Book-Bold.otf" media-type="application/x-font-opentype"/>
			
			<!-- Éléments générés -->
			<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml" />
			<item id="couverture" href="cover.xhtml" media-type="application/xhtml+xml"/>
			<item id="tableDesMatieres" href="toc.xhtml" media-type="application/xhtml+xml" properties="nav"/>

			<xsl:for-each select="page">
				<xsl:if test="position()>1"><!--exclure la page de la TdM -->
					<xsl:variable name="id" select="./url"/>
					<xsl:variable name="pageid" select="substring-after($id, 'pageId=')"/>
					<item xmlns="http://www.idpf.org/2007/opf" id="{concat('page_', $pageid)}"
						href="{concat($pageid, '.xhtml')}" media-type="application/xhtml+xml"/>					
				</xsl:if>
			</xsl:for-each>

			<xsl:for-each select="distinct-values(//img/@src)">
				<xsl:variable name="urlImg" select="."/>
				<xsl:variable name="imgFile"
					select="substring-before(tokenize($urlImg, '/')[last()], '?')"/>
				<xsl:variable name="imgFileExt" select="substring-after($imgFile, '.')"/>
				<item xmlns="http://www.idpf.org/2007/opf" id="{concat('image_', $imgFile)}"
					href="{concat('images/', $imgFile)}"
					media-type="{replace(lower-case(concat('image/', $imgFileExt)), 'jpg', 'jpeg')}"/>
			</xsl:for-each>

		</manifest>
	</xsl:template>

	<xsl:template name="spine">
		<spine toc="ncx">
			<itemref idref="couverture"/>
			<itemref idref="tableDesMatieres"/>
			<xsl:for-each select="page">
				<xsl:if test="position()>1"><!--exclure la page de la TdM -->
					<xsl:variable name="id" select="./url"/>
					<xsl:variable name="pageid" select="substring-after($id, 'pageId=')"/>
					<itemref idref="{concat('page_', $pageid)}"/>
				</xsl:if>
			</xsl:for-each>
		</spine>
	</xsl:template>

</xsl:stylesheet>
