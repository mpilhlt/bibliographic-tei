# TEI schema for bibliographic references

This repository contains a [TEI schema](./schema/tei-bib.odd), maintained in the 
[ODD format](https://tei-c.org/guidelines/customization/getting-started-with-p5-odds/), 
from which an [XSD schema](./schema/xsd/document.xsd) can be generated via the 
https://roma.tei-c.org/ tool.

It is part of the ["Legal Theory Knowledge Graph" project](https://www.lhlt.mpg.de/2514927/03-boulanger-legal-theory-graph) 
at the Max Planck Institute of Legal History and Legal Theory. 

Related repositories:

 - https://github.com/mpilhlt/pdf-tei-editor
 - https://github.com/mpilhlt/llamore

## Motivation

While the standard TEI format allows for the annotation of entries in properly formatted bibliographies, a number of edge cases exist that need to be addressed in order to achieve truly interoperable annotation data.

In particular, the TEI documentation does not yet provide sufficient guidance and examples for footnoted literature, which is a distinctive feature of humanities scholarship. In this type of publications, footnotes are characterized by a combination of incomplete bibliographic information and additional commentary, often cross-referencing information contained other footnotes.

Our objective is to annotate this textual data in a way that allows interoperability and the training of reference extraction models. To achieve this, we believe that annotation in this domain should be standardised to the necessary extent. We propose a couple of refinements to the current schema which would allow unambiguous encoding of citation conventions that exist in this kind of literature.

## Example annotations

See our current [set of examples](https://mpilhlt.github.io/bibliographic-tei/)

This is a work-in-progress meant to be discussed. The schema might change any time.
