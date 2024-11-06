local utils = require "utils"

local first_para = true

if FORMAT:match 'latex' then
	-- Used localy inside epigraph div
	local add_forceindent_to_first_para = {
		Para = function(para)
			if first_para then
				first_para = false
				return { {pandoc.RawInline('latex', [[\forceindent ]])} .. para.content}
			else
				return para
			end
		end
	}

	-- filter for Div
	function add_formating_to_div(div)
		local all_latex_before = {}  -- to store opening latex elements (same order as attributes)
		local all_latex_after = {}  -- to store closing latex elements (in reversed order of attributes)

		-- iterate over all the classes
		for _, class_name in ipairs(div.classes) do
			if class_name == "bold" then
				table.insert(all_latex_before, [[\begin{bfseries}]])
				table.insert(all_latex_after, 1, [[\end{bfseries}]])
			elseif class_name == "italic" then
				table.insert(all_latex_before, [[\begin{itshape}]])
				table.insert(all_latex_after, 1, [[\end{itshape}]])
			elseif class_name == "strikethrough" then
				table.insert(all_latex_before, [[\st{]])
				table.insert(all_latex_after, 1, "}")
			end
		end

		-- We need to add force an indentation at the begining of the div since novel class consider it
		-- like a new start of chapter and do not put an indend like any other para start
		-- BUG: the forceindent is included in the strikethrough when rendering
		first_para = true
		local content = div:walk(add_forceindent_to_first_para)

		return {
			pandoc.RawBlock('latex', table.concat(all_latex_before, "\n")),
			content,
			pandoc.RawBlock('latex', table.concat(all_latex_after, "\n")),
		}
	end

	-- filter for Div
	function add_formating_to_span(span)
		local all_latex_before = {}  -- to store opening latex elements (same order as attributes)
		local all_latex_after = {}  -- to store closing latex elements (in reversed order of attributes)
		-- iterate over all the classes
		for _, class_name in ipairs(span.classes) do
			if class_name == "bold" then
				table.insert(all_latex_before, [[\textbf{]])
				table.insert(all_latex_after, 1, "}")
			elseif class_name == "italic" then
				table.insert(all_latex_before, [[\textit{]])
				table.insert(all_latex_after, 1, "}")
			elseif class_name == "strikethrough" then
				table.insert(all_latex_before, [[\st{]])
				table.insert(all_latex_after, 1, "}")
			end
		end

		local content = span:walk()

		return {
			pandoc.RawInline('latex', table.concat(all_latex_before, "")),
			content,
			pandoc.RawInline('latex', table.concat(all_latex_after, "")),
		}
	end

	-- Set what function will be called on what kind of Pandoc element and in which order
	-- See: https://pandoc.org/lua-filters.html#typewise-traversal
	return {
		Div = add_formating_to_div,
		Span = add_formating_to_span
	}
end
