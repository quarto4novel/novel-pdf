local utils = require "../utils"

-- LaTeX multiline string declared here so that it does not have useless indentation
local raw_latex_empty_page <const> = [[
\thispagestyle{empty}
\null]]

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

    function clearpage(args, kwargs)
        -- Retreive parameters
        local style = pandoc.utils.stringify(kwargs.nextpagestyle)

        if style ~= "" then
            if not utils.table_contains(possible_styles, style) then
                error("clearpage shortcode called with attribute 'style=%(style)s' \z
                    but the only possible values are %(possible)s"
                    % {style=style, possible=table.concat(possible_styles, ', ')})
            end

            return pandoc.Blocks {
                pandoc.RawBlock('latex', [[\thispagestyle{%(style)s}]] % {style=style}),
                pandoc.RawBlock('latex', [[\clearpage]])
            }
        else
            return pandoc.RawBlock('latex', [[\clearpage]])
        end
    end

    function cleartorecto(args, kwargs)
        -- Retreive parameters
        local style = pandoc.utils.stringify(kwargs.nextpagestyle)

        if style ~= "" then
            if not utils.table_contains(possible_styles, style) then
                error("cleartorecto shortcode called with attribute 'style=%(style)s' \z
                    but the only possible values are %(possible)s"
                    % {style=style, possible=table.concat(possible_styles, ', ')})
            end

            return pandoc.Blocks {
                pandoc.RawBlock('latex', [[\thispagestyle{%(style)s}]] % {style=style}),
                pandoc.RawBlock('latex', [[\cleartorecto]])
            }
        else
            return pandoc.RawBlock('latex', [[\cleartorecto]])
        end
    end

    function emptypage(args)
        return pandoc.RawBlock('latex', raw_latex_empty_page)
    end

end
