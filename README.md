# Novel-pdf Format

## Installing

```bash
quarto use template pymaldebaran/novel-pdf
```

This will install the extension and create an example qmd file that you can use as a starting place for your book.

## Using

```bash
quarto render
```

The resulting pdf should appear as a pdf (PDF-X file) in the `_book` directory.

## Options

*TODO*: If your format has options that can be set via document metadata, describe them.

## Supported markdown features

- [x] chapter shortcode: fictional works have a very specific structure that do not correspond to academic structure used by classical LaTeX document. In particular the hierarchical `\part`, `\section`, `\chapter`, etc is not used in novels (see: [Novel class novel-documentation : Avoid Academic Structures](https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h1.2.3) ). That's why we provide a `{{< chapter My chapter One >}}` shortcode to create a chapter easily

## Unsupported markdown feature

Some very common feature of markdown are not supported by pdf-novel, don't try to use them:

- hierarchical titles `# level one title`, `## level two title`, etc they are replaced by the `{{< chapter My chapter One >}}` shortcode.

## Example

A novel is structured via an `_index.qmd` (you can not use another name for this file) file that contains a [include shortcodes]() for each chapter.

Here is the source code for a minimal sample document: [index.qmd](_index.qmd).

The chapters are located in the `chapters` directory, they ca&n be named whatever you want as long as you reference them correctly in the include directive in the `_index.qmd` file.

Here are the source code for a three sample chapters:

-	[chapters/chap_01.qmd](chapters/chap_01.qmd)
-	[chapters/chap_02.qmd](chapters/chap_02.qmd)
-	[chapters/chap_03.qmd](chapters/chap_03.qmd)

## Inspiration

I took heavy inspiration from thos great post about [quarto extensions](https://www.cynthiahqy.com/posts/quarto-extensions-explainer/index.html).
