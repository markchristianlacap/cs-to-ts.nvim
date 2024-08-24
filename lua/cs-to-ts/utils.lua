local M = {}

function M.get_visual_selection()
	-- Get the current buffer
	local bufnr = vim.api.nvim_get_current_buf()

	-- Get the start and end positions of the visual selection
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	-- Adjust the positions (Neovim API is 0-indexed, but vim.fn.getpos returns 1-indexed positions)
	local start_line = start_pos[2] - 1
	local start_col = start_pos[3] - 1
	local end_line = end_pos[2] - 1
	local end_col = end_pos[3] - 1

	-- Ensure the end column is greater than the start column
	if end_col < start_col then
		end_col = start_col
	end

	-- Get the lines within the visual selection
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)

	-- Handle single-line and multi-line selections
	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col + 1, end_col + 1)
	else
		lines[1] = string.sub(lines[1], start_col + 1)
		lines[#lines] = string.sub(lines[#lines], 1, end_col + 1)
	end

	-- Join the lines into a single string
	return table.concat(lines, "\n")
end

--function to convert string to camelCase from PascalCase
function M.to_camelcase(str)
	return str:gsub("(%u)([%w_']*)", function(first, rest)
		return first:lower() .. rest
	end)
end

function split_classes(code)
	local classes = {}
	local pattern = "public class.-%b{}"
	for class_definition in code:gmatch(pattern) do
		table.insert(classes, class_definition)
	end
	return classes
end

function M.split_classes(code)
	local classes = {}
	local pattern = "public class.-%b{}"
	for class_definition in code:gmatch(pattern) do
		table.insert(classes, class_definition)
	end
	return classes
end

return M
