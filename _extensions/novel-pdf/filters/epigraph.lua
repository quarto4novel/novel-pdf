-- LaTeX multiline strings declared here so that it does not have useless indentation
local raw_latex_open_format <const> = [[
\vspace*{%s\nbs}
\begin{adjustwidth}{%s}{%s}
{\itshape]]

local raw_latex_close_format <const> = [[
\par}
\hfill--- %s, ``%s''\par
\end{adjustwidth}
\vspace*{%s\nbs}]]

if FORMAT:match 'latex' then
	local from_meta = {}

	function get_margins_from_meta(meta)
		from_meta.lmargin = pandoc.utils.stringify(meta.epigraphs.lmargin)
		from_meta.rmargin = pandoc.utils.stringify(meta.epigraphs.rmargin)
		from_meta.lines_before = pandoc.utils.stringify(meta.epigraphs.lines_before)
		assert(
			tonumber(from_meta.lines_before),
			"invalid epigraphs.lines_before metadata: " .. from_meta.lines_before .. " is not a number"
		)
		from_meta.lines_after = pandoc.utils.stringify(meta.epigraphs.lines_after)
		assert(
			tonumber(from_meta.lines_after),
			"invalid epigraphs.lines_after metadata: " .. from_meta.lines_after .. " is not a number"
		)
		from_meta.keepindent = meta.epigraphs.keepindent
		assert(
			pandoc.utils.type(from_meta.keepindent) == 'boolean',
			"invalid epigraphs.keepindent metadata: " .. tostring(from_meta.keepindent) .. " is not a boolean"
		)
	end

	function table_contains(table, value)
	  for _, v in ipairs(table) do
	    if v == value then return true end
	  end
	  return false
	end

	-- Used localy inside epigraph div
	local make_para_noindent = {
		Para = function(para)
			return { {pandoc.RawInline('latex', [[\noindent ]])} .. para.content}
		end
	}

	function epigraph_from_div(div)
		if table_contains(div.classes, "epigraph") then
			-- Retreive the relevant attributes of the div if provided
			-- Eventualy defaulting to value provided in meta
			local lmargin
			if div.attributes.lmargin then
				lmargin = pandoc.utils.stringify(div.attributes.lmargin)
			else
				lmargin = from_meta.lmargin
			end

			local rmargin
			if div.attributes.rmargin then
				rmargin = pandoc.utils.stringify(div.attributes.rmargin)
			else
				rmargin = from_meta.rmargin
			end

			local lines_before
			if div.attributes.lines_before then
				lines_before = pandoc.utils.stringify(div.attributes.lines_before)
			else
				lines_before = from_meta.lines_before
			end
			assert(tonumber(lines_before), "invalid lines_before attribute: " .. lines_before .. " is not a number")

			local lines_after
			if div.attributes.lines_after then
				lines_after = pandoc.utils.stringify(div.attributes.lines_after)
			else
				lines_after = from_meta.lines_after
			end
			assert(tonumber(lines_after), "invalid lines_after attribute: " .. lines_after .. " is not a number")

			local keepindent
			if div.attributes.keepindent then
				keepindent = true
			else
				keepindent = from_meta.keepindent
			end

			local by
			if div.attributes.by then
				by = pandoc.utils.stringify(div.attributes.by)
			end

			local from
			if div.attributes.from then
				from = pandoc.utils.stringify(div.attributes.from)
			end

			local raw_latex_open = string.format(raw_latex_open_format, lines_before, lmargin, rmargin)

			local content
			if keepindent then
		    	content = div:walk()
		    else
		    	content = div:walk(make_para_noindent)
		    end

			local raw_latex_close = string.format(raw_latex_close_format, by, from, lines_after)

			return {
				pandoc.RawBlock('tex', raw_latex_open),
				content,
				pandoc.RawBlock('tex', raw_latex_close),
			}
		end

		-- if the div doesn't have the correct class we are not touching it
		return nil
	end

	-- Set what function will be called on what kind of Pandoc element and in which order
	-- See: https://pandoc.org/lua-filters.html#typewise-traversal
	return {
		{
			Meta = get_margins_from_meta
		},
		{
			Div = epigraph_from_div
		}
	}
end
