local enum_converter = require("cs-to-ts.enum")
local class_converter = require("cs-to-ts.class")
local M = {}

function M.convert(csharp_code)
  local ts_code = ""
  local class_name = csharp_code:match("class%s+(%w+)")
  local enum_name = csharp_code:match("enum%s+(%w+)")

  if class_name then
    ts_code = class_converter.convert_cs_to_ts(csharp_code)
  elseif enum_name then
    ts_code = enum_converter.convertCsToTSEnum(csharp_code)
  else
    return nil, "No valid class or enum found"
  end

  return ts_code
end

function M.get_selected_text()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, "\n")
end

return M
