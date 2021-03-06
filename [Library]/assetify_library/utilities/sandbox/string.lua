----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: string.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: String Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    md5 = md5,
    tostring = tostring,
    tonumber = tonumber,
    loadstring = loadstring,
    string = string,
    encodeString = encodeString,
    decodeString = decodeString
}


-----------------------
--[[ Class: String ]]--
-----------------------

local string = class:create("string", utf8)
for i, j in imports.pairs(imports.string) do
    string.public[i] = (not string.public[i] and j) or string.public[i]
end
string.private.minifier = imports.md5("vStudio")

local __string_gsub = string.public.gsub
function string.public.gsub(baseString, matchWord, replaceWord, matchLimit, isStrictcMatch, matchPrefix, matchPostfix)
    if not baseString or (imports.type(baseString) ~= "string") or not matchWord or (imports.type(matchWord) ~= "string") or not replaceWord or (imports.type(replaceWord) ~= "string") then return false end
    matchPrefix, matchPostfix = (matchPrefix and (imports.type(matchPrefix) == "string") and matchPrefix) or "", (matchPostfix and (imports.type(matchPostfix) == "string") and matchPostfix) or ""
    matchWord = (isStrictcMatch and "%f[^"..matchPrefix.."%z%s]"..matchWord.."%f["..matchPostfix.."%z%s]") or matchPrefix..matchWord..matchPostfix
    return __string_gsub(baseString, matchWord, replaceWord, matchLimit)
end

function string.public.parse(baseString)
    if not baseString then return false end
    if imports.tostring(baseString) == "nil" then return
    elseif imports.tostring(baseString) == "false" then return false
    elseif imports.tostring(baseString) == "true" then return true
    else return imports.tonumber(baseString) or baseString end
end

function string.public.encode(baseString, type, options)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    return imports.encodeString(type, baseString, options)
end

function string.public.decode(baseString, type, options, clipNull)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    baseString = imports.decodeString(type, baseString, options)
    return (baseString and clipNull and string.public.gsub(baseString, string.public.char(0), "")) or baseString
end

function string.public.split(baseString, separator)
    if not baseString or (imports.type(baseString) ~= "string") or not separator or (imports.type(separator) ~= "string") then return false end
    baseString = baseString..separator
    local result = {}
    for matchValue in string.public.gmatch(baseString, "(.-)"..separator) do
        if #string.public.gsub(matchValue, "%s", "") > 0 then
            table.insert(result, matchValue)
        end
    end
    return result
end

function string.public.kern(baseString, kerner)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    return string.public.sub(string.public.gsub(baseString, ".", (kerner or " ").."%0"), 2)
end

function string.public.minify(baseString)
    if not baseString or (imports.type(baseString) ~= "string") then return false end
    local result = ""
    for i = 1, #baseString, 1 do
        result = result..(string.private.minifier)..string.public.byte(baseString, i)
    end
    return [[
    local b, __b = string.split("]]..result..[[", "]]..(string.private.minifier)..[["), ""
    for i = 1, #b, 1 do __b = __b..(string.char(b[i]) or "") end
    loadstring(__b)()
    ]]
end
