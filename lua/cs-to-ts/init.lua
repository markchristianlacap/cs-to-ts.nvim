local M = {
	maps = {
		["string"] = "string",
		["bool"] = "boolean",
		["int"] = "number",
		["uint"] = "number",
		["long"] = "number",
		["ulong"] = "number",
		["float"] = "number",
		["double"] = "number",
		["DateTime"] = "Date",
		["DateTimeOffset"] = "Date",
		["TimeSpan"] = "number",
		["Guid"] = "string",
		["object"] = "any",
	},
	ignores = {
		"class",
		"void",
		"async",
		"static",
		"Task",
	},
}
local function className(str)
	return str:match("public class%s+(%w+)%s*")
end

local extendedClass = function(str)
	local _, class = str:match("public class%s+(%w+)%s+:%s+(%w+)%s*")
	return class
end
local function shouldIgnore(name, type)
	for _, str in ipairs(M.ignores) do
		if str == name or str == type then
			return true
		end
	end
	return false
end
local function isNullable(str)
	return string.find(str, "?")
end
-- get properties from class and map to {name, type, nullable}
local function getProperties(str)
	local properties = {}
	for type, name in str:gmatch("public%s+([%w?]+)%s*([%w]+)%s*") do
		-- check if needs to ignore
		if shouldIgnore(name, type) then
			goto next
		end
		local nullable = isNullable(type)
		type = string.gsub(type, "%?", "")
		table.insert(properties, { name = name, type = type, nullable = nullable })
		::next::
	end
	return properties
end

function M.convert(str)
	local class = className(str)
	local extended = extendedClass(str)
	local interface = "export interface " .. class
	if not extended == nil then
		interface = interface .. " : " .. extended
	end
	interface = interface .. " {"
	for _, prop in ipairs(getProperties(str)) do
		interface = interface .. "\n  " .. prop.name
		if prop.nullable then
			interface = interface .. "?"
		end
		interface = interface .. ": " .. (M.maps[prop.type] or prop.type)
	end
	interface = interface .. "\n}"
	return interface
end

return M
