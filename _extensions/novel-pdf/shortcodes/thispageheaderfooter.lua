local utils = require "../utils"

-- This shortcode is only for pdf
-- In all other format just do nothing
if FORMAT:match 'latex' then
    local possible_styles <const> = {
        "fancy",
        "empty",
        "footer",
        "forcenumber",
        "dropfoliobeneath",
        "dropfolioinside",
    }

    -- TODO replace this by a `nextpagestyle=???` attribute for the clearpage or cleartorecto shortcodes or chapter div
    function thispageheaderfooter(args)
        -- Retreive parameters
        local style = #args == 1 and pandoc.utils.stringify(args[1])
            or error("thispageheaderfooter shortcode has %(length)s arguments but it can ony have one arguments." % {length=#args})

        if not utils.table_contains(possible_styles, style) then
            error("thispageheaderfooter shortcode called with parameter '%(style)s' \z
                but the only possible values are %(possible)s"
                % {style=style, possible=table.concat(possible_styles, ', ')})
        end

        local raw_latex = [[\thispagestyle{%(style)s}]] % {style=style}

        return pandoc.RawBlock('latex', raw_latex)
    end

end