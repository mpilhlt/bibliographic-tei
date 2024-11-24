<xsl:stylesheet version="2.0"
    xmlns:ns="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:llam="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore" 
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <!-- parameters -->
    <xsl:param name="indentation" select="'  '"/>
    
    <xsl:output 
        method="xml"
        omit-xml-declaration="yes" 
        indent="no" 
        cdata-section-elements="llam:input llam:description"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <xsl:element name="dataset" namespace="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore">
            <xsl:copy-of select="/*/@*"/>
            <xsl:apply-templates select="/*/node()"/>
        </xsl:element>
    </xsl:template>    

    <xsl:template match="*">
        <xsl:param name="indent" select="indentation"/>

        <!-- first indentation -->
        <xsl:text>&#10;</xsl:text>
        <xsl:value-of select="$indent"/>
        
        <!-- Get the namespace of the current element -->
        <xsl:variable name="namespace" select="namespace-uri()"/>
        
        <!-- Create a new element with the same name and namespace -->
        <xsl:element name="{name()}" namespace="{$namespace}">
             <!-- Copy attributes -->
            <xsl:copy-of select="@*"/> 
            
            <!-- Apply templates to child nodes, passing the updated indent -->
            <xsl:apply-templates>
                <xsl:with-param name="indent" select="concat($indent, $indentation)"/>
            </xsl:apply-templates>
            
            <!-- If there are child elements, print a newline and indent again -->
            <xsl:if test="*">
                <xsl:text>&#10;</xsl:text>
                <xsl:value-of select="$indent"/>
            </xsl:if>

        </xsl:element>
    </xsl:template>    

    <!-- Normalize text nodes -->
    <xsl:template match="text()">
        <xsl:param name="indent" select="''"/>

        <!-- Normalize the text -->
        <xsl:variable name="normalized" select="normalize-space()" />
        
        <!-- Output the processed result -->
        <xsl:value-of select="$normalized" />
    </xsl:template>
    
    <!-- leave <input> and <description> alone -->
    <xsl:template match="text()[(parent::llam:input or parent::llam:description)]">
        <!-- Simply output the text as it is, preserving white space -->
        <xsl:value-of select="." />
    </xsl:template>

</xsl:stylesheet>
