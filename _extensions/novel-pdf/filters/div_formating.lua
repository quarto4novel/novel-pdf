local utils = require "../utils"

-- global variables needed to communicate between different filters
local para_need_smallcaps = false

if FORMAT:match 'latex' then
	local from_meta = {}

	function get_param_from_meta(meta)
		from_meta.page_layout = meta.page_layout
		from_meta.chapters = meta.chapters
	end

	-- Mark first paragraph for first line emphasis
	local mark_first_paragraph = {
		Blocks = function(blocks)
			for i = 1, #blocks, 1 do
				if blocks[i].t == "Para" then
					blocks[i].content:insert(1, pandoc.RawInline('latex', [[\FirstLine{]]))
					blocks[i].content:insert(pandoc.RawInline('latex', "}"))
					break
				end
			end
			return blocks
		end
	}


	-- Mark first letter of first paragraph for first line emphasis with bigmaj
	local mark_first_letter_for_bigmaj = {
		Blocks = function(blocks)
			-- Let's find the first para...
			for i = 1, #blocks, 1 do
				if blocks[i].t == "Para" then
					blocks[i] = blocks[i]:walk {
						Inlines = function(inlines)
							-- ...and in this para, let's find the first word and modify it
							for i = 1, #inlines, 1 do
								if inlines[i].t == "Str" then
									first_word = pandoc.utils.stringify(inlines[i])
									first_letter = first_word:sub(1, 1)
									rest = first_word:sub(2)

									inlines:remove(i)
									inlines:insert(i, rest)
									inlines:insert(i, pandoc.Span(first_letter, {class="firstlettermaj"}))
									break
								end
							end -- for inlines

							return inlines
						end
					}
					break
				end
			end -- for blocks
			return blocks
		end
	}


	-- Mark first letter of first paragraph for first line emphasiswith dropcap
	local mark_first_letter_for_dropcap = {
		Blocks = function(blocks)
			-- Let's find the first para...
			for i = 1, #blocks, 1 do
				if blocks[i].t == "Para" then
					blocks[i] = blocks[i]:walk {
						Inlines = function(inlines)
							-- ...and in this para, let's find the first word and modify it
							for i = 1, #inlines, 1 do
								if inlines[i].t == "Str" then
									first_word = pandoc.utils.stringify(inlines[i])
									first_letter = first_word:sub(1, 1)
									rest = first_word:sub(2)

									inlines:remove(i)
									inlines:insert(i, rest)
									inlines:insert(i, pandoc.Span(first_letter, {class="dropcap"}))
									break
								end
							end -- for inlines

							return inlines
						end
					}
					break
				end
			end -- for blocks
			return blocks
		end
	}

	-- Make paragraphs small caps if needed
	local make_changes_to_para = {
		Para = function(para)
			local before_para = {}
			local after_para = {}

			-- As \scshape does not work we need to apply \textsc para by para
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
				local parindent = pandoc.utils.stringify(from_meta.page_layout.parindent)

				table.insert(all_latex_before, [[\setlength{\parindent}{0em}]])
				table.insert(all_latex_after, 1, [[\setlength{\parindent}{]] .. parindent .. [[}]])
			elseif name == "parskip" then
				-- Retreive value from attribute
				local local_parskip = pandoc.utils.stringify(value)

				-- Retreive value from meta
				local global_parskip = pandoc.utils.stringify(from_meta.page_layout.parskip)

				table.insert(all_latex_before, [[\setlength{\parskip}{]] .. local_parskip .. [[}]])
				-- Since we have a space before the first paragraphe we insert a \null after
				-- the last one to also have a space after it (it's more symetrical)
				table.insert(all_latex_after, 1, [[\null\setlength{\parskip}{]] .. global_parskip .. [[}]])
			elseif name == "vfill" then
				-- Retreive value from attribute
				local vfill = pandoc.utils.stringify(value)

				if vfill == "before" then
					table.insert(all_latex_before, [[\null\vfill]])
				elseif vfill == "after" then
					table.insert(all_latex_after, 1, [[\vfill\null]])
				elseif vfill == "both" then
					table.insert(all_latex_before, [[\null\vfill]])
					table.insert(all_latex_after, 1, [[\vfill\null]])
				else
					error("vfill div attribute only possible values are before, after and both, but has value: %(val)s." % {val=vfill})
				end
			elseif name == "scale" then
				table.insert(all_latex_before, [[\begin{parascale}[%(scale)s] ]] % {scale=value})
				table.insert(all_latex_after, 1, [[\end{parascale}]])
			-- TODO: make number of lines the default unit if none provided
			elseif name == "vspace_before" then
				table.insert(all_latex_before, [[\vspace*{%(space)s}]] % {space=value})
			elseif name == "vspace_after" then
				table.insert(all_latex_after, 1, [[\vspace*{%(space)s}]] % {space=value})
			elseif name == "vspace_both" then
				table.insert(all_latex_before, [[\vspace*{%(space)s}]] % {space=value})
				table.insert(all_latex_after, 1, [[\vspace*{%(space)s}]] % {space=value})
			elseif name == "lines_before" then
				table.insert(all_latex_before, [[\vspace*{%(nb)s\nbs}]] % {nb=value})
			elseif name == "lines_after" then
				table.insert(all_latex_after, 1, [[\vspace*{%(nb)s\nbs}]] % {nb=value})
			elseif name == "lines_both" then
				table.insert(all_latex_before, [[\vspace*{%(nb)s\nbs}]] % {nb=value})
				table.insert(all_latex_after, 1, [[\vspace*{%(nb)s\nbs}]] % {nb=value})
			elseif name == "margin_left" then
				table.insert(all_latex_before, [[\begin{adjustwidth}{%(margin)s}{0em}]] % {margin=value})
				table.insert(all_latex_after, 1, [[\end{adjustwidth}]])
			elseif name == "margin_right" then
				table.insert(all_latex_before, [[\begin{adjustwidth}{0em}{%(margin)s}]] % {margin=value})
				table.insert(all_latex_after, 1, [[\end{adjustwidth}]])
			elseif name == "margin_both" then
				table.insert(all_latex_before, [[\begin{adjustwidth}{%(margin)s}{%(margin)s}]] % {margin=value})
				table.insert(all_latex_after, 1, [[\end{adjustwidth}]])
			elseif name == "align" then
				if value == "left" then
					table.insert(all_latex_before, [[\begin{FlushLeft}]])
					table.insert(all_latex_after, 1, [[\end{FlushLeft}]])
				elseif value == "right" then
					table.insert(all_latex_before, [[\begin{FlushRight}]])
					table.insert(all_latex_after, 1, [[\end{FlushRight}]])
				elseif value == "center" then
					table.insert(all_latex_before, [[\begin{Center}]])
					table.insert(all_latex_after, 1, [[\end{Center}]])
				elseif value == "justify" then
					table.insert(all_latex_before, [[\begin{justify}]])
					table.insert(all_latex_after, 1, [[\end{justify}]])
				else
					error("align attribute with value '%(attr_val)s' but the only possible values are left, right, center and justify." % {attr_val=value})
				end
			elseif name == "firstlinesc" then
				div = div:walk(mark_first_paragraph)
			elseif name == "firstlettermaj" then
				div = div:walk(mark_first_letter_for_bigmaj)
			elseif name == "dropcap" then
				div = div:walk(mark_first_letter_for_dropcap)
			end

		end  -- for classes_and_attrs

		-- TODO replace this by a local walk in the big for-if above
		-- Some changes need to be done for each para
		local div = div:walk(make_changes_to_para)
		para_need_smallcaps = false


		return {
			pandoc.RawBlock('latex', table.concat(all_latex_before, "\n")),
			div,
			pandoc.RawBlock('latex', table.concat(all_latex_after, "\n")),
		}
	end

	-- filter for Span
	function add_formating_to_span(span)
		local all_latex_before = {}  -- to store opening latex elements (same order as attributes)
		local all_latex_after = {}  -- to store closing latex elements (in reversed order of attributes)

		-- iterate over all the classes and attributes
		local classes_and_attrs = {}
		for _, class_name in ipairs(span.classes) do
			classes_and_attrs[class_name] = true
		end
		for attr_name, attr_value in pairs(span.attributes) do
			classes_and_attrs[attr_name] = attr_value
		end

		for name, value in pairs(classes_and_attrs) do
			if name == "bold" then
				table.insert(all_latex_before, [[\textbf{]])
				table.insert(all_latex_after, 1, "}")
			elseif name == "italic" then
				table.insert(all_latex_before, [[\textit{]])
				table.insert(all_latex_after, 1, "}")
			elseif name == "strikethrough" then
				table.insert(all_latex_before, [[\st{]])
				table.insert(all_latex_after, 1, "}")
			elseif name == "smallcaps" then
				-- don't need to do anything since pandoc automaticaly add \textsc{...} around span with smallcaps class
			elseif name == "monospace" then
				table.insert(all_latex_before, [[\texttt{]])
				table.insert(all_latex_after, 1, "}")
			elseif name == "scale" then
				table.insert(all_latex_before, [[\charscale[%(params)s]{]] % {params=value})
				table.insert(all_latex_after, 1, "}")
			elseif name == "hspace_before" then
				table.insert(all_latex_before, [[\hspace*{%(space)s}]] % {space=value})
			elseif name == "hspace_after" then
				table.insert(all_latex_after, 1, [[\hspace*{%(space)s}]] % {space=value})
			elseif name == "hspace_both" then
				table.insert(all_latex_before, [[\hspace*{%(space)s}]] % {space=value})
				table.insert(all_latex_after, 1, [[\vspace*{%(space)s}]] % {space=value})
			elseif name == "phantom" then
				table.insert(all_latex_before, [[\phantom{]])
				table.insert(all_latex_after, 1, "}")
			elseif name == "hfill" then
				if value == "before" then
					table.insert(all_latex_before, [[\strut\hfill]])
				elseif value == "after" then
					table.insert(all_latex_after, 1, [[\strut\hfill]])
				elseif value == "both" then
					table.insert(all_latex_before, [[\strut\hfill]])
					table.insert(all_latex_after, 1, [[\strut\hfill]])
				else
					error("hfill attribute with value '%(attr_val)s' but the only possible values are before, after and both." % {attr_val=value})
				end
			elseif name == "color" then
				local allowed_colors = {"black", "gray1", "gray2", "gray3", "gray4", "gray5", "gray6", "gray7", "gray8", "gray9", "white"}
				assert(
					utils.table_contains(allowed_colors, value),
					"Invalid color %(color)s. Accepted colors are: black, gray1, gray2, gray3, gray4, gray5, gray6, gray7, gray8, gray9, white" % {color=value}
				)
				table.insert(all_latex_before, [[{\color{%(color)s}]] % {color=value})
				table.insert(all_latex_after, 1, "}")
			elseif name == "firstlettermaj" then
				-- Retreive value from meta
				local scale = pandoc.utils.stringify(from_meta.chapters.beginning.bigmaj.scale)
				local hspace_after = pandoc.utils.stringify(from_meta.chapters.beginning.bigmaj.hspace_after)

				table.insert(all_latex_before, [[\charscale[%(scale)s]{\firstletterfont ]] % {scale=scale})
				table.insert(all_latex_after, 1, [[}\hspace{%(space)s}]] % {space=hspace_after})
			elseif name == "dropcap" then
				-- Retreive value from meta
				local lines = pandoc.utils.stringify(from_meta.chapters.beginning.dropcap.lines)

				table.insert(all_latex_before, [[\dropcap[lines=%(lines)s]{]] % {lines=lines})
				table.insert(all_latex_after, 1, [[}]])
			end
		end

		-- Get the content
		local content = span:walk()

		-- Encapsulate the content and return it
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
		},
		{
			Span = add_formating_to_span,
		}
	}
end
