local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('nova-kirala:server:PayRental', function(source, cb, price, time, model)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    if price > 0 then
        if Player.Functions.RemoveMoney('cash', price, "vehicle-rental") then
            cb(true)
        elseif Player.Functions.RemoveMoney('bank', price, "vehicle-rental") then
            cb(true)
        else
            TriggerClientEvent('QBCore:Notify', source, "Yeterli paranız yok! Gereken: $" .. price, "error")
            cb(false)
        end
    else
        -- 10 dakika veya daha az, ücretsiz
        cb(true)
    end
end)
