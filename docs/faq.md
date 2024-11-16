# Frequently Asked Questions

## Can I create my book using only one big file?

Yes. To do so you just need to use the `index.qmd` file as your only file:

```qml
---
output-file: my_novel.pdf
---

# Front matter

Your front matter content goes here.

# Body matter

Your body matter content goes here.

# Back matter

Your back metter (if you need one) goes here.
```

And that it !

## Can I create my book using multiple files?

Yes and that's what's the easiest. You can write your content in as many file as
you want as long as you include them in the main file `index.qmd` using the
**include shortcode** `{{< include relative/path/and/name_of_the_file.qmd >}}`.

Those files doesn't need to correspond to your chapter or anything (even if one
file per chapter is quite convenient AFAIC). Split your content according to
your own criterais. Just don't forget to include them in the `index.qmd`.

## Where should I write the name of my novel?

Your novel **title**, **subtitle**, **author** and many other info about your
book are located in the `_metadata.yml` file.

If you want to refer to any of those information in your book you can use le
**meta shortcode** `{{< meta name_of_metadata >}}`. For example if you want to
include the name of your book in your text you can du:

```qmd
This is a book named {{< meta title >}}, isn't it neat?
```

## Should I use formating classes, attribute and shortcodes in my novel?

I don't think so. At least not in the **body matter** fictional part of your
novel that should be kept simple with few formating to prevent any distraction
from your story. But you can use semantic classes to specify thing like dialogs,
computer/screen text, hand written notes, etc (and please not abuse... _with
great power comes great responsability_, even if you can't throw spider web with
your wrists!)

In the **front/back matter** most of the content is what is called "dispaly
pages" that consist of very few text and needs some fine formating tuning.
That's where you will typically use advanced formating.

## What is "the grid" that is mentioned in the documentation?

Any typesetted novel is configured to hold a certain number of lines in a page.
It also has fixed top, bottom, left and right margins. All of this is made so
that on any page of a book there is the exact same number of possible lines and
they would always appear at the exact same height in the page. This ensure that
lines from the left page and right page are alway perfectly aligned (this is
specific to fiction novels) to make the reading more smooth for the reader.

Thus we could draw a grid on each page and the lines would always be perfectly
aligned on this grid whatever the page, whatever the content. This is what we
call **the grid**.

And that is to ensure that the grid is respected that all the vertical space or
height in novel-pdf are expressed in **number of lines**. There are some
exceptions but most of them are designed to be used on "display pages" i.e.
pages that don't contain flow of text (and especialy no fiction text), in such
pages you can disregard the grid, it won't bother anyone.
