ESX = nil
local PlayerData = {}
local farmZones = {}
local isPlayerFarming = false

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

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Event handler to stop the farming loop, triggered by the server
RegisterNetEvent('esx_aramidfarm:stopFarmingLoop')
AddEventHandler('esx_aramidfarm:stopFarmingLoop', function()
    isPlayerFarming = false
end)

function initializeFarmZones()
    for farmName, farmData in pairs(Config.FarmZones) do
        local zone = { name = farmName, blip = nil, points = {}, data = farmData }
        if farmData.Blip then
            zone.blip = AddBlipForCoord(farmData.Blip.Pos.x, farmData.Blip.Pos.y, farmData.Blip.Pos.z)
            SetBlipSprite(zone.blip, farmData.Blip.Sprite)
            SetBlipDisplay(zone.blip, farmData.Blip.Display)
            SetBlipScale(zone.blip, farmData.Blip.Scale)
            SetBlipColour(zone.blip, farmData.Blip.Colour)
            SetBlipAsShortRange(zone.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(farmData.Blip.Name)
            EndTextCommandSetBlipName(zone.blip)
        end
        for _, pos in ipairs(farmData.StaticPoints) do
            table.insert(zone.points, { pos = pos })
        end
        farmZones[farmName] = zone
    end
end

-- Main loop for drawing markers and detecting interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local canFarm = false

        if not isPlayerFarming then
            for _, zone in pairs(farmZones) do
                for _, point in ipairs(zone.points) do
                    local dist = #(playerCoords - point.pos)
                    if dist < 10.0 then
                        DrawMarker(
                            zone.data.Marker.Type,
                            point.pos.x, point.pos.y, point.pos.z - 0.95,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                            zone.data.Marker.Size.x, zone.data.Marker.Size.y, zone.data.Marker.Size.z,
                            zone.data.Marker.Color.r, zone.data.Marker.Color.g, zone.data.Marker.Color.b, zone.data.Marker.Color.a,
                            false, true, 2, nil, nil, false
                        )
                        if dist < 2.0 then
                            canFarm = true
                            ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um mit dem Farmen zu beginnen.")
                            if IsControlJustReleased(0, 38) then -- Key E
                                if hasRequiredTool(zone.data) then
                                    startFarming(zone)
                                else
                                    ESX.ShowNotification("Dir fehlt das nötige Werkzeug: " .. zone.data.RequiredTool)
                                end
                            end
                        end
                    end
                end
            end
        end

        if not canFarm and not isPlayerFarming then
            Citizen.Wait(500)
        end
    end
end)

function hasRequiredTool(farmData)
    if not farmData.ToolRequired then return true end
    for _, item in ipairs(PlayerData.inventory) do
        if item.name == farmData.RequiredTool and item.count > 0 then
            return true
        end
    end
    return false
end

function startFarming(zone)
    if isPlayerFarming then return end
    isPlayerFarming = true

    local playerPed = PlayerPedId()

    -- The continuous farming loop
    Citizen.CreateThread(function()
        while isPlayerFarming do
            ESX.ShowHelpNotification("Farmen läuft... Drücke ~INPUT_CONTEXT~ zum Abbrechen.")
            FreezeEntityPosition(playerPed, true)

            -- Play Animation
            local dict = "random@domestic"
            local anim = "pickup_low"
            RequestAnimDict(dict)
            local timeout = 20
            while not HasAnimDictLoaded(dict) and timeout > 0 do
                Citizen.Wait(100)
                timeout = timeout - 1
            end
            if timeout > 0 then
                TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            else
                print("[esx_aramidfarm] ERROR: Animation dictionary failed to load: " .. dict)
            end

            -- Wait for harvest time, but check for cancellation
            local harvestTimer = zone.data.HarvestTime
            local cancelled = false
            while harvestTimer > 0 do
                Citizen.Wait(100)
                harvestTimer = harvestTimer - 100
                if IsControlJustReleased(0, 38) then -- Key E to cancel
                    isPlayerFarming = false
                    cancelled = true
                    ESX.ShowNotification("Du hast das Farmen abgebrochen.")
                    break
                end
                -- Also check if the server told us to stop (e.g. inventory full)
                if not isPlayerFarming then
                    cancelled = true
                    break
                end
            end

            -- If the loop finished without being cancelled, give item
            if not cancelled and isPlayerFarming then
                TriggerServerEvent('esx_aramidfarm:giveAndCheck', zone.data.Item, zone.data.Amount)
            end

            -- A small wait before the next loop iteration to prevent spamming server events too quickly
            Citizen.Wait(250)
        end

        -- Cleanup after loop ends
        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed, false)
    end)
end
