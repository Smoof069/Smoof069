ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_aramidfarm:giveItem')
AddEventHandler('esx_aramidfarm:giveItem', function(item, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        -- Ensure the item exists in the database before attempting to add it
        local itemLabel = ESX.GetItemLabel(item)
        if itemLabel then
            xPlayer.addInventoryItem(item, count)
            -- Notify the client that they received the item
            TriggerClientEvent('esx:showNotification', _source, 'Du hast ' .. count .. 'x ' .. itemLabel .. ' erhalten.')
        else
            print('esx_aramidfarm: Invalid item "' .. item .. '" specified in config.lua. Please check your items database.')
            TriggerClientEvent('esx:showNotification', _source, '~r~Fehler: Das Item existiert nicht.')
        end
    end
end)
