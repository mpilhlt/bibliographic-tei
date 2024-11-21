<xsl:stylesheet exclude-result-prefixes="#all" 
    version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- 
    Convert a <tei:bibl> to a <tei:biblStruct>, optionally resolving <ref> references 
    some code is originally from https://github.com/OpenArabicPE/convert_tei-to-bibliographic-data/blob/master/xslt/convert_tei-to-zotero-rdf_functions.xsl
  -->

  <!-- configure HTML output-->
  <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>

  <!-- output context-free, unresolved <biblStruct> -->
  <xsl:template match="tei:bibl" mode="unresolved">
    <biblStruct source="#{@xml:id}">
      <xsl:call-template name="process-bibl-children">
        <xsl:with-param name="node" select="." />
        <xsl:with-param name="original-node" select="." />
      </xsl:call-template>
    </biblStruct>
  </xsl:template>

  <!-- resolve incomplete references, adding information from the referenced elements -->
  <xsl:template match="tei:bibl" mode="resolved">
    <biblStruct source="#{@xml:id}">
      <!-- variables that can identify the reference if incomplete -->
      <xsl:variable name="original-author-surnames" select="tei:author//tei:surname/text()"/>
      <xsl:variable name="original-editor-surnames" select="tei:editor//tei:surname/text()"/>
      <xsl:variable name="ref-target" select="tei:ref/@target" />
      <xsl:choose>
        
        <!-- Handle incomplete references with reference to other bibls-->
        
        <!-- we have a @target attribute with the xml:id of the referenced bibl --> 
        <xsl:when test="exists($ref-target)">
          <xsl:variable name="bibl-node" select="//*[@xml:id = substring($ref-target, 2)]"/>
          <xsl:choose>
            <!-- referenced <bibl> exists -->
            <xsl:when test="exists($bibl-node)">
              <xsl:if test="$verbose = 'on'">
                <xsl:message>
                  <xsl:text>[+] Found reference for </xsl:text><xsl:value-of select="$ref-target"/>
                  <xsl:text> referenced in footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                  <xsl:text> (</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>).</xsl:text>
                </xsl:message>
              </xsl:if>
              <xsl:call-template name="process-bibl-children">
                <xsl:with-param name="node" select="$bibl-node" />
                <xsl:with-param name="original-node" select="." />
              </xsl:call-template>
            </xsl:when>
            <!-- <bibl> not found -->
            <xsl:otherwise>
              <xsl:message>
                <xsl:text>[-] Cannot find target '</xsl:text><xsl:value-of select="$ref-target"/>
                <xsl:text>' referenced in footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>).</xsl:text>
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose> 
        </xsl:when>

        <!-- find the target <bibl> via the footnote number and the author -->
        <xsl:when test="tei:ref[@type = 'footnote' and @n]">
          <!-- find the footnote node -->
          <xsl:variable name="footnote-num" select="tei:ref/@n" />
          <xsl:variable name="footnote-node" select="//tei:note[@n = $footnote-num and exists(.//tei:surname)]"/>
          <xsl:choose>
            <!-- <note type='footnote'> exists -->
            <xsl:when test="exists($footnote-node)">
              <xsl:variable name="bibl-node-author" select="$footnote-node//tei:bibl[deep-equal(tei:author//tei:surname/text(), $original-author-surnames)]" />
              <xsl:variable name="bibl-node-editor" select="$footnote-node//tei:bibl[deep-equal(tei:editor//tei:surname/text(), $original-editor-surnames)]" />
              <xsl:variable name="creator-role">
                <xsl:choose>
                  <xsl:when test="exists($bibl-node-author)">
                    <xsl:text>author(s)</xsl:text>
                  </xsl:when>
                  <xsl:when test="exists($bibl-node-editor)">
                    <xsl:text>editor(s)</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="bibl-node" select="$bibl-node-author | $bibl-node-editor"/>
              <xsl:choose>
                <xsl:when test="exists($bibl-node)">
                  <xsl:if test="$verbose = 'on'">
                    <xsl:message>
                      <xsl:text>[+] Found reference for </xsl:text><xsl:value-of select="$creator-role"/>
                      <xsl:text> </xsl:text><xsl:value-of select="string-join($original-author-surnames,'/')"/>
                      <xsl:text> in footnote </xsl:text><xsl:value-of select="$footnote-num"/>
                      <xsl:text> referenced in footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                      <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>).</xsl:text>
                    </xsl:message>
                  </xsl:if>
                  <xsl:call-template name="process-bibl-children">
                    <xsl:with-param name="node" select="$bibl-node" />
                    <xsl:with-param name="original-node" select="." />
                  </xsl:call-template>
                </xsl:when>
                <!-- <bibl> not found -->
                <xsl:otherwise>
                  <xsl:message>
                    <xsl:text>[-] Cannot find reference for </xsl:text><xsl:value-of select="$creator-role"/>
                    <xsl:text> </xsl:text><xsl:value-of select="string-join($original-author-surnames,'/')"/>
                    <xsl:text> in footnote </xsl:text><xsl:value-of select="$footnote-num"/>
                    <xsl:text> referenced in footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                    <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>).</xsl:text>
                  </xsl:message>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- <note type='footnote'> not found -->
            <xsl:otherwise>
              <xsl:message>
                <xsl:text>Footnote </xsl:text><xsl:value-of select="$footnote-num"/>
                <xsl:text> referenced in footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>) does not exist.</xsl:text>
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose> 

        </xsl:when>
        <!-- 
          here: handle op.cit etc. 
        --> 

        <!-- Handle complete references -->
        <xsl:otherwise>
          <xsl:call-template name="process-bibl-children">
            <xsl:with-param name="node" select="." />
            <xsl:with-param name="original-node" select="." />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </biblStruct>
  </xsl:template>

  <!-- Named template for processing <tei:bib> -->
  <xsl:template name="process-bibl-children">
    <xsl:param name="node" />
    <xsl:param name="original-node" />

    <!-- free-standing author, usually with a <ref> -->
    <xsl:if test="not($node/tei:title)">
      <xsl:copy-of select="$node/tei:author" />
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
    <xsl:if test="$node/tei:title[@level != 'a']">
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
    <xsl:copy-of select="$original-node/tei:citedRange" />
    <!-- Notes -->
    <xsl:copy-of select="$node/tei:note" />

  </xsl:template>
</xsl:stylesheet>
