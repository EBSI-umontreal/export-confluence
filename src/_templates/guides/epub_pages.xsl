<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:exp="http://export-confluence"
	xmlns="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="html xsl">
	<xsl:output method="xml" omit-xml-declaration="yes" encoding="utf-8" />
	<!-- Ne pas faire de sortie indentée pour éviter les problèmes d'espaces avant ou après les <span> -->
	
	<!-- ==================
		 COUVERTURE
		 ===================
	-->
	<xsl:template match="guide">
		<xsl:result-document href="cover.xhtml">
			<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
			<html lang="{normalize-space(//span[@id = 'metadonnées-langue'])}">
				<head>
					<meta charset="utf-8"/>
					<title>Couverture</title>
					<link type="text/css" rel="stylesheet" href="styles/stylesheet.css" />
				</head>
				<body>
					<div id="pageTitre-entête">
						<p>
							<span id="pageTitre-FAS">Faculté des arts et des sciences</span>
							<br/>
							<span id="pageTitre-EBSI">École de bibliothéconomie<br/>et des sciences de l’information</span>
						</p>
						<p id="pageTitre-titre"><xsl:value-of select="normalize-space(//span[@id = 'metadonnées-titre'])"/></p>
						<p id="pageTitre-année"><xsl:value-of select="normalize-space(//span[@id = 'metadonnées-date'])"/></p>
					</div>
					<div style="text-indent:0;text-align:center;margin-right:auto;margin-left:auto;width:99%;page-break-before:auto;page-break-inside:avoid;page-break-after:auto;">
						<div style="margin-left:0;margin-right:0;text-align:center;text-indent:0;width:100%;">
							<p style="display:inline-block;text-indent:0;width:100%;">
								<img alt="Illustration" src="images/suivez-le-guide.png" style="max-width:99%;"/>
							</p>
						</div>
					</div>
				</body>
			</html>
			
			<!-- Produire les pages du guide -->
			<xsl:apply-templates select="page"/>
			
		</xsl:result-document>
	</xsl:template>
	
	<!-- ==================
			 TDM
		 ===================
	-->
	<xsl:template match="//page[position()=1]">
		<xsl:result-document href="toc.xhtml">
			<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
			<html lang="{normalize-space(//span[@id = 'metadonnées-langue'])}">
				<head>
					<meta charset="utf-8"/>
					<title>Table des matières</title>
					<link type="text/css" rel="stylesheet" href="styles/stylesheet.css" />
				</head>
				<body>
					<xsl:apply-templates select="rubriques"/>
				</body>
			</html>
		</xsl:result-document>

	</xsl:template>
	
	<!-- Ne pas traiter la rubrique des métadonnées lors de la première page-->
	<xsl:template match="div[@id='metadonnées']" mode="copy-no-namespaces"></xsl:template>
	
	
	<!-- Traiter la TdM -->
	<xsl:template match="div[contains(@class, 'table-des-matières')]" mode="copy-no-namespaces">
		<nav epub:type="toc" class="table-des-matières">
			<h1>Table des matières</h1>
			<ol>
				<li><a href="toc.xhtml">Table des matières</a></li>
				<xsl:apply-templates select="child::div[@class='rwui_expandable_item']|child::div[@class='rwui_expandable_item  ']"/>
			</ol>
		</nav>
	</xsl:template>
	<xsl:template match="div[@class='rwui_expandable_item']|div[@class='rwui_expandable_item  ']">
		<!-- div[contains(@class, 'rwui_expandable_item')] ambigue avec le template suivant -->
		<li>
			<!-- Ajouter un lien vers la première entrée, sinon aucune entrée n'apparait dans la ToC du EPUB -->
			<a>
				<xsl:attribute name="href">
					<xsl:value-of select="exp:traiterLiens((.//a/@href)[1])"/>
				</xsl:attribute>
				<!-- Enlever la numérotation provenant de Confluence pour restyler -->
				<xsl:value-of select="normalize-space(substring-after(./a, '.'))"/>
			</a>
			<xsl:apply-templates select="div[contains(@class, 'rwui_expandable_item_body')]"/>
		</li>
	</xsl:template>
	<xsl:template match="div[contains(@class, 'rwui_expandable_item_body')]">
		<xsl:apply-templates select="ol" mode="copy-no-namespaces"/>
	</xsl:template>
	
	<!-- ==================
		 Pages du guide
		 ===================
	-->
	<xsl:template match="//page[position()>1]">
		<!-- CRÉATION DU FICHIER DE SORTIE -->
		<xsl:variable name="id" select="./url"/>
		<xsl:result-document href="{concat(substring-after($id, 'pageId='), '.xhtml')}">
			
			<!-- CONTENU DU FICHIER DE SORTIE -->
			<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
			<html lang="{normalize-space(//span[@id = 'metadonnées-langue'])}">
				<head>
					<meta charset="utf-8"/>
					<title><xsl:value-of select="normalize-space(./titre)"/></title>
					<link type="text/css" rel="stylesheet" href="styles/stylesheet.css" />
				</head>
				<body>
					<h1><xsl:apply-templates select="titre" mode="copy-no-namespaces"/></h1>
					<xsl:apply-templates select="rubriques"/>
					<xsl:apply-templates select="bas-de-page"/>
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>
	
	<!-- Enlever les indications concernant le public cible, ex. "(1er cycle)" -->
	<xsl:template match="titre" mode="copy-no-namespaces">
		<!--<em><xsl:value-of select="normalize-space(.)"/></em>-->
		<xsl:choose>
			<xsl:when test="contains(., ' (')">
				<xsl:value-of select="normalize-space(substring-before(., ' ('))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="rubriques">
		<xsl:apply-templates mode="copy-no-namespaces"/>
	</xsl:template>
	
	<!-- Pieds de page -->
	<xsl:template match="bas-de-page">
		<xsl:apply-templates mode="copy-no-namespaces"/>
	</xsl:template>
	
	
	<!-- Traiter les images -->
	<xsl:template match="img" mode="copy-no-namespaces">
	
		<div style="text-indent:0;text-align:center;margin-right:auto;margin-left:auto;width:99%;page-break-before:auto;page-break-inside:avoid;page-break-after:auto;">
			<div style="margin-left:0;margin-right:0;text-align:center;text-indent:0;width:100%;">
				<p style="display:inline-block;text-indent:0;width:100%;">
				
					<xsl:element name="img">
						<xsl:variable name="urlImg" select="@src"/>
						<xsl:variable name="imgFile" select="substring-before(tokenize($urlImg, '/')[last()], '?')"/>
						<xsl:attribute name="src">
							<xsl:value-of select="concat('images/', $imgFile)"/>
							<!--Conf6.7+ <xsl:value-of select="$imgFile"/>-->
						</xsl:attribute>
						<!--Il n'y a pas d'attribut alt dans les balises img de Confluence -->
						<xsl:attribute name="alt">
							<xsl:text> </xsl:text>
						</xsl:attribute>
						
						<!-- Si c'est une illustration, aggrandir l'image -->
						<!--<xsl:if test="ancestor::div[@class='tp-illustration']">-->
						<xsl:if test="ancestor::div[contains(@class, 'tp-illustration')]">
							<xsl:attribute name="style">max-width:99%;</xsl:attribute>
						</xsl:if>
					</xsl:element>
				
				</p>
			</div>
		</div>
		
	</xsl:template>
	
	
	<!-- Traiter les liens entre les pages -->
	<xsl:template match="@href">
		<xsl:attribute name="href">
			<xsl:value-of select="exp:traiterLiens(.)"/>
		</xsl:attribute>
	</xsl:template>	
	<xsl:function name="exp:traiterLiens">
		<xsl:param name="href"/>
		<xsl:choose>
			<!-- Lien interne -->
			<xsl:when test="starts-with($href, '#')">
				<xsl:variable name="ancre" select="exp:traiterID(substring-after($href, '#'))"/>
				<xsl:value-of select="concat('#', $ancre)"/>
			</xsl:when>
			<!-- Lien externe (EPUB) avec ancre -->
			<xsl:when test="contains($href, '/pages/viewpage.action?pageId=') and contains($href, '#')">
				<xsl:variable name="pageid" select="substring-before(substring-after($href, 'pageId='), '#')"/>
				<xsl:variable name="ancre" select="exp:traiterID(substring-after($href, '#'))"/>
				<xsl:value-of select="concat($pageid, '.xhtml', '#', $ancre)"/>
			</xsl:when>
			<!-- Lien externe (EPUB) -->
			<xsl:when test="contains($href, '/pages/viewpage.action?pageId=')">
				<xsl:variable name="pageid" select="substring-after($href, 'pageId=')"/>
				<xsl:value-of select="concat($pageid, '.xhtml')"/>
			</xsl:when>
			<!-- Lien externe (Wiki) -->
			<xsl:when test="starts-with($href, '/')">
				<xsl:value-of select="concat('https://wiki.umontreal.ca', $href)"/>
			</xsl:when>
			<!-- Lien externe (Web) -->
			<xsl:otherwise>
				<xsl:value-of select="$href"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!--Traitement des ID de Confluence pour enlever les caractères non valides -->
	<xsl:template match="@id">
		<xsl:attribute name="id" select="exp:traiterID(.)"/>
	</xsl:template>
	<xsl:function name="exp:traiterID">
		<xsl:param name="id"/>
		<xsl:value-of select="replace($id, '[^a-zA-Z0-9. ]', '')"/>
	</xsl:function>
	


	<!--Conf6.7+ Éliminer les colgroup -->
	<xsl:template match="colgroup" mode="copy-no-namespaces"></xsl:template>
	
	
	<!-- FIX - Éliminer le tableau de consitution des comités (trop large) -->
	<xsl:template match="div[contains(@class, 'tableau-comités')]" mode="copy-no-namespaces"></xsl:template>
	
	
	<!-- Traitements génériques -->
	<xsl:template match="*" mode="copy-no-namespaces">
		<xsl:element name="{local-name()}">
			<!--Éliminer certains attributs de Confluence, débutant par "data"-->
			<xsl:apply-templates select="@*[not(starts-with(name(), 'data'))]"/>
			<xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="comment()| processing-instruction()" mode="copy-no-namespaces">
		<xsl:copy/>
	</xsl:template>
	
	
		
</xsl:stylesheet>
