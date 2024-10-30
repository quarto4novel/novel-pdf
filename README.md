# Novel-pdf Format

## Installing

```bash
quarto use template pymaldebaran/novel-pdf
```

This will install the extension and create an example qmd file that you can use
as a starting place for your book.

## Using

```bash
quarto render
```

The resulting pdf should appear as a pdf (PDF-X file) in the `_book` directory.

## Options

*TODO*: If your format has options that can be set via document metadata,
describe them.

## Supported markdown features

Based on [Quarto - mardown basics](https://quarto.org/docs/authoring/markdown-basics.html).

- [x] *italics*, **bold**, ***bold italics***
- [x] superscript^2^ / subscript~2~
- [x] ~~strikethrough~~
- [x] `verbatim inline code`
- [x] Angle bracket links <https://quarto.org>
- [x] Classic markdown links [Quarto](https://quarto.org) ⚠️without link as
footnote for the moment⚠️
- [x] simple footnote
- [x] inline footnote
- [ ] blockquotes
- [ ] line blocks
- [ ] source code without language specification
- [ ] source code with language specification
- [ ] raw content block
- [ ] raw content inline
- [ ] inline math
- [ ] display math
- [ ] callout blocks
- [ ] div attributes
- [ ] span attributes
- [ ] endash `--`
- [ ] emdash `---`
- [ ] elipsis `...`

## Unsupported markdown feature

Some very common feature of markdown are not supported by pdf-novel, don't try
to use them:

- **headings** `# level one title`, `## level two title`, etc they are replaced
by the `{{< chapter My chapter One >}}` shortcode.
- **lists** are typeset using layout incompatible with the rest of novel as
specified in the
[novel class documentation about lists and tables](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h8)
. This includes **ordered lists**, **unordered lists**, **definition lists** and
***task lists**.
- **tables** are typeset using layout incompatible with the rest of novel as
specified in the [novel class documentation about lists and tables](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h8)
- images `![Caption](elephant.png)` ???
- source code with file name
- any advanced math
- diagrams
- videos (obviously !)
- keyboard shortcuts

## Supported Quarto specific feature

- [x] [**lipsum shortcode**](https://quarto.org/docs/authoring/lipsum.html)
`{{< lipsum >}}`
- [ ] `include-before-body` metadata
- [ ] `include-after-body` metadata
- [ ] `include-in-header` metadata
- [ ] `metadata-files` metadata

## Unsupported Quarto specific feature

- `reference-location` metadata: Footnotes appear at the bottom of the page
where they are placed as specified in
[novel class documentation about footnotes](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h9.1).

## Novel specific features

- [x] **chapter shortcode**: fictional works have a very specific structure that
do not correspond to academic structure used by classical LaTeX document. In
particular the hierarchical `\part`, `\section`, `\chapter`, etc is not used in
novels (see: [Novel class novel-documentation : Avoid Academic Structures](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h1.2.3)
). That's why we provide a `{{< chapter My chapter One >}}` shortcode to create
a chapter easily
- [ ] **epigraph shortcode**
- [ ] **toc shortcode**
- [ ] **vspace shortcode**
- [ ] **foreignlanguage filter**

## Example

A novel is structured via an `_index.qmd` (you can not use another name for this
file) file that contains an [include shortcodes](https://quarto.org/docs/authoring/shortcodes.html)
for each chapter.

Here is the source code for a minimal sample document: [index.qmd](_index.qmd).

The chapters are located in the `chapters` directory, they ca&n be named
whatever you want as long as you reference them correctly in the include
directive in the `_index.qmd` file.

Here are the source code for a three sample chapters:

- [chapters/chap_01.qmd](chapters/chap_01.qmd)
- [chapters/chap_02.qmd](chapters/chap_02.qmd)
- [chapters/chap_03.qmd](chapters/chap_03.qmd)

## Inspiration

I took heavy inspiration from thos great post about
[quarto extensions](https://www.cynthiahqy.com/posts/quarto-extensions-explainer/index.html).
