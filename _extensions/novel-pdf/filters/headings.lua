local utils = require "../utils"
local builders = require "../builders"

local MATTER <const> = {
	NOTHING = 0,
	FRONT = 1,
	BODY = 2,
	BACK = 3
}

if FORMAT:match 'latex' then
	local from_meta = {}

	--- return the LaTeX representation of a front/body/back matter that should
	-- replace the header 1 element
	-- @param header the header from which to generate the matter from
	-- @return LaTeX Block to replace the header with
	-- @return int representing the kind of matter (NOTHING, FRONT, BODY or BACK)
	local function _matter_from_header_1(header)
		local title = pandoc.utils.stringify(header.content)

		if title == "Front matter" then
			print("Front matter start")
			return builders.build_frontmatter(), MATTER.FRONT

		elseif title == "Body matter" then
			print("Body matter start")
			return builders.build_mainmatter(), MATTER.BODY

		elseif title == "Back matter" then
			print("Back matter start")
			return builders.build_backmatter(), MATTER.BACK
		else
			error("Level 1 heading '# %(title)s' found but the only possible title are Front matter, Body matter and Back matter" % {title=title})
		end
	end


	local function _frontback_matter_subpart_from_header_2(header)
		local title = pandoc.utils.stringify(header.content)

		if utils.table_contains(header.classes, "chapterlike") then
			-- TODO add specific default config for chapterlike
			-- Retreive attributes or get default from meta
			local lines_before = pandoc.utils.stringify(header.attributes.lines_before or from_meta.chapters.title.lines_before)
			local height = pandoc.utils.stringify(header.attributes.height or from_meta.chapters.header_height)

			-- build chapterlike
			local chapter = builders.ChapterBuilder:new()
				:title_inlines(header.content)
				:lines_before_title(lines_before)
				:height(height)
				-- TODO: add support for chapter style
				:build()

			return chapter
		else
			-- TODO: add support for .samepage class
			-- TODO: add support for page_style=empty attribute
			return builders.build_frontmatter_sub(title)
		end
	end

	local function _chapter_or_part_from_header_2(header)
		if utils.table_contains(header.classes, "part") then
			-- Retreive attributes or get default from meta
			local lines_before = pandoc.utils.stringify(header.attributes.lines_before or from_meta.parts.title.lines_before)
			local height = pandoc.utils.stringify(header.attributes.height or from_meta.parts.header_height)
			local scale = pandoc.utils.stringify(header.attributes.scale or from_meta.parts.title.scale)

			-- Build the part
			local part = builders.PartBuilder:new()
				:title_inlines(header.content)
				:title_scale(scale)
				:lines_before_title(lines_before)
				:height(height)
				:build()

			return part
		else
			-- Retreive attributes or get default from meta
			local lines_before = pandoc.utils.stringify(header.attributes.lines_before or from_meta.chapters.title.lines_before)
			local height = pandoc.utils.stringify(header.attributes.height or from_meta.chapters.header_height)
			local page_style = pandoc.utils.stringify(header.attributes.page_style or from_meta.chapters.page_style)

			local chap_builder = builders.ChapterBuilder:new()
				:title_inlines(header.content)
				:lines_before_title(lines_before)
				:height(height)
				:page_style(page_style)

			return chap_builder:build()
		end
	end


	local function _quickchapter_from_header_3(header)
		-- Retreive attributes or get default from meta
		local name_inlines = header.content
		local line = pandoc.utils.stringify(header.attributes.line or from_meta.quickchapters.line)

		return builders.build_quickchapter(name_inlines, line)
	end


	local function _scenebreak_from_header_4(header)
		local title = pandoc.utils.stringify(header.content)

		-- Retreive attributes or get default from meta
		local default_break = pandoc.utils.stringify(from_meta.scenebreaks.default)

		return builders.build_scenebreak(title, default_break)
	end


	local function structure_from_headers(blocks)
		local current_matter = MATTER.NOTHING

		for i, header in ipairs(blocks) do
			-- Anything but header, do nothing
			if header.t ~= "Header" then goto continue end

			if header.level == 1 then
				blocks[i], current_matter = _matter_from_header_1(header)
			end -- level 1

			if current_matter == MATTER.FRONT
			or current_matter == MATTER.BACK then
				if header.level == 2 then
					blocks[i] = _frontback_matter_subpart_from_header_2(header)
				end
			elseif current_matter == MATTER.BODY then
				if header.level == 2 then
					blocks[i] = _chapter_or_part_from_header_2(header)
				elseif header.level == 3 then
					blocks[i] = _quickchapter_from_header_3(header)
				elseif header.level == 4 then
					blocks[i] = _scenebreak_from_header_4(header)
				end
			end
			::continue::
		end -- for blocks

		return blocks
	end

	return {
		{
			Meta = function(meta) from_meta = meta end
		},
		{
			Blocks = structure_from_headers
		}
	}
end