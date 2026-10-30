-- lua/rae/synonyms.lua
local M = {}

--- Abre el picker de sinónimos/antónimos.
--- @param entries table[]  Lista de { word=string, kind="sin"|"ant", source=string }
--- @param origin table     { buf=bufnr, row=int(0-based), start_col=int(0-based), end_col=int(0-based, exclusivo) }
--- @param config table     Config de rae.nvim (no se usa por ahora, reservado)
function M.pick(entries, origin, config)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "RAE: sinónimos / antónimos",
			-- Redimensionar la ventana para que sea compacta
			layout_strategy = "vertical", -- o "horizontal"
			layout_config = {
				width = 0.4, -- 40% del ancho de la pantalla
				height = 0.4, -- 40% del alto de la pantalla
				prompt_position = "top",
			},
			sorting_strategy = "ascending",
			finder = finders.new_table({
				results = entries,
				entry_maker = function(e)
					return {
						value = e,
						display = string.format("[%s] %s", e.kind, e.word),
						ordinal = e.word,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),

			attach_mappings = function(prompt_bufnr, _map)
				actions.select_default:replace(function()
					local sel = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					if not sel then
						return
					end

					if not (origin and vim.api.nvim_buf_is_valid(origin.buf)) then
						vim.notify("rae.nvim: el buffer original ya no existe", vim.log.levels.WARN)
						return
					end

					vim.api.nvim_buf_set_text(
						origin.buf,
						origin.row,
						origin.start_col,
						origin.row,
						origin.end_col,
						{ sel.value.word }
					)
				end)
				return true
			end,
		})
		:find()
end
return M
