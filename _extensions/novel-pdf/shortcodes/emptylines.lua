local utils = require "../utils"

function emptylines(args)
    -- Retreive parameters
    local lines
    if #args == 1 then
        lines = pandoc.utils.stringify(args[1])
    else
        error("emptylines shortcode has %(length)s arguments but it can ony have one arguments." % {length=#args})
    end

    -- This shortcode is only for pdf
    -- In all other format just return nothing
    if not quarto.doc.isFormat('pdf') then
        return nil
    end

    local raw_latex = [[\vspace*{%(lines)s\nbs}]] % {lines=lines}

    return pandoc.RawBlock('tex', raw_latex)
end

function vfill()
    -- This shortcode is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('tex', [[\vfill]])
end