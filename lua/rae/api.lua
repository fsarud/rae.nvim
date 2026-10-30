local M = {}

local BASE = "https://rae-api.com/api"

-- NFD → NFC para los caracteres del español.
local COMBINING = {
	[0x81] = { a = "á", e = "é", i = "í", o = "ó", u = "ú", A = "Á", E = "É", I = "Í", O = "Ó", U = "Ú" },
	[0x88] = { u = "ü", U = "Ü" },
	[0x83] = { n = "ñ", N = "Ñ" },
}

function M.normalize(word)
	if not word or word == "" then
		return word
	end
	local out = {}
	local i = 1
	while i <= #word do
		local b = word:byte(i)
		if b == 0xCC and i < #word then
			local c = word:byte(i + 1)
			local prev = out[#out]
			local map = COMBINING[c]
			if map and prev and map[prev] then
				out[#out] = map[prev]
				i = i + 2
			else
				out[#out + 1] = string.char(b)
				i = i + 1
			end
		else
			out[#out + 1] = string.char(b)
			i = i + 1
		end
	end
	return table.concat(out)
end

function M.get_key(config)
	return (config and config.api_key) or vim.env.RAE_API_KEY or nil
end

function M.lookup(word, config, cb)
	local key = M.get_key(config)
	word = M.normalize(word)

	local url = string.format("%s/words/%s", BASE, vim.uri_encode(word))
	if key then
		url = url .. "?api_key=" .. vim.uri_encode(key)
	end

	local cmd = { "curl", "-s", "-H", "accept: application/json", url }

	vim.system(cmd, { text = true }, function(out)
		vim.schedule(function()
			if out.code == 127 then
				return cb(nil, { code = "CURL_ERROR", msg = "curl no está instalado o no está en el PATH" })
			end

			if out.code ~= 0 or not out.stdout or out.stdout == "" then
				return cb(nil, { code = "CURL_ERROR", msg = out.stderr or "request failed" })
			end

			local ok, decoded = pcall(vim.json.decode, out.stdout)
			if not ok or type(decoded) ~= "table" then
				return cb(nil, { code = "BAD_JSON", msg = out.stdout, status = 200 })
			end

			if decoded.ok and decoded.data then
				return cb(decoded.data, nil)
			end

			return cb(nil, {
				code = decoded.error or "HTTP_ERROR",
				msg = decoded.error or out.stdout or "unknown error",
				suggestions = decoded.suggestions,
			})
		end)
	end)
end

return M
