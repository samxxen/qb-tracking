QBCore = exports['qb-core']:GetCoreObject()
local Strings = {}


QBCore.Functions.CreateUseableItem("tracker", function(source)
    TriggerClientEvent('code:tracking:useTrackerItem', source)
end)

QBCore.Functions.CreateCallback('code:tracking:checkPlayerByPhone', function(source, cb, phoneNumber)
    local result = MySQL.query.await('SELECT owner_id FROM phone_phones WHERE phone_number = ?', {phoneNumber})
    if not result or #result == 0 then return cb(false, nil, false) end

    local ownerId = result[1].owner_id
    local target = QBCore.Functions.GetPlayerByCitizenId(ownerId)
    if not target then return cb(false, nil, false) end

    local phoneStatus = true 
    cb(true, target.PlayerData.source, phoneStatus)
end)

RegisterNetEvent('code:tracking:startTracking', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or Player.PlayerData.job.name ~= 'police' or not Player.PlayerData.job.onduty then
        print(('^5[TRACKING] ^1Unauthorized use attempt by ID: %s^0'):format(src))
        return
    end

    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, Strings['player_offline'], 'error')
        return
    end

    TriggerClientEvent('code:tracking:targetMinigame', targetPlayer.PlayerData.source, src)
end)

RegisterNetEvent('code:tracking:targetMinigameResult', function(requesterId, allowTracking)
    local src = source
    if allowTracking then
        local coords = GetEntityCoords(GetPlayerPed(src))
        TriggerClientEvent('code:tracking:startClientTracking', requesterId, coords)
    else
        TriggerClientEvent('QBCore:Notify', requesterId, Strings['tracking_failed'], 'error')
    end
end)
