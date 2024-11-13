local utils = {}

function utils.table_contains(table, value)
	for _, v in ipairs(table) do
		if v == value then return true end
	end
	return false
end

function utils.table_is_empty(table)
	if next(table) then
		return false
	end

	return true
end

-- python-like % string formating/interpolation
-- Example: print( "%(key)s is %(val)7.2f%" % {key = "concentration", val = 56.2795}
--          outputs "concentration is   56.28%"
-- See: https://www.lua-users.org/wiki/StringInterpolation (with a fix to allow _ in variable names)
-- See: https://www.lua.org/pil/20.2.html for the regex details
function utils.interp(s, tab)
	return (
		s:gsub(
			'%%%((%a[_%w]*)%)([-0-9%.]*[cdeEfgGiouxXsq])',
			function(k, fmt)
				return tab[k] and ("%"..fmt):format(tab[k]) or '%('..k..')'..fmt end
		)
	)
end
getmetatable("").__mod = utils.interp


function utils.create_quickchapter(title_inlines, line)
    -- title_inlines: pandoc.Inlines
    -- line: string with different possible values
    --      - "true": default line length
    --      - "false": no line
    --      - length of line in LaTeX unit

    -- This is only for LaTeX
    -- In all other format just return the title as a paragraph
    if not FORMAT:match 'latex' then
        return pandoc.Para(title_inlines)
    end

    -- line parameter need to be adapted
    local line_config
    if line == "true" then
        line_config = ""
    elseif line == "false" then
        line_config = "[*]"
    else
        line_config = "[%(line)s]" % {line=line}
    end

    -- We encapsulate the title inlines to make them a title
    table.insert(title_inlines, 1, pandoc.RawInline('latex', [[\QuickChapter%(line_config)s{]] % {line_config=line_config}))
    table.insert(title_inlines, pandoc.RawInline('latex', "}"))

    return pandoc.Div {title_inlines}
end


function utils.create_chapter(title_inlines, lines_before, height)
    assert(title_inlines)
    assert(lines_before)
    assert(height)

    -- This is only for LaTeX
    -- In all other format just return the title as a paragraph
    if not FORMAT:match 'latex' then
        return pandoc.Para(title_inlines)
    end

    local raw_latex_clear = pandoc.RawBlock('latex', [[\clearpage %% next chapter may begin recto or verso]])
    local raw_latex_open = pandoc.RawBlock('latex', [[\begin{ChapterStart}[%(height)s] ]] % {height=height})

    -- We encapsulate the title inlines to make them a title
    table.insert(title_inlines, 1, pandoc.RawInline('latex', [[\ChapterTitle{]]))
    table.insert(title_inlines, pandoc.RawInline('latex', "}"))

    title_div = pandoc.Div {title_inlines}
    title_div.attr.attributes = {lines_before=lines_before}

    local raw_latex_close = pandoc.RawBlock('latex', [[\end{ChapterStart}]])

    -- Build and return the resulting div
    return pandoc.Div {
        raw_latex_clear,
        raw_latex_open,
        title_div,
        raw_latex_close
    }
end


local frontmatter_raw_latex <const> = [[
% This command must be written immediately after \begin{document}
\frontmatter]]


function utils.create_frontmatter()
    -- This is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('tex', frontmatter_raw_latex)
end


local mainmatter_raw_latex <const> = [[
% here, inserts blank, so mainmatter begins recto
\cleartorecto

% Now to begin your story:
\mainmatter]]

function utils.create_mainmatter()
    -- This is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('tex', mainmatter_raw_latex)
end


local backmatter_raw_latex <const> = [[
% it does nothing.
% If you really wish to change page numbering, then you must code it manually.
% This is not advised for P.O.D. books, as it may confuse someone performing quality inspection
\backmatter]]


function utils.create_backmatter()
    -- This is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('tex', backmatter_raw_latex)
end

return utils