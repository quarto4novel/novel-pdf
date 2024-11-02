local utils = require "utils"

if FORMAT:match 'latex' then
	-- Create a valid set of options for the novel class according to the metadata provided
	-- The resulting options are stored in an array in the class_options metadata
	-- See: https://ctan.math.illinois.edu/macros/luatex/latex/novel/doc/novel-documentation.html#h2
	function Meta(meta)
		-- Retrieve metadata
		local spcl_rendering = pandoc.utils.stringify(meta.special_rendering)
		local lang = pandoc.utils.stringify(meta.lang)

		-- Set a new meta according to the one provided by the user
		if spcl_rendering == "printready" then
			meta.class_options = {"v2", lang, ""}
		elseif spcl_rendering == "cropmarks" then
			meta.class_options = {"v2", lang, "cropmarks"}
		elseif spcl_rendering == "draft" then
			meta.class_options = {"v2", lang, "draft"}
		elseif spcl_rendering == "shademargins" then
			meta.class_options = {"v2", lang, "draft","shademargins"}
		elseif spcl_rendering == "cropview" then
			meta.class_options = {"v2", lang, "draft","cropview"}
		elseif spcl_rendering == "closecrop" then
			meta.class_options = {"v2", lang, "draft","closecrop"}
		elseif spcl_rendering == "sandbox" then
			meta.class_options = {"v2", lang, "sandbox"}
		else
			error(
				"special_rendering metadata has value '%(actual)s' but \z
				the only possible values are: \z
				printready, cropmarks, draft, \z
				shademargins, cropview, closecrop and sandbox" % {actual=spcl_rendering}
			)
		end

		if utils.table_contains(meta.class_options, "draft") then
			meta.draft_watermark = true
		end

		-- Return the modified meta
		return meta
	end

end
