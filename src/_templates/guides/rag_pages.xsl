<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:exp="http://export-confluence"
	xmlns="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="html xsl">
	
	<xsl:output method="text" encoding="utf-8" />

	<!-- Clé pour dédoublonner les pages sur le pageId extrait, quel que soit le format d'URL -->
	<xsl:key name="pages-by-id" match="page" use="
		if (contains(./url, 'pageId=')) then 
			let $after := substring-after(./url, 'pageId=')
			return (if (contains($after, '#')) then substring-before($after, '#') else $after)
		else if (contains(./url, '/pages/')) then
			let $afterPages := substring-after(./url, '/pages/')
			return (if (contains($afterPages, '/')) then substring-before($afterPages, '/') else $afterPages)
		else 
			./url
	"/>

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
		<!-- Extraire le pageId pour nommer correctement les fichiers, peu importe le format d'URL -->
		<xsl:variable name="pageid">
			<xsl:choose>
				<!-- Format: ...pageId=XXXXX[#ancre] -->
				<xsl:when test="contains($id, 'pageId=')">
					<xsl:variable name="after" select="substring-after($id, 'pageId=')"/>
					<xsl:choose>
						<xsl:when test="contains($after, '#')">
							<xsl:value-of select="substring-before($after, '#')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$after"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- Nouveau format Confluence: .../pages/XXXXX[/Titre] -->
				<xsl:when test="contains($id, '/pages/')">
					<xsl:variable name="afterPages" select="substring-after($id, '/pages/')"/>
					<xsl:choose>
						<xsl:when test="contains($afterPages, '/')">
							<xsl:value-of select="substring-before($afterPages, '/')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$afterPages"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Ne générer le fichier que pour la première occurrence de chaque pageId -->
		<xsl:if test="generate-id(.) = generate-id(key('pages-by-id', $pageid)[1])">
			<xsl:result-document href="{concat($pageid, '.md.txt')}">
			
			<!-- CONTENU DU FICHIER DE SORTIE -->
			<xsl:apply-templates select="url" mode="copy-no-namespaces"/>
			<xsl:apply-templates select="titre" mode="copy-no-namespaces"/>
			<xsl:text>&#xa;&#xa;</xsl:text>
			<xsl:apply-templates select="rubriques"/>
			<xsl:apply-templates select="bas-de-page"/>

			</xsl:result-document>
		</xsl:if>
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
		<xsl:value-of select="exp:traiterLiens(@href)" />
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

	<!-- Réécriture des liens Confluence vers des href locaux (réutilise la logique EPUB) -->
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
			<!-- Nouveau format Confluence: /spaces/.../pages/ID[/Titre][#ancre] avec ancre -->
			<xsl:when test="contains($href, '/spaces/') and contains($href, '/pages/') and contains($href, '#')">
				<xsl:variable name="afterPages" select="substring-after($href, '/pages/')"/>
				<xsl:variable name="pageid">
					<xsl:choose>
						<xsl:when test="contains($afterPages, '/')">
							<xsl:value-of select="substring-before($afterPages, '/')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$afterPages"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="ancre" select="exp:traiterID(substring-after($href, '#'))"/>
				<xsl:value-of select="concat($pageid, '.xhtml', '#', $ancre)"/>
			</xsl:when>
			<!-- Nouveau format Confluence: /spaces/.../pages/ID[/Titre] sans ancre -->
			<xsl:when test="contains($href, '/spaces/') and contains($href, '/pages/')">
				<xsl:variable name="afterPages" select="substring-after($href, '/pages/')"/>
				<xsl:choose>
					<xsl:when test="contains($afterPages, '/')">
						<xsl:value-of select="concat(substring-before($afterPages, '/'), '.xhtml')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($afterPages, '.xhtml')"/>
					</xsl:otherwise>
				</xsl:choose>
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
	<xsl:function name="exp:traiterID">
		<xsl:param name="id"/>
		<xsl:value-of select="replace($id, '[^a-zA-Z0-9. ]', '')"/>
	</xsl:function>
	
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
