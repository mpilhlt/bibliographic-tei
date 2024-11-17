<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

  <xsl:template match="dataset">
    <html lang="en">
      <head>
        <title>Dataset</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/cferdinandi/tabby/dist/css/tabby-ui.min.css" />
        <script src="https://cdn.jsdelivr.net/gh/cferdinandi/tabby/dist/js/tabby.polyfills.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.10.0/languages/xml.min.js" integrity="sha512-dG+W2e5Wf51XUF9HqsX31z5+nTTuxe8wpOEC3/1gCJImJusP1FZS1PHxiH3NjBUQJ6oDpVRKKXH7+aCVd+wkDA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <style>
          body {
            font-family:Arial, Helvetica, sans-serif
          }
          .raw-text { 
            padding: 10px;
            font-family: 'Courier New', Courier, monospace;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="description-dataset">
            Dataset-level description: 
            <xsl:value-of select="description"/>
          </div>
          
          <xsl:apply-templates select="instance"/>
        </div>
        <script>
          new Tabby('[data-tabs]');
          hljs.highlightAll();
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="instance">
    <div>
      <div class="description-instance">
        Description instance <xsl:value-of select="@xml:id"/>
      </div>
      <ul data-tabs="">
        <li><a data-tabby-default="" href="#input-{@xml:id}">Input</a></li>
        <li><a href="#block-{@xml:id}">Block</a></li>
        <li><a href="#bibl-{@xml:id}">bibl</a></li>
        <li><a href="#biblStruct-{@xml:id}">biblStruct</a></li>
      </ul>
      
      <xsl:apply-templates select="output"/>
    </div>
  </xsl:template>

  <xsl:template match="output[@type='raw']">
    <div id="input-{@xml:id}">
      <div class="raw-text">
        <xsl:value-of select="text()"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="output[@type='block']">
    <div id="block-{@xml:id}">
      <pre><code>
        <xsl:value-of select="text()" normalize-space="yes" disable-output-escaping="yes"/>
      </code></pre>
    </div>
  </xsl:template>

  <xsl:template match="output[@type='bibl']">
    <div id="block-{@xml:id}/>">
      <pre><code>
        <xsl:value-of select="text()" normalize-space="yes" disable-output-escaping="yes"/>
      </code></pre>
    </div>
  </xsl:template>

  <xsl:template match="output[@type='bibl']">
    <div id="block-{@xml:id}/>">
      <pre><code>
        <xsl:value-of select="text()" normalize-space="yes" disable-output-escaping="yes"/>
      </code></pre>
    </div>
  </xsl:template>

  </xsl:stylesheet>