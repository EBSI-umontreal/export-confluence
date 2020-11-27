<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:opf="http://www.idpf.org/2007/opf"
	xmlns="http://www.idpf.org/2007/opf">
	<xsl:output method="xml" version="1.0" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>


	<xsl:template match="guide">
		<package version="3.0" unique-identifier="BookId" xml:lang="{normalize-space(//span[@id = 'metadonnées-langue'])}">
			<xsl:call-template name="metadata"/>
			<xsl:call-template name="manifest"/>
			<xsl:call-template name="spine"/>
		</package>
	</xsl:template>

	<xsl:template name="metadata">
		<!--EPUB2
		<metadata xmlns:opf="http://www.idpf.org/2007/opf"	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		-->
		<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
			<dc:title>
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-titre'])"/> : <xsl:value-of select="normalize-space(//span[@id = 'metadonnées-date'])"/>
			</dc:title>
			<!--EPUB2
			<dc:creator
				opf:role="aut"
				opf:file-as="{normalize-space(concat(//span[@id='metadonnées-auteur-nom'], ',', //span[@id='metadonnées-auteur-prénom']))}">
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-auteur-nom'])"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-auteur-prénom'])"/>
			</dc:creator>
			-->
			<dc:creator>
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-auteur-nom'])"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-auteur-prénom'])"/>
			</dc:creator>
			<dc:language>
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-langue'])"/>
			</dc:language>
			<dc:date>
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-date'])"/>
			</dc:date>
			<dc:rights>
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-droits'])"/>
			</dc:rights>
			<dc:publisher>
				<xsl:value-of select="normalize-space(//span[@id = 'metadonnées-éditeur'])"/>
			</dc:publisher>
			<dc:identifier id="BookId">
				<xsl:value-of
					select="concat('urn:uuid:', normalize-space(//span[@id = 'metadonnées-uuid']))"
				/>
			</dc:identifier>
			<meta property="dcterms:modified">
				<xsl:value-of select="concat(format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]'), 'Z')"/>
			</meta>
		</metadata>
	</xsl:template>

	<xsl:template name="manifest">
		<manifest>
			<!-- items inclus dans le templates -->
			<item id="style" href="styles/stylesheet.css" media-type="text/css"/>
			<item id="image_afaire.png" href="images/afaire.png" media-type="image/png"/>
			<item id="fonts_Charlotte-Std-Book" href="fonts/Charlotte-Std-Book.otf" media-type="application/x-font-opentype"/>
			<item id="fonts_Charlotte-Std-Book-Italic" href="fonts/Charlotte-Std-Book-Italic.otf" media-type="application/x-font-opentype"/>
			<item id="fonts_Charlotte-Std-Book-Bold" href="fonts/Charlotte-Std-Book-Bold.otf" media-type="application/x-font-opentype"/>
			<item id="fonts_frutiger" href="fonts/frutiger.ttf" media-type="application/x-font-ttf"/>
			<item id="fonts_frutiger-bold" href="fonts/frutiger-bold.ttf" media-type="application/x-font-ttf"/>
			<item id="fonts_frutiger-bold-italic" href="fonts/frutiger-bold-italic.ttf" media-type="application/x-font-ttf"/>
			<item id="fonts_frutiger-italic" href="fonts/frutiger-italic.ttf" media-type="application/x-font-ttf"/>
			
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
