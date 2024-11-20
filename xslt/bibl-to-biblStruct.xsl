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

    <xsl:template match="tei:bibl">
       <biblStruct>
            <xsl:copy-of select="@*"/>
            <xsl:if test="tei:title[@level = 'a']">
                <analytic>
                    <xsl:copy-of select="tei:title[@level = 'a']"/>
                    <xsl:copy-of select="tei:author"/>
                </analytic>
            </xsl:if>
            <monogr>
                <xsl:copy-of select="tei:title[@level != 'a']"/>
                <xsl:copy-of select="tei:idno"/>
                <!-- author: depending on which level we are on -->
                <xsl:choose>
                    <!-- if this is for a book section, article etc., the author has been part of <analytic> -->
                    <xsl:when test="tei:title[@level = 'a']"/>
                    <xsl:otherwise>
                        <xsl:copy-of select="tei:author"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:copy-of select="tei:editor"/>
                <imprint>
                    <xsl:copy-of select="descendant::tei:date"/>
                    <xsl:copy-of select="tei:pubPlace"/>
                    <xsl:copy-of select="tei:publisher"/>
                </imprint>
                <xsl:copy-of select="tei:biblScope"/>
                <xsl:copy-of select="tei:citedRange"/>
            </monogr>
            <!-- retain all potential notes  -->
            <xsl:copy-of select="tei:note"/>
        </biblStruct>
    </xsl:template>


</xsl:stylesheet>
