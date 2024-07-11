local M = {}
local function to_camel(str)
  if #str == 0 then
    return str
  end
  return str:sub(1, 1):lower() .. str:sub(2)
end
-- Utility function to split strings
local function split(str, delim)
  local result = {}
  local pattern = string.format("([^%s]+)", delim)
  string.gsub(str, pattern, function(c)
    result[#result + 1] = c
  end)
  return result
end
local function is_nullable(type)
  return string.find(type, "%?$") ~= nil
end

-- Function to map C# types to TypeScript types
local function map_type(type)
  type = type:gsub("%?$", "")
  local types = {
    ["int"] = "number",
    ["float"] = "number",
    ["double"] = "number",
    ["bool"] = "boolean",
    ["string"] = "string",
    ["Guid"] = "string",
    ["DateTime"] = "Date",
    ["DateOnly"] = "Date",
    -- Add more types as needed
  }
  return types[type] or type
end

-- Function to parse a C# class definition
local function parse_class(class)
  local lines = split(class, "\n")
  local class_name = ""
  local properties = {}

  for _, line in ipairs(lines) do
    line = line:match("^%s*(.-)%s*$") -- Trim whitespace

    if string.find(line, "^public class") then
      class_name = string.match(line, "public class (%w+)")
    elseif string.find(line, "^public") then
      local method = string.find(line, "%(")
      local readonly = string.find(line, "=>")
      if not method or readonly then
        local type, name = line:match("^public ([%w_:%.<>?]+)%s+([%w_:%.]+)")
        name = to_camel(name)
        local nullable = is_nullable(type)
        type = map_type(type)
        if nullable then
          name = name .. "?"
        end
        properties[#properties + 1] = { name = name, type = type, nullable = nullable }
      end
    end
  end

  return class_name, properties
end

-- Function to generate TypeScript interface
local function generate_interface(class, props)
  local interface = "export interface " .. class .. " {\n"

  for _, prop in ipairs(props) do
    local type = prop.type
    if prop.nullable then
      type = type .. " | null"
    end
    interface = interface .. "    " .. prop.name .. ": " .. type .. ";\n"
  end

  interface = interface .. "}\n"
  return interface
end

-- Main function to convert C# class to TypeScript interface
function M.convert_cs_to_ts(csharpClass)
  local class, props = parse_class(csharpClass)
  return generate_interface(class, props)
end

return M
