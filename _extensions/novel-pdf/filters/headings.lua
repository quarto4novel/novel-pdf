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
		from_meta.scene_break_default = meta.scenebreaks.default[1]
	end

	local function structure_from_headers(header)
		local title = pandoc.utils.stringify(header.content)

		if header.level == 1 then
			if title == "Front matter" then
				print("Front matter start")
				current_matter = MATTER.FRONT
				return utils.create_frontmatter()

			elseif title == "Body matter" then
				print("Body matter start")
				current_matter = MATTER.BODY
				return utils.create_mainmatter()

			elseif title == "Back matter" then
				print("Back matter start")
				current_matter = MATTER.BACK
				return utils.create_backmatter()
			else
				error("Level 1 heading '# %(title)s' found but the only possible title are Front matter, Body matter and Back matter" % {title=title})
			end
		elseif header.level == 2 and current_matter == MATTER.BODY then
			-- Retreive attributes or get default from meta
			local chapter = utils.ChapterBuilder:new()
				:title_inlines(header.content)
				:lines_before_title(pandoc.utils.stringify(header.attributes.lines_before or from_meta.lines_before))
				:height(pandoc.utils.stringify(header.attributes.height or from_meta.height))
				-- TODO: add support for chapter style
				:build()

			return chapter
		elseif header.level == 3 and current_matter == MATTER.BODY then
			print(">> Quickchapter: ", pandoc.utils.stringify(header))
			-- Retreive attributes or get default from meta
			local name_inlines = header.content
			local line = pandoc.utils.stringify(header.attributes.line or from_meta.line)

			return utils.create_quickchapter(name_inlines, line)
		elseif header.level == 4 and current_matter == MATTER.BODY then
			if title == "Scene break" then
				print(">> Scenebreak default")
				local default_break = pandoc.utils.stringify(from_meta.scene_break_default)

				if default_break == "blank" then
					return pandoc.RawBlock("latex", [[\scenebreak]])
				elseif default_break == "line" then
					return pandoc.RawBlock("latex", [[\sceneline]])
				elseif default_break == "stars" then
					return pandoc.RawBlock("latex", [[\scenestars]])
				else
					error("Scene break asked but metadata 'scenebreaks.default' \z
						has invalid value '%(val)s' but only possible values are \z
						'blank', 'line' and 'stars'."
						% {val=default_break}
					)
				end
			elseif title == "Scene break blank" then
				print(">> Scenebreak blank")
				return pandoc.RawBlock("latex", [[\scenebreak]])
			elseif title == "Scene break line" then
				print(">> Scenebreak line")
				return pandoc.RawBlock("latex", [[\sceneline]])
			elseif title == "Scene break stars" then
				print(">> Scenebreak stars")
				return pandoc.RawBlock("latex", [[\scenestars]])
			else
				error("Level 4 heading '# %(title)s' found but the only possible title are 'Scene break', 'Scene break line' and 'Scene break stars'" % {title=title})
			end
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