local utils = require "../utils"
local builders = require "../builders"

-- global variables needed to communicate between different filters
local g = {
	from_meta = {},
	builder = nil,
}

if FORMAT:match 'latex' then
	-- Used localy inside chapter div
	local part_titles_from_header = {
		Header = function(header)
			assert(g.builder)

			if header.level == 2 then
				local before_title = pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.parts.title.lines_before)
				local title_scale = pandoc.utils.stringify(header.attributes.scale or g.from_meta.parts.title.scale)

				g.builder
					:lines_before_title(before_title)
					:title_inlines(header.content)
					:title_scale(title_scale)

				-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
				-- this is important since we already created the chapter and its title here
				return {}

			elseif header.level == 3 then
				local before_subtitle = pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.parts.subtitle.lines_before)
				local subtitle_scale = pandoc.utils.stringify(header.attributes.scale or g.from_meta.parts.subtitle.scale)

				g.builder
					:lines_before_subtitle(before_subtitle)
					:subtitle_inlines(header.content)
					:subtitle_scale(subtitle_scale)

				-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
				-- this is important since we already created the chapter and its subtitle here
				return {}

			else
				error("Only level 2 and 3 heading are allowed inside a .part DIV. Level %(lvl)s found." % {lvl=header.level})
			end
		end
	}

	function part_start_from_div(div)
		if utils.table_contains(div.classes, "part") then
			g.builder = builders.PartBuilder:new()

			g.builder:height(pandoc.utils.stringify(div.attributes.height or g.from_meta.parts.header_height))
			g.builder:content_block(div:walk(part_titles_from_header))

			return g.builder:build()
		end

		-- if the div doesn't have the correct class we are not touching it
		return nil
	end

	-- Set what function will be called on what kind of Pandoc element and in which order
	-- See: https://pandoc.org/lua-filters.html#typewise-traversal
	return {
		{
			Meta = function(meta) g.from_meta = meta end
		},
		{
			Div = part_start_from_div
		}
	}
end
