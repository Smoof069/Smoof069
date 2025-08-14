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
            table.insert(zone.points, { pos = pos })
        end

        farmZones[farmName] = zone
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local canFarm = false

        for _, zone in pairs(farmZones) do
            for _, point in ipairs(zone.points) do
                local dist = #(playerCoords - point.pos)

                if dist < 2.0 then
                    canFarm = true
                    ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um " .. zone.data.ItemLabel .. " zu farmen.")
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

        if not canFarm then
            Citizen.Wait(500)
        end
    end
end)

function hasRequiredTool(farmData)
    if not farmData.ToolRequired then
        return true
    end

    local requiredItem = farmData.RequiredTool
    for _, item in ipairs(PlayerData.inventory) do
        if item.name == requiredItem and item.count > 0 then
            return true
        end
    end
    return false
end

function startFarming(zone)
    if isPlayerFarming then return end

    isPlayerFarming = true
    local playerPed = PlayerPedId()

    FreezeEntityPosition(playerPed, true)

    local dict = "random@domestic"
    RequestAnimDict(dict)

    local timeout = 20
    while not HasAnimDictLoaded(dict) and timeout > 0 do
        Citizen.Wait(100)
        timeout = timeout - 1
    end

    if timeout > 0 then
        TaskPlayAnim(playerPed, dict, "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
    else
        print("[esx_aramidfarm] ERROR: Animation dictionary failed to load: " .. dict)
    end

    ESX.ShowNotification("Du beginnst mit dem Farmen...")
    Citizen.Wait(zone.data.HarvestTime)

    TriggerServerEvent('esx_aramidfarm:giveItem', zone.data.Item, zone.data.Amount)

    ClearPedTasks(playerPed)
    FreezeEntityPosition(playerPed, false)
    isPlayerFarming = false
end
