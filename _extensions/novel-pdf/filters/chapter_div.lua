local utils = require "../utils"

-- global variables needed to communicate between different filters
local from_meta = {}

if FORMAT:match 'latex' then
	function get_vspaces_from_meta(meta)
		from_meta.lines_before_title = meta.chapters.title.lines_before
		from_meta.lines_before_subtitle = meta.chapters.subtitle.lines_before
		from_meta.height = meta.chapters.header_height
	end

	-- Used localy inside chapter div
	local chapter_titles_from_header = {
		Header = function(header)
			if header.level == 2 then
				local lines = pandoc.utils.stringify(from_meta.lines_before_title)
				local title_inlines = header.content

				local raw_latex_before = pandoc.RawInline('latex', [[\ChapterTitle{]])
				local raw_latex_after = pandoc.RawInline('latex', "}")

				table.insert(title_inlines, 1, raw_latex_before)
				table.insert(title_inlines, raw_latex_after)

				new_div = pandoc.Div {title_inlines}
				new_div.attributes = {lines_before=lines}

				return new_div
			elseif header.level == 3 then
				local lines = pandoc.utils.stringify(from_meta.lines_before_subtitle)
				local subtitle_inlines = header.content

				local raw_latex_before = pandoc.RawInline('latex', [[\ChapterSubtitle{]])
				local raw_latex_after = pandoc.RawInline('latex', "}")

				table.insert(subtitle_inlines, 1, raw_latex_before)
				table.insert(subtitle_inlines, raw_latex_after)

				new_div = pandoc.Div {subtitle_inlines}
				new_div.attributes = {lines_before=lines}

				return new_div
			else
				error("Only level 2 and 3 heading are allowed inside a .chapter DIV. Level %(lvl)s found." % {lvl=header.level})
			end
		end
	}

	function chapter_start_from_div(div)
		if utils.table_contains(div.classes, "chapter") then
			local height = pandoc.utils.stringify(div.attributes.height or from_meta.height)

		    local content_block = div:walk(chapter_titles_from_header)

		    local raw_latex_clear = pandoc.RawBlock('latex', [[\clearpage %% next chapter may begin recto or verso]])
			local raw_latex_open = pandoc.RawBlock('latex', [[\begin{ChapterStart}[%(height)s] ]] % {height=height})
			local raw_latex_close = pandoc.RawBlock('latex', [[\end{ChapterStart}]])

			-- Build and return the resulting div
			return pandoc.Div {
				raw_latex_clear,
				raw_latex_open,
				content_block,
				raw_latex_close
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
