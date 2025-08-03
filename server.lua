RegisterNetEvent("reloadarea:logReload", function(name, serverId, coords)
    if type(Config) ~= "table" or not Config.WebhookEnabled or type(Config.WebhookURL) ~= "string" then return end

    local data = {
        username = "ReloadArea Logger",
        embeds = {{
            title = "Texture Reload Triggered",
            color = 65280,
            fields = {
                { name = "Player", value = name .. " [" .. serverId .. "]", inline = true },
                { name = "Position", value = ("X: %.2f, Y: %.2f, Z: %.2f"):format(coords.x, coords.y, coords.z), inline = false },
                { name = "Time", value = os.date("%Y-%m-%d %H:%M:%S"), inline = true }
            },
            footer = { text = "Texture Reload Log" }
        }}
    }

    PerformHttpRequest(Config.WebhookURL, function() end, "POST", json.encode(data), {
        ["Content-Type"] = "application/json"
    })
end)