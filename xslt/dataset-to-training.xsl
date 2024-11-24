<xsl:stylesheet exclude-result-prefixes="#all" 
    version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:llam="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">

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
    encoding="UTF-8" 
    indent="yes" 
    omit-xml-declaration="yes"
    cdata-section-elements="llam:input llam:description"/>

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

  <xsl:template match="llam:title|llam:description">
    <xsl:copy-of select="."/>
  </xsl:template>

  <!-- Process <llam:instance> -->
  <xsl:template match="llam:instance">
      <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="llam:description"/>
          <xsl:apply-templates select="llam:input" />
          <xsl:apply-templates select="llam:output[@type='bibl']" mode="segmented-instance"/>
          <xsl:apply-templates select="llam:output[@type='bibl']"/>
          <xsl:apply-templates select="llam:output[@type='bibl']" mode="biblstruct"/>
          <xsl:apply-templates select="llam:output[@type='bibl']" mode="resolved-biblstruct"/>
      </xsl:copy>
  </xsl:template>

  <!-- Process <llam:input> -->
  <xsl:template match="llam:input">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="text()"/>
      </xsl:copy>
  </xsl:template>
  
  <!-- Process <llam:output type="bibl">  -->
  <xsl:template match="llam:output[@type='bibl']">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="node()"/>
      </xsl:copy>
  </xsl:template>

  <!-- Create <llam:output type="segmented-instance">  -->
  <xsl:template match="llam:output[@type='bibl']" mode="segmented-instance">
    <xsl:element name="output" namespace="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">
      <xsl:attribute name="type" select="'segmented-instance'"/>
        <xsl:for-each select="*[1]">
          <xsl:element name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="./*">
              <xsl:element name="{name()}">
                <xsl:value-of>
                  <!-- serialize the content of the node-->
                  <xsl:variable name="var1" select="normalize-space(serialize(text()|node(), map {'method':'text'}))"/>
                  <!-- remove whitespace before punctuation at the end of a clause -->
                  <xsl:variable name="var2" select="replace($var1, ' ([.;,!?%:])( |$)', '$1$2')"></xsl:variable>
                  <!-- remove whitespace after opening puntuation -->
                  <xsl:variable name="var3" select="replace($var2, '(\p{Pi}|\p{Ps})\s+', '$1')" />
                  <!-- remove whitespace before closing puntuation -->
                  <xsl:variable name="var4" select="replace($var3, '\s+(\p{Pe}|\p{Pf})', '$1')" />
                  <!-- remove whitespace before and after slash -->
                  <xsl:variable name="var5" select="replace($var4, '\s+/\s+', '/')" />
                  <xsl:variable name="result" select="$var5"></xsl:variable>
                  <!-- check serialization, in case the above rules do not cover all serialization problems -->
                  <xsl:variable name="raw-input" select="../../preceding-sibling::llam:input[@type='raw']/text()"/>
                  <xsl:if test="not(contains($raw-input, $result))">
                    <xsl:message>
                      <xsl:text>&#10;Warning: In </xsl:text><xsl:value-of select="ancestor::llam:instance[1]/@xml:id"/>
                      <xsl:text>, """</xsl:text><xsl:value-of select="$result"/>
                      <xsl:text>""" is not contained in the raw input.&#10;</xsl:text>
                  </xsl:message>
                  </xsl:if>
                  <xsl:value-of select="$result"/>
                </xsl:value-of>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:for-each>
    </xsl:element>
  </xsl:template>
  
  <!-- Create <llam:output type="biblstruct">  -->
  <xsl:template match="llam:output[@type='bibl']" mode="biblstruct">
      <xsl:element name="output" namespace="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">
        <xsl:attribute name="type" select="'biblstruct'"/>
        <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select=".//tei:bibl" mode="bibl-to-biblstruct"/>
        </xsl:element>
      </xsl:element>
  </xsl:template>

  <!-- Create <llam:output type="resolved-biblstruct">  -->
  <xsl:template match="llam:output[@type='bibl']" mode="resolved-biblstruct">
    <xsl:element name="output" namespace="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">
      <xsl:attribute name="type" select="'resolved-biblstruct'"/>
      <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select=".//tei:bibl" mode="bibl-to-resolved-biblstruct"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
