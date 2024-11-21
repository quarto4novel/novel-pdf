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
					blocks[i].content:insert(pandoc.RawInline('latex', [[}]]))
					break
				end
			end
			return blocks
		end
	}


	-- returns a filter that enclose the first letter of the first paragraph in a SPAN with classes
	-- classes must be one string with space between each class (without the leading point)
	local function filter_to_enclose_first_letter_in_span(classes) return {
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
									inlines:insert(i, pandoc.Span(first_letter, {class=classes}))
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
	end


	-- filter for Div
	local function add_formating_to_div(div)
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
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{bfseries}]]))
				div.content:insert(pandoc.RawBlock('latex', [[\end{bfseries}]]))
			elseif name == "italic" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{itshape}]]))
				div.content:insert(pandoc.RawBlock('latex', [[\end{itshape}]]))
			elseif name == "strikethrough" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\st{]]))
				div.content:insert(pandoc.RawBlock('latex', [[}]]))
			elseif name == "smallcaps" then
				-- BUG just using \scshape does not work (no error but no actual effect)
				-- So we add \textsc to each paragraphs
				div = div:walk {
					Para = function(para)
						para.content:insert(1, pandoc.RawInline('latex', [[\textsc{]]))
						para.content:insert(pandoc.RawInline('latex', [[}]]))
						return para
					end
				}
			elseif name == "monospace" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{ttfamily}]]))
				div.content:insert(pandoc.RawBlock('latex', [[\end{ttfamily}]]))

				-- We had ragged right command since it's not possible to have monospaced justified text
				-- since LaTeX can't adjust spaces in any way. And also to respect the alignment of
				-- letters from line to line justified paragraph
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{flushleft}]]))
				div.content:insert(pandoc.RawBlock('latex', [[\end{flushleft}]]))
			elseif name == "noparindent" then
				-- Retreive value from meta
				local parindent = pandoc.utils.stringify(from_meta.page_layout.parindent)

				div.content:insert(1, pandoc.RawBlock('latex', [[\setlength{\parindent}{0em}]]))
				div.content:insert(pandoc.RawBlock('latex', [[\setlength{\parindent}{%(indent)s}]] % {indent=parindent}))
			elseif name == "parskip" then
				-- Retreive value from attribute
				local local_parskip = pandoc.utils.stringify(value)

				-- Retreive value from meta
				local global_parskip = pandoc.utils.stringify(from_meta.page_layout.parskip)

				div.content:insert(1, pandoc.RawBlock('latex', [[\setlength{\parskip}{%(skip)s}]] % {skip=local_parskip}))
				-- Since we have a space before the first paragraphe we insert a \null after
				-- the last one to also have a space after it (it's more symetrical)
				div.content:insert(pandoc.RawBlock('latex', [[\null\setlength{\parskip}{%(skip)s}]] % {skip=global_parskip}))
			elseif name == "vfill" then
				-- Retreive value from attribute
				local vfill = pandoc.utils.stringify(value)

				if vfill == "before" then
					div.content:insert(1, pandoc.RawBlock('latex', [[\null\vfill]]))
				elseif vfill == "after" then
					div.content:insert(pandoc.RawBlock('latex', [[\vfill\null]]))
				elseif vfill == "both" then
					div.content:insert(1, pandoc.RawBlock('latex', [[\null\vfill]]))
					div.content:insert(pandoc.RawBlock('latex', [[\vfill\null]]))
				else
					error("vfill div attribute only possible values are before, after and both, but has value: %(val)s." % {val=vfill})
				end
			elseif name == "scale" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{parascale}[%(scale)s] ]] % {scale=value}))
				div.content:insert(pandoc.RawBlock('latex', [[\end{parascale}]]))
			-- TODO: make number of lines the default unit if none provided
			elseif name == "vspace_before" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\vspace*{%(space)s}]] % {space=value}))
			elseif name == "vspace_after" then
				div.content:insert(pandoc.RawBlock('latex', [[\vspace*{%(space)s}]] % {space=value}))
			elseif name == "vspace_both" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\vspace*{%(space)s}]] % {space=value}))
				div.content:insert(pandoc.RawBlock('latex', [[\vspace*{%(space)s}]] % {space=value}))
			elseif name == "lines_before" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\vspace*{%(nb)s\nbs}]] % {nb=value}))
			elseif name == "lines_after" then
				div.content:insert(pandoc.RawBlock('latex', [[\vspace*{%(nb)s\nbs}]] % {nb=value}))
			elseif name == "lines_both" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\vspace*{%(nb)s\nbs}]] % {nb=value}))
				div.content:insert(pandoc.RawBlock('latex', [[\vspace*{%(nb)s\nbs}]] % {nb=value}))
			elseif name == "margin_left" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{adjustwidth}{%(margin)s}{0em}]] % {margin=value}))
				div.content:insert(pandoc.RawBlock('latex', [[\end{adjustwidth}]]))
			elseif name == "margin_right" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{adjustwidth}{0em}{%(margin)s}]] % {margin=value}))
				div.content:insert(pandoc.RawBlock('latex', [[\end{adjustwidth}]]))
			elseif name == "margin_both" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{adjustwidth}{%(margin)s}{%(margin)s}]] % {margin=value}))
				div.content:insert(pandoc.RawBlock('latex', [[\end{adjustwidth}]]))
			elseif name == "align" then
				if value == "left" then
					div.content:insert(1, pandoc.RawBlock('latex', [[\begin{FlushLeft}]]))
					div.content:insert(pandoc.RawBlock('latex', [[\end{FlushLeft}]]))
				elseif value == "right" then
					div.content:insert(1, pandoc.RawBlock('latex', [[\begin{FlushRight}]]))
					div.content:insert(pandoc.RawBlock('latex', [[\end{FlushRight}]]))
				elseif value == "center" then
					div.content:insert(1, pandoc.RawBlock('latex', [[\begin{Center}]]))
					div.content:insert(pandoc.RawBlock('latex', [[\end{Center}]]))
				elseif value == "justify" then
					div.content:insert(1, pandoc.RawBlock('latex', [[\begin{justify}]]))
					div.content:insert(pandoc.RawBlock('latex', [[\end{justify}]]))
				else
					error("align attribute with value '%(attr_val)s' but the only possible values are left, right, center and justify." % {attr_val=value})
				end
			elseif name == "firstlinesc" then
				div = div:walk(mark_first_paragraph)
			elseif name == "firstlettermaj" then
				div = div:walk(filter_to_enclose_first_letter_in_span("firstlettermaj"))
			elseif name == "dropcap" then
				div = div:walk(filter_to_enclose_first_letter_in_span("dropcap"))
			end

		end  -- for classes_and_attrs

		-- Return the content of the modified div (the div itself is not usefull in LaTeX)
		return div.content
	end

	-- filter for Span
	local function add_formating_to_span(span)
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
				span.content:insert(1, pandoc.RawInline('latex', [[\textbf{]]))
				span.content:insert(pandoc.RawInline('latex', [[}]]))
			elseif name == "italic" then
				span.content:insert(1, pandoc.RawInline('latex', [[\textit{]]))
				span.content:insert(pandoc.RawInline('latex', [[}]]))
			elseif name == "strikethrough" then
				span.content:insert(1, pandoc.RawInline('latex', [[\st{]]))
				span.content:insert(pandoc.RawInline('latex', [[}]]))
			elseif name == "smallcaps" then
				-- don't need to do anything since pandoc automaticaly add \textsc{...} around span with smallcaps class
			elseif name == "monospace" then
				span.content:insert(1, pandoc.RawInline('latex', [[\texttt{]]))
				span.content:insert(pandoc.RawInline('latex', [[}]]))
			elseif name == "scale" then
				span.content:insert(1, pandoc.RawInline('latex', [[\charscale[%(params)s]{]] % {params=value}))
				span.content:insert(pandoc.RawInline('latex', [[}]]))
			elseif name == "hspace_before" then
				span.content:insert(1, pandoc.RawInline('latex', [[\hspace*{%(space)s}]] % {space=value}))
			elseif name == "hspace_after" then
				span.content:insert(pandoc.RawInline('latex', [[\hspace*{%(space)s}]] % {space=value}))
			elseif name == "hspace_both" then
				span.content:insert(1, pandoc.RawInline('latex', [[\hspace*{%(space)s}]] % {space=value}))
				span.content:insert(pandoc.RawInline('latex', [[\vspace*{%(space)s}]] % {space=value}))
			elseif name == "phantom" then
				span.content:insert(1, pandoc.RawInline('latex', [[\phantom{]]))
				span.content:insert(pandoc.RawInline('latex', [[}]]))
			elseif name == "hfill" then
				if value == "before" then
					span.content:insert(1, pandoc.RawInline('latex', [[\strut\hfill]]))
				elseif value == "after" then
					span.content:insert(pandoc.RawInline('latex', [[\strut\hfill]]))
				elseif value == "both" then
					span.content:insert(1, pandoc.RawInline('latex', [[\strut\hfill]]))
					span.content:insert(pandoc.RawInline('latex', [[\strut\hfill]]))
				else
					error("hfill attribute with value '%(attr_val)s' but the only possible values are before, after and both." % {attr_val=value})
				end
			elseif name == "color" then
				local allowed_colors = {"black", "gray1", "gray2", "gray3", "gray4", "gray5", "gray6", "gray7", "gray8", "gray9", "white"}
				assert(
					utils.table_contains(allowed_colors, value),
					"Invalid color %(color)s. Accepted colors are: black, gray1, gray2, gray3, gray4, gray5, gray6, gray7, gray8, gray9, white" % {color=value}
				)
				span.content:insert(1, pandoc.RawInline('latex', [[{\color{%(color)s}]] % {color=value}))
				span.content:insert(pandoc.RawInline('latex', [[}]]))
			elseif name == "firstlettermaj" then
				-- Retreive value from meta
				local scale = pandoc.utils.stringify(from_meta.chapters.beginning.bigmaj.scale)
				local hspace_after = pandoc.utils.stringify(from_meta.chapters.beginning.bigmaj.hspace_after)

				span.content:insert(1, pandoc.RawInline('latex', [[\charscale[%(scale)s]{\firstletterfont ]] % {scale=scale}))
				span.content:insert(pandoc.RawInline('latex', [[}\hspace{%(space)s}]] % {space=hspace_after}))
			elseif name == "dropcap" then
				-- Retreive value from meta
				local lines = pandoc.utils.stringify(from_meta.chapters.beginning.dropcap.lines)

				span.content:insert(1, pandoc.RawInline('latex', [[\dropcap[lines=%(lines)s]{]] % {lines=lines}))
				span.content:insert(pandoc.RawInline('latex', [[}]]))
			end
		end

		-- Return the content of the modified SPAN (the DIV itself is not usefull in LaTeX)
		return span.content
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
