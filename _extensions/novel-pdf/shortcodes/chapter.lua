local utils = require "../utils"

-- DEPRECATED
function chapter(args, kwargs, meta)
    -- Retreive parameters or get default from meta
    local chapter_name = pandoc.utils.stringify(args[1])
    local lines_before = pandoc.utils.stringify(kwargs.lines_before[1] or meta.chapters.title.lines_before[1])

    return utils.create_chapter(chapter_name, lines_before)
end

-- DEPRECATED
function quickchapter(args, kwargs, meta)
    -- Retreive parameters or get default from meta
    local chapter_name = pandoc.utils.stringify(args[1])
    local line = pandoc.utils.stringify(kwargs.line[1] or meta.chapters.quick.line[1])

    return utils.create_quickchapter(chapter_name, line)
end
