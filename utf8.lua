-- UTF-8 helper functions for proper Chinese text handling
local utf8 = {}

-- Convert UTF-8 string to codepoints
function utf8.codepoints(str)
    local codepoints = {}
    local i = 1
    while i <= #str do
        local byte = string.byte(str, i)
        local codepoint
        local length

        if byte < 128 then
            -- ASCII character
            codepoint = byte
            length = 1
        elseif byte < 224 then
            -- 2-byte UTF-8
            codepoint = (byte - 192) * 64 + (string.byte(str, i + 1) - 128)
            length = 2
        elseif byte < 240 then
            -- 3-byte UTF-8 (most Chinese characters)
            local b2 = string.byte(str, i + 1)
            local b3 = string.byte(str, i + 2)
            codepoint = (byte - 224) * 4096 + (b2 - 128) * 64 + (b3 - 128)
            length = 3
        else
            -- 4-byte UTF-8
            local b2 = string.byte(str, i + 1)
            local b3 = string.byte(str, i + 2)
            local b4 = string.byte(str, i + 3)
            codepoint = (byte - 240) * 262144 + (b2 - 128) * 4096 + (b3 - 128) * 64 + (b4 - 128)
            length = 4
        end

        table.insert(codepoints, codepoint)
        i = i + length
    end

    return codepoints
end

-- Get length of UTF-8 string in characters (not bytes)
function utf8.len(str)
    local length = 0
    local i = 1
    while i <= #str do
        local byte = string.byte(str, i)
        if byte < 128 then
            i = i + 1
        elseif byte < 224 then
            i = i + 2
        elseif byte < 240 then
            i = i + 3
        else
            i = i + 4
        end
        length = length + 1
    end
    return length
end

-- Substring for UTF-8 strings
function utf8.sub(str, start, finish)
    local chars = {}
    local i = 1
    local charIndex = 1

    while i <= #str do
        local byte = string.byte(str, i)
        local length

        if byte < 128 then
            length = 1
        elseif byte < 224 then
            length = 2
        elseif byte < 240 then
            length = 3
        else
            length = 4
        end

        if charIndex >= start and (not finish or charIndex <= finish) then
            table.insert(chars, string.sub(str, i, i + length - 1))
        end

        i = i + length
        charIndex = charIndex + 1

        if finish and charIndex > finish then
            break
        end
    end

    return table.concat(chars)
end

return utf8