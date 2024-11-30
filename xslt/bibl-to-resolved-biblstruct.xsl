<xsl:stylesheet exclude-result-prefixes="#all" 
    version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
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

        <!-- find bibl referenced by 'op.cit' etc by assuming it is the previous bibl -->
        <xsl:when test="not(exists(tei:ref[@type = 'footnote'])) and exists(tei:ref[@type = 'op-cit'])">
          <xsl:variable name="op-cit" select="tei:ref[@type = 'op-cit'][1]/text()"/>
          <!-- use the first surname found to match the bibl in the referenced footnote, this will fail in edge cases -->
          <xsl:variable name="name" select="(.//tei:surname[1] | .//tei:orgName)[1]"/>
          <xsl:variable name="bibl-node-id">
              <xsl:choose>
                  <xsl:when test="exists($name)">
                      <!-- if the name matches one or more of the preceding bibls, take the first one of those -->
                      <xsl:value-of select="preceding::tei:bibl[.//tei:surname = $name or .//tei:orgName = $name][1]/@xml:id" />
                  </xsl:when>
                  <xsl:otherwise>
                      <!-- otherwise just take the first of the previous ones -->
                      <xsl:value-of select="preceding::tei:bibl[1]/@xml:id" />
                  </xsl:otherwise>
              </xsl:choose>
          </xsl:variable>
          <xsl:variable name="bibl-node" select="//tei:bibl[@xml:id = $bibl-node-id]"/>
          <xsl:variable name="note-node" select="//tei:note[exists(tei:bibl[@xml:id = $bibl-node-id])]" />
          <xsl:choose>
            <xsl:when test="exists($bibl-node) and exists($bibl-node//tei:surname | $bibl-node//tei:orgName)">
              <!-- referenced <bibl> exists -->
              <xsl:if test="$verbose = 'on'">
                <xsl:message>
                  <xsl:text>[+] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                  <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                  <xsl:text>'</xsl:text><xsl:value-of select="$op-cit"/><xsl:text>' resolves to </xsl:text>
                  <xsl:text>'</xsl:text>
                  <xsl:value-of select="($bibl-node//tei:surname | $bibl-node//tei:orgName)[1]"/>
                  <xsl:text>' in footnote </xsl:text><xsl:value-of select="$note-node/@n"/>
                  <xsl:text>.</xsl:text>
                </xsl:message>
              </xsl:if>
              <xsl:call-template name="process-bibl-children">
                <xsl:with-param name="node" select="$bibl-node" />
                <xsl:with-param name="original-node" select="." />
              </xsl:call-template>
            </xsl:when>            
            
            <xsl:otherwise>
              <!-- <bibl> not found -->
              <xsl:message>
                <xsl:text>[-] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                <xsl:text>Cannot find reference for '</xsl:text>
                <xsl:value-of select="concat($name, if ($name) then ', ' else '', $op-cit)" />
                <xsl:text>'</xsl:text>
                <xsl:choose>
                  <xsl:when test="exists($note-node)">
                    <xsl:text> in footnote </xsl:text><xsl:value-of select="$note-node/@n"/>
                  </xsl:when> 
                  <xsl:otherwise>
                    <xsl:text> in any previous footnote</xsl:text>
                  </xsl:otherwise>             
                </xsl:choose>
                <xsl:text>.</xsl:text>
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
          <!-- use the first surname found to match the bibl in the referenced footnote, this will fail in edge cases -->
          <xsl:variable name="name" select=".//tei:surname[1] | .//tei:orgName[1]"/>
          <xsl:choose>
            <!-- <note type='footnote'> exists and we do not have author or editor -->
            <xsl:when test="exists($footnote-node) and not(exists($name))">
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
            <xsl:when test="exists($footnote-node) and exists($name)">
              <xsl:variable name="bibl-node" 
                select="$footnote-node//tei:bibl[.//tei:surname = $name or .//tei:orgName = $name]"/>
              <xsl:choose>
                <xsl:when test="count($bibl-node) = 1">
                  <!-- Success ! -->
                  <xsl:if test="$verbose = 'on'">
                    <xsl:message>
                      <xsl:text>[+] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                      <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                      <xsl:text>found reference for </xsl:text><xsl:value-of select="$name"/>
                      <xsl:text> in footnote </xsl:text><xsl:value-of select="$footnote-num"/><xsl:text>.</xsl:text>
                    </xsl:message>
                  </xsl:if>
                  <xsl:call-template name="process-bibl-children">
                    <xsl:with-param name="node" select="$bibl-node" />
                    <xsl:with-param name="original-node" select="." />
                  </xsl:call-template>
                </xsl:when>              
                <xsl:when test="count($bibl-node) > 1">
                  <!-- more than one -->
                  <xsl:message terminate="yes">
                    <xsl:text>[-] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                    <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                    <xsl:text>Error: More than one bibl-node </xsl:text><xsl:value-of select="$name"/>
                    <xsl:text> found for </xsl:text><xsl:value-of select="$name"/>
                    <xsl:text> in footnote </xsl:text><xsl:value-of select="$footnote-num"/><xsl:text>.</xsl:text>
                  </xsl:message>
                </xsl:when>
                <xsl:otherwise>
                  <!-- <bibl> not found -->
                  <xsl:message>
                    <xsl:text>[-] Footnote </xsl:text><xsl:value-of select="parent::node()/@n"/>
                    <xsl:text> (#</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>): </xsl:text>
                    <xsl:text>cannot find reference for </xsl:text><xsl:value-of select="$name"/>
                    <xsl:text> stated to be in footnote </xsl:text><xsl:value-of select="$footnote-num"/>
                    <xsl:text>.</xsl:text>
                    <!-- xsl:copy-of select="$footnote-node"/-->
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
