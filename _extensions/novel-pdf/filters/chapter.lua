local utils = require "utils"

-- LaTeX multiline string declared here so that it does not have useless indentation
local raw_latex_open_fmt <const> = [[
\clearpage %% next chapter may begin recto or verso
\begin{ChapterStart}%{options}s]]

if FORMAT:match 'latex' then
	local lines_before_title_from_meta
	local lines_before_subtitle_from_meta

	function get_vspaces_from_meta(meta)
		lines_before_title_from_meta = pandoc.utils.stringify(meta.chapters.title.lines_before)
		lines_before_subtitle_from_meta = pandoc.utils.stringify(meta.chapters.subtitle.lines_before)
	end

	-- Used localy inside chapter div
	local chapter_titles_from_header = {
		Header = function(header)
			if header.level == 1 then
				local lines = lines_before_title_from_meta
				local title = pandoc.utils.stringify(header.content)

				local raw_latex_vspace = [[\vspace*{%(lines)s\nbs}]] % {lines=lines}
				local raw_latex_title = [[\ChapterTitle{%(title)s}]] % {title=title}

				return {
					pandoc.RawBlock('tex', raw_latex_vspace),
					pandoc.RawBlock('tex', raw_latex_title)
				}
			elseif header.level == 2 then
				local lines = lines_before_subtitle_from_meta
				local subtitle = pandoc.utils.stringify(header.content)

				local raw_latex_vspace = [[\vspace*{%(lines)s\nbs}]] % {lines=lines}
				local raw_latex_subtitle = [[\ChapterSubtitle{%(subtitle)s}]] % {subtitle=subtitle}

				return {
					pandoc.RawBlock('tex', raw_latex_vspace),
					pandoc.RawBlock('tex', raw_latex_subtitle)
				}
			else
				-- All other case we don't touche the content
				return nil
			end
		end
	}

	function chapter_start_from_div(div)
		if utils.table_contains(div.classes, "chapter") then
			-- Retreive the height of the chapter header in the attribute of the div if provided
			local nb_lines_config
			if div.attributes.height then
				nb_lines_config = "[%(height)s]" % {height=pandoc.utils.stringify(div.attributes.height)}
			else
				nb_lines_config = ""
			end

			local raw_latex_open = raw_latex_open_fmt % {options=nb_lines_config}

		    local content = div:walk(chapter_titles_from_header)

			local raw_latex_close = [[\end{ChapterStart}]]

			return {
				pandoc.RawBlock('tex', raw_latex_open),
				content,
				pandoc.RawBlock('tex', raw_latex_close),
			}
		end

		-- if the div doesn't have the correct class we are not touching it
		return nil
	end

	-- Set what function will be called on what kind of Pandoc element and in which order
	-- See: https://pandoc.org/lua-filters.html#typewise-traversal
	return {
		{
			Meta = get_vspaces_from_meta
		},
		{
			Div = chapter_start_from_div
		}
	}
end