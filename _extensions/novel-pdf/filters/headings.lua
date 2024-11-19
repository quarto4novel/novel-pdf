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
	local current_matter = MATTER.NOTHING

	function get_param_from_meta(meta)
		from_meta.chapters = meta.chapters
		from_meta.quickchapters = meta.quickchapters
		from_meta.scenebreaks = meta.scenebreaks
		from_meta.parts = meta.parts
	end


	local function structure_from_headers(header)
		local title = pandoc.utils.stringify(header.content)

		if header.level == 1 then
			if title == "Front matter" then
				print("Front matter start")
				current_matter = MATTER.FRONT
				return builders.build_frontmatter()

			elseif title == "Body matter" then
				print("Body matter start")
				current_matter = MATTER.BODY
				return builders.build_mainmatter()

			elseif title == "Back matter" then
				print("Back matter start")
				current_matter = MATTER.BACK
				return builders.build_backmatter()
			else
				error("Level 1 heading '# %(title)s' found but the only possible title are Front matter, Body matter and Back matter" % {title=title})
			end
		end -- level 1

		if current_matter == MATTER.FRONT or current_matter == MATTER.BACK then
			if header.level == 2 then
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
		elseif current_matter == MATTER.BODY then
			if header.level == 2 then
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
			elseif header.level == 3 then
				-- Retreive attributes or get default from meta
				local name_inlines = header.content
				local line = pandoc.utils.stringify(header.attributes.line or from_meta.quickchapters.line)

				return builders.build_quickchapter(name_inlines, line)

			elseif header.level == 4 then
				-- Retreive attributes or get default from meta
				local default_break = pandoc.utils.stringify(from_meta.scenebreaks.default)

				return builders.build_scenebreak(title, default_break)
			end
		end -- current_matter
	end

	return {
		{
			Meta = get_param_from_meta
		},
		{
			Header = structure_from_headers
		}
	}
end