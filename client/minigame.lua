local result = nil
local active = false

exports('Minigame', function(rounds, speed)
    result = nil -- reset
    active = true

    SetNuiFocus(false, true)
    SendNUIMessage({
        type = 'start',
        rounds = rounds,
        speed = speed
    }) 

    while active do
        sleep = 3
        if IsControlJustPressed(0, 38) then
            SendNUIMessage({
                type = "check",
            })
        end
        Citizen.Wait(sleep)
    end
    
    SetNuiFocus(false, false)
    return result
end)

RegisterNUICallback('GetResult', function(data, cb)
    result = data
    active = false
    cb()
end)
