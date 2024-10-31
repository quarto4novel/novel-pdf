function chapter(args, kwargs, meta)
    -- Retreive parameters
    local chapter_name = pandoc.utils.stringify(args[1])
    local vspace_before = pandoc.utils.stringify(kwargs.vspace_before)

    -- Set default value for parameters if needed
    if vspace_before == "" then
        vspace_before = pandoc.utils.stringify(meta.chapters.vspace_before_title)
    end

    -- This shortcode is only for pdf
    -- In all other format just return the title as a paragraph
    if not quarto.doc.isFormat('pdf') then
        return pandoc.Para(chapter_name)
    end

    local raw_latex = string.format(
        [[\clearpage %% next chapter may begin recto or verso
        \begin{ChapterStart}
        \vspace*{%s\nbs}
        \ChapterTitle{%s}
        \end{ChapterStart}]],
        vspace_before, chapter_name)

    return pandoc.RawBlock('tex', raw_latex)
end