local utils = require "./utils"

local builders = {}

-- ****************************************************************************
-- To create quick chapters
function builders.build_quickchapter(title_inlines, line)
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
function builders.build_scenebreak(title, default_break)
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
builders.ChapterBuilder = {}

-- Constructor
-- See: https://www.lua.org/pil/16.1.html
function builders.ChapterBuilder:new()
    builder = {}
    setmetatable(builder, self)
    self.__index = self
    return builder
end

function builders.ChapterBuilder:title_inlines(v) self._title_inlines = v; return self end
function builders.ChapterBuilder:lines_before_title(v) self._lines_before_title = v; return self end
function builders.ChapterBuilder:subtitle_inlines(v) self._subtitle_inlines = v; return self end
function builders.ChapterBuilder:lines_before_subtitle(v) self._lines_before_subtitle = v; return self end
function builders.ChapterBuilder:height(v) self._height = v; return self end
function builders.ChapterBuilder:page_style(v) self._page_style = v; return self end
function builders.ChapterBuilder:content_block(v) self._content_block = v; return self end

function builders.ChapterBuilder:build()
    assert(self._title_inlines)
    assert(self._lines_before_title)
    assert(self._height)

    -- This is only for LaTeX
    -- In all other format just return the title as a paragraph
    if not FORMAT:match 'latex' then
        return pandoc.Para(self._title_inlines)
    end

    local raw_latex_page_style = pandoc.RawBlock('latex', [[\thispagestyle{%(page_style)s}]] % {page_style=self._page_style})
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
-- To create the Chapter start
builders.PartBuilder = {}

-- Constructor
-- See: https://www.lua.org/pil/16.1.html
function builders.PartBuilder:new()
    builder = {}
    setmetatable(builder, self)
    self.__index = self
    return builder
end

function builders.PartBuilder:title_inlines(v) self._title_inlines = v; return self end
function builders.PartBuilder:title_scale(v) self._title_scale = v; return self end
function builders.PartBuilder:lines_before_title(v) self._lines_before_title = v; return self end
function builders.PartBuilder:subtitle_inlines(v) self._subtitle_inlines = v; return self end
function builders.PartBuilder:subtitle_scale(v) self._subtitle_scale = v; return self end
function builders.PartBuilder:lines_before_subtitle(v) self._lines_before_subtitle = v; return self end
function builders.PartBuilder:height(v) self._height = v; return self end
function builders.PartBuilder:content_block(v) self._content_block = v; return self end

function builders.PartBuilder:build()
    assert(self._title_inlines)
    assert(self._lines_before_title)
    assert(self._height)

    -- This is only for LaTeX
    -- In all other format just return the title as a paragraph
    if not FORMAT:match 'latex' then
        return pandoc.Para(self._title_inlines)
    end

    -- BUG: the first part is preceded by 2 blank pages
    local raw_latex_cleartorecto = pandoc.RawBlock('latex', [[\thispagestyle{empty}\null\cleartorecto\thispagestyle{empty} %% part are always recto with empty verso]])
    local raw_latex_open = pandoc.RawBlock('latex', [[\begin{ChapterStart}[%(height)s] ]] % {height=self._height})

    -- We add scaling to title
    local scaled_title_inlines = pandoc.Inlines {
        pandoc.Span(self._title_inlines, {scale=self._title_scale}),
    }

    -- We encapsulate the title inlines to make them a title
    table.insert(scaled_title_inlines, 1, pandoc.RawInline('latex', [[\ChapterTitle{\parttitlefont ]]))
    table.insert(scaled_title_inlines, pandoc.RawInline('latex', "}"))

    local title_div = pandoc.Div {scaled_title_inlines}
    title_div.attr.attributes = {lines_before=self._lines_before_title}

    local subtitle_div
    if self._subtitle_inlines then
        -- We add scaling to title
        local subtitle_inlines = pandoc.Inlines {
            pandoc.Span(self._subtitle_inlines, {scale=self._subtitle_scale}),
        }

        -- We encapsulate the subtitle inlines to make them a subtitle
        table.insert(subtitle_inlines, 1, pandoc.RawInline('latex', [[\ChapterSubtitle{\parttitlefont ]]))
        table.insert(subtitle_inlines, pandoc.RawInline('latex', "}"))

        subtitle_div = pandoc.Div {subtitle_inlines}
        subtitle_div.attr.attributes = {lines_before=self._lines_before_subtitle}
    end

    local raw_latex_close = pandoc.RawBlock('latex', [[\end{ChapterStart}]])

    -- get a string version of the title to put in latex variable
    local title_str = pandoc.utils.stringify(self._title_inlines)

    -- handle the LaTeX variables for chapter and quickchapter
    local raw_latex_set_thepart = pandoc.RawBlock("latex", [[\renewcommand{\thepart}{%(title)s}]] % {title=title_str})
    local raw_latex_reset_thechapter = pandoc.RawBlock("latex", [[\renewcommand{\thechapter}{}]])
    local raw_latex_reset_thequickchapter = pandoc.RawBlock("latex", [[\renewcommand{\thequickchapter}{}]])

    print("> Part: ", title_str)

    -- Build and return the resulting div
    return pandoc.Div {
        raw_latex_cleartorecto,
        raw_latex_open,
        title_div,
        subtitle_div or {},
        self._content_block or {},
        raw_latex_close,
        raw_latex_set_thepart,
        raw_latex_reset_thechapter,
        raw_latex_reset_thequickchapter,
    }
end

-- ****************************************************************************
-- Build front matter
local frontmatter_raw_latex <const> = [[
% This command must be written immediately after \begin{document}
\frontmatter]]

function builders.build_frontmatter()
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

function builders.build_mainmatter()
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


function builders.build_backmatter()
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

function builders.build_frontmatter_sub(title)
    print("> Front Subsection: ", title)
    return pandoc.RawBlock(
        'latex',
        bm_sub_raw_latex % {title=title}
    )
end

return builders