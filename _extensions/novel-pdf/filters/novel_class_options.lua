
if FORMAT:match 'latex' then

	function table_contains(table, value)
	  for _, v in ipairs(table) do
	    if v == value then return true end
	  end
	  return false
	end

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
			error(string.format("special_rendering metadata has value '%s' but the only possible values are: printready, cropmarks, draft, shademargins, cropview, closecrop and sandbox", spcl_rendering))
		end

		if table_contains(meta.class_options, "draft") then
			meta.draft_watermark = true
		end

		-- Return the modified meta
		return meta
	end

end
