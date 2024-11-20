<xsl:stylesheet exclude-result-prefixes="#all" 
    version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- 
        clues taken from https://github.com/OpenArabicPE/convert_tei-to-bibliographic-data 
        Author: Till Grallert
     -->

    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>

  <!-- 
    convert a bibl to a biblStruct
    code originally adapted from
  https://github.com/OpenArabicPE/convert_tei-to-bibliographic-data/blob/master/xslt/convert_tei-to-zotero-rdf_functions.xsl
    Author: Till Grallert
  -->

  <!--Output context-free data -->
  <xsl:template match="tei:bibl" mode="unresolved">
    <biblStruct source="#{@xml:id}">
      <xsl:call-template name="process-bib-body">
        <xsl:with-param name="node" select="." />
        <xsl:with-param name="citation-target" select="." />
      </xsl:call-template>
    </biblStruct>
  </xsl:template>

  <!-- Resolve incomplete references from the document -->
  <xsl:template match="tei:bibl" mode="resolved">
    <biblStruct source="#{@xml:id}">
      <xsl:choose>
        <!-- Handle incomplete references with reference to other bibls-->
        <xsl:when test="tei:ref[@target]">
          <!-- Placeholder logic to look up and process the referenced bibl -->
          <xsl:variable name="referenced-bibl" select="tei:ref/@target" />
          <!-- Process the referenced <tei:bibl> -->
          <xsl:call-template name="process-bib-body">
            <xsl:with-param name="node" select="//*[@xml:id = substring($referenced-bibl, 2)]" />
            <xsl:with-param name="citation-target" select="." />
          </xsl:call-template>
        </xsl:when>
        <!-- Handle complete references -->
        <xsl:otherwise>
          <xsl:call-template name="process-bib-body">
            <xsl:with-param name="node" select="." />
            <xsl:with-param name="citation-target" select="." />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </biblStruct>
  </xsl:template>

  <!-- Named template for processing <tei:bib> -->
    <xsl:template name="process-bib-body">
      <xsl:param name="node" />
      <xsl:param name="citation-target" />

      <!-- free-standing author, usually with a <ref> -->
      <xsl:if test="not($node/tei:title)">
        <xsl:copy-of select="$node/tei:author" />
      </xsl:if>

      <!-- Process analytic section -->
      <xsl:if test="$node/tei:title[@level = 'a']">
          <analytic>
              <xsl:copy-of select="$node/tei:title[@level = 'a']" />
              <xsl:copy-of select="$node/tei:author" />
          </analytic>
      </xsl:if>

      <!-- Process monographic section -->
      <xsl:if test="$node/tei:title[@level != 'a']">
          <monogr>
              <xsl:copy-of select="$node/tei:title[@level != 'a']" />
              <xsl:copy-of select="$node/tei:idno" />
              <xsl:choose>
                  <xsl:when test="$node/tei:title[@level = 'a']" />
                  <xsl:otherwise>
                      <xsl:copy-of select="$node/tei:author" />
                  </xsl:otherwise>
              </xsl:choose>
              <xsl:copy-of select="$node/tei:editor" />
              <imprint>
                  <xsl:copy-of select="$node/descendant::tei:date" />
                  <xsl:copy-of select="$node/tei:pubPlace" />
                  <xsl:copy-of select="$node/tei:publisher" />
              </imprint>
              <xsl:copy-of select="$node/tei:edition" />
              <xsl:copy-of select="$node/tei:biblScope" />
          </monogr>
      </xsl:if>

      <!-- References -->
      <xsl:copy-of select="$node/tei:ref" />
      <!-- citations-->
      <xsl:copy-of select="$citation-target/tei:citedRange" />
      <!-- Notes -->
      <xsl:copy-of select="$node/tei:note" />

    </xsl:template>
</xsl:stylesheet>
