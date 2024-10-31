function emptylines(args)
    -- Retreive parameters
    local lines
    if #args == 1 then
        lines = pandoc.utils.stringify(args[1])
    else
        error(string.format("emptylines shortcode has %s arguments but it can ony have one arguments.", #args))
    end

    -- This shortcode is only for pdf
    -- In all other format just return nothing
    if not quarto.doc.isFormat('pdf') then
        return nil
    end

    local raw_latex = string.format([[\vspace*{%s\nbs}]], lines)

    return pandoc.RawBlock('tex', raw_latex)
end