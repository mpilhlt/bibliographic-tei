<xsl:stylesheet version="2.0"
  xmlns:llm="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

  <!-- this stylesheet generates a TEI/XML bibliography from all <bibl> elements found in the text
  of a TEI/XML document -->
  <!-- taken from https://github.com/OpenArabicPE/convert_tei-to-bibliographic-data -->
  <xsl:import href="bibl-to-biblstruct.xsl" />

  <!-- output html -->
  <xsl:output method="html" indent="yes" encoding="UTF-8"
    doctype-public="-//W3C//DTD HTML5//EN" doctype-system="http://www.w3.org/TR/html5/html.html" />

  <!-- prevent pass-through of text nodes -->
  <xsl:template match="text()"></xsl:template>

  <!-- Match <llm:dataset> and process its children -->
  <xsl:template match="llm:dataset">
    <html lang="en">
      <head>
        <title>Dataset</title>
        <meta charset="UTF-8"></meta>
        <!-- tabby -->
        <link rel="stylesheet" href="resources/tabby/dist/css/tabby-ui.min.css"></link>
        <script src="resources/tabby/dist/js/tabby.polyfills.min.js"></script>
        <!-- highlight.js -->
        <link rel="stylesheet" href="resources/highlight.js/11.9.0/styles/default.min.css" />
        <script src="resources/highlight.js/11.9.0/highlight.min.js"></script>
        <script src="resources/highlight.js/11.9.0/languages/xml.min.js"></script>
        <style>
          body {
          font-family: Arial, Helvetica, sans-serif;
          }
          .raw-text {
          padding: 10px;
          font-family: 'Courier New', Courier, monospace;
          }
          .block-with-description, .block-no-description {
          }
        </style>
      </head>
      <body>
        <div class="document-container">
          <div class="document-description">
            <xsl:value-of select="llm:description" disable-output-escaping="yes" />
          </div>
          <!-- Apply templates to all llm:instance elements with a description -->
          <xsl:apply-templates select="llm:instance[llm:description]" />

          <!-- Then apply templates to all llm:instance elements without a description -->
          <hr />
          <xsl:apply-templates select="llm:instance[not(llm:description)]" />
        </div>
        <script>
          const tabSelectors = document.querySelectorAll('[data-tabs]');
          for (const [i, tabs] of [...tabSelectors].entries()) {
          tabs.setAttribute(`data-tabs-${i}`, '');
          new Tabby(`[data-tabs-${i}]`);
          }
          hljs.highlightAll();
        </script>
      </body>
    </html>
  </xsl:template>

  <!-- Template for top-level <llm:description> -->
  <xsl:template match="llm:description">
    <div class="description-dataset">
      <xsl:copy-of select="." />
    </div>
  </xsl:template>

  <!-- Template to process <llm:instance> with a <description> child -->
  <xsl:template match="llm:instance[llm:description]">
    <fieldset class="block-with-description">
      <legend><a name="{@xml:id}" href="#{@xml:id}"><xsl:value-of select="@xml:id"/></a></legend>
      <div class="description-instance">
        <xsl:value-of select="llm:description" disable-output-escaping="yes" />
      </div>
      <!-- Process <llm:input[@type='raw']> -->
        <div
        id="input-{@xml:id}" class="raw-text">
        <xsl:value-of select="llm:input[@type='raw']" />
      </div>
      <!-- Process <llm:output> nodes -->
      <xsl:call-template name="tabbed-codeblocks">
        <xsl:with-param name="node" select="." />
      </xsl:call-template>
    </fieldset>
  </xsl:template>

  <!-- Template to process <llm:instance> without a <description> child -->
  <xsl:template match="llm:instance[not(llm:description)]">
    <fieldset class="block-no-description">
      <legend><a name="{@xml:id}" href="#{@xml:id}"><xsl:value-of select="@xml:id"/></a></legend>
      <!-- Process <llm:input[@type='raw']> -->
      <div id="input-{@xml:id}"
      class="raw-text">
      <xsl:value-of select="llm:input[@type='raw']" />
    </div>
    <!-- Process <llm:output> nodes -->    
    <xsl:call-template name="tabbed-codeblocks">
      <xsl:with-param name="node" select="." />
    </xsl:call-template>
    </fieldset>
  </xsl:template>

  <!-- Template for the tabbed code blocks -->
  <xsl:template name="tabbed-codeblocks">
    <xsl:param name="node" />
    
    <ul data-tabs="">
      <li>
        <a href="#block-{$node/@xml:id}">Block</a>
      </li>
      <li>
        <a href="#bibl-{$node/@xml:id}">&lt;bibl&gt;</a>
      </li>
      <li>
        <a href="#biblStruct-{$node/@xml:id}">&lt;biblStruct&gt; (from source)</a>
      </li>
      <li>
        <a href="#biblStruct-unresolved-{$node/@xml:id}">&lt;biblStruct&gt; (unresolved)</a>
      </li>
      <li>
        <a href="#biblStruct-resolved-{$node/@xml:id}">&lt;biblStruct&gt; (resolved)</a>
      </li>
    </ul>

    <!-- Process <llm:output[@type='block']> -->
    <div
      id="block-{$node/@xml:id}">
      <pre><code>
            <xsl:call-template name="serialize-stripped">
                <xsl:with-param name="node" select="$node/llm:output[@type='block']/*[1]"/>
            </xsl:call-template>
        </code></pre>
    </div>

    <!-- Process <llm:output[@type='bibl']> -->
    <div
      id="bibl-{$node/@xml:id}">
      <pre><code>
            <xsl:call-template name="serialize-stripped">
                <xsl:with-param name="node" select="$node/llm:output[@type='bibl']/*[1]"/>
            </xsl:call-template>
        </code></pre>
    </div>

    <!-- Process <llm:output[@type='biblStruct']> -->
    <div
      id="biblStruct-{$node/@xml:id}">
      <pre><code>
        <xsl:call-template name="serialize-stripped">
            <xsl:with-param name="node" select="$node/llm:output[@type='biblStruct']/*[1]"/>
        </xsl:call-template>
        </code></pre>
    </div>

    <!-- Unresolved biblStruct -->
    <div id="biblStruct-unresolved-{$node/@xml:id}">
      <pre><code>
          <xsl:variable name="biblStructResult">
            <listBibl>
              <xsl:apply-templates select="$node/llm:output[@type='bibl']//tei:bibl" mode="unresolved" />
            </listBibl>
          </xsl:variable>
          <xsl:call-template name="serialize-stripped">
            <xsl:with-param name="node" select="$biblStructResult"/>
          </xsl:call-template>
        </code></pre>
    </div>

    <!-- Resolved biblStruct -->
    <div id="biblStruct-resolved-{$node/@xml:id}">
      <pre><code>
          <xsl:variable name="biblStructResult">
            <listBibl>
              <xsl:apply-templates select="$node/llm:output[@type='bibl']//tei:bibl" mode="resolved"/>
            </listBibl>
          </xsl:variable>
          <xsl:call-template name="serialize-stripped">
            <xsl:with-param name="node" select="$biblStructResult"/>
          </xsl:call-template>
        </code></pre>
    </div>

  </xsl:template>

  <!-- Template to escape XML data and remove indentation and namespaces, then pretty-print -->
  <xsl:template name="serialize-stripped">
    <xsl:param name="node" />

    <!-- Serialize the node with pretty-printing enabled -->
  <xsl:variable name="serialized"
      select="serialize($node, map {'method': 'xml', 'indent': true()})" />

    <!-- Post-process to remove indentation of attributes -->
  <xsl:variable
      name="attributes-fixed"
      select="replace($serialized, '[\n\r]+\s+([^\s&lt;]+=&quot;.+?&quot;)', ' $1')" />

    <!-- Remove namespace expressions -->
  <xsl:variable
      name="namespace-stripped"
      select="replace($attributes-fixed, ' xmlns(:\w+)?=&quot;[^&quot;]*&quot;', '')" />

    <!-- De-indent -->
  <xsl:variable
      name="de-intented"
      select="llm:replace_while_match($namespace-stripped, '', '[\n\r]&lt;', '([\n\r]+)\s', '$1')" />

    <!-- Output the final formatted and pretty-printed XML -->
  <xsl:value-of
      select="$de-intented" />
  </xsl:template>

  <!-- function to recursively search/replace as long as a certain regular expression matches or
  does not match -->
  <xsl:function name="llm:replace_while_match" as="xs:string">
    <xsl:param name="input" as="xs:string" />
  <xsl:param name="match" as="xs:string" />
  <xsl:param
      name="not-match" as="xs:string" />
  <xsl:param name="search" as="xs:string" />
  <xsl:param
      name="replace" as="xs:string" />

    <!-- Replace while matching the pattern and ensuring we don't recurse indefinitely -->
  <xsl:variable name="replaced"
      select="replace($input, $search, $replace)" />

    <!-- Check if a replacement happened, and if so, recurse, otherwise return the input -->
  <xsl:choose>
      <!-- Continue replacing if there's a match and the input changed -->
      <xsl:when test="($match != '' and matches($input, $match)) and ($replaced != $input)">
        <xsl:sequence
          select="llm:replace_while_match($replaced, $match, $not-match, $search, $replace)" />
      </xsl:when>

      <!-- Check if the input does not match the 'not-match' pattern and continue -->
      <xsl:when
        test="($not-match != '' and not(matches($input, $not-match))) and ($replaced != $input)">
        <xsl:sequence
          select="llm:replace_while_match($replaced, $match, $not-match, $search, $replace)" />
      </xsl:when>

      <!-- If no match occurs or the string didn't change, return the input -->
      <xsl:otherwise>
        <xsl:sequence select="$input" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>