local utils = require "utils"

-- global variables to overcome weird bugs
local first_para = true
local para_need_smallcaps = false

if FORMAT:match 'latex' then
	-- Used localy inside epigraph div
	local make_changes_to_para = {
		Para = function(para)
			local before_para = {}
			local after_para = {}

			if first_para then
				table.insert(before_para, [[\forceindent ]])
				first_para = false
			end

			if para_need_smallcaps then
				table.insert(before_para, [[\textsc{]])
				table.insert(after_para, "}")
			end

			return {
				{pandoc.RawInline('latex', table.concat(before_para, ""))}
				.. para.content
				.. {pandoc.RawInline('latex', table.concat(after_para, ""))}
			}
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
			elseif class_name == "smallcaps" then
				-- BUG just using \scshape does not work (no error but no actual effect)
				-- So we add \textsc to each paragraphs
				para_need_smallcaps = true
			end
		end

		-- We need to add force an indentation at the begining of the div since novel class consider it
		-- like a new start of chapter and do not put an indend like any other para start
		-- BUG: the forceindent is included in the strikethrough when rendering
		first_para = true
		local content = div:walk(make_changes_to_para)
		para_need_smallcaps = false

		return {
			pandoc.RawBlock('latex', table.concat(all_latex_before, "\n")),
			content,
			pandoc.RawBlock('latex', table.concat(all_latex_after, "\n")),
		}
	end

	-- filter for Span
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
			elseif class_name == "smallcaps" then
				-- don't need to do anything since pandoc automaticaly add \textsc{...} around span with smallcaps class
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