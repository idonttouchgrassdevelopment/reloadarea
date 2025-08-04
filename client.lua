
local teleportCoords = vector3(-1600.0, -1500.0, 0.0)
local cooldownActive = false
local cooldownSeconds = 15
local reloadDuration = 10000

RegisterCommand('reloadarea', function()
    if cooldownActive then
        lib.notify({
            title = 'Reload Area',
            description = 'Please wait for cooldown to finish.',
            type = 'error'
        })
        return
    end

    cooldownActive = true
    reloadAreaTextures()

    CreateThread(function()
        Wait(cooldownSeconds * 1000)
        cooldownActive = false
        lib.notify({
            title = 'Reload Area',
            description = 'Cooldown expired. You can reload textures again.',
            type = 'inform'
        })
    end)
end)

RegisterKeyMapping('reloadarea', 'Reload Nearby Textures (Client-Side Keybind)', 'keyboard', '')

function reloadAreaTextures()
    local ped = PlayerPedId()
    local originalCoords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    optimizeClientTextures()

    SetEntityCoordsNoOffset(ped, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false)
    SetEntityHeading(ped, 180.0)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    DisplayRadar(false)

    lib.notify({
        title = 'Reload Area',
        description = 'Refreshing textures... Please wait.',
        type = 'inform'
    })

    Wait(reloadDuration)

    RequestCollisionAtCoord(originalCoords)
    local interior = GetInteriorAtCoords(originalCoords)
    if interior ~= 0 then RefreshInterior(interior) end

    for i = 1, 15 do
        RequestCollisionAtCoord(originalCoords)
        Wait(200)
    end

    local attempts = 0
    while not HasCollisionLoadedAroundEntity(ped) and attempts < 30 do
        RequestCollisionAtCoord(originalCoords)
        Wait(250)
        attempts += 1
    end

    SetEntityCoordsNoOffset(ped, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
    SetEntityHeading(ped, heading)
    Wait(1000)

    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)
    DisplayRadar(true)

    lib.notify({
        title = 'Reload Area',
        description = 'Textures refreshed and optimized.',
        type = 'success'
    })

    -- sendWebhookLog(originalCoords)
end

function optimizeClientTextures()
    SetReducePedModelBudget(true)
    SetReduceVehicleModelBudget(true)

    ClearFocus()
    ClearHdArea()
    ClearAllBrokenGlass()
    ClearTimecycleModifier()
    SetTimecycleModifier("neutral")
    SetTimecycleModifierStrength(0.0)

    TriggerEvent("graphics:flush")

    Wait(300)

    SetReducePedModelBudget(false)
    SetReduceVehicleModelBudget(false)
end

function sendWebhookLog(coords)
    local webhookUrl = "https://yourwebhookurl.com" -- Replace with actual webhook URL
    local name = GetPlayerName(PlayerId())
    local serverId = GetPlayerServerId(PlayerId())

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

    PerformHttpRequest(webhookUrl, function() end, "POST", json.encode(data), {
        ["Content-Type"] = "application/json"
    })
end
