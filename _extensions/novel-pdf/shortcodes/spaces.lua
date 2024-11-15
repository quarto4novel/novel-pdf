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

    return pandoc.RawBlock('latex', raw_latex)
end


function vfill()
    -- This shortcode is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('latex', [[\vfill]])
end


-- Insert an empty element (LaTeX tends to remove spaces if there is nothing before or after them)
-- Usefull when a a vfill has no content before or after on the same page
function null()
    -- This shortcode is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('latex', [[\null]])
end
