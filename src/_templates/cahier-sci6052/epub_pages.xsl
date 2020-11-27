<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="html xsl">
	<xsl:output method="xml" version="1.0" indent="yes" encoding="utf-8" omit-xml-declaration="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
	
	<!-- ==========================================================
		  =                 MODÈLE DES FICHES PAR TERME           =
		  =                 (début)                               =
		  =========================================================
	-->
	<xsl:template match="//page">
		<!-- CRÉATION DU FICHIER DE SORTIE -->
		<xsl:variable name="id" select="./url"/>
		<xsl:result-document href="{concat(substring-after($id, 'pageId='), '.xhtml')}">
		
			<!-- CONTENU DU FICHIER DE SORTIE -->
			<html xmlns="http://www.w3.org/1999/xhtml" lang="fr-ca">
				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
					<title><xsl:value-of select="./title"/></title>
					<link type="text/css" rel="stylesheet" href="stylesheet.css" />
				</head>
				<body>
					<h1><xsl:value-of select="title"/></h1>
					<xsl:apply-templates select="rubriques"/>
				</body>
				
				
			</html>
		</xsl:result-document>
	</xsl:template>
	<!-- ==========================================================
		  =                 MODÈLE DES FICHES PAR TERME           =
		  =                 (fin)                                 =
		  =========================================================
	-->
	
	<xsl:template match="rubriques">
		<xsl:apply-templates mode="copy-no-namespaces"/>
	</xsl:template>
	
	<xsl:template match="img" mode="copy-no-namespaces">
		<xsl:element name="img">
			<xsl:variable name="urlImg" select="@src"/>
			<xsl:variable name="imgFile" select="substring-before(tokenize($urlImg, '/')[last()], '?')"/>
			<xsl:attribute name="src">
				<xsl:value-of select="concat('images/', $imgFile)"/>
				<!--<xsl:value-of select="$imgFile"/>-->
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*" mode="copy-no-namespaces">
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="comment()| processing-instruction()" mode="copy-no-namespaces">
		<xsl:copy/>
	</xsl:template>
		
</xsl:stylesheet>
