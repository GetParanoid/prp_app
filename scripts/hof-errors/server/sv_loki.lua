---@diagnostic disable: undefined-global

local LokiLogger = {}


--? Shotout ox_lib for the following code.
    -- ? Function to format tags into a string suitable for Loki logging
    -- ? Intakes a table of key-value pairs and returns a formatted loki label string i.e key:value,key2:value2
local function formatTags(tagData)
	if type(tagData) ~= "table" then
		return ""
	end

	local keys = {}
	for key in pairs(tagData) do
		keys[#keys + 1] = key
	end

	table.sort(keys)

	local segments = {}

	for index = 1, #keys do
		local key = keys[index]
		local value = tagData[key]
		if value ~= nil then
			local specifier = type(value) == "number" and "%d" or "%s"
			segments[#segments + 1] = string.format("%s:" .. specifier, key, value)
		end
	end

	table.sort(segments)

	return table.concat(segments, ",")
end

local function mergeTags(base, extra)
	local merged = {}

	if type(base) == "table" then
		for key, value in pairs(base) do
			merged[key] = value
		end
	end

	if type(extra) == "table" then
		for key, value in pairs(extra) do
			merged[key] = value
		end
	end

	return merged
end

function LokiLogger.log(config, entry)
	if type(config) ~= "table" or config.enabled == false then
		return
	end

	if type(entry) ~= "table" then
		return
	end

	local tags = mergeTags(config.labels, entry.tags)
	tags.level = entry.level or tags.level or "error"

	local formattedTags = formatTags(tags)

	local source = entry.source or config.source or "hof-errors"
	local event = entry.event or "ErrorEvent"
	local message = entry.message or ""

	if formattedTags == "" then
		formattedTags = "level:error"
	end

	lib.logger(source, event, message, formattedTags)
end

return LokiLogger
