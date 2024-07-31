<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:exp="http://export-confluence"
	xmlns="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="html xsl">
	
	<xsl:output method="text" encoding="utf-8" />

	<xsl:template match="guide">
			
			<!-- Produire les pages du guide -->
			<xsl:apply-templates select="page"/>
			
	</xsl:template>
	
	<!-- ==================
			 TDM
		 ===================
	-->
	<!-- Ne pas traiter la TDM-->
	<xsl:template match="//page[position()=1]"></xsl:template>
	
	<!-- Ne pas traiter la rubrique des métadonnées lors de la première page-->
	<xsl:template match="div[@id='metadonnées']" mode="copy-no-namespaces"></xsl:template>
	
	<!-- ==================
		 Pages du guide
		 ===================
	-->
	<xsl:template match="//page[position()>1]">
		<!-- CRÉATION DU FICHIER DE SORTIE -->
		<xsl:variable name="id" select="./url"/>
		<xsl:result-document href="{concat(substring-after($id, 'pageId='), '.md.txt')}">
			
			<!-- CONTENU DU FICHIER DE SORTIE -->
			<xsl:apply-templates select="url" mode="copy-no-namespaces"/>
			<xsl:apply-templates select="titre" mode="copy-no-namespaces"/>
			<xsl:text>&#xa;&#xa;</xsl:text>
			<xsl:apply-templates select="rubriques"/>
			<xsl:apply-templates select="bas-de-page"/>

		</xsl:result-document>
	</xsl:template>

	<xsl:template match="url" mode="copy-no-namespaces">
		<xsl:text>Source : </xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="titre" mode="copy-no-namespaces">
		<xsl:value-of select="concat('# ', normalize-space(.))"/>
	</xsl:template>
	
	<xsl:template match="rubriques|bas-de-page">
		<xsl:apply-templates select="div" mode="copy-no-namespaces"/>
	</xsl:template>
	
	
	<!-- ==================
		 MARKDOWN
		 ===================
	-->
	<!-- Ne pas traiter les images et les tableaux -->
	<xsl:template match="img|table" mode="copy-no-namespaces"></xsl:template>
	
	<xsl:template match="li" mode="copy-no-namespaces">
		<!-- Compter le nombre d'éléments ul ou ol ancêtres et soustraire 1 -->
		<xsl:variable name="indentLevel" select="count(ancestor::ul | ancestor::ol) - 1" />
		
		<!-- Ajouter une tabulation pour chaque niveau d'imbrication -->
		<xsl:for-each select="1 to $indentLevel">
			<xsl:text>&#x09;</xsl:text> <!-- &#x09; est le code pour une tabulation -->
		</xsl:for-each>
		
		<!-- Ajouter la puce -->
		<xsl:text>* </xsl:text>
		
		<!-- Traiter le contenu du li -->
		<xsl:apply-templates select="node()"/>
		
		<!-- Ajouter une nouvelle ligne à la fin de chaque élément li -->
		<xsl:text>&#10;</xsl:text> <!-- &#10; est le code pour une nouvelle ligne -->
	</xsl:template>
	
	<xsl:template match="a" mode="copy-no-namespaces">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="node()|text()" />
		<xsl:text>](</xsl:text>
		<xsl:value-of select="@href" />
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	
	<xsl:template match="strong|b" mode="copy-no-namespaces">
		<xsl:text>**</xsl:text>
		<xsl:value-of select="normalize-space(.)" />
		<xsl:text>**</xsl:text>
	</xsl:template>
	<xsl:template match="em|i" mode="copy-no-namespaces">
		<xsl:text>*</xsl:text>
		<xsl:value-of select="normalize-space(.)" />
		<xsl:text>*</xsl:text>
	</xsl:template>
	<xsl:template match="code" mode="copy-no-namespaces">
		<!-- todo: skip the ` if inside a pre -->
		<xsl:text>`</xsl:text>
		<xsl:value-of select="." />
		<xsl:text>`</xsl:text>
	</xsl:template>
	
	<xsl:template match="br" mode="copy-no-namespaces">
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<!-- Block elements -->
	<xsl:template match="hr" mode="copy-no-namespaces">
		<xsl:text>----&#xa;&#xa;</xsl:text>
	</xsl:template>
	
	
	<xsl:template match="p|div|blockquote" mode="copy-no-namespaces">
		<xsl:apply-templates mode="copy-no-namespaces"/>
		<xsl:text>&#xa;</xsl:text><!-- Block element -->
	</xsl:template>
	
	<xsl:template match="h1" mode="copy-no-namespaces">
		<xsl:value-of select="concat('# ', normalize-space(.))"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="h2" mode="copy-no-namespaces">
		<xsl:value-of select="concat('## ', normalize-space(.))"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="h3" mode="copy-no-namespaces">
		<xsl:value-of select="concat('### ', normalize-space(.))"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="h4" mode="copy-no-namespaces">
		<xsl:value-of select="concat('#### ', normalize-space(.))"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="h5" mode="copy-no-namespaces">
		<xsl:value-of select="concat('##### ', normalize-space(.))"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="h6" mode="copy-no-namespaces">
		<xsl:value-of select="concat('###### ', normalize-space(.))"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	
	<xsl:template match="pre" mode="copy-no-namespaces">
		<xsl:text>    </xsl:text>
		<xsl:value-of select="replace(text(), '&#xa;', '&#xa;    ')" />
		<xsl:text>&#xa;&#xa;</xsl:text> <!-- Block element -->
	</xsl:template>
	
</xsl:stylesheet>
