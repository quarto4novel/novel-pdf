local utils = require "../utils"

-- global variables needed to communicate between different filters
local g = {
	from_meta = {},
}

if FORMAT:match 'latex' then

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
			elseif name == "sans" then
				div.content:insert(1, pandoc.RawBlock('latex', [[\begin{sffamily}]]))
				div.content:insert(pandoc.RawBlock('latex', [[\end{sffamily}]]))
			elseif name == "noparindent" then
				-- Retreive value from meta
				local parindent = pandoc.utils.stringify(g.from_meta.page_layout.parindent)

				div.content:insert(1, pandoc.RawBlock('latex', [[\setlength{\parindent}{0em}]]))
				div.content:insert(pandoc.RawBlock('latex', [[\setlength{\parindent}{%(indent)s}]] % {indent=parindent}))
			elseif name == "parskip" then
				-- Retreive value from attribute
				local local_parskip = pandoc.utils.stringify(value)

				-- Retreive value from meta
				local global_parskip = pandoc.utils.stringify(g.from_meta.page_layout.parskip)

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

		-- Return the modified DIV
		return div
	end

	-- Set what function will be called on what kind of Pandoc element and in which order
	-- See: https://pandoc.org/lua-filters.html#typewise-traversal
	return {
		{
			Meta = function(meta) g.from_meta = meta end,
		},
		{
			Div = add_formating_to_div,
		},
	}
end
