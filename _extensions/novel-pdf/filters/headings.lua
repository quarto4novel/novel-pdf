local utils = require "../utils"

if FORMAT:match 'latex' then
	local from_meta = {}

	function get_param_from_meta(meta)
		from_meta.line = meta.chapters.quick.line[1]
	end

	local function structure_from_headers(header)
		if header.level == 2 then
			-- TODO
		elseif header.level == 3 then
			local chap_name = pandoc.utils.stringify(header.content)
			local line = pandoc.utils.stringify(header.attributes.line or from_meta.line)

			print("line=", line)

			return utils.create_quickchapter(chap_name, line)
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