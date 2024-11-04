local utils = require "utils"

if FORMAT:match 'latex' then
	-- Used localy inside epigraph div
	local make_para_noindent = {
		Para = function(para)
			return { {pandoc.RawInline('latex', [[\noindent ]])} .. para.content}
		end
	}

	-- filter for Div
	function add_formating_to_div(div)
		local latex_before = {}  -- to store opening latex elements (same order as attributes)
		local latex_after = {}  -- to store closing latex elements (in reversed order of attributes)
		-- iterate over all the classes
		for _, class_name in ipairs(div.classes) do
			if class_name == "bold" then
				table.insert(latex_before, [[\begin{bfseries}]])
				table.insert(latex_after, 1, [[\end{bfseries}]])
			elseif class_name == "italic" then
				table.insert(latex_before, [[\begin{itshape}]])
				table.insert(latex_after, 1, [[\end{itshape}]])
			end
		end

		local content = div:walk()

		return {
			pandoc.RawBlock('tex', table.concat(latex_before, "\n")),
			content,
			pandoc.RawBlock('tex', table.concat(latex_after, "\n")),
		}
	end

	-- Set what function will be called on what kind of Pandoc element and in which order
	-- See: https://pandoc.org/lua-filters.html#typewise-traversal
	return {
		Div = add_formating_to_div,
	}
end
