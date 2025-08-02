local teleportCoords = vector3(-1600.0, -1500.0, 0.0) -- Unload zone
local cooldownActive = false
local cooldownSeconds = 45

-- Register command for texture reloading
RegisterCommand('reloadarea', function()
    if cooldownActive then
        TriggerEvent('chat:addMessage', {
            color = {255, 50, 50},
            args = { '[ReloadArea]', 'Please wait for cooldown to finish.' }
        })
        return
    end

    cooldownActive = true
    reloadAreaTextures()

    -- Start cooldown
    CreateThread(function()
        Wait(cooldownSeconds * 1000)
        cooldownActive = false
        TriggerEvent('chat:addMessage', {
            color = {50, 255, 50},
            args = { '[ReloadArea]', 'Cooldown expired. You can reload textures again.' }
        })
    end)
end, false)

-- Register key mapping (no default key — fully customizable)
RegisterKeyMapping('reloadarea', 'Textures Reload', 'keyboard', '')

-- Main logic
function reloadAreaTextures()
    local ped = PlayerPedId()
    local originalCoords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    -- Fade out
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(50) end

    -- Step 1: Move to beach
    RequestCollisionAtCoord(teleportCoords)
    SetEntityCoordsNoOffset(ped, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false)
    FreezeEntityPosition(ped, true)
    LoadScene(teleportCoords.x, teleportCoords.y, teleportCoords.z)
    Wait(2000)

    -- Step 2: Return to original position
    RequestCollisionAtCoord(originalCoords)
    SetEntityCoordsNoOffset(ped, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
    SetEntityHeading(ped, heading)

    -- Force streaming
    for i = 1, 5 do
        RequestCollisionAtCoord(originalCoords)
        Wait(300)
    end

    ClearFocus()
    SetFocusPosAndVel(originalCoords.x, originalCoords.y, originalCoords.z, 0.0, 0.0, 0.0)

    local interior = GetInteriorAtCoords(originalCoords.x, originalCoords.y, originalCoords.z)
    if interior ~= 0 then RefreshInterior(interior) end

    FreezeEntityPosition(ped, false)
    Wait(1000)
    DoScreenFadeIn(800)

    -- Chat notify
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = { '[ReloadArea]', 'Textures have been refreshed successfully.' }
    })
end
