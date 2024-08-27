local utils = require("cs-to-ts.utils")
local M = {
  maps = {
    ["string"] = "string",
    ["bool"] = "boolean",
    ["int"] = "number",
    ["uint"] = "number",
    ["long"] = "number",
    ["ulong"] = "number",
    ["float"] = "number",
    ["decimal"] = "number",
    ["double"] = "number",
    ["DateTime"] = "string",
    ["DateTimeOffset"] = "string",
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
  camel_case = true,
}
local function class_name(str)
  return str:match("public class%s+(%w+)%s*")
end

local extended_class = function(str)
  local _, class = str:match("public class%s+(%w+)%s+:%s+(%w+)%s*")
  return class
end
local function should_ignore(name, type)
  for _, str in ipairs(M.ignores) do
    if str == name or str == type then
      return true
    end
  end
  return false
end
local function is_nullable(str)
  return string.find(str, "?")
end
-- get properties from class and map to {name, type, nullable}
local function get_properties(str)
  local properties = {}
  for type, name in str:gmatch("public%s+([^%s]+)%s+([^%s]+)%s*") do
    -- check if needs to ignore
    if should_ignore(name, type) then
      goto next
    end
    -- if type contains new
    if string.find(type, "new") then
      type, name = str:match("public%s+new%s+(%w+<%w+>)%s+(%w+)%s*{")
    end
    local list_type = string.match(type, "List<(.+)>")
        or string.match(type, "IEnumerable<(.+)>")
        or string.match(type, "IList<(.+)>")
    if list_type ~= nil then
      type = list_type .. "[]"
    end

    local nullable = is_nullable(type)
    type = string.gsub(type, "%?", "")
    if M.camel_case then
      name = utils.to_camelcase(name)
    end
    table.insert(properties, { name = name, type = type, nullable = nullable })
    ::next::
  end
  return properties
end

local function generate_interface(class_code)
  local class = class_name(class_code)
  if class == nil then
    return nil
  end
  local extended = extended_class(class_code)
  local interface = "export interface " .. class
  if extended ~= nil then
    interface = interface .. " extends " .. extended
  end
  interface = interface .. " {"
  for _, prop in ipairs(get_properties(class_code)) do
    interface = interface .. "\n  " .. prop.name
    if prop.nullable then
      interface = interface .. "?"
    end
    interface = interface .. ": " .. (M.maps[prop.type] or prop.type)
  end
  interface = interface .. "\n}"
  return interface
end

function M.convert(code)
  local classes = utils.split_classes(code)
  local interfaces = {}
  for _, class in ipairs(classes) do
    table.insert(interfaces, generate_interface(class))
  end
  return table.concat(interfaces, "\n\n")
end

return M
