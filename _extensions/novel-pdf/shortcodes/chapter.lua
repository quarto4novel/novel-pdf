local utils = require "../utils"

-- LaTeX multiline strings declared here so that it does not have useless indentation
local raw_latex_chap_fmt <const> = [[
\clearpage %% next chapter may begin recto or verso
\begin{ChapterStart}
\vspace*{%(lbefore)s\nbs}
\ChapterTitle{%(title)s}
\end{ChapterStart}
]]

function chapter(args, kwargs, meta)
    -- Retreive parameters
    local chapter_name = pandoc.utils.stringify(args[1])
    local lines_before = pandoc.utils.stringify(kwargs.lines_before)

    -- Set default value for parameters if needed
    if lines_before == "" then
        lines_before = pandoc.utils.stringify(meta.chapters.title.lines_before)
    end

    -- This shortcode is only for LaTeX
    -- In all other format just return the title as a paragraph
    if not FORMAT:match 'latex' then
        return pandoc.Para(chapter_name)
    end

    local raw_latex = raw_latex_chap_fmt % {
        lbefore=lines_before,
        title=chapter_name
    }

    return pandoc.RawBlock('tex', raw_latex)
end

function quickchapter(args, kwargs, meta)
    -- Retreive parameters or get default from meta
    local chapter_name = pandoc.utils.stringify(args[1])
    local line = pandoc.utils.stringify(kwargs.line[1] or meta.chapters.quick.line[1])

    -- line parameter need to be adapted
    local line_config
    if line == "true" then
        line_config = ""
    elseif line == "false" then
        line_config = "[*]"
    else
        line_config = "[%(line)s]" % {line=line}
    end

    -- This shortcode is only for LaTeX
    -- In all other format just return the title as a paragraph
    if not FORMAT:match 'latex' then
        return pandoc.Para(chapter_name)
    end

    local raw_latex = [[\QuickChapter%(line_config)s{%(title)s}]] % {
        line_config=line_config,
        title=chapter_name
    }

    return pandoc.RawBlock('tex', raw_latex)
end
