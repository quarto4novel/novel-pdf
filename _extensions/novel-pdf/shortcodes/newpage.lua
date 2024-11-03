-- This shortcode is only for pdf
-- In all other format just do nothing
if FORMAT:match 'latex' then

    function clearpage(args)
        return pandoc.RawBlock('latex', [[\clearpage]])
    end

    function cleartorecto(args)
        return pandoc.RawBlock('latex', [[\cleartorecto]])
    end

end
