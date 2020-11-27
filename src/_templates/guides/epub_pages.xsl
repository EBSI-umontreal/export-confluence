<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:html="http://www.w3.org/1999/xhtml" 
	xmlns="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="html xsl">
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" encoding="utf-8" />
	
	<xsl:template match="guide">
		
		<!-- ==================
			 COUVERTURE
			 ===================
		-->
		<xsl:result-document href="cover.xhtml">
			<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
			<html lang="fr-ca">
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
						<p id="pageTitre-titre">Guide</p>
						<p id="pageTitre-année">20XX-20XX</p>
					</div>
				</body>
			</html>
		</xsl:result-document>
		
		<!-- ==================
			 TDM
			 ===================
		-->
		<xsl:result-document href="toc.xhtml">
			<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
			<html lang="fr-ca">
				<head>
					<meta charset="utf-8"/>
					<title>Table des matières</title>
					<link type="text/css" rel="stylesheet" href="styles/stylesheet.css" />
				</head>
				<body>
					<nav epub:type="toc">
						<h1>Table des matières</h1>
						<ol>
							<li><a href="toc.xhtml">Table des matières</a></li>
							<xsl:for-each select="page">
								<xsl:if test="position()>1"><!--exclure la page de la TdM -->
									<li>
										<xsl:variable name="id" select="./url"/>
										<xsl:variable name="pageid" select="substring-after($id, 'pageId=')"/>
										<a href="{concat($pageid, '.xhtml')}"><xsl:value-of select="normalize-space(./titre)"/></a>
									</li>
								</xsl:if>
							</xsl:for-each>
						</ol>
					</nav>
				</body>
			</html>
		</xsl:result-document>
		
		<!-- Produire les pages du guide -->
		<xsl:apply-templates select="page"/>

	</xsl:template>
	
	<!-- ==================
		 Pages du guide
		 ===================
	-->
	<xsl:template match="//page[position()=1]"></xsl:template>
	<xsl:template match="//page[position()>1]">
		<!-- CRÉATION DU FICHIER DE SORTIE -->
		<xsl:variable name="id" select="./url"/>
		<xsl:result-document href="{concat(substring-after($id, 'pageId='), '.xhtml')}">
			
			<!-- CONTENU DU FICHIER DE SORTIE -->
			<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
			<html lang="fr-ca">
				<head>
					<meta charset="utf-8"/>
					<title><xsl:value-of select="./titre"/></title>
					<link type="text/css" rel="stylesheet" href="styles/stylesheet.css" />
				</head>
				<body>
					<h1><xsl:value-of select="titre"/></h1>
					<xsl:apply-templates select="rubriques"/>
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>
	
	
	
	<xsl:template match="rubriques">
		<xsl:apply-templates mode="copy-no-namespaces"/>
	</xsl:template>
	
	<xsl:template match="img" mode="copy-no-namespaces">
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
				<xsl:attribute name="style">width:99%;</xsl:attribute>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<!-- Pieds de page -->
	<xsl:template match="sup[./a/@class='footnotes-marker']" mode="copy-no-namespaces">
		<xsl:element name="sup">
			<xsl:element name="a">
				<xsl:attribute name="href">
					<xsl:value-of select="concat('#', ./a/@name)"/>
				</xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="concat('fn',./a/@name)"/>
				</xsl:attribute>
				<xsl:attribute name="epub:type">noteref</xsl:attribute>
				<xsl:value-of select="concat('[', normalize-space(.) , ']')"/>				
			</xsl:element>
		</xsl:element>
		<!--
		<xsl:element name="aside">
			<xsl:attribute name="class">tp-piedDePage</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:value-of select="./a/@name"/>
			</xsl:attribute>
			<xsl:attribute name="epub:type">footnote</xsl:attribute>
			<xsl:element name="a">
				<xsl:attribute name="href">
					<xsl:value-of select="concat('#fn',./a/@name)"/>
				</xsl:attribute>
			</xsl:element>
			<xsl:value-of select="./a/@content" disable-output-escaping="yes"/>
		</xsl:element>
		-->
	</xsl:template>
	
	
	<!--Traitement des ID de Confluence pour enlever les caractères non valides -->	
	<xsl:template match="@id">
		<xsl:attribute name="id">
			<xsl:value-of select="replace(., '[^a-zA-Z0-9. ]', '')"/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@href">
		<xsl:choose>
			<xsl:when test="starts-with(., '#')">
				<xsl:attribute name="href">
					<!-- corriger les liens internes avec les mêmes règles -->
					<xsl:value-of select="concat('#', replace(., '[^a-zA-Z0-9. ]', ''))"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	
	<!--Conf6.7+ Éliminer les colgroup -->
	<xsl:template match="colgroup" mode="copy-no-namespaces"></xsl:template>
	
	
	
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
