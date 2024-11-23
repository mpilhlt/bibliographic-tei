<xsl:stylesheet version="2.0"
  xmlns:llm="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

  <!-- this stylesheet generates a set of static sites to view and analyze the gold standard files -->

  <xsl:import href="bibl-to-resolved-biblstruct.xsl" />

  <!-- you can pass `-param verbose yes` to the saxon cli command to get more verbose output -->
  <xsl:param name="verbose" select="'off'"/> 

  <!-- output html -->
  <xsl:output method="html" indent="yes" encoding="UTF-8"
    doctype-public="-//W3C//DTD HTML5//EN" doctype-system="http://www.w3.org/TR/html5/html.html" />

  <!-- prevent pass-through of text nodes -->
  <xsl:template match="text()"></xsl:template>

  <!-- Match <llm:dataset> and process its children -->
  <xsl:template match="llm:dataset">
    <xsl:message>Processing <xsl:value-of select="base-uri(/)"/></xsl:message>
    
    <html lang="en">
      <head>
        <title><xsl:value-of select="llm:title"/></title>
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
          ul[data-tabs] > li > a {
            font-size: small;
          }
        </style>
      </head>
      <body>
        <!-- title, description, source -->
        <h1><xsl:value-of select="llm:title"/></h1>
        <xsl:if test="llm:description">
          <div class="description-dataset">
            <xsl:value-of select="llm:description" disable-output-escaping="yes" />
          </div>
        </xsl:if>
        <xsl:if test="starts-with(@source, 'http')">
          <div class="source-dataset">
              <a href="{@source}" target="_blank">Source URL</a>
          </div>
      </xsl:if>
        <!-- main content -->
        <div class="document-container">
          <xsl:apply-templates />
        </div>
        <!-- UI - related scripts -->
        <script>
          const tabs = []
          const tabSelectors = document.querySelectorAll('[data-tabs]');
            for (const [i, tab] of [...tabSelectors].entries()) {
            tab.setAttribute(`data-tab-${i+1}`, '');
            tabs[i+1] = new Tabby(`[data-tab-${i+1}]`);
          }
          hljs.highlightAll();
          
          // add links
          function addLinks() {
            const spans = document.querySelectorAll('span') 
            spans.forEach((span, idx) => {
              if (span.textContent.trim() == 'xml:id') {
                const next = spans[idx+1];
                if (next) {
                  const id = next.textContent.trim();
                  next.innerHTML = `&lt;a id=${id}&gt;${id}&lt;/a&gt;`;
                }
              } else {
                const match = span.textContent.trim().match(/^"#(.+)"$/);
                if (match) {
                  const biblId = match[1]
                  const tabElement = document.querySelector(`[data-bibl-ids*="${biblId}"]`);
                  if (!tabElement) {
                    console.error(`Cannot find tab containing #${biblId}`)
                  } else {
                    const tabIndex = tabElement.dataset.tabIndex;
                    span.innerHTML = `"&lt;a href="#${biblId}" onclick=&quot;tabs[${tabIndex}].toggle(&apos;${tabElement.id}&apos;)&quot;&gt;#${biblId}&lt;/a&gt;"`;
                  }
                }
              }
            });            
          }
          setTimeout(addLinks, 2000)
        </script>
      </body>
    </html>
  </xsl:template>

  <!-- Template to process <llm:instance> -->
  <xsl:template match="llm:instance">
    <fieldset id="{@xml:id}" class="block-with-description">
      <legend><a href="#{@xml:id}"><xsl:value-of select="@xml:id"/></a></legend>
      <!-- description element -->
      <xsl:if test="llm:description">
        <div class="description-instance">
          <xsl:value-of select="llm:description" disable-output-escaping="yes" />
        </div>
      </xsl:if>
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

  <!-- Template for the tabbed code blocks -->
  <xsl:template name="tabbed-codeblocks">
    <xsl:param name="node" />
    
    <ul data-tabs="">
      <li>
        <a href="#bibl-{$node/@xml:id}">&lt;bibl&gt; (gold)</a>
      </li>
      <li>
        <a href="#block-{$node/@xml:id}">&lt;bibl&gt; (unsegmented)</a>
      </li>
      <li>
        <a href="#biblstruct-source-{$node/@xml:id}">&lt;biblStruct&gt; (source)</a>
      </li>
      <li>
        <a href="#biblstruct-unresolved-{$node/@xml:id}">&lt;biblStruct&gt; (unresolved)</a>
      </li>
      <li>
        <a href="#biblstruct-resolved-{$node/@xml:id}">&lt;biblStruct&gt; (resolved)</a>
      </li>
    </ul>

    <!-- Main gold <llm:output[@type='bibl']> -->     
      <div
      id="bibl-{$node/@xml:id}"
      data-bibl-ids="{string-join($node//tei:bibl/@xml:id, ' ')}"
      data-tab-index="{replace(@xml:id, '^[^\d]*(\d+)$', '$1')}">
      <pre><code>
            <xsl:call-template name="serialize-stripped">
                <xsl:with-param name="node" select="$node/llm:output[@type='bibl']/*[1]"/>
            </xsl:call-template>
        </code></pre>
    </div>

    <!-- <llm:output[@type='block']> -->
    <div
      id="block-{$node/@xml:id}">
      <pre><code>
            <xsl:call-template name="serialize-stripped">
                <xsl:with-param name="node" select="$node/llm:output[@type='block']/*[1]"/>
            </xsl:call-template>
        </code></pre>
    </div>



    <!-- Process <llm:output[@type='biblStruct']> -->
    <div id="biblstruct-source-{$node/@xml:id}">
      <pre><code>
        <xsl:call-template name="serialize-stripped">
            <xsl:with-param name="node" select="$node/llm:output[@type='biblStruct']/*[1]"/>
        </xsl:call-template>
        </code></pre>
    </div>

    <!-- Unresolved biblStruct -->
    <div id="biblstruct-unresolved-{$node/@xml:id}">
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
    <div id="biblstruct-resolved-{$node/@xml:id}" class="tab-biblstruct-resolved">
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
      select="serialize($node, map {
        'method': 'xml', 
        'indent': if ($node/self::tei:note) then false() else true()
      })" />

    <!-- Replace whitespace before a opening characters -->
    <xsl:variable name="whitespace-fixes" 
        select="replace($serialized, '(\p{Pi}|\p{Ps})\n(\s*)', '&#10;$2$1')" />

    <!-- Post-process to remove indentation of attributes -->
    <xsl:variable
      name="attribute-fixes"
      select="replace($whitespace-fixes, '[\n\r]+\s+([^\s&lt;]+=&quot;.+?&quot;)', ' $1')" />

    <!-- Remove namespace expressions -->
    <xsl:variable
      name="namespace-stripped"
      select="replace($attribute-fixes, ' xmlns(:\w+)?=&quot;[^&quot;]*&quot;', '')" />

    <!-- De-indent -->
    <xsl:variable
      name="de-indented"
      select="llm:replace_while_match($namespace-stripped, '', '[\n\r]&lt;', '([\n\r]+)\s', '$1')" />

    <!-- Output the final formatted and pretty-printed XML -->
    <xsl:value-of select="$de-indented" />
  </xsl:template>


  <!-- function to recursively search/replace as long as a certain regular expression matches or
  does not match -->
  <xsl:function name="llm:replace_while_match" as="xs:string">
    <xsl:param name="input" as="xs:string" />
    <xsl:param name="match" as="xs:string" />
    <xsl:param name="not-match" as="xs:string" />
    <xsl:param name="search" as="xs:string" />
    <xsl:param name="replace" as="xs:string" />

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