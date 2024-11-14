local utils = require "../utils"

-- global variables needed to communicate between different filters
local from_meta = {}
local builder = nil

if FORMAT:match 'latex' then
	function get_vspaces_from_meta(meta)
		from_meta.lines_before_title = meta.chapters.title.lines_before
		from_meta.lines_before_subtitle = meta.chapters.subtitle.lines_before
		from_meta.height = meta.chapters.header_height
	end

	-- Used localy inside chapter div
	local chapter_titles_from_header = {
		Header = function(header)
			assert(builder)

			if header.level == 2 then
				builder
					:lines_before_title(pandoc.utils.stringify(header.attributes.lines_before or from_meta.lines_before_title))
					:title_inlines(header.content)

				-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
				-- this is important since we already created the chapter and its title here
				return {}

			elseif header.level == 3 then
				builder
					:lines_before_subtitle(pandoc.utils.stringify(header.attributes.lines_before or from_meta.lines_before_subtitle))
					:subtitle_inlines(header.content)

				-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
				-- this is important since we already created the chapter and its subtitle here
				return {}

			else
				error("Only level 2 and 3 heading are allowed inside a .chapter DIV. Level %(lvl)s found." % {lvl=header.level})
			end
		end
	}

	function chapter_start_from_div(div)
		if utils.table_contains(div.classes, "chapter") then
			builder = utils.ChapterBuilder:new()

			builder:height(pandoc.utils.stringify(div.attributes.height or from_meta.height))
			builder:content_block(div:walk(chapter_titles_from_header))

			return builder:build()
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
