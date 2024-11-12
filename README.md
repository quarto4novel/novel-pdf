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
- [x] headings (inside `.chapter` divs): only level 2 `## chapter tile` and
  level 3 `### chapter subtitle` are allowed and only in chapter div:
  ```qmd
  :::{.chapter}
  ## chapter tile
  ### chapter subtitle
  :::
  ```
- [ ] headings (outside `.chapter` divs):
  - [ ] level 1: structural parts
    - `# Front matter`
    - `# Body matter`
    - `# Back matter`
    - any other level 1 title is an error
  - [ ] level 2 (in frontmatter): subpart of **front matter**. The name of each
    subpart won't appear in the final document and are here only for
    structuration when writing.
    See: https://en.wikipedia.org/wiki/Book_design#Front_matter
    - `## Half matter`
    - `## Frontispiece`
    - `## Title page`
    - `## Copyright page`
    - `## Dedication`
    - `## Epigraph`
    - `## Table of contents`
    - `## Foreword`
    - `## Preface`
    - `## Acknowledgments`
    - `## Introduction`
    - `## Prologue`
    - any other level 2 title inside front matter is an error
  - [ ] level 2 (in backmatter): subpart of **back matter**. The name of each
    subpart won't appear in the final document and are here only for
    structuration when writing.
    See: https://en.wikipedia.org/wiki/Book_design#Back_matter_(end_matter)
    - `## Epilogue`
    - `## Outro`
    - `## Afterword`
    - `## Conclusion`
    - `## Postscript`
    - `## Appendix` or `## Addendum`
    - `## Glossary`
    - `## Bibliography`
    - `## Index`
    - `## Colophon`
    - `## Postface`
    - `## Author`
    - any other level 2 title inside front matter is an error
  - [ ] level 2 (in body matter): **chapter** with title `## My chapter title`.
    You can use the `lines_before=7` attribute to set the position of the title,
    it defaults to `chapters.title.lines_before` metadata. The chapter can have
    more detailed when encapsulated in a ``.chapter` div.

    ```qmd
    :::{.chapter}
    ## My Super Chapter Title
    ### And a wonderful subtitle to go with it

    Some more content for the chapter start (epigraph, for word, image...).
    :::
    ```
  - [ ] level 3 (in body matter and inside .chapter div): chapter subtitle
  - [ ] level 3 (in body matter):
    - a **scenebreak** if the title is `### scenebreak`
    - a **sceneline** if the title is `### sceneline`
    - a **scenestars** if the title is `### scenestars`
    - a **quick chapter** with title otherwise `### my title`
- [ ] blockquotes
- [x] line blocks
- [x] raw content block
- [x] raw content inline
- [x] inline math
- [x] display math
- [ ] images `![Caption](elephant.png)`
- [ ] callout blocks
- [x] div attributes
- [x] span attributes
- [x] special characters support:
  - hyphen (inter-word) `-``
  - en dash `--`
  - em dash `---`
  - ellipsis `...`
  - simple quotes `'...'`
  - double quotes `"..."`
  - french quotes `«...»`
  - dollar sign `$`
  - pound sign `£`
  - euro sign `€`
  - hashtag `#`
  - pipe `|`
  - star sign `*`
  - slash `/`
  - backslash `\`
- [ ] direct emoji support: 😍🐺✈️  should be rendered in a clean black and
  white dedicated font
  - https://tex.stackexchange.com/questions/224584/define-fallback-font-for-specific-unicode-characters-in-lualatex
  - [Substituting fonts for emojis in LuaLaTeX](https://tex.stackexchange.com/a/572220)
    this is the best way
  - [Define fallback font for missing glyphs in LuaLaTeX](https://tex.stackexchange.com/q/514940)

## Unsupported markdown feature

Some very common feature of markdown are not supported by pdf-novel, don't try
to use them:

- **lists** are typeset using layout incompatible with the rest of novel as
specified in the
[novel class documentation about lists and tables](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h8)
. This includes **ordered lists**, **unordered lists**, **definition lists** and
***task lists**.
- **tables** are typeset using layout incompatible with the rest of novel as
specified in the [novel class documentation about lists and tables](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h8)
- code blocks
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

- [x] **novel specific font configuration**: multiple options are available in
  the `_metadata.yml` file to configure fonts used in your novel and they are
  all well documented directly in the file itself.
- [x] **scenebreak shortcode**: mark a seperation in the text flow. Three
  different kind of scene breake are possible `{{< scenebreak blank >}}`,
  `{{< scenebreak line >}}` and `{{< scenebreak stars >}}` corresponding to the
  [3 possible Scene Breaks of the novel class](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h5.3).

  ```qmd
  {{< scenebreak >}}

  {{< scenebreak blank >}}

  {{< scenebreak line >}}

  {{< scenebreak stars >}}
  ```

  You can control if there is an indend in the text with the
  `scenebreak.indent` metadata (false by default as it is a standard in
  fiction). And you can set the default scene break type with the
  `scenebreak.default` metadata (possible value are `blank`, `line` and
  `stars`)

  ```{.yaml filename=_metadata.yml}
  scenebreaks:
    indent: false
    default: blank
  ```
- [x] **mainmatter shortcode**: mark the begining of your story
  `{{< mainmatter >}}`
- [ ] **page header** and **page footer** control
- [x] **clearpage shortcode**: provides a new page, which will be verso or
  recto, without skipping a page.
- [x] **cleartorecto shortcode**: forces new page to begin on a recto page, if
  necessary inserting a blank verso.
- [x] **emptypage shortcode**
- [x] **null shortcode**: put a character with no width (usefull sometimes for
  manual layout)
- [x] **vfill shortcode**: fill the vertical space as long as possible pushing
  subsequent element down
- [x] **epigraph filter**: include an epigraph (poem or citation) with author
  and source:

  ```qmd
  :::{.epigraph by="John Lennon" from="An interview"}
  When I was 5 years old, my mother always told me that happiness was the key
  to life. When I went to school, they asked me what I wanted to be when I
  grew up. I wrote down ‘happy’. They told me I didn’t understand the
  assignment, and I told them they didn’t understand life.
  :::
  ```

  or

  ```
  :::{.epigraph by="Robert Frost" from="Nothing Gold Can Stay"}
  | Nature's first green is gold,
  | Her hardest hue to hold.
  | Her early leaf's a flower;
  | But only so an hour.
  :::
  ```
  Available attributes:

  - `lmargin` and `rmargin` to control the left and right margins
  - `lines_before` and `lines_after` to jump a certain amount of lines before
    and after the epigraph
  - `keepindend` to let the paragraphs inside the epigraph have an indend like
    any other paragraphs

  Available metadata:

  - `epigraphs.lmargin` and `epigraphs.rmargin` default values for `lmargin`
    and `rmargin` attributes for the whole document
  - `epigraphs.lines_before` and `epigraphs.lines_after` default values for
    `lines_before` and `lines_after`for the whole document
  - `epigraphs.keepindend` default value for `keepindent` attribute for the
    whole document

- [ ] **raw div formating** and **raw span formating**: classes that can be
  applied to any div or span. ⚠️ ***markdown favors meaning over presentation
  so those classes should not be used directly in your document, prefer the
  semantic classes (see below) that are more suited for clean, meaning centered,
  wrinting.*** ⚠️

  Here are the available classes and attributes:

  - for divs:
    - [x] `.bold`
    - [x] `.italic`
    - [x] `.strikethrough`
    - [x] `.smallcaps`
    - [x] `.monospace` (with respect to multilign alignment by using right
      alignment instead of default justified one)
    - [x] `.noparindent` to remove indentation of the first line of paragraphs
    - [x] `noparskip=value` to set the space between 2 consecutive paragraph
      (in LaTeX units)
    - [x] `vfill=before/after/both`
    - [x] `vspace_before/after/both=length` in LaTeX units (including `\nbs` for
      number of lines). For example `vspace_after=3\nbs` to jump 3 lines after
      the div
    - [x] `lines_before/after/both=nb` in number of lines. Shortcut for vspace
      attribute with value always in number of lines. For example
      `lines_after=3` to jump 3 lines after the div
    - [ ] `font=???`
    - [x] `scale=factor` scale the text by a factor. `scale=1.2` will scale the
      text by x1.2. The resulting paragraphs may finish off-grid (the grid of
      lines that all pages should respect for a good readability) you can
      compensate by adding vertical space after the div using `vspace`
      attribute. The exact vertical space to add is for you to calculate
      See:
      [novel class -- Environment: parascale](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h6.1.3)
    - [ ] `lang=???`
    - [x] `margin_left/right/both=length` in LaTeX units. For example
      `margin_left=5em` to add a margin of 5em at the left of the div
    - [x] `align=left/right/centered/justified`
  - for spans:
    - [x] `.bold`
    - [x] `.italic`
    - [x] `.strikethrough`
    - [x] `.smallcaps`
    - [x] `.monospace`
    - [x] `hfill=before/after/both`
    - [ ] `font=???`
    - [x] `scale=factor,hoffset,voffset` scale the text by a factor. Only the
      first parameter is mandatory. `scale=1.2` will scale the text by x1.2. The
      two other parameters are optional and need LaTeX units. Other lines are
      not adjusted so there may be some overlapping.
      See:
      [novel class -- Local sizing: `\charscale`](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h6.1.2)
    - [ ] `lang=???`
    - [x] `hspace_before/after/both=length` in LaTeX units. For example
      `hspace_before=2cm` to add a horizontal space of 2cm at the left of the
      span
    - [x] `phantom` Does not print the text, but leaves a horizontal gap as if
      the text were there. Caution: ⚠️ In some locations, this command has
      unexpected results, such as by adding a line.
    - [ ] `first_words/last_words=???`

- [ ] **semantic div formating** and **semantic span formating**: you can define
  specific classes in the `semantic_classes` metadata and specify which
  **raw formating classes** you want to apply to that class (see this as a
  very simple CSS system). Here is a typical config `_metadata.yml`:

  ```yaml
  semantic_classes:
    greek_lang: [italic, lang=greek]
    robot_speech: [bold, font=sf_futuristic_font]
    shout: [scale=1.5, smallcaps]
    whisper: [scale=0.8]
    hand_written: [scale=1.2, font=my_cursive_font]
  ```

  And here is how to use it in you document:

  ```qml
  The young boy was afraid but he needed to communicate with his friend so he
  whispered in her ear. [« I think we are doomed. »]{.whisper} But Valerie was
  not the kind of person to hide when confronted to danger. [« Don't worry
  dude, this monstruous teddy bear is nothing like the pirate I crushed last
  week ! »]{.shout}.
  ```

- [ ] **toc shortcode**
- [x] **emptylines shortcode**: add vertical space by a number of lines
- [ ] **foreignlanguage filter**
- [x] Different **rendering mode** adapted to different stage of writing or
  reviewing: printready, cropmarks, shademargins, cropview, closecrop and
  sandbox. They are detailed and documented in `_metadata.yml`.
- [x] **parindent** and **parskip** metadata to specify the default indentation
  and default vertical space between paragraphs.
  See: https://latexref.xyz/fr/_005cparindent-_0026-_005cparskip.html
- [ ] **hyphenation control**
  You can set an "hyphenation cutting point" wherever you want using `\-` even
  in a monospace div or span (useful for url and stuff like that)
  - https://en.wikibooks.org/wiki/LaTeX/Text_Formatting#Hyphenation
  - https://en.wikibooks.org/wiki/LaTeX/Text_Formatting#Margin_misalignment

## Deprecated features

- **chapter shortcode** and **chapter div**: fictional works have a very
  specific structure that do not correspond to academic structure used by
  classical LaTeX document. In particular the hierarchical `\part`,
  `\section`, `\chapter`, etc is not used in novels (see:
  [Novel class novel-documentation : Avoid Academic Structures](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h1.2.3)
  ). That's why we provide a `{{< chapter "My chapter One" >}}` shortcode to
  create a chapter easily and a div class that let you create advanced
  chapters header with title, subtitle using level 1 and 2 headers and other
  content:

  ```qmd
  :::{.chapter}
  ## My Super Chapter Title
  ### And a wonderful subtitle to go with it
  :::
  ```

  And with height specified:

  ```qmd
  :::{.chapter height=20}
  ## My Super Chapter Title
  ### And a wonderful subtitle to go with it
  :::
  ```
- **quickchapter shortcode**: used by some books are designed with numerous
  short chapters that run continously, so that chapters may start anywhere on a
  page. They can also be used as **named scene break**. You can use it like that
  `{{< quickchapter "chaptertitle" line=true/false/length >}}`.

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

I took heavy inspiration from the great post about
[quarto extensions](https://www.cynthiahqy.com/posts/quarto-extensions-explainer/index.html).

And for book structure:

- [Wikipedia - Book design](https://en.wikipedia.org/wiki/Book_design)
- [Les différentes parties d’un livre : de la page de titre à la postface](https://www.commentecrire.fr/blog/les-differentes-parties-dun-livre-de-la-page-de-titre-a-la-postface/)
