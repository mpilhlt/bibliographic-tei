<xsl:stylesheet version="2.0"
  xmlns:llm="https://gitlab.mpcdf.mpg.de/dcfidalgo/llamore"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

  <xsl:output method="html" indent="yes" encoding="UTF-8" />

  <!-- prevent pass-through of text nodes -->
  <xsl:template match="text()"></xsl:template>

  <!-- Match <llm:dataset> and process its children -->
  <xsl:template match="llm:dataset">
    <html lang="en">
      <head>
        <title>Dataset</title>
        <meta charset="UTF-8"></meta>
        <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/gh/cferdinandi/tabby/dist/css/tabby-ui.min.css"></link>
        <script src="https://cdn.jsdelivr.net/gh/cferdinandi/tabby/dist/js/tabby.polyfills.min.js"></script>
        <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css" />
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
        <script
          src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.10.0/languages/xml.min.js"
          integrity="sha512-dG+W2e5Wf51XUF9HqsX31z5+nTTuxe8wpOEC3/1gCJImJusP1FZS1PHxiH3NjBUQJ6oDpVRKKXH7+aCVd+wkDA=="
          crossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <style>
          body {
          font-family: Arial, Helvetica, sans-serif;
          }
          .raw-text {
          padding: 10px;
          font-family: 'Courier New', Courier, monospace;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="description">
            <xsl:value-of select="llm:description" disable-output-escaping="yes" />
          </div>
          <xsl:apply-templates select="llm:instance[llm:description]" />
        </div>
        <script>
          new Tabby('[data-tabs]');
          hljs.highlightAll();
        </script>
      </body>
    </html>
  </xsl:template>

  <!-- Template for <llm:description> -->
  <xsl:template match="llm:description">
    <div class="description-dataset">
        <xsl:copy-of select="." />
    </div>
  </xsl:template>

  <!-- template to escape xml data and remove indentation -->
  <xsl:template name="serialize-stripped">
    <xsl:param name="node"/>
    <xsl:variable name="serialized-node" select="serialize($node, map {'method': 'xml'})"/>
    <xsl:variable name="stripped-node" select="replace($serialized-node, '\n\s{8}', '&#10;')"/>
    <xsl:value-of select="$stripped-node"/>
  </xsl:template>

  <!-- Template for <llm:instance> with a <description> child -->
  <xsl:template match="llm:instance[llm:description]">

    <div class="description-instance">
        <xsl:value-of select="llm:description" disable-output-escaping="yes" />
    </div>

    <ul data-tabs="">
      <li>
        <a data-tabby-default="" href="#input-{@xml:id}">Input</a>
      </li>
      <li>
        <a href="#block-{@xml:id}">Block</a>
      </li>
      <li>
        <a href="#bibl-{@xml:id}">bibl</a>
      </li>
      <li>
        <a href="#biblStruct-{@xml:id}">biblStruct</a>
      </li>
    </ul>


    <!-- Process <llm:input[@type='raw']> -->
      <div id="input-{@xml:id}" class="raw-text">
        <xsl:value-of select="llm:input[@type='raw']"/>
      </div>    

    <!-- Process <llm:output[@type='block']> -->
    <div id="block-{@xml:id}">
      <pre><code>
        <xsl:call-template name="serialize-stripped">
          <xsl:with-param name="node" select="llm:output[@type='block']"/>
        </xsl:call-template>
      </code></pre>
    </div>

    <!-- Process <llm:output[@type='bibl']> -->
    <div id="bibl-{@xml:id}">
      <pre><code>
        <xsl:call-template name="serialize-stripped">
          <xsl:with-param name="node" select="llm:output[@type='bibl']"/>
        </xsl:call-template>
      </code></pre>
    </div>

    <!-- Process <llm:output[@type='biblStruct']> -->
    <div id="biblStruct-{@xml:id}">
      <pre><code>
        <xsl:call-template name="serialize-stripped">
          <xsl:with-param name="node" select="llm:output[@type='block']"/>
        </xsl:call-template>
      </code></pre>
    </div>

  </xsl:template>

</xsl:stylesheet>