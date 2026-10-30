local M = {}

local defaults = {
	api_key = nil, -- o vim.env.RAE_API_KEY
	display = "float_cursor", -- "float_cursor" | "float_bottom" | "split"
	mappings = {
		definition = "<leader>rd",
		synonyms = "<leader>rs",
	},
	cache = {
		enabled = true,
		ttl = 86400, -- 24h
	},
	debounce_ms = 200, -- reservado para futuro finder dinámico
}

M.config = vim.deepcopy(defaults)
M._setup_done = false

local function word_under_cursor()
	local w = vim.fn.expand("<cword>")
	if w == nil or w == "" then
		vim.notify("rae.nvim: no hay palabra bajo el cursor", vim.log.levels.WARN)
		return nil
	end
	return w
end

local WORD = "[%wáéíóúüñÁÉÍÓÚÜÑ]"

local function word_range_at_cursor()
	local cursor = vim.api.nvim_win_get_cursor(0) -- {row1, col0}
	local row1 = cursor[1] -- 1-based
	local col0 = cursor[2] -- 0-based
	local line = vim.api.nvim_buf_get_lines(0, row1 - 1, row1, false)[1] or ""

	-- Pasamos col a 1-based para trabajar con line:sub
	local col1 = col0 + 1

	-- start1: primer carácter de la palabra (1-based, inclusivo)
	local start1 = col1
	while start1 > 1 and line:sub(start1 - 1, start1 - 1):match(WORD) do
		start1 = start1 - 1
	end

	-- end1: último carácter de la palabra (1-based, inclusivo)
	local end1 = col1
	while end1 < #line and line:sub(end1 + 1, end1 + 1):match(WORD) do
		end1 = end1 + 1
	end

	-- Convertir a lo que espera nvim_buf_set_text:
	--   start_col: 0-based inclusivo  → start1 - 1
	--   end_col:   0-based exclusivo  → end1
	return {
		buf = vim.api.nvim_get_current_buf(),
		row = row1 - 1, -- 0-based
		start_col = start1 - 1, -- 0-based inclusivo
		end_col = end1, -- 0-based exclusivo
	}
end
local function get_word_or_selection(range)
	-- Si viene de modo visual (range > 0), tomar la selección.
	if range and range > 0 then
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		local lines = vim.fn.getline(start_pos[2], end_pos[2])
		if #lines == 0 then
			return nil
		end
		-- Recortar la primera y última línea a las columnas de la selección
		lines[1] = lines[1]:sub(start_pos[3])
		lines[#lines] = lines[#lines]:sub(1, end_pos[3] - start_pos[3] + 1)
		local text = table.concat(lines, " "):gsub("^%s+", ""):gsub("%s+$", "")
		if text == "" then
			return nil
		end
		-- Si la selección tiene una sola palabra, devolverla tal cual.
		return text
	end
	return word_under_cursor()
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
	if M.config.api_key then
		vim.env.RAE_API_KEY = M.config.api_key
	end
	M._setup_done = true
end

-- Aplica defaults si el usuario nunca llamó a setup().
function M.ensure_setup()
	if not M._setup_done then
		M.setup({})
	end
end

function M.lookup_def(word, range)
	M.ensure_setup()
	word = word or get_word_or_selection(range)
	if not word then
		vim.notify("rae.nvim: no hay palabra bajo el cursor ni selección", vim.log.levels.WARN)
		return
	end

	-- Capturar el origen: si hay selección, el rango es la selección;
	-- si no, la palabra bajo el cursor.
	local origin
	if range and range > 0 then
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		origin = {
			buf = vim.api.nvim_get_current_buf(),
			row = start_pos[2] - 1,
			start_col = start_pos[3] - 1,
			end_col = end_pos[3], -- 1-based → exclusivo 0-based coincide
		}
	-- Ojo: si la selección es multilínea, esto solo reemplaza la primera línea.
	-- Para una palabra sola alcanza; para multilínea habría que hacer un
	-- reemplazo más complejo. Por ahora asumimos selección de una línea.
	else
		origin = word_range_at_cursor()
	end
	local api = require("rae.api")
	local fmt = require("rae.format")
	local def = require("rae.definition")
	api.lookup(word, M.config, function(data, err)
		if err then
			return require("rae.util").notify_error(err, word)
		end
		local lines = fmt.format_definition(data)
		def.open(lines, M.config)
	end)
end

function M.lookup_syn(word, range)
	M.ensure_setup()
	word = word or get_word_or_selection(range)
	if not word then
		vim.notify("rae.nvim: no hay palabra bajo el cursor ni selección", vim.log.levels.WARN)
		return
	end

	-- Capturar el origen: si hay selección, el rango es la selección;
	-- si no, la palabra bajo el cursor.
	local origin
	if range and range > 0 then
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		origin = {
			buf = vim.api.nvim_get_current_buf(),
			row = start_pos[2] - 1,
			start_col = start_pos[3] - 1,
			end_col = end_pos[3], -- 1-based → exclusivo 0-based coincide
		}
	-- Ojo: si la selección es multilínea, esto solo reemplaza la primera línea.
	-- Para una palabra sola alcanza; para multilínea habría que hacer un
	-- reemplazo más complejo. Por ahora asumimos selección de una línea.
	else
		origin = word_range_at_cursor()
	end

	local api = require("rae.api")
	local fmt = require("rae.format")
	local syn = require("rae.synonyms")
	api.lookup(word, M.config, function(data, err)
		if err then
			return require("rae.util").notify_error(err, word)
		end
		local entries = fmt.extract_syn_ant(data)
		if #entries == 0 then
			vim.notify("No hay sinónimos ni antónimos para '" .. word .. "'", vim.log.levels.WARN)
			return
		end
		syn.pick(entries, origin, M.config)
	end)
end

return M
