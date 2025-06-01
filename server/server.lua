QBCore = exports['qb-core']:GetCoreObject()


local function HasPermission(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    for _, job in ipairs(Config.AllowedJobs) do
        if Player.PlayerData.job.name == job and Player.PlayerData.job.onduty then
            return true
        end
    end
    return false
end

QBCore.Functions.CreateUseableItem(Config.TrackerItem, function(source)
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
    if not HasPermission(src) then
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
