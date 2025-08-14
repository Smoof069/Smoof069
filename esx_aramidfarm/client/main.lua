ESX = nil
local PlayerData = {}
local farmZones = {}
local isPlayerFarming = false -- Use a local flag for the player

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

function initializeFarmZones()
    for farmName, farmData in pairs(Config.FarmZones) do
        local zone = {
            name = farmName,
            blip = nil,
            points = {},
            data = farmData
        }

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
            table.insert(zone.points, {
                pos = pos,
                cooldownUntil = 0
            })
        end

        farmZones[farmName] = zone
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5) -- Small wait to prevent meltdown
        local playerCoords = GetEntityCoords(PlayerPedId())
        local canFarm = false

        for _, zone in pairs(farmZones) do
            for _, point in ipairs(zone.points) do
                local dist = #(playerCoords - point.pos)

                if dist < 2.0 then
                    canFarm = true
                    if GetGameTimer() > point.cooldownUntil then
                        ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um " .. zone.data.ItemLabel .. " zu farmen.")
                        if IsControlJustReleased(0, 38) then -- Key E
                            if hasRequiredTool(zone.data) then
                                startFarming(zone, point)
                            else
                                ESX.ShowNotification("Dir fehlt das nötige Werkzeug: " .. zone.data.RequiredTool)
                            end
                        end
                    else
                        ESX.ShowHelpNotification("Dieser Ort wurde bereits abgeerntet. Versuche es später erneut.")
                    end
                    -- No marker is drawn, as requested
                end
            end
        end

        if not canFarm then
            Citizen.Wait(500) -- Sleep longer if not near any point
        end
    end
end)

function hasRequiredTool(farmData)
    if not farmData.ToolRequired then
        return true -- No tool required
    end

    local requiredItem = farmData.RequiredTool
    for _, item in ipairs(PlayerData.inventory) do
        if item.name == requiredItem and item.count > 0 then
            return true
        end
    end
    return false
end

function startFarming(zone, point)
    if isPlayerFarming then return end

    isPlayerFarming = true
    point.cooldownUntil = GetGameTimer() + zone.data.PointCooldown

    -- Switched to a crouch/inspect animation for a better "farming" look
    local dict = "amb@world_human_crouch_inspect@male@base"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict, "base", 8.0, -8.0, -1, 49, 0, false, false, false)

    ESX.ShowNotification("Du beginnst mit dem Farmen...")
    Citizen.Wait(zone.data.HarvestTime)

    ClearPedTasks(PlayerPedId())
    isPlayerFarming = false
    TriggerServerEvent('esx_aramidfarm:giveItem', zone.data.Item, zone.data.Amount)
end
