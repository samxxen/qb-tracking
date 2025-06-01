QBCore = exports['qb-core']:GetCoreObject()
local isTracking = false
local trackingBlip = nil
local trackingTimer = nil
local Strings = {}


local function LoadLanguage()
    local lang = Config.Locale or 'en'
    
    if lang == 'ar' then
        Strings = {
            ['tracking_started'] = 'تم بدء تعقب الهدف',
            ['tracking_ended'] = 'انتهى وقت التعقب',
            ['tracking_blocked'] = 'تم إحباط محاولة تعقبك',
            ['tracking_success'] = 'تم تعقب موقعك!',
            ['no_permission'] = 'ليست لديك صلاحية استخدام الجهاز',
            ['player_offline'] = 'اللاعب غير متصل أو الرقم غير صحيح',
            ['tracking_failed'] = 'فشل تعقب الهدف، لقد أحبط المحاولة',
            ['tracking_title'] = 'نظام تعقب الأفراد',
            ['phone_input_label'] = 'رقم الهاتف',
            ['phone_input_desc'] = 'أدخل رقم الهاتف المراد تعقبه',
            ['blip_name'] = 'موقع التعقب',
            ['use_tracker'] = 'استخدام جهاز التعقب',
            ['tracker_item_name'] = 'جهاز التعقب'
        }
    else
        Strings = {
            ['tracking_started'] = 'Started tracking target',
            ['tracking_ended'] = 'Tracking time has ended',
            ['tracking_blocked'] = 'You blocked the tracking attempt',
            ['tracking_success'] = 'Your location has been tracked!',
            ['no_permission'] = 'You are not authorized to use this device',
            ['player_offline'] = 'Player is offline or number is invalid',
            ['tracking_failed'] = 'Tracking failed, target blocked the attempt',
            ['tracking_title'] = 'Personnel Tracking System',
            ['phone_input_label'] = 'Phone Number',
            ['phone_input_desc'] = 'Enter the phone number to track',
            ['blip_name'] = 'Tracking Location',
            ['use_tracker'] = 'Use Tracking Device',
            ['tracker_item_name'] = 'Tracking Device'
        }
    end
end


local function HasPermission()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData then return false end
    
    for _, job in ipairs(Config.AllowedJobs) do
        if PlayerData.job.name == job and PlayerData.job.onduty then
            return true
        end
    end
    return false
end

local function CreateTrackingBlip(coords)
    if trackingBlip and DoesBlipExist(trackingBlip) then
        RemoveBlip(trackingBlip)
    end

    if trackingTimer then
        Citizen.ClearTimeout(trackingTimer)
    end

    trackingBlip = AddBlipForRadius(coords.x, coords.y, coords.z, Config.Tracking.Radius)
    SetBlipHighDetail(trackingBlip, true)
    SetBlipColour(trackingBlip, 1)
    SetBlipAlpha(trackingBlip, 80)

    local exactBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(exactBlip, 480)
    SetBlipColour(exactBlip, 1)
    SetBlipDisplay(exactBlip, 4)
    SetBlipScale(exactBlip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Strings['blip_name'])
    EndTextCommandSetBlipName(exactBlip)

    trackingTimer = Citizen.SetTimeout(Config.Tracking.Duration, function()
        if DoesBlipExist(trackingBlip) then RemoveBlip(trackingBlip) end
        if DoesBlipExist(exactBlip) then RemoveBlip(exactBlip) end
        isTracking = false
        QBCore.Functions.Notify(Strings['tracking_ended'], 'info')
    end)
end


CreateThread(function()
    LoadLanguage()
end)

RegisterNetEvent('code:tracking:startClientTracking', function(coords)
    if isTracking then return end
    isTracking = true
    QBCore.Functions.Notify(Strings['tracking_started'], 'success')
    CreateTrackingBlip(coords)
end)

RegisterNetEvent('code:tracking:targetMinigame', function(requesterId)
    local minigameResult = exports["five-repairkit"]:Minigame(1, 30)
    
    if minigameResult and minigameResult == true then
        QBCore.Functions.Notify(Strings['tracking_blocked'], 'success')
        TriggerServerEvent('code:tracking:targetMinigameResult', requesterId, false) 
    else
        QBCore.Functions.Notify(Strings['tracking_success'], 'error')
        TriggerServerEvent('code:tracking:targetMinigameResult', requesterId, true) 
    end
end)

RegisterNetEvent('code:tracking:useTrackerItem', function()
    if not HasPermission() then
        QBCore.Functions.Notify(Strings['no_permission'], 'error')
        return
    end

    local input = lib.inputDialog(Strings['tracking_title'], {
        {type = 'number', label = Strings['phone_input_label'], description = Strings['phone_input_desc'], required = true}
    })

    if not input then return end
    local phoneNumber = tostring(input[1])

    QBCore.Functions.TriggerCallback('code:tracking:checkPlayerByPhone', function(isOnline, playerId, phoneStatus)
        if not isOnline then
            QBCore.Functions.Notify(Strings['player_offline'], 'error')
            return
        end
        TriggerServerEvent('code:tracking:startTracking', playerId)
    end, phoneNumber)
end)
