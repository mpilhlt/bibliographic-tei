<xsl:stylesheet version="2.0"
  xmlns:ns="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:llam="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore" 
  xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <xsl:output method="xml"
      omit-xml-declaration="yes" indent="no" 
      cdata-section-elements="input description"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <!-- Manually create the root element with the target namespace -->
        <xsl:element name="dataset" namespace="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">
            <xsl:copy-of select="/*/@*"/>
            <xsl:apply-templates select="/*/node()"/>
        </xsl:element>
    </xsl:template>    

    <xsl:template match="*">
        <xsl:param name="indent" select="'  '" />
        <xsl:text>&#10;</xsl:text>
        <xsl:value-of select="$indent"/>
        
        <!-- Get the namespace of the current element -->
        <xsl:variable name="namespace" select="namespace-uri()"/>
        
        <!-- Create a new element with the same name and namespace -->
        <xsl:element name="{name()}" namespace="{$namespace}">
            <xsl:copy-of select="@*"/>  <!-- Copy attributes -->
            
            <!-- Apply templates to child nodes, passing the updated indent -->
            <xsl:apply-templates>
                <xsl:with-param name="indent" select="concat($indent, '  ')"/>
            </xsl:apply-templates>
            
            <!-- If there are child elements, print a newline and indent again -->
            <xsl:if test="*">
                <xsl:text>&#10;</xsl:text>
                <xsl:value-of select="$indent"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>    

    <xsl:template match="text()">
        <!-- Normalize the text -->
        <xsl:variable name="normalized" select="normalize-space()" />
        
        <!-- Replace whitespace before a opening characters -->
        <xsl:variable name="formatted" 
            select="replace($normalized, '(\p{Pi}|\p{Ps})\n(\s*)', '&#10;$2$1')" />
        
        <!-- Output the processed result -->
        <xsl:value-of select="$formatted" />
    </xsl:template>
    

</xsl:stylesheet>
