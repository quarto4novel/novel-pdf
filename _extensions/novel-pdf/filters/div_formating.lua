local utils = require "../utils"

-- global variables to overcome weird bugs
local first_para_need_indent = true
local para_need_smallcaps = false

if FORMAT:match 'latex' then
	local from_meta = {}

	function get_param_from_meta(meta)
		from_meta.parindent = meta.page_layout.parindent
		from_meta.parskip = meta.page_layout.parskip
	end

	-- Used localy inside epigraph div
	local make_changes_to_para = {
		Para = function(para)
			local before_para = {}
			local after_para = {}

			-- As \scshape does not work we need to apply \textsc para by para
			-- But that makes novel detect each para as a new chapter and so does not insert an indent at the para start
			if para_need_smallcaps then
				table.insert(before_para, [[\textsc{]])
				table.insert(before_para, [[\forceindent ]])
				first_para_need_indent = false
				table.insert(after_para, "}")
			end

			-- BUG: this also add an indent if this is the first para of a chapter (that should not be indented)
			if first_para_need_indent then
				table.insert(before_para, [[\forceindent ]])
				first_para_need_indent = false
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

		first_para_need_indent = true

		-- iterate over all the classes and attributes
		local classes_and_attrs = {}
		for _, class_name in ipairs(div.classes) do
			classes_and_attrs[class_name] = true
		end
		for attr_name, attr_value in pairs(div.attributes) do
			classes_and_attrs[attr_name] = attr_value
		end

		for name, value in pairs(classes_and_attrs) do
			if name == "bold" then
				table.insert(all_latex_before, [[\begin{bfseries}]])
				table.insert(all_latex_after, 1, [[\end{bfseries}]])
			elseif name == "italic" then
				table.insert(all_latex_before, [[\begin{itshape}]])
				table.insert(all_latex_after, 1, [[\end{itshape}]])
			elseif name == "strikethrough" then
				table.insert(all_latex_before, [[\st{]])
				table.insert(all_latex_after, 1, "}")
			elseif name == "smallcaps" then
				-- BUG just using \scshape does not work (no error but no actual effect)
				-- So we add \textsc to each paragraphs
				para_need_smallcaps = true
			elseif name == "monospace" then
				table.insert(all_latex_before, [[\begin{ttfamily}]])
				table.insert(all_latex_after, 1, [[\end{ttfamily}]])

				-- We had ragged right command since it's not possible to have monospaced justified text
				-- since LaTeX can't adjust spaces in any way. And also to respect the alignment of
				-- letters from line to line justified paragraph
				table.insert(all_latex_before, [[\begin{flushleft}]])
				table.insert(all_latex_after, 1, [[\end{flushleft}]])
			elseif name == "noparindent" then
				-- Retreive value from meta
				local parindent = pandoc.utils.stringify(from_meta.parindent)

				table.insert(all_latex_before, [[\setlength{\parindent}{0em}]])
				table.insert(all_latex_after, 1, [[\setlength{\parindent}{]] .. parindent .. [[}]])

				first_para_need_indent = false
			elseif name == "parskip" then
				-- Retreive value from attribute
				local local_parskip = pandoc.utils.stringify(value)

				-- Retreive value from meta
				local global_parskip = pandoc.utils.stringify(from_meta.parskip)

				table.insert(all_latex_before, [[\setlength{\parskip}{]] .. local_parskip .. [[}]])
				-- Since we have a space before the first paragraphe we insert a \null after
				-- the last one to also have a space after it (it's more symetrical)
				table.insert(all_latex_after, 1, [[\null\setlength{\parskip}{]] .. global_parskip .. [[}]])

				first_para_need_indent = false
			end
		end

		-- if nothing was detected, change nothing
		if utils.table_is_empty(all_latex_before) and utils.table_is_empty(all_latex_before) and not para_need_smallcaps then
			return nil
		end

		-- We need to add force an indentation at the begining of the div since novel class consider it
		-- like a new start of chapter and do not put an indend like any other para start
		-- BUG: the forceindent is included in the strikethrough when rendering
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
			elseif class_name == "monospace" then
				table.insert(all_latex_before, [[\texttt{]])
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
		{
			Meta = get_param_from_meta,
		},
		{
			Div = add_formating_to_div,
			Span = add_formating_to_span
		}
	}
end
