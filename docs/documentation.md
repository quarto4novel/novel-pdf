# novel-pdf documentation

## Basic formatin

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

## Structure

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

Novel use only 2 structure inside the **main matter**:

- **chapters**: a chapter always start on a new page and has a **chapter
  start**, an empty vertical space containing only the chapter title, subtitle
  and sometimes some other content (epigraph, illustration...) before the text
  of the chapter itself.
- **quickchapters**: a quick chapter only has a title (and sometimes decoration)
  and does not start on a new page.

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

Here are the possible class or attributes you can add to a level 3 or 4 heading
inside a chapter div to control its rendering:

- `lines_before=7` (in number of lines) attribute to set the position of the
  title/subtitle

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
