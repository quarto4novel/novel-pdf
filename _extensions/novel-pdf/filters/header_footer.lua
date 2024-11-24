if not FORMAT:match 'latex' then
	return
end

local STYLE <const> = {
	onlyheadercentered = 1,
	onlyheaderoutside = 4,
	onlyheaderinside = 6,
	onlyfootercentered = 3,
	onlyfooteroutside = 2,
	bothcentered = 5,
}

-- Create a valid configuration for header/footer according to the metadata provided
function Meta(meta)
	local style = pandoc.utils.stringify(meta.headerfooter.style)
	meta.headerfooter.raw_style = STYLE[style]

	return meta
end
