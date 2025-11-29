---@diagnostic disable: undefined-global

local Logger = {}

local queue = {}
local processing = false
local rateLimitMs = 2000


local function jsonEncode(payload)
    local ok, encoded = pcall(json.encode, payload)
    if ok and encoded then
        return encoded
    end

    return "{}"
end

local function processQueue()
    local entry = table.remove(queue, 1)
    if not entry then
        processing = false
        return
    end

    if type(entry.webhook) ~= "string" or entry.webhook == "" then
        processQueue()
        return
    end

    processing = true

    local body = jsonEncode(entry.payload)

    PerformHttpRequest(entry.webhook, function()
        if #queue == 0 then
            processing = false
            return
        end

        SetTimeout(rateLimitMs, processQueue)
    end, 'POST', body, {
        ['Content-Type'] = 'application/json'
    })
end

function Logger.log(config, entry)
    if type(entry) ~= "table" then
        return
    end

    config = config or {}

    if type(config.rateLimitMs) == "number" and config.rateLimitMs > 0 then
        rateLimitMs = math.floor(config.rateLimitMs)
    end

    local webhook = entry.webhook or config.webhook
    if type(webhook) ~= "string" or webhook == "" then
        return
    end

    local embed = entry.embed or {
        title = entry.event or "Server Log",
        description = entry.message or "",
        color = entry.color,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }

    if entry.source then
        embed.footer = embed.footer or {
            text = string.format("Source: %s", entry.source)
        }
    end

    local payload = {
        username = entry.username or config.username or "Logger",
        avatar_url = entry.avatarUrl or config.avatarUrl,
        content = entry.content,
        embeds = entry.embeds or { embed }
    }

    queue[#queue + 1] = {
        webhook = webhook,
        payload = payload
    }

    if not processing then
        processQueue()
    end
end

function Logger.setRateLimit(ms)
    if type(ms) ~= "number" or ms <= 0 then
        return
    end

    rateLimitMs = math.floor(ms)
end

function Logger.queueSize()
    return #queue
end

return Logger
