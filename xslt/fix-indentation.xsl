<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0" 
  xmlns:llam="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output  method="xml" indent="yes"/>

  <xsl:strip-space elements="*"/>

  <!-- Template for the root node -->
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Template for elements -->
  <xsl:template match="*">
    <xsl:element name="{name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <!-- make sure to have the TEI namespace in the root element -->
  <xsl:template match="llam:dataset">
    <xsl:copy>
        <xsl:namespace name="tei" select="'http://www.tei-c.org/ns/1.0'"/>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="llam:description">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Preserve inline mixed content without splitting -->
  <xsl:template match="*[text() and node()]">
    <xsl:element name="{name()}">
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="node()">
        <xsl:choose>
          <xsl:when test="self::text()">
            <xsl:value-of select="normalize-space(.)" disable-output-escaping="yes"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <!-- Template to handle comments -->
  <xsl:template match="comment()">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>

  <!-- Template to handle processing instructions -->
  <xsl:template match="processing-instruction()">
    <xsl:processing-instruction name="{name()}">
      <xsl:value-of select="."/>
    </xsl:processing-instruction>
  </xsl:template>

  <!-- Handle pure text nodes -->
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)" disable-output-escaping="yes"/>
  </xsl:template>
</xsl:stylesheet>
