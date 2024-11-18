-- This shortcode is only for pdf
-- In all other format just do nothing
if FORMAT:match 'latex' then

    function thepage(args)
        return pandoc.RawInline('latex', [[\thepage]])
    end

    function thechapter(args)
        return pandoc.RawInline('latex', [[\thechapter]])
    end

    function thequickchapter(args)
        return pandoc.RawInline('latex', [[\thequickchapter]])
    end

    function theauthor(args)
        return pandoc.RawInline('latex', [[\theauthor]])
    end

    function thetitle(args)
        return pandoc.RawInline('latex', [[\thetitle]])
    end

end
