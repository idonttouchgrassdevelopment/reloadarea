RegisterCommand("reloadarea", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local radius = 100.0 -- You can adjust this radius

    -- Notify user
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        args = {"[ReloadArea]", "Refreshing textures and streaming assets..."}
    })

    -- Clear visual artifacts (props, particles, decals)
    ClearAreaOfEverything(coords.x, coords.y, coords.z, radius, false, false, false, false)

    -- Force unloading and reloading map content
    ClearFocus()
    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    LoadScene(coords.x, coords.y, coords.z)

    -- Force interior refresh
    local interior = GetInteriorAtCoords(coords.x, coords.y, coords.z)
    if interior ~= 0 then
        RefreshInterior(interior)
    end

    -- Refresh weather-based visuals
    SetForcePedFootstepsTracks(false)
    SetForceVehicleTrails(false)
    Citizen.Wait(100)
    SetForcePedFootstepsTracks(true)
    SetForceVehicleTrails(true)

    -- Force texture re-stream
    Citizen.Wait(500)
    RemoveDecalsInRange(coords.x, coords.y, coords.z, radius)
    Citizen.Wait(200)

    -- Force reload LODs and props
    SetEntityCoordsNoOffset(playerPed, coords.x + 0.01, coords.y + 0.01, coords.z, false, false, false)
    Citizen.Wait(250)
    SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, false)

    -- Done
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = {"[ReloadArea]", "Textures and streaming data reloaded!"}
    })
end, false)
