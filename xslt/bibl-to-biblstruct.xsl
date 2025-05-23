<xsl:stylesheet exclude-result-prefixes="#all" 
    version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- 
    Convert a <tei:bibl> to a <tei:biblStruct>
    some code is originally from https://github.com/OpenArabicPE/convert_tei-to-bibliographic-data/blob/master/xslt/convert_tei-to-zotero-rdf_functions.xsl
  -->

  <!-- configure output-->
  <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>

  <!-- Default behavior is unresolved -->
  <xsl:template match="tei:bibl">
    <xsl:apply-templates select="." mode="bibl-to-biblstruct"/>
  </xsl:template>

  <!-- output context-free <biblStruct> -->
  <xsl:template match="tei:bibl" mode="bibl-to-biblstruct">
    <biblStruct source="#{@xml:id}">
      <xsl:call-template name="process-bibl-children">
        <xsl:with-param name="node" select="." />
        <xsl:with-param name="original-node" select="." />
      </xsl:call-template>
    </biblStruct>
  </xsl:template>

  <!-- Named template for processing <tei:bib> -->
  <xsl:template name="process-bibl-children">
    <!-- the current bibl node -->
    <xsl:param name="node" />
    <!-- the referring bibl node, when resolving incomplete references, otherwise the same as $node -->
    <xsl:param name="original-node" />

    <!-- free-standing authors without a title, usually with a <ref> indicating where to find the missing reference data -->
    <xsl:if test="not($node/tei:title) and exists($node/tei:author | $node/tei:persName | $node/tei:orgName )">
      <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:copy-of select="$node/tei:author/tei:persName" />
        <xsl:copy-of select="$node/tei:author/tei:orgName" />
        <xsl:copy-of select="$node/tei:persName" />
        <xsl:copy-of select="$node/tei:orgName" />
      </xsl:element>
    </xsl:if>

    <!-- Process analytic section from current or original node-->
      <xsl:choose>
      <xsl:when test="$original-node/tei:title[@level = 'a']">
        <analytic source="#{$original-node/@xml:id}">
            <xsl:copy-of select="$original-node/tei:title[@level = 'a']" />
            <xsl:copy-of select="$original-node/tei:author" />
        </analytic>
      </xsl:when>
      <xsl:when test="$node/tei:title[@level = 'a']">
          <analytic source="#{$node/@xml:id}">
              <xsl:copy-of select="$node/tei:title[@level = 'a']" />
              <xsl:copy-of select="$node/tei:author" />
          </analytic>
      </xsl:when>
      </xsl:choose>
    
    <!-- Process monographic section -->
    <xsl:if test="$node/tei:title[@level != 'a'] | $node/tei:editor | $node/tei:idno | $node/tei:date">
        <monogr source="#{$node/@xml:id}">
            <xsl:copy-of select="$node/tei:title[@level != 'a']" />
            <xsl:copy-of select="$node/tei:idno" />
            <xsl:choose>
                <xsl:when test="$node/tei:title[@level = 'a']" />
                <xsl:otherwise>
                    <xsl:copy-of select="$node/tei:author" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="$node/tei:editor" />
            <xsl:copy-of select="$node/tei:edition" />
            <imprint>
                <xsl:copy-of select="$node/descendant::tei:date" />
                <xsl:copy-of select="$node/tei:pubPlace" />
                <xsl:copy-of select="$node/tei:publisher" />
            </imprint>
            <xsl:copy-of select="$node/tei:biblScope" />
        </monogr>
    </xsl:if>

    <!-- References -->
    <xsl:copy-of select="$node/tei:ref" />
    <!-- citations-->
    <xsl:copy-of select="$original-node/tei:citedRange" />
    <!-- Notes -->
    <xsl:copy-of select="$node/tei:note" />

  </xsl:template>
</xsl:stylesheet>
