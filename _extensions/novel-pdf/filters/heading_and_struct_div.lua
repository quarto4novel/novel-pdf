local utils = require "../utils"
local builders = require "../builders"

if not FORMAT:match 'latex' then
	return
end

local MATTER <const> = {
	NOTHING = 0,
	FRONT = 1,
	BODY = 2,
	BACK = 3
}

-- global variables needed to communicate between different filters
local g = {
	from_meta = {},
	chap_builder = nil,
	part_builder = nil,
	current_matter = MATTER.NOTHING,
	chap_first_para_found = true,
	quickchap_first_para_found = true,
	first_part_found = false,
}

-- Used localy inside chapter div
local chapter_titles_from_header = {
	Header = function(header)
		assert(g.chap_builder)

		if header.level == 2 then
			g.chap_builder
				:lines_before_title(pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.chapters.title.lines_before))
				:title_inlines(header.content)

			-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
			-- this is important since we already created the chapter and its title here
			return {}

		elseif header.level == 3 then
			g.chap_builder
				:lines_before_subtitle(pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.chapters.subtitle.lines_before))
				:subtitle_inlines(header.content)

			-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
			-- this is important since we already created the chapter and its subtitle here
			return {}

		else
			error("Only level 2 and 3 heading are allowed inside a .chapter DIV. Level %(lvl)s found." % {lvl=header.level})
		end
	end
}

--- Replace the header 1 element with front/body/back matter
-- @param header the header from which to generate the matter from
-- @return LaTeX Block to replace the header with
local function _matter_from_header_1(header)
	local title = pandoc.utils.stringify(header.content)

	if title == "Front matter" then
		g.current_matter = MATTER.FRONT
		return builders.build_frontmatter(g.from_meta)

	elseif title == "Body matter" then
		g.current_matter = MATTER.BODY
		return builders.build_mainmatter(g.from_meta)

	elseif title == "Back matter" then
		g.current_matter = MATTER.BACK
		return builders.build_backmatter(g.from_meta)
	else
		error("Level 1 heading '# %(title)s' found but the only possible title are Front matter, Body matter and Back matter" % {title=title})
	end
end


local function _frontback_matter_subpart_from_header_2(header)
	local title = pandoc.utils.stringify(header.content)

	if header.classes:find("chapterlike") then
		-- TODO add specific default config for chapterlike
		-- Retreive attributes or get default from meta
		local lines_before = pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.chapters.title.lines_before)
		local height = pandoc.utils.stringify(header.attributes.height or g.from_meta.chapters.header_height)

		-- build chapterlike
		local chapter = builders.ChapterBuilder:new()
			:title_inlines(header.content)
			:lines_before_title(lines_before)
			:height(height)
			-- TODO: add support for chapter style
			:build()

		return chapter
	else
		-- TODO: add support for .samepage class
		-- TODO: add support for page_style=empty attribute
		return builders.build_frontmatter_sub(title)
	end
end

local function _chapter_or_part_from_header_2(header)
	if header.classes:find("part") then
		-- Retreive attributes or get default from meta
		local lines_before = pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.parts.title.lines_before)
		local height = pandoc.utils.stringify(header.attributes.height or g.from_meta.parts.header_height)
		local scale = pandoc.utils.stringify(header.attributes.scale or g.from_meta.parts.title.scale)

		-- Build the part
		local part_builder = builders.PartBuilder:new()
			:title_inlines(header.content)
			:title_scale(scale)
			:lines_before_title(lines_before)
			:height(height)

		-- Adjust the blank page before
		if not g.first_part_found then
			part_builder:very_first_part(true)
			g.first_part_found = true
		end

		return part_builder:build()
	else
		-- Retreive attributes or get default from meta
		local lines_before = pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.chapters.title.lines_before)
		local height = pandoc.utils.stringify(header.attributes.height or g.from_meta.chapters.header_height)
		local page_style = pandoc.utils.stringify(header.attributes.page_style or g.from_meta.chapters.page_style)
		local nofldeco = header.classes:find("nofldeco") ~= nil

		-- Build the chapter
		local chap_builder = builders.ChapterBuilder:new()
			:title_inlines(header.content)
			:lines_before_title(lines_before)
			:height(height)
			:page_style(page_style)

		-- If we don't need to mark first line of chapter then do as if it was already found
		if nofldeco then
			g.chap_first_para_found = true
		else
			g.chap_first_para_found = false
		end

		return chap_builder:build()
	end
end


local function _quickchapter_from_header_3(header)
	-- Retreive attributes or get default from meta
	local name_inlines = header.content
	local line = pandoc.utils.stringify(header.attributes.line or g.from_meta.quickchapters.line)
	local nofldeco = header.classes:find("nofldeco") ~= nil

	-- If we don't need to mark first line of quickchapter then do as if it was already found
	if nofldeco or not g.chap_first_para_found then
		g.quickchap_first_para_found = true
	else
		g.quickchap_first_para_found = false
	end

	return builders.build_quickchapter(name_inlines, line)
end


local function _scenebreak_from_header_4(header)
	local title = pandoc.utils.stringify(header.content)

	-- Retreive attributes or get default from meta
	local default_break = pandoc.utils.stringify(g.from_meta.scenebreaks.default)

	return builders.build_scenebreak(title, default_break)
end

function _structure_from_headers(header)
	if header.level == 1 then
		return _matter_from_header_1(header)
	end -- level 1

	if g.current_matter == MATTER.FRONT
	or g.current_matter == MATTER.BACK then
		if header.level == 2 then
			return _frontback_matter_subpart_from_header_2(header)
		end
		-- TODO add an else block to show an error when we have another case
	elseif g.current_matter == MATTER.BODY then
		if header.level == 2 then
			return _chapter_or_part_from_header_2(header)
		elseif header.level == 3 then
			return _quickchapter_from_header_3(header)
		elseif header.level == 4 then
			return _scenebreak_from_header_4(header)
		end
		-- TODO add an else block to show an error when we have another case
	end

	-- any other header is returned as-is
	return header
end


-- Used localy inside part div
local part_titles_from_header = {
	Header = function(header)
		assert(g.part_builder)

		if header.level == 2 then
			local before_title = pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.parts.title.lines_before)
			local title_scale = pandoc.utils.stringify(header.attributes.scale or g.from_meta.parts.title.scale)

			g.part_builder
				:lines_before_title(before_title)
				:title_inlines(header.content)
				:title_scale(title_scale)

			-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
			-- this is important since we already created the chapter and its title here
			return {}

		elseif header.level == 3 then
			local before_subtitle = pandoc.utils.stringify(header.attributes.lines_before or g.from_meta.parts.subtitle.lines_before)
			local subtitle_scale = pandoc.utils.stringify(header.attributes.scale or g.from_meta.parts.subtitle.scale)

			g.part_builder
				:lines_before_subtitle(before_subtitle)
				:subtitle_inlines(header.content)
				:subtitle_scale(subtitle_scale)

			-- return empty table to remove the heading from AST preventing it to be processed later by dedicated filters
			-- this is important since we already created the chapter and its subtitle here
			return {}

		else
			error("Only level 2 and 3 heading are allowed inside a .part DIV. Level %(lvl)s found." % {lvl=header.level})
		end
	end
}


function _chapter_start_from_div(div)
	-- Retreive attributes or get default from meta
	local height = pandoc.utils.stringify(div.attributes.height or g.from_meta.chapters.header_height)
	local page_style = pandoc.utils.stringify(div.attributes.page_style or g.from_meta.chapters.page_style)
	local nofldeco = div.classes:find("nofldeco") ~= nil

	-- We need a global builder so that walk can access it
	g.chap_builder = builders.ChapterBuilder:new()

	-- Retreive the content of the chapter after some conversion
	-- Warning: we need the global chap_builder to already exist for this !
	local content = div:walk(chapter_titles_from_header)

	-- build the chapter
	local new_block = g.chap_builder
		:height(height)
		:page_style(page_style)
		:content_block(content)
		:build()

	-- Deactivate the builder to prevent unintended side effects
	g.chap_builder = nil

	-- If we don't need to mark first line of chapter then do as if it was already found
	if nofldeco then
		g.chap_first_para_found = true
	else
		g.chap_first_para_found = false
	end

	return new_block
end


function _part_start_from_div(div)
	-- Retreive attributes or get default from meta
	local height = pandoc.utils.stringify(div.attributes.height or g.from_meta.parts.header_height)

	-- We need a global builder so that walk can access it
	g.part_builder = builders.PartBuilder:new()

	-- Adjust the blank page before
	if not g.first_part_found then
		g.part_builder:very_first_part(true)
		g.first_part_found = true
	end

	-- Retreive the content of the part after some conversion
	-- Warning: we need the global part_builder to already exist for this !
	local content = div:walk(part_titles_from_header)

	-- build the part
	local new_block = g.part_builder
		:height(height)
		:content_block(content)
		:build()

	-- Deactivate the builder to prevent unintended side effects
	g.part_builder = nil

	return new_block
end

function _mark_first_paragraph(para)
	-- Early exit if it we're not in the body matter or have already found 1st para
	if g.current_matter ~= MATTER.BODY then return nil end
	if g.quickchap_first_para_found and g.chap_first_para_found then return nil end

	-- Retreive attributes from meta
	local chap_fldeco = pandoc.utils.stringify(g.from_meta.chapters.fldeco.style)
	local quickchap_fldeco = pandoc.utils.stringify(g.from_meta.quickchapters.fldeco.style)

	local STYLE2CLASS <const> = {
		bigmaj = "firstlettermaj",
		dropcap = "dropcap",
		scline = "firstlinesc",
		bigmajscline = "firstlettermaj firstlinesc",
	}

	-- Marking chapter first line deco
	if not g.chap_first_para_found then
		g.chap_first_para_found = true

		if chap_fldeco == "none" then
			return nil
		else
			return pandoc.Div(para, {class=STYLE2CLASS[chap_fldeco]})
		end
	end

	-- Marking quickchapter first line deco
	if not g.quickchap_first_para_found then
		g.quickchap_first_para_found = true

		if quickchap_fldeco == "none" then
			return nil
		else
			return pandoc.Div(para, {class=STYLE2CLASS[quickchap_fldeco]})
		end
	end
end


-- Set what function will be called on what kind of Pandoc element and in which order
-- See: https://pandoc.org/lua-filters.html#typewise-traversal
return {
	{
		Meta = function(meta) g.from_meta = meta end
	},
	{
		traverse = "topdown",
		Div = function(div)
			if div.classes:find("chapter") then
				-- Return the representation of the chapter and stop processing of child nodes
				return _chapter_start_from_div(div), false
			end

			if div.classes:find("part")
			and g.current_matter == MATTER.BODY
			then
				-- Return the representation of the part and stop processing of child nodes
				return _part_start_from_div(div), false
			end
		end,
		Header = function(header) return _structure_from_headers(header) end,
		Para = function(para) return _mark_first_paragraph(para) end,
	}
}
