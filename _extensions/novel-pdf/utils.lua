local utils = {}

-- ****************************************************************************
-- Table utils
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

-- ****************************************************************************
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


-- ****************************************************************************
-- To create quick chapters
function utils.build_quickchapter(title_inlines, line)
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

    -- get a string version of the title to put in latex variable
    local title_str = pandoc.utils.stringify(title_inlines)

    return pandoc.Div {
        title_inlines,
        pandoc.RawBlock("latex", [[\renewcommand{\thequickchapter}{%(title)s}]] % {title=title_str})
    }
end


-- ****************************************************************************
-- To create the 3 kinds of scene break
function utils.build_scenebreak(title, default_break)
    if title == "Scene break blank"
    or (title == "Scene break" and default_break == "blank") then
        return pandoc.RawBlock("latex", [[\scenebreak]])
    elseif title == "Scene break line"
    or (title == "Scene break" and default_break == "line") then
        return pandoc.RawBlock("latex", [[\sceneline]])
    elseif title == "Scene break stars"
    or title == "Scene break" and default_break == "stars" then
        return pandoc.RawBlock("latex", [[\scenestars]])
    else
        error("Scene break asked by level 4 heading with title '%(title)s' and default '%(default)s'"
            % {title=title, default=default_break}
        )
    end
end


-- ****************************************************************************
-- To create the Chapter start
utils.ChapterBuilder = {}

-- Constructor
-- See: https://www.lua.org/pil/16.1.html
function utils.ChapterBuilder:new()
    builder = {}
    setmetatable(builder, self)
    self.__index = self
    return builder
end

function utils.ChapterBuilder:title_inlines(v) self._title_inlines = v; return self end
function utils.ChapterBuilder:lines_before_title(v) self._lines_before_title = v; return self end
function utils.ChapterBuilder:subtitle_inlines(v) self._subtitle_inlines = v; return self end
function utils.ChapterBuilder:lines_before_subtitle(v) self._lines_before_subtitle = v; return self end
function utils.ChapterBuilder:height(v) self._height = v; return self end
function utils.ChapterBuilder:content_block(v) self._content_block = v; return self end

function utils.ChapterBuilder:build()
    assert(self._title_inlines)
    assert(self._lines_before_title)
    assert(self._height)

    -- This is only for LaTeX
    -- In all other format just return the title as a paragraph
    if not FORMAT:match 'latex' then
        return pandoc.Para(self._title_inlines)
    end

    local raw_latex_clear = pandoc.RawBlock('latex', [[\clearpage %% next chapter may begin recto or verso]])
    local raw_latex_open = pandoc.RawBlock('latex', [[\begin{ChapterStart}[%(height)s] ]] % {height=self._height})

    -- We encapsulate the title inlines to make them a title
    table.insert(self._title_inlines, 1, pandoc.RawInline('latex', [[\ChapterTitle{]]))
    table.insert(self._title_inlines, pandoc.RawInline('latex', "}"))

    local title_div = pandoc.Div {self._title_inlines}
    title_div.attr.attributes = {lines_before=self._lines_before_title}

    local subtitle_div
    if self._subtitle_inlines then
        -- We encapsulate the subtitle inlines to make them a subtitle
        table.insert(self._subtitle_inlines, 1, pandoc.RawInline('latex', [[\ChapterSubtitle{]]))
        table.insert(self._subtitle_inlines, pandoc.RawInline('latex', "}"))

        subtitle_div = pandoc.Div {self._subtitle_inlines}
        subtitle_div.attr.attributes = {lines_before=self._lines_before_subtitle}
    end

    local raw_latex_close = pandoc.RawBlock('latex', [[\end{ChapterStart}]])

    -- get a string version of the title to put in latex variable
    local title_str = pandoc.utils.stringify(self._title_inlines)

    -- handle the LaTeX variables for chapter and quickchapter
    local raw_latex_set_thechapter = pandoc.RawBlock("latex", [[\renewcommand{\thechapter}{%(title)s}]] % {title=title_str})
    local raw_latex_reset_thequickchapter = pandoc.RawBlock("latex", [[\renewcommand{\thequickchapter}{}]])

    print("> Chapter: ", title_str)

    -- Build and return the resulting div
    return pandoc.Div {
        raw_latex_clear,
        raw_latex_open,
        title_div,
        subtitle_div or {},
        self._content_block or {},
        raw_latex_close,
        raw_latex_set_thechapter,
        raw_latex_reset_thequickchapter,
    }
end

-- ****************************************************************************
-- Build front matter
local frontmatter_raw_latex <const> = [[
% This command must be written immediately after \begin{document}
\frontmatter]]

function utils.build_frontmatter()
    -- This is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('latex', frontmatter_raw_latex)
end


-- ****************************************************************************
-- Build main matter
local mainmatter_raw_latex <const> = [[
% here, inserts blank, so mainmatter begins recto
\cleartorecto

% Now to begin your story:
\mainmatter]]

function utils.build_mainmatter()
    -- This is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('latex', mainmatter_raw_latex)
end


-- ****************************************************************************
-- Build back matter
local backmatter_raw_latex <const> = [[
% it does nothing.
% If you really wish to change page numbering, then you must code it manually.
% This is not advised for P.O.D. books, as it may confuse someone performing quality inspection
\backmatter]]


function utils.build_backmatter()
    -- This is only for LaTeX
    -- In all other format just return nothing
    if not FORMAT:match 'latex' then
        return nil
    end

    return pandoc.RawBlock('latex', backmatter_raw_latex)
end

-- ****************************************************************************
-- Build front matter subsection

local bm_sub_raw_latex <const> = [[
%% Front matter %(title)s
\clearpage
\thispagestyle{empty}]]

function utils.build_frontmatter_sub(title)
    print("> Front Subsection: ", title)
    return pandoc.RawBlock(
        'latex',
        bm_sub_raw_latex % {title=title}
    )
end

return utils