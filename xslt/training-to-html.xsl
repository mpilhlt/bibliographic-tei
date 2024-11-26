<xsl:stylesheet version="2.0"
  xmlns:llam="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

  <!-- 
    This stylesheet generates a set of static sites to view and analyze 
    the gold standard files 
  -->

  <!-- params -->
  <xsl:param name="verbose" select="'off'"/> 

  <!-- output configuration -->
  <xsl:output   
    encoding="utf-8"
    method="html" 
    indent="yes" 
    doctype-public="-//W3C//DTD HTML5//EN" 
    doctype-system="http://www.w3.org/TR/html5/html.html" />

  <!-- prevent pass-through of text nodes -->
  <xsl:template match="text()"></xsl:template>

  <!-- Match <llam:dataset> and process its children -->
  <xsl:template match="llam:dataset">
    <xsl:message>Processing <xsl:value-of select="base-uri(/)"/></xsl:message>
    
    <html lang="en">
      <head>
        <title><xsl:value-of select="llam:title"/></title>
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
          .validation-error {
            color: 'red'
          }
        </style>
      </head>
      <body>
        <!-- title, description, source -->
        <h1><xsl:value-of select="llam:title"/></h1>
        <xsl:if test="llam:description">
          <div class="description-dataset">
            <xsl:value-of select="llam:description" disable-output-escaping="yes" />
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
            // mark errors
            let firstSpan = false;
            document.querySelectorAll("span").forEach(span =&gt; {
              if (span.textContent == "error") {
                span.style.color = "red";
              }
            });
          }
          setTimeout(addLinks, 2000)
        </script>
      </body>
    </html>
  </xsl:template>

  <!-- Template to process <llam:instance> -->
  <xsl:template match="llam:instance">
    <fieldset id="{@xml:id}" class="block-with-description">
      <legend><a href="#{@xml:id}"><xsl:value-of select="@xml:id"/></a></legend>
      <!-- description element -->
      <xsl:if test="llam:description">
        <div class="description-instance">
          <xsl:value-of select="llam:description" disable-output-escaping="yes" />
        </div>
      </xsl:if>
      <!-- Process <llam:input[@type='raw']> -->
        <div
        id="input-{@xml:id}" class="raw-text">
        <xsl:value-of select="llam:input[@type='raw']" />
      </div>
      <!-- Process <llam:output> nodes -->
      <xsl:call-template name="tabbed-codeblocks">
        <xsl:with-param name="node" select="." />
      </xsl:call-template>
    </fieldset>
  </xsl:template>

  <!-- Template for the tabbed code blocks -->
  <xsl:template name="tabbed-codeblocks">
    <xsl:param name="node" />

    <!-- heuristic: if we have a <ref> element, the reference is probably incomplete -->
    <xsl:variable name="biblstruct-is-incomplete" select="exists($node/llam:output[@type='bibl']//tei:ref)"/>
    
    <ul data-tabs="">
      <li>
        <a href="#segmented-instance-{$node/@xml:id}">Segmented &lt;instance&gt;</a>
      </li>
      <li>
        <a href="#bibl-{$node/@xml:id}">Segmented &lt;bibl&gt; (gold)</a>
      </li>
      <li>
        <a href="#unresolved-biblstruct-{$node/@xml:id}">&lt;biblStruct&gt;</a>
      </li>
      <xsl:if test="$biblstruct-is-incomplete">
        <li>
          <a href="#resolved-biblstruct-{$node/@xml:id}">Resolved &lt;biblStruct&gt;</a>
        </li>
      </xsl:if>

    </ul>

    <!-- <llam:output[@type='block']> -->
    <div id="segmented-instance-{$node/@xml:id}">
      <pre><code>
            <xsl:call-template name="serialize-to-html">
                <xsl:with-param name="node" select="$node/llam:output[@type='segmented-instance']/*[1]"/>
            </xsl:call-template>
        </code></pre>
    </div>    

    <!-- Main gold <llam:output[@type='bibl']> -->     
    <div id="bibl-{$node/@xml:id}"
      data-bibl-ids="{string-join($node//tei:bibl/@xml:id, ' ')}"
      data-tab-index="{replace(@xml:id, '^[^\d]*(\d+)$', '$1')}">
      <pre><code>
            <xsl:call-template name="serialize-to-html">
                <xsl:with-param name="node" select="$node/llam:output[@type='bibl']/*[1]"/>
            </xsl:call-template>
        </code></pre>
    </div>


    <!-- Process <llam:output[@type='biblStruct']> -->
    <div id="unresolved-biblstruct-{$node/@xml:id}">
      <pre><code>
        <xsl:call-template name="serialize-to-html">
            <xsl:with-param name="node" select="$node/llam:output[@type='biblstruct']/*[1]"/>
        </xsl:call-template>
        </code></pre>
    </div>

    <!-- Process <llam:output[@type='biblStruct']> containing <ref> elements -->
    <xsl:if test="$biblstruct-is-incomplete">
      <div id="resolved-biblstruct-{$node/@xml:id}">
        <pre><code>
          <xsl:call-template name="serialize-to-html">
              <xsl:with-param name="node" select="$node/llam:output[@type='resolved-biblstruct']/*[1]"/>
          </xsl:call-template>
          </code></pre>
      </div>
    </xsl:if>

  </xsl:template>

  <!-- Template to escape XML data and remove indentation and namespaces, then pretty-print -->
  <xsl:template name="serialize-to-html">
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
      select="replace(replace($attribute-fixes, '\{http://www\.tei-c\.org/ns/1\.0\}', 'tei:'), '( xmlns(:\w+)?=&quot;[^&quot;]*&quot;)', '')" />

    <!-- De-indent -->
    <xsl:variable
      name="de-indented"
      select="llam:replace_while_match($namespace-stripped, '', '[\n\r]&lt;', '([\n\r]+)\s', '$1')" />

    <!-- Output the final formatted and pretty-printed XML -->
    <xsl:value-of select="$de-indented" />
  </xsl:template>


  <!-- function to recursively search/replace as long as a certain regular expression matches or
  does not match -->
  <xsl:function name="llam:replace_while_match" as="xs:string">
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
          select="llam:replace_while_match($replaced, $match, $not-match, $search, $replace)" />
      </xsl:when>

      <!-- Check if the input does not match the 'not-match' pattern and continue -->
      <xsl:when
        test="($not-match != '' and not(matches($input, $not-match))) and ($replaced != $input)">
        <xsl:sequence
          select="llam:replace_while_match($replaced, $match, $not-match, $search, $replace)" />
      </xsl:when>

      <!-- If no match occurs or the string didn't change, return the input -->
      <xsl:otherwise>
        <xsl:sequence select="$input" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>