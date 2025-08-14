ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- This event is triggered in a loop from the client
RegisterServerEvent('esx_aramidfarm:giveAndCheck')
AddEventHandler('esx_aramidfarm:giveAndCheck', function(itemName, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if not xPlayer then return end

    -- Check if the player can carry the item
    if xPlayer.canCarryItem(itemName, amount) then
        -- Add the item to inventory
        xPlayer.addInventoryItem(itemName, amount)
        -- Notify the client of success (optional, could be spammy)
        -- TriggerClientEvent('esx:showNotification', _source, 'Du hast ' .. amount .. 'x ' .. xPlayer.getInventoryItem(itemName).label .. ' erhalten.')
    else
        -- Notify the client that their inventory is full
        TriggerClientEvent('esx:showNotification', _source, '~r~Dein Inventar ist voll.')
        -- Trigger a client event to stop the farming loop
        TriggerClientEvent('esx_aramidfarm:stopFarmingLoop', _source)
    end
end)
