local M = {}

function M.getSelected()
	-- Save the current mode
	local current_mode = vim.fn.mode()
	-- If not in visual mode, return empty
	if current_mode ~= "v" and current_mode ~= "V" and current_mode ~= "<C-v>" then
		return ""
	end

	-- Get the start and end positions of the visual selection
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2]
	local start_col = start_pos[3]
	local end_line = end_pos[2]
	local end_col = end_pos[3]

	-- Get the lines in the visual selection
	local lines = vim.fn.getline(start_line, end_line)

	-- If only one line is selected, slice it
	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col)
	else
		-- For the first line, slice from the start column
		lines[1] = string.sub(lines[1], start_col)
		-- For the last line, slice up to the end column
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end
end

function M.findCsproj()
	local current_dir = vim.fn.expand("%:p:h") -- Get the current directory
	local parent_dir = current_dir
	while parent_dir ~= "" do
		local csproj_files = vim.fn.readdir(parent_dir)
		for _, file in ipairs(csproj_files) do
			if file:match("%.csproj$") then
				return parent_dir .. "/" .. file
			end
		end
		parent_dir = vim.fn.fnamemodify(parent_dir, ":h") -- Move to the parent directory
	end
	return nil -- If no .csproj file is found -- If no .csproj file is found
end

-- Function to generate the namespace based on the project structure
function M.generate()
	-- Find the nearest .csproj file
	local csproj_path = M.findCsproj()
	if csproj_path then
		-- Extract project name from .csproj file
		local project_name = vim.fn.fnamemodify(csproj_path, ":t:r")

		-- Get the full path of the current file
		local current_file = vim.fn.expand("%:p")

		-- Get the directory of the .csproj file
		local project_dir = vim.fn.fnamemodify(csproj_path, ":h")

		-- Get the relative path from the project root
		local relative_path = vim.fn.fnamemodify(current_file, ":~:.")

		-- Convert relative path to namespace format
		local namespace = string.gsub(relative_path, "/", ".") -- Replace slashes with dots
		namespace = string.gsub(namespace, "^%./", "") -- Remove leading './'
		namespace = string.gsub(namespace, "/%.", ".") -- Remove intermediate './'
		namespace = string.gsub(namespace, "/$", "") -- Remove trailing '/'
		namespace = string.gsub(namespace, "^.-%.", "") -- Remove leading folders up to and including 'Api.'

		-- Remove '.cs' extension
		namespace = string.gsub(namespace, ".cs$", "")

		-- Combine project name and namespace
		local full_namespace = project_name .. "." .. namespace
		return full_namespace
	else
		-- If no .csproj file is found, return nil
		return nil
	end
end

return M
