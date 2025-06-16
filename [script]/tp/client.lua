-- Teleport to Waypoint when set on the pause map
local lastCoords = vector3(0.0, 0.0, 0.0)

local function distance(a, b)
    local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function findGroundZ(x, y, z)
    print(string.format("Finding ground Z at (%.2f, %.2f, %.2f)", x, y, z))
    RequestCollisionAtCoord(x, y, z)
    local ground, groundZ = GetGroundZFor_3dCoord(x, y, z, 0.0)
    if ground then
        print(string.format("Ground found at Z = %.2f", groundZ))
        return groundZ
    end
    for height = 1000.0, 0.0, -25.0 do
        local found
        RequestCollisionAtCoord(x, y, height)
        found, groundZ = GetGroundZFor_3dCoord(x, y, height, 0.0)
        if found then
            print(string.format("Ground found at height %.2f, Z = %.2f", height, groundZ))
            return groundZ
        end
        Citizen.Wait(0)
    end
    print("Ground not found, using original Z")
    return z
end

local function teleportToWaypoint(coords)
    print(string.format("Teleporting to waypoint at (%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
    local groundZ = findGroundZ(coords.x, coords.y, coords.z)
    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, coords.x, coords.y, groundZ + 1.0)
    print(string.format("Teleported to (%.2f, %.2f, %.2f)", coords.x, coords.y, groundZ + 1.0))
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if IsPauseMenuActive() and IsWaypointActive() then
            local blip = GetFirstBlipInfoId(8)
            if DoesBlipExist(blip) then
                local coord = GetBlipInfoIdCoord(blip)
                if distance(coord, lastCoords) > 1.0 then
                    print("New waypoint detected, teleporting...")
                    teleportToWaypoint(coord)
                    lastCoords = coord
                end
            end
        end
    end
end)