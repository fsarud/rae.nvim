local M = {}

local FRIENDLY = {
	NOT_FOUND = "palabra no encontrada",
	MISSING_KEY = "falta la API key (configurá RAE_API_KEY o setup({ api_key = ... }))",
	INVALID_API_KEY = "API key inválida",
	RATE_LIMITED = "límite de consultas alcanzado",
	CURL_ERROR = "no se pudo conectar con rae-api.com",
	BAD_JSON = "respuesta inválida de la API",
}

function M.notify_error(err, word)
	local msg = FRIENDLY[err.code] or err.code or "error desconocido"
	if err.code == "NOT_FOUND" and err.suggestions and #err.suggestions > 0 then
		msg = string.format("'%s' no existe. ¿Quisiste decir '%s'?", word, err.suggestions[1])
	elseif word then
		msg = string.format("rae.nvim (%s): %s", word, msg)
	else
		msg = "rae.nvim: " .. msg
	end
	vim.notify(msg, vim.log.levels.WARN)
end

return M
