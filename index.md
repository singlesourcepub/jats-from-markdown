---
title: JATS from Markdown
subtitle: Developer friendly single-source scholarly publishing
author:
- name: Albert Krewinkel
  email: albert@zeitkraut.de
  orcid: 0000-0002-9455-0796
  affiliation:
  - id: 1
    organization: Open Journals
- name: Juanjo Bazán
  orcid: 0000-0001-7699-3983
  affiliation:
  - id: 2
    organization: Open Journals
- name: Arfon M. Smith
  orcid: 0000-0002-3957-2474
  affiliation:
  - id: 3
    organization: GitHub
    country: USA
    country-code: US
  - id: 4
    organization: Open Journals
copyright:
  statement: >-
    © 2022 The authors. Published under a CC BY-SA 4.0 license.
  year: 2022
  holder: Albert Krewinkel, Juanjo Bazán, Arfon Smith
license:
  - text: >-
      This work is licensed under a Creative Commons
      Attribution-ShareAlike 4.0 International License.
    type: open-access
    link: 'https://creativecommons.org/licenses/by-sa/4.0/'
  - >-
      The copyright holder grants the U.S. National Library of Medicine
      permission to archive and post a copy of this paper on the Journal
      Article Tag Suite Conference proceedings website.
bibliography: paper.bib
---

# Abstract

Software is an integral part of modern research and as a
consequence, it is becoming increasingly important to find ways to
acknowledge and credit this work through publication. The [Journal
of Open Source Software](https://joss.theoj.org) (JOSS) is a
developer friendly, open access journal for research software
packages. Authors of JOSS submissions are generally comfortable
with tools commonly used by software developers, as such, the JOSS
paper format, submission, and review process happen in a
developer-focused way with papers written in Markdown (a
lightweight markup-language) and the review happening on GitHub.

Here we present the single-source publishing pipeline developed
for JOSS,
especially the conversion of articles authored in Markdown into
PDF and XML formats, including JATS. We describe how we built on
and extended the document converter *pandoc*, how metadata is
processed and integrated into the publishing artifacts, and which
advantages and challenges we see in enriching plain-text inputs
into structured documents.

# Introduction

The Journal of Open Source Software, created in May 2016, has the
dual goals of "improving the quality of the software submitted and
providing a mechanism for research software developers to receive
credit".[@smith2018]

We developed a publishing system to go from Markdown to JATS in a
mostly automated fashion. The system follows the general idea of
using Markdown as the central format of a document production
system, which has been described previously.[@krewinkel2017]

The idea of using Markdown to produce JATS output has been
described previously[@johnston2016jatdown]; our method differs in
that we consider JATS not as an intermediary format, but as the
normalized exchange format for articles. The source for all output
formats remains the author-generated Markdown file.

## Journal of Open Source Software

The JOSS experience is designed to be family to software
developers. It uses the same infrastructure that many software
authors are already using, and models its reviewing and publishing
processes around this as well.

Reviewing and publishing happens mostly on the software
collaboration platform [GitHub](https://github.com/). Authors and
editors are supported by an "editorialbot", a software that can be
controlled through comments posted to the website[@chatops]. It
automates many aspects of the editorial checks including
information on the submitted software, generates PDF proofs for
the convenience of authors and reviewers, checking citation
metadata and triggering the final publishing step in case of paper
acceptance.

Papers, published under a Creative Commons license, are
immediately uploaded to the journal's website and
[archived](https://github.com/openjournals/joss-papers) in a
public git repository.

This paper focuses on the publishing system, i.e., the component
producing proofs and final artifacts, with the Markdown-to-JATS
conversion as the major point of interest.

# Markup Conversion

Below we demonstrate how a the conversion takes plance by examining
some key document structures and how they are
represented in Markdown and converted to JATS. This should not
be understood as a complete reference, but as a few examples to
demonstrate the general system capabilities.

## Emphasis Markup

The markup in Markdown in supposed to be semantic, not
presentational. The table below gives a small example.

| Markup          | Markdown   | JATS                    | Result   |
|-----------------|------------|-------------------------|----------|
| Emphasis        | `*this*`   | `<italic>this</italic>` | *this*   |
| Strong emphasis | `**that**` | `<bold>that</bold>`     | **that** |
| Subscript       | `H~2~O`    | `H<sub>2</sub>O`        | H~2~0    |
| Superscript     | `Ca^2+^`   | `Ca<sup>2+</sup>`       | Ca^2+^   |

## Mathematical Formulæ

Markdown allows the inclusion of mathematical formulæ using TeX
notation, where the math is delimited by single dollar `$`
characters for inline math, and double `$$` characters for display
math. A formula like $a^2 + b^2 = c^2$ is rendered as

``` xml
<inline-formula>
  <alternatives>
    <tex-math>
<![CDATA[a^2 + b^2 = c^2]]>
    </tex-math>
    <mml:math display="inline"
    xmlns:mml="http://www.w3.org/1998/Math/MathML">
      <mml:mrow>
        <mml:msup>
          <mml:mi>a</mml:mi>
          <mml:mn>2</mml:mn>
        </mml:msup>
        <mml:mo>+</mml:mo>
        <mml:msup>
          <mml:mi>b</mml:mi>
          <mml:mn>2</mml:mn>
        </mml:msup>
        <mml:mo>=</mml:mo>
        <mml:msup>
          <mml:mi>c</mml:mi>
          <mml:mn>2</mml:mn>
        </mml:msup>
      </mml:mrow>
    </mml:math>
  </alternatives>
</inline-formula>
```

Whitespace and indentations are not as in the generated output but
were added for readability.

Note that the XML includes both the raw TeX markup as well as the
MathML representation.

<!--
Maybe this one is nicer?
$\int_{-\infty}^{+\infty} e^{-x^2} \, dx$
-->

## Code listings

There are multiple ways in which code blocks can be written in
Markdown. The most frequently used syntax delimits the code by
three backticks on a separate line, where the programming language
can optionally be given on the opening line.

````` markdown
``` html
<h1>HTML heading</h1>
```
`````

Code blocks are put into `<code>` elements. If the language is
unknown, then `<preformat>` is used instead. No syntax
highlighting is done when targeting JATS.

## Figures

Pandoc currently uses *implicit figures*, i.e., paragraphs that
contain only an image are treated as figures.

``` markdown
![The figure caption](image-path.jpg "optional title")
```

``` xml
<fig>
  <caption><p>The figure caption</p></caption>
  <graphic mimetype="image" mime-subtype="jpeg"
           xlink:href="image-path.jpg"
           xlink:title="optional title" />
</fig>
```

Linebreaks in the graphic element above were added for readability.

## Tables

The most common way to write tables are so-called "pipe tables",
named in reference to the pipe character `|` being used as column
separator.

``` markdown
: Table caption

| Item | Name |
|------|------|
| 1    | Fork |
| 2    | Glas |
```

As demonstrated above, a caption for the table can be added by
prefixing a line before the table with a colon `:`.

``` xml
<table-wrap>
  <caption>
    <p>Table caption</p>
  </caption>
  <table>
    <thead>
      <tr>
        <th>Item</th>
        <th>Name</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1</td>
        <td>Fork</td>
      </tr>
      <tr>
        <td>2</td>
        <td>Glas</td>
      </tr>
    </tbody>
  </table>
</table-wrap>
```

More complex tables, e.g. with cells spanning multiple columns or
rows, can currently not be represented in Markdown syntax.
However, Markdown, due in part to its origins as a blogging tool,
allows to embed raw HTML. Pandoc can be configured to parse and
convert these snippets, so it would be possible to fall back to
HTML when necessary.

## References

BibTeX, and the advanced reimplementation BibLaTeX, are popular
reference management systems. The `.bib` text files used by these
tools can be regarded as a kind of *lingua franca* of reference
handling, as most systems can read and write the format. Due to
this familiarity to most authors, and as pandoc has full support
for bib files, these the preferred source for bibliography
generation.

Pandoc uses the Citation Style Language (CSL) to style citations
as well as the bibliography. By default, `<mixed-citation>`
elements are used and filled with plain (untagged) text that is
formatted according to the requirements of the current CSL.

For JOSS, however, we chose to use the alternative
`<element-citation>` elements, which can be enabled via an pandoc
option. This allows round-trips from bib to JATS and back, should
it ever be necessary.

# Architecture

The unconventional nature of the system increases the importance
of easy deployment and usability: Software developers are very
accustomed to Markdown as a tool for software documentation and
exchange, but less used to using it for publishing. As part of the
JOSS experience, authors are offered an easy way to generate
artifacts like a PDF preview of their paper in the review thread
itself by issuing commands such as `@editorialbot generate pdf`.

Pandoc is the base component of the publishing pipeline, with
scripts, templates, and configuration files as another essential
part.

## Containerization

The publishing component is containerized and available as a
Docker image from multiple container registries. Authors can use
the image in a fashion similar to a normal command line program,
generating PDF and JATS output just by pointing the program to the
article's Markdown file.

Familiarity with the command line should not be a prerequisite for
article authors. For that reason, and since most published
software is developed on GitHub, we [provide a "GitHub
Action"](https://github.com/openjournals/openjournals-draft-action)
that can be enabled by placing a file with a few lines of code in
the software's repository. This will build the publishing
artifacts on a remote server and make the artifacts available for
download each time the repository is updated.

## Conversion Adjustments

The conversion process by stock pandoc is not always sufficient
for a satisfactory XML output. E.g., many authors are used to
writing LaTeX, and include raw LaTeX snippets in the Markdown
input. These snippets will be used when producing PDF output, but
do not show up in other output formats. The most common use of
such snippets is for document-internal cross-references.

Pandoc offers a feature called "[Lua
filters](https://pandoc.org/lua-filters)" that allows to modify
the abstract document tree programmatically. We made heavy use of
Lua filters to improve and shape the conversion process.

### Cross-references

Markdown support for cross-references is limited. For example,
there is no automatic numbering of figures or tables, as there is
in LaTeX. However, as many authors are familiar with the
respective LaTeX mechanisms, the decision was made to add support
for these features.

The system checks the document for raw LaTeX code relevant for
cross-referencing. The snippets are then processed further in a
Lua filter, using pandoc's LaTeX parser to read the raw LaTeX.

Below is example Lua code, showing the kind of processing
necessary to support LaTeX cross-references.

``` lua
-- Function called on all raw inline snippets.
RawInline = function (raw)
  -- Do nothing if the snippet does not contain TeX code.
  if not raw.format == 'tex' then
    return nil
  end

  -- Check if code is related to cross-references.
  -- If it is, then parse the snippet as LaTeX and
  -- use the parse-result to replace the snippet
  -- in the document structure.
  local is_ref_or_label = raw.text:match '^\\ref%{'
    or raw.text:match '^\\autoref'
    or raw.text:match '^\\label%{.*%}$'
  if is_ref_or_label then
    -- parse TeX as a document;
    -- use first paragraph of the result.
    local first = pandoc.read(raw.text, 'latex').blocks[1]
    return first and first.content or nil
  end

  -- Otherwise do nothing.
  return nil
end
```

The actual numbering of equations and tables, not shown here, is
done in the filter as well.

## Metadata

The systems primary format for metadata is
[YAML](https://yaml.org/), a "human-friendly data serialization
language"[@OfficialYAMLWeb]. Pandoc supports the specification of
article metadata in YAML blocks, either directly in the article
file or in separate metadata files.

``` yaml
---
title: Exemplum
date: 2022-05-02
---
```

Three different types of metadata are differentiated in the
publishing system: journal metadata, typically included in the
`<journal-meta>` element, as well as author-supplied and
system-generated article metadata. Journal metadata are hard-coded
into a global configuration file, while author-supplied metadata,
like title and contributors, are taken from the YAML header of the
Markdown file. System-generated article-metadata include the DOI,
submission and acceptance dates, as well as volume and issue
numbers, and are passed to the pipeline only when building the
final publishing artifacts.

All three types of metadata are merged into the article object;
journal metadata is given the highest precedence, followed by
system-generated metadata, thereby ensuring that authors cannot
overwrite any of these data in the final artifacts.

We use pandoc's [metadata schema for JATS
output](<https://pandoc.org/jats>), which can be thought of as a
restricted subset of JATS frontmatter. As the focus is on author
convenience, and due in part to historical decisions and part to
the limitations of YAML, the system performs a normalization step
on the user-provided metadata. This includes the linking of
authors with their affiliations, as well as parsing of names into
firstname, surname, and suffixes. Authors can add details and
override the algorithm in case this automatic parsing fails.

The structure to specify authors and affiliations is influenced by
historical decisions going back to a previous publishing system,
but is focused on simplicity. Each author is given as a list item
in the `authors` field. Affiliations are declared via references
to affiliation indexes.

``` yaml
authors:
  - name: John Doe
    orcid: 0000-1234-5678-901X
    affiliation: 1

affiliations:
  - name: Federation of Planets
    index: 1
```

# Advantages and Drawbacks

This pipeline is well suited for a journal like JOSS, where there
is a heavy focus on automation and reducing manual steps in the
publishing process.

## Output Formats

Besides JATS, the publishing pipeline is also used to produce
PDF/A-3a output suitable for publishing and archiving[@pdfa3]. Just as
JATS, the PDF is generated directly from the Markdown input via
pandoc and LaTeX; the author-submitted text files constitute the
source in this single source publishing workflow. Furthermore, the
pipeline is also used to produce Crossref XML.

It would be possible to extended the system to produce HTML, EPUB,
or other target formats supported by pandoc. The main obstacle for
this is the handling of metadata, as the converter assumes a
simpler metadata structure for most formats than what it supports
for JATS. This can be resolved with moderate effort by using
custom template that includes all relevant variables in the
output.

## Markup expressiveness

The limited number of markup elements helps to produce
semantically tagged output. However, Markdown is, by design, less
expressive than JATS. For example, there is no standard way in
Markdown to add a title to the caption of a figure or table, to
build an index, or to specify inline attribution information for a
quote or graph, all of which are supported in JATS. Similar
problems arise when targeting HTML, especially when adding inline
semantic information.

While it is possible to encode semantics in
Markdown[@krewinkel2017], and to extend pandoc via various methods
(e.g., [Lua filters](https://pandoc.org/lua-filters)) to map this
data into the appropriate tags, these extensions will typically be
*ad hoc* and might require new standardization efforts to prevent
the development of new and incompatible conventions.

Nonetheless, we found Markdown to be sufficiently expressive for
all articles published in JOSS, and believe that the simplicity
and author convenience justifies its use as the base format in a
single-source publishing workflow.

## Reuse

The publishing system is currently geared towards JOSS, but could
be adjusted to suit different journals as well.^[For example, the
JATS version of this article was generated using a similar system.
The sources are available from
https://github.com/tarleb/jats-con-2022] All software used by
JOSS, including the publishing pipeline, is Open Source and
available under an [OSI](https://opensource.org) approved license.
The sources can be found on the [GitHub account of the Open
Journals organization](https://github.com/openjournals).

One aspect worth highlighting in this context is that, due to
pandoc's wide range of supported input formats, the pipeline could
be modified to work with additional or alternative input formats.
Work is underway to build a modified version that works with
reStructuredText[@reStructuredText]. Support for other formats,
like Emacs org[@Dominik2010], Quarto[@quarto], Jupyter notebooks,
or even Docx, would be possible as well.

# Conclusions

Our pipeline implements a single-source publishing workflow that
uses the author-provided Markdown document and BibTeX file as
primary input, producing JATS, PDF, and Crossref XML.

The *pandoc* document converter supports common scientific
document components like code listings, tables, formulæ, and
figures, allowing automated tagging, as well as the production of
visually-focused artifacts. This is enhanced further by
customizing the document conversion process via various pandoc
mechanisms, including custom Lua scripts for metadata handling and
document-internal cross-references.

The system presented here allows for the quick generation of
article proofs and archiving artifacts. This, combined with the
heavy focus on automation in JOSS, enables a single-source
workflow that supports a very short write--review cycle, as well
as direct and effortless publishing.
