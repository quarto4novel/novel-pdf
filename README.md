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
- [x] headings (inside `.chapter` divs): only level 1 `# chapter tile` and level 2 `## chapter subtitle`
    are allowed and only in chapter div:
    ```qmd
    :::{.chapter}
    # chapter tile
    ## chapter subtitle
    :::
    ```
- [ ] headings (outside `.chapter` divs):
    - level 1: structural parts (front matter, body matter, back matter)
    - level 2 (in front/back matter): subpart of **front/back matter**
- [ ] blockquotes
- [x] line blocks
- [ ] source code without language specification
- [ ] source code with language specification
- [x] raw content block
- [x] raw content inline
- [ ] inline math
- [ ] display math
- [ ] images `![Caption](elephant.png)`
- [ ] callout blocks
- [x] div attributes
- [ ] span attributes
- [ ] endash `--`
- [ ] emdash `---`
- [ ] elipsis `...`
- [ ] direct emoji support: 😍🐺✈️  should be rendered in a clean black and
    white dedicated font

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

- [x] **chapter shortcode** and **chapter div**: fictional works have a very
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
    # My Super Chapter Title
    ## And a wonderful subtitle to go with it
    :::
    ```

    And with height specified:

    ```qmd
    :::{.chapter height=20}
    # My Super Chapter Title
    ## And a wonderful subtitle to go with it
    :::
    ```
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
- [x] **null shortcode**
- [ ] **vertical_fill shortcode**
- [ ] **horizontal_fill shortcode**
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

    Here are the available classes:

    - for divs:
        - [x] **.bold**
        - [x] *.italic*
        - [x] ~~.strikethrough~~
        - [x] .smallcaps
        - [ ] .monospace
        - [ ] .noindent
        - [ ] vfill=before/after/both
        - [ ] font=???
        - [ ] scale=???
        - [ ] lang=???
        - [ ] lmargin=???: left margin
        - [ ] rmargin=???: right margin
        - [ ] bmargin=???: equal margins (left and right with the same
            value)
        - [ ] align=left/right/centered (div only)
    - for spans:
        - [x] **.bold**
        - [x] *.italic*
        - [x] ~~.strikethrough~~
        - [x] .smallcaps
        - [ ] .monospace
        - [ ] hfill=before/after/both
        - [ ] font=???
        - [ ] scale=???
        - [ ] lang=???
        - [ ] first_words/last_words=???

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
    whispered in her ear. [« I think we are doomed. »]{.whisper} But Valerie was not
    the kind of person to hide when confronted to danger. [« Don't worry dude,
    this monstruous teddy bear is nothing like the pirate I crushed last week !
    »]{.shout}.
    ```

- [ ] **toc shortcode**
- [x] **emptylines shortcode**: add vertical space by a number of lines
- [ ] **foreignlanguage filter**
- [x] Different **rendering mode** adapted to different stage of writing or
    reviewing: printready, cropmarks, shademargins, cropview, closecrop and
    sandbox. They are detailed and documented in `_metadata.yml`.


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
