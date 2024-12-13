local utils = require "../utils"


function setheader(args, kwargs)
    -- This shortcode is only for pdf
    -- In all other format just do nothing
    if not FORMAT:match 'latex' then return nil end

    -- Retreive parameters
    local verso = pandoc.utils.stringify(kwargs.verso)
    local recto = pandoc.utils.stringify(kwargs.recto)

    -- TODO: use inlines instead of strings
    if verso == "" and recto == "" then
        error("setheader shortcode must have verso and/or recto parameters but nothing was provided.")
    end

    result = pandoc.Blocks {}

    if verso ~= "" then
        result:insert(pandoc.RawBlock('latex', [[\SetVersoHeadText{%(verso)s}]] % {verso=verso}))
    end

    if recto ~= "" then
        result:insert(pandoc.RawBlock('latex', [[\SetRectoHeadText{%(recto)s}]] % {recto=recto}))
    end

    return result
end
