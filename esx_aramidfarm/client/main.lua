ESX = nil
local PlayerData = {}
local farmZones = {}
local isFarming = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
    initializeFarmZones()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

function initializeFarmZones()
    for farmName, farmData in pairs(Config.FarmZones) do
        local zone = {
            name = farmName,
            blip = nil,
            points = {},
            data = farmData
        }

        -- Create a central blip
        if farmData.Blip then
            zone.blip = AddBlipForCoord(farmData.Pos.x, farmData.Pos.y, farmData.Pos.z)
            SetBlipSprite(zone.blip, farmData.Blip.Sprite)
            SetBlipDisplay(zone.blip, farmData.Blip.Display)
            SetBlipScale(zone.blip, farmData.Blip.Scale)
            SetBlipColour(zone.blip, farmData.Blip.Colour)
            SetBlipAsShortRange(zone.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(farmData.Blip.Name)
            EndTextCommandSetBlipName(zone.blip)
        end

        -- Generate farm points in a grid
        local numPoints = farmData.FarmPoints.Count
        local distance = farmData.FarmPoints.Distance
        local pointsPerRow = math.ceil(math.sqrt(numPoints))

        for i = 0, numPoints - 1 do
            local row = math.floor(i / pointsPerRow)
            local col = i % pointsPerRow
            local x_offset = (col - (pointsPerRow / 2)) * distance
            local y_offset = (row - (pointsPerRow / 2)) * distance

            table.insert(zone.points, {
                pos = {
                    x = farmData.Pos.x + x_offset,
                    y = farmData.Pos.y + y_offset,
                    z = farmData.Pos.z
                },
                isFarming = false
            })
        end

        farmZones[farmName] = zone
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local closestDistance = -1
        local closestPoint = nil

        for _, zone in pairs(farmZones) do
            for i, point in ipairs(zone.points) do
                local dist = #(playerCoords - vector3(point.pos.x, point.pos.y, point.pos.z))

                if dist < 1.5 and not isFarming then
                    closestDistance = dist
                    closestPoint = point

                    ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um " .. zone.data.ItemLabel .. " zu farmen.")

                    if IsControlJustReleased(0, 38) then -- Key E
                        startFarming(zone, point)
                    end
                end

                if dist < 10.0 then -- Draw marker only when close
                    DrawMarker(
                        zone.data.Marker.Type,
                        point.pos.x, point.pos.y, point.pos.z - 0.95,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        zone.data.Marker.Size.x, zone.data.Marker.Size.y, zone.data.Marker.Size.z,
                        zone.data.Marker.Color.r, zone.data.Marker.Color.g, zone.data.Marker.Color.b, zone.data.Marker.Color.a,
                        false, true, 2, nil, nil, false
                    )
                end
            end
        end
    end
end)

function startFarming(zone, point)
    if isFarming or point.isFarming then return end

    isFarming = true
    point.isFarming = true

    -- Animation
    local dict = "anim@amb@world_human_gardener_plant@male@base"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict, "base", 8.0, -8.0, -1, 1, 0, false, false, false)

    -- Progress bar and wait
    ESX.ShowNotification("Du beginnst mit dem Farmen...")
    Citizen.Wait(zone.data.HarvestTime)

    -- Stop animation and give item
    ClearPedTasks(PlayerPedId())
    isFarming = false
    point.isFarming = false
    TriggerServerEvent('esx_aramidfarm:giveItem', zone.data.Item, zone.data.Amount)
end
