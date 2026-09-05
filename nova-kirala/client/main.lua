local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPed = nil
local rentedVehicle = nil

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

CreateThread(function()
    local model = GetHashKey(Config.Ped.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    -- Z koordinatından 1.0 çıkarıyoruz ki ped havada kalmasın
    spawnedPed = CreatePed(0, model, Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z - 1.0, Config.Ped.coords.w, false, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)

    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            local pedCoords = vector3(Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z)
            local dist = #(pos - pedCoords)

            if dist < 5.0 then
                sleep = 0
                if dist < 2.0 then
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, "~g~[E]~w~ Araç Kirala")
                    if IsControlJustPressed(0, 38) then -- E tuşu
                        TriggerEvent('nova-kirala:client:OpenMenu')
                    end
                end
            end
            Wait(sleep)
        end
    end)
end)

RegisterNetEvent('nova-kirala:client:OpenMenu', function()
    local menu = {
        {
            header = "🚗 Araç Kiralama",
            isMenuHeader = true,
        }
    }

    for i, v in ipairs(Config.Vehicles) do
        menu[#menu+1] = {
            header = v.name,
            txt = "İlk " .. Config.FreeTime .. " dk ücretsiz.<br>Sonrası dk başı: $" .. v.pricePerMinute .. "<br>Maks: " .. Config.MaxTime .. " dk.",
            icon = v.icon,
            params = {
                event = "nova-kirala:client:SelectTime",
                args = {
                    vehicleIndex = i
                }
            }
        }
    end

    menu[#menu+1] = {
        header = "❌ Kapat",
        icon = "fas fa-times",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }

    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('nova-kirala:client:SelectTime', function(data)
    local vehicleData = Config.Vehicles[data.vehicleIndex]
    
    local dialog = exports['qb-input']:ShowInput({
        header = vehicleData.name .. " Kiralama Süresi",
        submitText = "Kirala",
        inputs = {
            {
                text = "Kaç dakika? (Maks " .. Config.MaxTime .. ")",
                name = "time",
                type = "number",
                isRequired = true,
                default = 10
            }
        }
    })

    if dialog then
        local time = tonumber(dialog.time)
        if not time or time < 1 or time > Config.MaxTime then
            QBCore.Functions.Notify("Geçersiz süre! 1 ile " .. Config.MaxTime .. " dakika arasında bir değer girin.", "error")
            return
        end

        local price = 0
        if time > Config.FreeTime then
            price = (time - Config.FreeTime) * vehicleData.pricePerMinute
        end

        QBCore.Functions.TriggerCallback('nova-kirala:server:PayRental', function(success)
            if success then
                SpawnRentalVehicle(vehicleData.model, time)
            end
        end, price, time, vehicleData.model)
    end
end)

function SpawnRentalVehicle(model, time)
    if rentedVehicle and DoesEntityExist(rentedVehicle) then
        QBCore.Functions.Notify("Önceki kiralık aracınız siliniyor...", "primary")
        DeleteEntity(rentedVehicle)
    end

    local spawnCoords = Config.VehicleSpawn

    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityHeading(veh, spawnCoords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        
        rentedVehicle = veh
        
        QBCore.Functions.Notify("Araç " .. time .. " dakikalığına başarıyla kiralandı!", "success")
        
        -- Zamanlayıcı
        CreateThread(function()
            local currentVehicle = rentedVehicle
            local timeMs = time * 60 * 1000
            Wait(timeMs)
            
            -- Eğer araç hala aynıysa ve mevcutsa sil
            if rentedVehicle == currentVehicle and DoesEntityExist(rentedVehicle) then
                DeleteEntity(rentedVehicle)
                rentedVehicle = nil
                QBCore.Functions.Notify("Kiralama süreniz doldu, araç geri alındı!", "error", 5000)
            end
        end)

    end, spawnCoords, true)
end
