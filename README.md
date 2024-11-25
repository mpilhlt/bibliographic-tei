# TEI schema for bibliographic references

This repository contains a [TEI schema](./schema/tei-bib.odd), maintained in the 
[ODD format](https://tei-c.org/guidelines/customization/getting-started-with-p5-odds/), 
from which an [XSD schema](./schema/xsd/document.xsd) is generated via the 
https://roma.tei-c.org/ tool.

## Motivation

While annotating entries in properly formatted bibliographies can be done with
standard TEI, a number of edge cases need to be addressed which can be expressed
in a variety of ways using the TEI elements in order to achieve interoperability.

In the domain of footnoted literature mainly from the Humanities, the TEI 
documentation does not yet provide sufficient guidance. Footnotes contain messy and
incomplete bibliographic information, interspersed with additional commentary.  
As our aim is to annotate this textual data in a way that allows interoperability and 
the training of models that will allow reference extraction, we think that 
there is a real need of standardization. We also propose a couple of refinements 
to the current schema which would allow to unambiguously encode citation conventions 
that exist in this kind of literature. 

## Example annotations

See our current [set of examples](https://mpilhlt.github.io/bibliographic-tei/)

This is a work-in-progress meant to be discussed. The schema might change any time.
