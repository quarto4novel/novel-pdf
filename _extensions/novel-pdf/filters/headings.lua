local utils = require "../utils"

if FORMAT:match 'latex' then
	local from_meta = {}

	function get_param_from_meta(meta)
		from_meta.line = meta.chapters.quick.line[1]
		from_meta.lines_before = meta.chapters.title.lines_before[1]
		from_meta.height = meta.chapters.header_height[1]
	end

	local function chapters_from_bodymatter_headers(header)
		if header.level == 2 then
			-- Retreive attributes or get default from meta
			local title_inlines = header.content
			local lines_before = pandoc.utils.stringify(header.attributes.lines_before or from_meta.lines_before)
			local height = pandoc.utils.stringify(header.attributes.height or from_meta.height)
			-- TODO: add support for chapter style

			return utils.create_chapter(title_inlines, lines_before, height)
		elseif header.level == 3 then
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
			Header = chapters_from_bodymatter_headers
		}
	}
end