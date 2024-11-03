-- LaTeX multiline string declared here so that it does not have useless indentation
local raw_latex_empty_page <const> = [[
\thispagestyle{empty}
\null]]

-- This shortcode is only for pdf
-- In all other format just do nothing
if FORMAT:match 'latex' then

    function clearpage(args)
        return pandoc.RawBlock('latex', [[\clearpage]])
    end

    function cleartorecto(args)
        return pandoc.RawBlock('latex', [[\cleartorecto]])
    end

    function emptypage(args)
        return pandoc.RawBlock('latex', raw_latex_empty_page)
    end

end
