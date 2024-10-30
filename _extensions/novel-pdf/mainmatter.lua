function mainmatter()
    -- This shortcode is only for pdf
    -- In all other format just return nothing
    if not quarto.doc.isFormat('pdf') then
        return nil
    end

    local raw_latex = [[% here, inserts blank, so mainmatter begins recto
        \cleartorecto

        % Now to begin your story:
        \mainmatter]]

    return pandoc.RawBlock('tex', raw_latex)
end