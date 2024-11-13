local utils = require "../utils"

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
		from_meta.line = meta.chapters.quick.line[1]
		from_meta.lines_before = meta.chapters.title.lines_before[1]
		from_meta.height = meta.chapters.header_height[1]
	end

	local function structure_from_headers(header)
		if header.level == 1 then
			local title = pandoc.utils.stringify(header.content)

			if title:match "Front matter" then
				print("Front matter start")
				current_matter = MATTER.FRONT
				return utils.create_frontmatter()

			elseif title:match "Body matter" then
				print("Body matter start")
				current_matter = MATTER.BODY
				return utils.create_mainmatter()

			elseif title:match "Back matter" then
				print("Back matter start")
				current_matter = MATTER.BACK
				return utils.create_backmatter()
			else
				error("Level 1 heading '# %(title)s' found but the only possible title are Front matter, Body matter and Back matter" % {title=title})
			end
		elseif header.level == 2 and current_matter == MATTER.BODY then
			print("> Chapter: ", pandoc.utils.stringify(header))
			-- Retreive attributes or get default from meta
			local title_inlines = header.content
			local lines_before = pandoc.utils.stringify(header.attributes.lines_before or from_meta.lines_before)
			local height = pandoc.utils.stringify(header.attributes.height or from_meta.height)
			-- TODO: add support for chapter style

			return utils.create_chapter(title_inlines, lines_before, height)
		elseif header.level == 3 and current_matter == MATTER.BODY then
			print(">> Quickchapter: ", pandoc.utils.stringify(header))
			-- Retreive attributes or get default from meta
			local name_inlines = header.content
			local line = pandoc.utils.stringify(header.attributes.line or from_meta.line)

			return utils.create_quickchapter(name_inlines, line)
		else
			-- TODO
		end
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