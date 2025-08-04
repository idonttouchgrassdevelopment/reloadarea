-- Function to reload area via teleporting to beach
function ReloadArea()
    local playerPed = PlayerPedId()
    local originalPos = GetEntityCoords(playerPed)
    local beachCoords = vector3(-1600.0, -1045.0, 13.0)

    -- Cooldown check
    if ReloadAreaCooldown and (GetGameTimer() < ReloadAreaCooldown) then
        local remaining = math.ceil((ReloadAreaCooldown - GetGameTimer()) / 1000)
        lib.notify({
            title = 'Reload Area',
            description = ('Please wait %d seconds before using again.'):format(remaining),
            type = 'error'
        })
        return
    end

    -- Set cooldown
    ReloadAreaCooldown = GetGameTimer() + (Config.ReloadAreaCooldown or 30000)

    -- Fade out screen
    DoScreenFadeOut(1000)
    Wait(1000)

    -- Teleport to beach
    SetEntityCoordsNoOffset(playerPed, beachCoords.x, beachCoords.y, beachCoords.z, false, false, false)
    RequestCollisionAtCoord(beachCoords.x, beachCoords.y, beachCoords.z)
    ClearAreaOfObjects(beachCoords.x, beachCoords.y, beachCoords.z, 50.0, false)

    -- Make player invisible
    SetEntityVisible(playerPed, false, false)

    -- Progress bar (ox_lib)
    local finished = lib.progressBar({
        duration = 3000,
        label = 'Reloading area...',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, combat = true }
    })

    -- Wait and clear area assets
    Wait(1000)
    ClearAreaOfEverything(beachCoords.x, beachCoords.y, beachCoords.z, 50.0, false, false, false, false)

    -- Wait to simulate asset cleanup
    Wait(2000)

    -- Teleport back to original position
    SetEntityCoordsNoOffset(playerPed, originalPos.x, originalPos.y, originalPos.z, false, false, false)
    RequestCollisionAtCoord(originalPos.x, originalPos.y, originalPos.z)
    ClearAreaOfObjects(originalPos.x, originalPos.y, originalPos.z, 50.0, false)

    -- Prevent texture issues: force asset and collision loading
    for i = 1, 30 do
        RequestCollisionAtCoord(originalPos.x, originalPos.y, originalPos.z)
        RequestAdditionalCollisionAtCoord(originalPos.x, originalPos.y, originalPos.z)
        -- Force loading map tiles
        SetFocusPosAndVel(originalPos.x, originalPos.y, originalPos.z, 0.0, 0.0, 0.0)
        -- Wait a bit to allow streaming
        Wait(50)
        if HasCollisionLoadedAroundEntity(playerPed) then
            break
        end
    end
    ClearFocus()

    -- Make player visible again
    SetEntityVisible(playerPed, true, false)

    -- Wait and fade in
    Wait(1000)
    DoScreenFadeIn(1000)

    -- Notify player with ox_lib notification
    lib.notify({
        title = 'Reload Area',
        description = 'Textures and environment reloaded.',
        type = 'success'
    })
end

-- Command
RegisterCommand("reloadarea", function()
    ReloadArea()
end, false)

-- Chat suggestion
TriggerEvent('chat:addSuggestion', '/reloadarea', 'Teleports you to a beach temporarily to reload area textures')

-- Keybind (F5)
-- The code you have already achieves the goal: it teleports the player to a beach, clears the area to force texture/asset reload, waits, and then teleports the player back. 
-- If you want to further ensure textures are reloaded, you can add a call to RequestCollisionAtCoord and ClearAreaOfObjects for extra asset cleanup.

-- Example: Add after teleporting to the beach
RequestCollisionAtCoord(beachCoords.x, beachCoords.y, beachCoords.z)
ClearAreaOfObjects(beachCoords.x, beachCoords.y, beachCoords.z, 50.0, false)

-- And after teleporting back to the original position
RequestCollisionAtCoord(originalPos.x, originalPos.y, originalPos.z)
ClearAreaOfObjects(originalPos.x, originalPos.y, originalPos.z, 50.0, false)
