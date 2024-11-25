<xsl:stylesheet exclude-result-prefixes="#all" 
    version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- 
    Convert a <tei:bibl> to a <tei:biblStruct>,
  -->

  <!-- handle complete references only -->
  <xsl:import href="bibl-to-biblstruct.xsl" />

  <!-- configure output-->
  <xsl:output 
    method="xml"
    version="1.0" 
    name="xml" 
    encoding="UTF-8" 
    indent="yes"
    omit-xml-declaration="yes"/>

  <!-- resolve incomplete references, adding information from the referenced elements -->
  <xsl:template match="tei:bibl" mode="bibl-to-resolved-biblstruct">
    <biblStruct source="#{@xml:id}">
      <!-- variables that can identify the reference if incomplete -->
      <xsl:variable name="original-author-surnames" select="tei:author//tei:surname"/>
      <xsl:variable name="original-editor-surnames" select="tei:editor//tei:surname"/>
      <xsl:variable name="count-creators" select="count($original-author-surnames) + count($original-editor-surnames)" />
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
                  <xsl:text>[+] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                  <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                  <xsl:text>found reference for target </xsl:text><xsl:value-of select="$ref-target"/><xsl:text>.</xsl:text>
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
                <xsl:text>[-] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                <xsl:text>Cannot find target '</xsl:text><xsl:value-of select="$ref-target"/><xsl:text>'.</xsl:text>
              </xsl:message>
              <xsl:call-template name="process-bibl-children">
                <xsl:with-param name="node" select="." />
                <xsl:with-param name="original-node" select="." />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose> 
        </xsl:when>

        <!-- op.cit etc simply refers to the previous <bibl>, that might or might not be always correct -->
        <xsl:when test="not(exists(tei:ref[@type = 'footnote'])) and exists(tei:ref[@type = 'op-cit'])">
          <xsl:variable name="op-cit" select="tei:ref[@type = 'op-cit'][1]/text()"/>
          <xsl:variable name="surname" select="(tei:author[1]//surname | tei:editor[1]//surname)[1]"/>
          <xsl:variable name="bibl-node">
            <xsl:choose>
              <xsl:when test="exists($surname)">
                <xsl:value-of select="preceding::tei:bibl[tei:surname[1][text() = $surname]][1]" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="preceding::tei:bibl[1]" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <!-- referenced <bibl> exists -->
            <xsl:when test="exists($bibl-node)">
              <xsl:if test="$verbose = 'on'">
                <xsl:message>
                  <xsl:text>[+] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                  <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                  <xsl:text>found reference for '</xsl:text><xsl:value-of select="$op-cit"/><xsl:text>'.</xsl:text>
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
                <xsl:text>[-] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                <xsl:text>Cannot find reference for '</xsl:text>
                <xsl:value-of select="concat($surname, if ($surname) then ', ' else '', $op-cit)" />
                <xsl:text>'.</xsl:text>
              </xsl:message>
              <xsl:call-template name="process-bibl-children">
                <xsl:with-param name="node" select="." />
                <xsl:with-param name="original-node" select="." />
              </xsl:call-template>
            </xsl:otherwise>            
          </xsl:choose>
        </xsl:when>

        <!-- find the target <bibl> via the footnote number and the author -->
        <xsl:when test="exists(tei:ref[@type = 'footnote' and @n])">
          <!-- find the footnote node -->
          <xsl:variable name="footnote-num" select="tei:ref/@n" />
          <xsl:variable name="footnote-node" select="//tei:note[@n = $footnote-num and exists(.//tei:surname | .//tei:orgName)]"/>
          <xsl:choose>
            <!-- <note type='footnote'> exists and we do not have author or editor -->
            <xsl:when test="exists($footnote-node) and $count-creators = 0">
              <xsl:if test="$verbose = 'on'">
                <xsl:message>
                  <xsl:text>[+] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                  <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                  <xsl:text>found anonymous reference in footnote </xsl:text><xsl:value-of select="$footnote-num"/><xsl:text>.</xsl:text>
                </xsl:message>
              </xsl:if>
              <xsl:call-template name="process-bibl-children">
                <xsl:with-param name="node" select="$footnote-node/bibl[1]" />
                <xsl:with-param name="original-node" select="." />
              </xsl:call-template>
            </xsl:when>
            <!-- <note type='footnote'> exists and we have an author or editor -->
            <xsl:when test="exists($footnote-node) and $count-creators > 0">
              <xsl:variable name="bibl-node-author" select="
              if (exists($original-author-surnames)) then 
                $footnote-node//tei:bibl[deep-equal(tei:author//tei:surname/text(), $original-author-surnames/text())] |
                $footnote-node//tei:bibl[deep-equal(tei:editor//tei:surname/text(), $original-author-surnames/text())]
              else ()"/>
              <xsl:variable name="bibl-node-editor" select="
                if (exists($original-editor-surnames)) then 
                  $footnote-node//tei:bibl[deep-equal(tei:editor//tei:surname/text(), $original-editor-surnames/text())]
                else ()"/>
              <xsl:variable name="role-and-name" select="
                if (exists($bibl-node-author)) then concat('author(s) ', string-join($original-author-surnames/text(),'/'))
                else if (exists($bibl-node-editor)) then concat('editors(s) ', string-join($original-editor-surnames/text(),'/'))
                else ''"/>
              <xsl:variable name="bibl-node" select="
                if (exists($bibl-node-author)) then $bibl-node-author
                else if (exists($bibl-node-editor)) then $bibl-node-editor
                else ()"/>
              <xsl:if test="count($bibl-node) > 1">
                <xsl:message terminate="yes">
                  <xsl:text>[-] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                  <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                  <xsl:text>Error: More than one bibl-node for </xsl:text><xsl:value-of select="$role-and-name"/>
                  <xsl:text> in footnote </xsl:text><xsl:value-of select="$footnote-num"/><xsl:text>.</xsl:text>
                </xsl:message>
              </xsl:if>
              <xsl:choose>
                <xsl:when test="exists($bibl-node)">
                  <xsl:if test="$verbose = 'on'">
                    <xsl:message>
                      <xsl:text>[+] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                      <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                      <xsl:text>found reference for </xsl:text><xsl:value-of select="$role-and-name"/>
                      <xsl:text> in footnote </xsl:text><xsl:value-of select="$footnote-num"/><xsl:text>.</xsl:text>
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
                    <xsl:text>[-] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                    <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                    <xsl:text>cannot find reference for </xsl:text><xsl:value-of select="$role-and-name"/>
                    <xsl:text>.</xsl:text>
                  </xsl:message>
                  <xsl:call-template name="process-bibl-children">
                    <xsl:with-param name="node" select="." />
                    <xsl:with-param name="original-node" select="." />
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- <note type='footnote'> not found -->
            <xsl:otherwise>
              <xsl:message>
                <xsl:text>[-] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                <xsl:text>Cannot find referenced footnote </xsl:text><xsl:value-of select="$footnote-num"/>
                <xsl:text>.</xsl:text>
                <xsl:call-template name="process-bibl-children">
                  <xsl:with-param name="node" select="." />
                  <xsl:with-param name="original-node" select="." />
                </xsl:call-template>
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
  
</xsl:stylesheet>
