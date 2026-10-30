-- ~/proyectos/rae.nvim/plugin/rae.lua
if vim.g.loaded_rae then
	return
end
vim.g.loaded_rae = true

vim.api.nvim_create_user_command("RAESin", function(args)
	require("rae").lookup_syn(args.args ~= "" and args.args or nil, args.range)
end, { nargs = "?", range = true, desc = "RAE: sinónimos/antónimos", force = true })

vim.api.nvim_create_user_command("RAEDef", function(args)
	require("rae").lookup_def(args.args ~= "" and args.args or nil, args.range)
end, { nargs = "?", range = true, desc = "RAE: definición de la palabra", force = true })
