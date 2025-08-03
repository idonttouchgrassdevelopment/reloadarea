local teleportCoords = vec3(-2083.26, -1019.12, 15.99)
local cooldownActive = false
local cooldownSeconds = 45
local reloadDuration = 5000

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

    SetEntityVisible(ped, false, false)
    SetEntityCoordsNoOffset(ped, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false)
    SetEntityHeading(ped, 180.0)
    FreezeEntityPosition(ped, true)
    DisplayRadar(false)

    lib.notify({
        title = 'Reload Area',
        description = 'Refreshing textures... Please wait.',
        type = 'inform'
    })

    CreateThread(function()
        local endTime = GetGameTimer() + reloadDuration
        while GetGameTimer() < endTime do
            HideHudComponentThisFrame(0)
            HideHudComponentThisFrame(1)
            HideHudComponentThisFrame(2)
            HideHudComponentThisFrame(3)
            HideHudComponentThisFrame(4)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(9)
            HideHudComponentThisFrame(13)
            HideHudComponentThisFrame(14)
            HideHudComponentThisFrame(17)
            HideHudComponentThisFrame(20)
            DisableAllControlActions(0)
            Wait(0)
        end
    end)

    Wait(reloadDuration)

    RequestCollisionAtCoord(originalCoords)
    SetEntityCoordsNoOffset(ped, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
    SetEntityHeading(ped, heading)
    SetEntityVisible(ped, true, false)

    for i = 1, 5 do
        RequestCollisionAtCoord(originalCoords)
        Wait(300)
    end

    ClearFocus()
    SetFocusPosAndVel(originalCoords.x, originalCoords.y, originalCoords.z, 0.0, 0.0, 0.0)

    local interior = GetInteriorAtCoords(originalCoords.x, originalCoords.y, originalCoords.z)
    if interior ~= 0 then RefreshInterior(interior) end

    FreezeEntityPosition(ped, false)
    DisplayRadar(true)

    lib.notify({
        title = 'Reload Area',
        description = 'Textures refreshed and optimized.',
        type = 'success'
    })

    sendWebhookLog(originalCoords)
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
    if not Config.WebhookEnabled then return end

    local name = GetPlayerName(PlayerId())
    local serverId = GetPlayerServerId(PlayerId())

    function sendWebhookLog(coords)
    if not Config.WebhookEnabled then return end

    local name = GetPlayerName(PlayerId())
    local serverId = GetPlayerServerId(PlayerId())

    TriggerServerEvent("reloadarea:logReload", name, serverId, coords)
end
    local data = {
        username = "Reload Area Log",
        embeds = {
            {
                title = "Area Reloaded",
                description = string.format("Player: **%s**\nServer ID: **%s**\nCoordinates: **X: %.2f, Y: %.2f, Z: %.2f**", name, serverId, coords.x, coords.y, coords.z),
                color = 16711680,
                footer = {
                    text = "Reload Area Script"
                }
            }
        }
    }

    PerformHttpRequest(Config.WebhookURL, function() end, "POST", json.encode(data), {
        ["Content-Type"] = "application/json"
    })
end
