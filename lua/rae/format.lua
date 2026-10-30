local M = {}

local function pretty_raw(raw)
	raw = raw or ""
	raw = raw:gsub("%.Sin%.", ". Sin.: "):gsub("%.Ant%.", ". Ant.: ")
	return raw
end

--- Devuelve un array de líneas markdown.
function M.format_definition(data)
	local lines = {}
	local word = data.word or "?"

	local homonyms = {}
	for _, m in ipairs(data.meanings or {}) do
		if m.homonym_index then
			homonyms[#homonyms + 1] = m
		end
	end
	local multi = #homonyms > 1

	lines[#lines + 1] = "# " .. word
	lines[#lines + 1] = ""

	for idx, meaning in ipairs(data.meanings or {}) do
		if multi then
			lines[#lines + 1] = "## " .. word .. "^" .. (meaning.homonym_index or idx)
		end

		if meaning.origin and meaning.origin.raw and meaning.origin.raw ~= "" then
			lines[#lines + 1] = "**Etimología:** " .. meaning.origin.raw
			lines[#lines + 1] = ""
		end

		if multi then
			lines[#lines + 1] = "### Acepciones"
		else
			lines[#lines + 1] = "## Acepciones"
		end
		lines[#lines + 1] = ""

		for _, sense in ipairs(meaning.senses or {}) do
			lines[#lines + 1] = pretty_raw(sense.raw)
		end

		if meaning.locutions and #meaning.locutions > 0 then
			lines[#lines + 1] = ""
			lines[#lines + 1] = multi and "### Locuciones" or "## Locuciones"
			lines[#lines + 1] = ""
			for _, loc in ipairs(meaning.locutions) do
				for _, sense in ipairs(loc.senses or {}) do
					lines[#lines + 1] = "- **" .. loc.expression .. "**: " .. pretty_raw(sense.raw)
				end
			end
		end

		lines[#lines + 1] = ""
	end

	return lines
end

function M.extract_syn_ant(data)
	local sins, ants = {}, {}
	local seen = {}

	local meanings = type(data.meanings) == "table" and data.meanings or {}

	for _, meaning in ipairs(meanings) do
		local senses = type(meaning.senses) == "table" and meaning.senses or {}

		for _, sense in ipairs(senses) do
			local desc = sense.description or ""
			local synonyms = type(sense.synonyms) == "table" and sense.synonyms or {}
			local antonyms = type(sense.antonyms) == "table" and sense.antonyms or {}

			for _, w in ipairs(synonyms) do
				local k = "sin:" .. w
				if not seen[k] then
					seen[k] = true
					sins[#sins + 1] = { word = w, kind = "sin", source = desc }
				end
			end

			for _, w in ipairs(antonyms) do
				local k = "ant:" .. w
				if not seen[k] then
					seen[k] = true
					ants[#ants + 1] = { word = w, kind = "ant", source = desc }
				end
			end
		end
	end

	local out = {}
	for _, e in ipairs(sins) do
		out[#out + 1] = e
	end
	for _, e in ipairs(ants) do
		out[#out + 1] = e
	end
	return out
end

return M
