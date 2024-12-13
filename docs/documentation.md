# novel-pdf documentation

## LaTeX compilation and fonts

The novel-pdf template is using LuaLaTeX (a nodern and flexible implementation
of LaTeX) to compile the final PDF file. For this it use the texlive2024 and all
it's dependancies.

All font used in the template are part of the one provided by texlive2024. We
only use otf (OpenTypeFont) fonts because we need modern fonts, more detail in
[Novel class - Fonts, normal font size](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h4.2).

### Font adapted to each situation

Multiple fonts are defined for you tu use and some are automaticaly used by the
template:

- **parent font**: the font on which all document font are derived (by changing size
  or other font feature) except ones listed below. It is usually an easily
  readable serif font
- **sans font**: the font used for all sans serif text
- **mono font**: the font used for verbatim text and for explicitly `.monospace`
  divs and spans
- **math font**: the font used when writing math
- **deco font**: the font used to have some decorative glyphs

TODO: implement this

- **title font**
- **chapter font**
- **handwritting font**
- **science-fiction font**
- **lettrine font**

### Fonts configuration

Novel-pdf specific font configuration: multiple options are available in the
`_metadata.yml` file to configure fonts used in your novel and they are all well
documented directly in the file itself.

You can see what LaTeX font are available on this page
[The LaTeX Font Catalogue](https://www.tug.org/FontCatalogue/) and more
specificaly on the
[Fonts with OpenType or TrueType Support](https://www.tug.org/FontCatalogue/opentypefonts.html).

## Basic formating

You can use the following native markdown formating:

- *italics*, **bold**, ***bold italics***
- superscript^2^ / subscript~2~
- ~~strikethrough~~
- `verbatim inline code`

## Links

- Angle bracket links <https://quarto.org>
- Classic markdown links [Quarto](https://quarto.org) ⚠️without link as
footnote for the moment⚠️

## Footnotes

- simple footnote
- inline footnote

## Page header and footer

### For the whole book

You can control what kind of header and footer will be displayed in the book
using the `headerfooter.style` metadata.

Possible values are based on the classic header/footer you can typicaly
find in fiction novel (if you want to use a customized config, use the
closest default):
- `onlyheadercentered`
  - Only Header.
  - Page number at outside (left verso, right recto).
  - Optional emblem adjacent to page number.
  - Text centered. Default author verso, title recto.
  - This is the default for the novel document class.
- `onlyheaderoutside`
  - Only Header.
  - Page number at outside (left verso, right recto).
  - Optional emblem adjacent to page number.
  - Text towards outside, instead of centered.
  - Text begins or ends 1em from the emblem.
  - Default author verso, title recto.
- `onlyheaderinside`
  - Only Header.
  - Page number at outside (left verso, right recto).
  - Optional emblem adjacent to page number.
  - Text towards inside, instead of centered.
  - Default author verso, title recto.
- `onlyfootercentered`
  - Only Footer.
  - Page number centered.
  - Disregards emblem, if coded.
- `onlyfooteroutside`
  - Only Footer.
  - Page number at outside (left verso, right recto).
  - Optional emblem adjacent to page number.
- `bothcentered`
  - Header and Footer.
  - Page number centered in footer.
  - Disregards emblem, if coded.
  - Text centered in header.
  - Default author verso, title recto.

See: https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h4.3.3.1

### For just the next page

To change the header and footer style for just the next page you can use the
`nextpagestyle=???` of the **clearpage shortcode** or
**cleartorecto shortcode**:

```qmd
{{< clearpage nextpagestyle=fancy>}}
```

or

```qmd
{{< cleartorecto nextpagestyle=fancy>}}
```

Possible values are:

- fancy
- empty
- footer
- forcenumber
- dropfoliobeneath
- dropfolioinside

See [novel class - tispagestyle](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h4.3.5.1)

## Structure

**chapter adapted to fiction**: fictional works have a very specific structure
that do not correspond to academic structure used by classical LaTeX document.
In particular the hierarchical `\part`, `\section`, `\chapter`, etc is not used
in novels (see:
[Novel class novel-documentation : Avoid Academic Structures](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h1.2.3)).
That's why we provide a headers and div classes that let you create advanced
chapters, quickchapters, scene breaks, parts and even high level separation of
the "matters" of a book.

### The 3 matters

Fiction books have (for historical reason but that still have effect nowadays)
been structured around three main parts:

1. **front matter**: this is the non fiction part of your book. It contains title,
  editing information, legal stuff, etc The only fictional that could fit in
  here is the prologue.
2. **body matter**: where the actual fictional content of your book is.
3. **back matter**: in modern fiction this is rarely used except for the words
  "The end" (or "To be continued") or complemental content that would otherwise
  constitute a spoiler.

Those are represented by **level 1 heading with corresponding names** and no
other level 1 heading can be used in your book.

The default files provided with novel-pdf provides you with convenient default
for all the non fictional parts. It's not exhaustive, you can add anything you
want and you can modify them as you see fit.

Important note: those 3 part of a book don't have visible titles in a book, they
are just a way to organise your work in the document (we don't need to tell the
reader "This is the part with the story", they usualy are able to find that by
them self).

### Inside the main matter

Novel use 3 structures inside the **main matter**:

- **chapters**: a chapter always start on a new page and has a **chapter
  start**, an empty vertical space containing only the chapter title, subtitle
  and sometimes some other content (epigraph, illustration...) before the text
  of the chapter itself.
- **quickchapters**: a quick chapter only has a title (and sometimes decoration)
  and does not start on a new page.
- **parts**: a part is a chapter with no text content, it is just a separation
  between two chapters. There is no hierarchical relationship between chapters
  and parts but you can use them as if there was. Parts are in fact a chapter
  with a chapter start and no content. It is always on it's own recto page next
  to an empty verso page.

#### Chapter and quick chapters (and scene breaks)

Chapters are the most common subdivision for a full book, but if you prefer a
more fluid narration without cut in the action you can use quickchapter as your
main subdivision.

Quick chapter are also a good choice if you write a small novel and don't feel
the need for page break in your story.

One important point is **chapters and quick chapters** can be used together! You
want to have big chapters but feel the need to split them in named subparts? No
problem: use quick chapters inside your chapters! If you just need to mark a
pause in your story but don't need it to be named you can use the little sibling
of quick chapters, the **scene break** (it juste add 2 blank lines optionaly
with and horizontal line or some ornaments).

- Chapters are represented by **level 2 headings** like that:
  `## My cool chapter`
- Quick chapters are represented by **level 3 headings** like that:
  `### My funky quick chapter`
- Scene break are represented by **level 4 headings**:
    - a **blank scene break** that just add a vertical space in the text
      flow if the title is `#### Scene break blank`
    - a **line scene break** that insert an horizontal line in the text flow
      if the title is `#### Scene break line`
    - a **stars scene break** that insert three little stars in the text
      flow if the title is `#### Scene break stars`
    - a **default scene break** that insert one of the previous scene break if
      the title is simply `#### Scene break`
    - any other level 4 title is considered an error

Here are the possible metadata that control default behaviors of the chapters
(for details see the `_metadata.yml` file it is documented):

- `chapters.title.lines_before=???` (in number of lines)
- `chapter.height=???` (in number of lines)
- `scenesbreaks.default=blank/line/stars`

#### Advanced chapters: usage of chapter divs

It is possible to give more detail about a chapter, for example to add a
subtitle, a fancy illustration, a big number at the top, an epigraph or whatever
you can think of. To do this you just need to use a **chapter div** (see
[quarto documentation about divs] if you never used them). The div must contain
a unique **level 2 heading for the chapter title** and can contain a unique
**level 3 heading to specify the subtitle**... afer that you can add what ever
content you want in the chapter start. Just like that:

```qmd
:::{.chapter}
## My Super Chapter Title
### And a wonderful subtitle to go with it

Some more content for the chapter start (epigraph, for word, image...).
:::

Here goes the text of your chapter itself.

With as many paragraph as you want.
```

Here are the possible class or attributes you can add to a chapter div to
control its rendering:

- `height=15` (in number of lines) to set the height of the vertical space for
  the chapter start. The default value is set in `_metadata.yml` via the
  `chapters.height` metadata
- `page_style=empty` to set header/footer style for the first page of the
  chapter. The possible values are:
  - **fancy**: like any normal page
  - **empty**: no header, no footer
  - **footer**: only footer (if there is one)
  - **forcenumber**: show page number at it normal place (header or footer)
  - **dropfoliobeneath**: In this context, "folio" means page number. Write the
    page number in the bottom margin
  - **dropfolioinside**: In this context, "folio" means page number. Write the
    page number above the bottom margin (for this it reduc e the number of lines
    of the page)
  See:
  [Novel class - Exceptional pages style](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h4.3.5.1)

Here are the possible class or attributes you can add to a level 3 or 4 heading
inside a chapter div to control its rendering:

- `lines_before=7` (in number of lines) attribute to set the position of the
  title/subtitle

#### Chapter and quick chapter first line decoration

Chapter and quick chapter can start with a decorated first line. This is purely
decorative and can be configured using the `_metadata.yml` file using the
`chapters.fldeco` and `quickchapters.fldeco` metadatas.

The possible decorations for the first line are:

- big majuscule using the `fonts.firstletter` font (overflow over the current
  line)
- huge majuscupe on multiple lines using `fonts.dropcap` font (underflow under
  the current line)
- first line of first para in small caps
- both big majuscule and smallcaps first line
- nothing special, just regular line

It is possible to disable this effect for a specific chapter or quick chapter by
using the `.nofldeco` class on the header or div used:

```qmd
:::{.chapter .nofldeco}
## A chapter without decoration
:::

## Another chapter without decoration {.nofldeco}

### A quick chapter without decoration {.nofldeco}
```

**One important thing: it is not possible tu use some advanced formating in an
first paragraph with such decoration, especialy vertical space and
multi-paragraph footnotes.**

#### What about parts?

To create a part use a **part div**:

```qmd
:::{.part}
## Title of my big part
### Subtitle if you need one

Anything you want integrated in your part page
```

...or a a **level 2 heading with .part class**:

```qmd
## Title of my huge part{.part}
```

This will insert a clear to recto and write the title, subtitle and what you
added after that to the rector page. Default fonts for parts are scaled to be
bigger than regular chapters.

The default values for parts is in the `parts` metadata.

### Inside the front/back matter

Those non fictional part can have many subpart dedicated to showing specific
information. Technically you can put anything in here but there are some
typographic usage (some are for legal reasons, other for historical reasons).

Each subpart can be inserted via a **level 2 heading**. The name of each subpart
won't appear in the final document and are here only for structuration when
writing, by default it only insert a page break (you can override this if
you want to pout for example title and legal notice on the same page).

Most of the subpart of front/back matter are **display pages** i.e. page without
flow of text. That whyb you can use advanced formatting like huge scaling,
vfill, vspace, etc to get the exact rendering you want.

Here is an informational list of the [classical possible **front matter
contents**](https://en.wikipedia.org/wiki/Book_design#Front_matter):

- Half matter
- Frontispiece (aka decorative illustration)
- Title page (mandatory if distributed)
- Legal notice (mandatory if distributed)
- Dedication
- Epigraph
- Table of contents
- Foreword (always written by "not the author")
- Preface (always written by the author)
- Acknowledgments
- Introduction (this is where you can recall what happens in the previous books)
- Prologue (the only part that is fictional and in the universe of your story)

Here is an informational list of the [classical possible **back matter
contents**](https://en.wikipedia.org/wiki/Book_design#Back_matter_(end_matter)):

- Epilogue (the only part that is fictional and in the universe of your story)
- Outro (this is where you write "The End" or "To be continued...")
- Afterword
- Conclusion
- Postscript
- Appendix or Addendum
- Glossary
- Bibliography
- Index
- Colophon
- Postface
- Author (nowadays this is not used, the author is presented on the cover)

But remember youy can put anything that is "aside from your story" in the front
or back matter. The most common stuff in fiction novels are:

- maps
- presentation of the characters or races
- other graphical helpers for the readers : genealogy, schema, death star
  schematics...


**Important note: most of the time it the editor job to fill and fine tune the
front and back matter so except if you are opting for auto editing don't spend
time to micro manage those... spend your time on your story, most reader don't
even read the front/back matter!**

## Access to the current structural elements

You can access to current structural element title or value using convenient
shortcodes:

- **thetitle shortcode** `{{< thetitle >}}`
- **theauthor shortcode** `{{< theauthor >}}`
- **thepage shortcode** `{{< thepage >}}`
- **thechapter shortcode** `{{< thechapter >}}`
- **thequickchapter shortcode** `{{< thequickchapter >}}`
- **thepart shortcode** `{{< thepart >}}`

You also have LaTeX commands of the exact same names if ever you want to
customize header/footer:

- **thetitle command** `\thetitle`
- **theauthor command** `\theauthor`
- **thepage command** `\thepage`
- **thechapter command** `\thechapter`
- **thequickchapter command** `\thequickchapter`
- **thepart command** `\thepart`
