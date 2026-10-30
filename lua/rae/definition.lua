local M = {}

local ns = vim.api.nvim_create_namespace("rae_definition")

local function close_win(win)
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
end

local function make_buffer(lines)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"
	vim.keymap.set("n", "q", function()
		close_win(vim.api.nvim_get_current_win())
	end, { buffer = buf, nowait = true, silent = true })
	return buf
end

local function word_range_under_cursor()
	local cword = vim.fn.expand("<cword>")
	if cword == "" then
		return nil
	end
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	local start = col
	while start > 1 and line:sub(start - 1, start - 1):match("[%wáéíóúüñÁÉÍÓÚÜÑ]") do
		start = start - 1
	end
	local finish = col
	while finish <= #line and line:sub(finish, finish):match("[%wáéíóúüñÁÉÍÓÚÜÑ]") do
		finish = finish + 1
	end
	return { buf = vim.api.nvim_get_current_buf(), srow = vim.fn.line(".") - 1, scol = start - 1, ecol = finish - 1 }
end

local function attach_close_on_leave(win, range)
	if not range then
		return
	end
	local group = vim.api.nvim_create_augroup("RaeDefClose_" .. win, { clear = true })
	-- defer para no cerrar en el mismo tick
	vim.defer_fn(function()
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" }, {
			group = group,
			callback = function()
				if not vim.api.nvim_win_is_valid(win) then
					pcall(vim.api.nvim_del_augroup_by_id, group)
					return
				end
				local cur = vim.api.nvim_win_get_cursor(0)
				local row, col = cur[1] - 1, cur[2]
				local inside = vim.api.nvim_get_current_buf() == range.buf
					and row == range.srow
					and col >= range.scol
					and col < range.ecol
				if not inside then
					close_win(win)
					pcall(vim.api.nvim_del_augroup_by_id, group)
				end
			end,
		})
	end, 50)
end

local function open_float_cursor(lines, buf)
	local width = math.min(80, vim.o.columns - 4)
	local height = math.min(#lines, 20)
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})
	return win
end

local function open_float_bottom(lines, buf)
	local width = math.min(100, vim.o.columns - 6)
	local height = math.min(#lines, 20)
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		row = vim.o.lines - height - 3,
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})
	return win
end

local function open_split(lines, buf)
	vim.cmd("botright new")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	local height = math.max(3, math.floor(vim.o.lines * 0.2))
	vim.cmd("resize " .. height)

	return win
end

function M.open(lines, config)
	config = config or {}
	local mode = config.display or "float_cursor"
	local range = word_range_under_cursor()
	local buf = make_buffer(lines)

	local win
	if mode == "split" then
		win = open_split(lines, buf)
	elseif mode == "float_bottom" then
		win = open_float_bottom(lines, buf)
		attach_close_on_leave(win, range)
	else
		win = open_float_cursor(lines, buf)
		attach_close_on_leave(win, range)
	end
	return win
end

return M
