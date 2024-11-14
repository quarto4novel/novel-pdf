-- DEPRECATED
function scenebreak(args, kwargs, meta)
    -- Retreive parameters
    local scenebreak_default = pandoc.utils.stringify(meta.scenebreaks.default)
    local scenebreak_type
    if #args == 0 then
        scenebreak_type = scenebreak_default
    elseif #args == 1 then
        scenebreak_type = pandoc.utils.stringify(args[1])
    else
        error(string.format("scenebreak shortcode has %s argument but it can ony have zero or one arguments.", #args))
    end

    -- This shortcode is only for pdf
    -- In all other format just return nothing
    if not quarto.doc.isFormat('pdf') then
        return nil
    end

    local raw_latex
    if scenebreak_type == "blank" then
        raw_latex = [[\scenebreak]]
    elseif scenebreak_type == "line" then
        raw_latex = [[\sceneline]]
    elseif scenebreak_type == "stars" then
        raw_latex = [[\scenestars]]
    else
        error(string.format("scenebreak shortcode type %s but it must be blank, line or stars.", scenebreak_type))
    end

    return pandoc.RawBlock('tex', raw_latex)
end
