local utils = {}

-- ****************************************************************************
-- Table utils
function utils.table_contains(table, value)
	for _, v in ipairs(table) do
		if v == value then return true end
	end
	return false
end

function utils.table_is_empty(table)
	if next(table) then
		return false
	end

	return true
end

-- ****************************************************************************
-- python-like % string formating/interpolation
-- Example: print( "%(key)s is %(val)7.2f%" % {key = "concentration", val = 56.2795}
--          outputs "concentration is   56.28%"
-- See: https://www.lua-users.org/wiki/StringInterpolation (with a fix to allow _ in variable names)
-- See: https://www.lua.org/pil/20.2.html for the regex details
function utils.interp(s, tab)
	return (
		s:gsub(
			'%%%((%a[_%w]*)%)([-0-9%.]*[cdeEfgGiouxXsq])',
			function(k, fmt)
				return tab[k] and ("%"..fmt):format(tab[k]) or '%('..k..')'..fmt end
		)
	)
end
getmetatable("").__mod = utils.interp

return utils