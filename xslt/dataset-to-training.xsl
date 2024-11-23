<xsl:stylesheet exclude-result-prefixes="#all" 
    version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:llm="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">

  <!-- 
    Convert the dataset to different forms of training data 
  -->
    
  <xsl:import href="bibl-to-resolved-biblstruct.xsl" />

  <!-- you can pass `verbose=yes` to the cli command to get more verbose output -->
  <xsl:param name="verbose" select="'off'"/> 

  <!-- configure output-->
  <xsl:output 
    method="xml" 
    version="1.0"
    encoding="utf-8" 
    indent="yes" 
    omit-xml-declaration="yes"
    cdata-section-elements="input description"/>

  <!-- prevent pass-through of text nodes -->
  <xsl:template match="text()"/>

  <!-- Manually create the root element with the target namespace and process its children -->
  <xsl:template match="/">
    <xsl:message>Processing <xsl:value-of select="base-uri(/)"/></xsl:message>
    <xsl:element name="dataset" namespace="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">
        <xsl:copy-of select="/*/@*"/>
        <xsl:apply-templates select="/*/node()"/>
    </xsl:element>
  </xsl:template>

  <!-- Process <llm:instance> -->
  <xsl:template match="llm:instance">
      <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="llm:input"/>
          <xsl:apply-templates select="llm:output[@type='bibl']"/>
          <xsl:apply-templates select="llm:output[@type='bibl']" mode="biblstruct"/>
          <xsl:apply-templates select="llm:output[@type='bibl']" mode="resolved-biblstruct"/>
      </xsl:copy>
  </xsl:template>

  <!-- Process <llm:input> -->
  <xsl:template match="llm:input">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="text()"/>
      </xsl:copy>
  </xsl:template>
  
  <!-- Process <llm:output type="bibl">  -->
  <xsl:template match="llm:output[@type='bibl']">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="node()"/>
      </xsl:copy>
  </xsl:template>

  <!-- ignore sections to be deleted -->
  <xsl:template match="llm:output[@type='block']" /> 
  <xsl:template match="llm:output[@type='biblStruct']" /> 

  <!-- Create <llm:output type="biblstruct">  -->
  <xsl:template match="llm:output[@type='bibl']" mode="biblstruct">
      <xsl:element name="output" namespace="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">
        <xsl:attribute name="type" select="'biblstruct'"/>
        <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select=".//tei:bibl" mode="bibl-to-biblstruct"/>
        </xsl:element>
      </xsl:element>
  </xsl:template>

  <!-- Create <llm:output type="resolved-biblstruct">  -->
  <xsl:template match="llm:output[@type='bibl']" mode="resolved-biblstruct">
    <xsl:element name="output" namespace="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">
      <xsl:attribute name="type" select="'resolved-biblstruct'"/>
      <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select=".//tei:bibl" mode="bibl-to-resolved-biblstruct"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  


</xsl:stylesheet>
