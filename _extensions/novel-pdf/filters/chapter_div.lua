local utils = require "../utils"
local builders = require "../builders"

-- global variables needed to communicate between different filters
local from_meta = {}
local chap_builder = nil

if FORMAT:match 'latex' then

	-- Used localy inside chapter div
	local chapter_titles_from_header = {
		Header = function(header)
			assert(chap_builder)

			if header.level == 2 then
				chap_builder
					:lines_before_title(pandoc.utils.stringify(header.attributes.lines_before or from_meta.chapters.title.lines_before))
					:title_inlines(header.content)

				-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
				-- this is important since we already created the chapter and its title here
				return {}

			elseif header.level == 3 then
				chap_builder
					:lines_before_subtitle(pandoc.utils.stringify(header.attributes.lines_before or from_meta.chapters.subtitle.lines_before))
					:subtitle_inlines(header.content)

				-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
				-- this is important since we already created the chapter and its subtitle here
				return {}

			else
				error("Only level 2 and 3 heading are allowed inside a .chapter DIV. Level %(lvl)s found." % {lvl=header.level})
			end
		end
	}

	function chapter_start_from_div(blocks)
		local height
		local page_style
		local content

		for i, div in ipairs(blocks) do
			-- Anything but div chapter, do nothing
			if not (div.t == "Div" and utils.table_contains(div.classes, "chapter")) then goto continue end

			-- Retreive attributes or get default from meta
			height = pandoc.utils.stringify(div.attributes.height or from_meta.chapters.header_height)
			page_style = pandoc.utils.stringify(div.attributes.page_style or from_meta.chapters.page_style)

			-- We need a global builder so that walk can access it
			chap_builder = builders.ChapterBuilder:new()

			-- Retreive the content of the chapter after some conversion
			-- Warning: we need the global chap_builder to already exist for this !
			content = div:walk(chapter_titles_from_header)

			-- build the chapter
			chap_builder
				:height(height)
				:page_style(page_style)
				:content_block(content)

			-- Replace the block by what we built
			blocks[i] = chap_builder:build()

			::continue::
			chap_builder = nil
		end

		return blocks
	end

	-- Set what function will be called on what kind of Pandoc element and in which order
	-- See: https://pandoc.org/lua-filters.html#typewise-traversal
	return {
		{
			Meta = function(meta) from_meta = meta end
		},
		{
			Blocks = chapter_start_from_div
		}
	}
end
