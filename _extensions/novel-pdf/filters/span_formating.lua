local utils = require "../utils"

-- global variables needed to communicate between different filters
local para_need_smallcaps = false

if FORMAT:match 'latex' then
	-- global var to retrieve the metadata via the Meta filter so that other filters can access it
	local from_meta = {}

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
			elseif name == "sans" then
				span.content:insert(1, pandoc.RawInline('latex', [[\textsf{]]))
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

		-- Return the modified SPAN
		return span
	end

	-- Set what function will be called on what kind of Pandoc element and in which order
	-- See: https://pandoc.org/lua-filters.html#typewise-traversal
	return {
		{
			Meta = function(meta) from_meta = meta end,
		},
		{
			Span = add_formating_to_span,
		}
	}
end
