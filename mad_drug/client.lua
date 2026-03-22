local ESX = exports['es_extended']:getSharedObject()
local uiOpen = false
local currentSellingPed = nil

local interactedPeds = {}

exports.ox_target:addGlobalPed({
    {
        name = 'drogue_sell',
        icon = 'fas fa-hand-holding-usd',
        label = 'Proposer de la marchandise',
        distance = Config.InteractionDistance or 2.0,
        canInteract = function(entity, distance, coords, name, bone)
            if uiOpen then return false end
            
            if Config.EnableZones then
                local inZone = false
                local plyCoords = GetEntityCoords(PlayerPedId())
                for _, zoneCoords in ipairs(Config.AllowedZones) do
                    if #(plyCoords - zoneCoords) <= Config.ZoneRadius then
                        inZone = true
                        break
                    end
                end
                if not inZone then return false end
            end
            
            if interactedPeds[entity] then return false end
            if IsPedAPlayer(entity) then return false end
            if not IsPedHuman(entity) then return false end
            if IsPedDeadOrDying(entity, true) then return false end
            if IsPedInAnyVehicle(entity, true) then return false end
            
            return true
        end,
        onSelect = function(data)
            ESX.TriggerServerCallback('drogue:canSellConditions', function(canSell, reason)
                if canSell then
                    OpenSellMenu(data.entity)
                else
                    ESX.ShowNotification(reason)
                end
            end)
        end
    }
})

function OpenSellMenu(ped)
    local itemToSell = nil
    local count = 0
    
    for itemDataName, cfg in pairs(Config.Items) do
        local itemCount = exports.ox_inventory:Search('count', itemDataName)
        if itemCount and itemCount > 0 then
            itemToSell = itemDataName
            count = itemCount
            break
        end
    end
    
    if not itemToSell then
        ESX.ShowNotification("~r~Vous n'avez aucune marchandise à vendre.")
        return
    end
    
    local cfg = Config.Items[itemToSell]
    
    local requestedQty = math.random(cfg.minQuantity or 1, cfg.maxQuantity or 10)
    local finalQuantity = count > requestedQty and requestedQty or count
    
    uiOpen = true
    currentSellingPed = ped
    
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 2000)
    Wait(500)
    TaskStandStill(ped, -1)
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        payload = {
            item = itemToSell,
            label = cfg.label,
            quantity = finalQuantity,
            minPrice = cfg.minPrice,
            maxPrice = cfg.maxPrice,
            defaultPrice = cfg.defaultPrice
        }
    })
end

RegisterNUICallback('sellItem', function(data, cb)
    SetNuiFocus(false, false)
    uiOpen = false
    
    local ped = currentSellingPed
    currentSellingPed = nil
    
    if cb then cb('ok') end
    
    if not ped then return end
    
    ESX.TriggerServerCallback('drogue:attemptSell', function(result)
        interactedPeds[ped] = true
        ClearPedTasks(ped)
        
        if result == 'success' then
            local dict = "mp_common"
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do Wait(10) end
            
            local playerPed = PlayerPedId()
            TaskTurnPedToFaceEntity(playerPed, ped, 1000)
            TaskTurnPedToFaceEntity(ped, playerPed, 1000)
            Wait(800)
            
            TaskPlayAnim(playerPed, dict, "givetake2_a", 8.0, -8.0, 2000, 0, 0, false, false, false)
            TaskPlayAnim(ped, dict, "givetake2_b", 8.0, -8.0, 2000, 0, 0, false, false, false)
            Wait(2000)
            
            TaskWanderStandard(ped, 10.0, 10)
        elseif result == 'steal' then
            ESX.ShowNotification("~r~Le client t'a volé ta came sans payer !")
            TaskReactAndFleePed(ped, PlayerPedId())
            if math.random(1, 100) <= Config.PoliceCallChance then Config.CallPolice() end
        elseif result == 'attack' then
            ESX.ShowNotification("~r~Le client s'énerve et veut te fumer !")
            local weapons = {`WEAPON_KNIFE`, `WEAPON_BAT`, `WEAPON_PISTOL`}
            local wp = weapons[math.random(1, #weapons)]
            GiveWeaponToPed(ped, wp, 255, false, true)
            TaskCombatPed(ped, PlayerPedId(), 0, 16)
            if math.random(1, 100) <= Config.PoliceCallChance then Config.CallPolice() end
        elseif result == 'refuse' then
            ESX.ShowNotification("~r~Le client a trouvé ton prix abusif !")
            TaskReactAndFleePed(ped, PlayerPedId())
            if math.random(1, 100) <= Config.PoliceCallChance then Config.CallPolice() end
        end
    end, data.item, data.quantity, data.price, data.chance)
end)

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    uiOpen = false
    
    if currentSellingPed then
        ClearPedTasks(currentSellingPed)
    end
    currentSellingPed = nil
    if cb then cb('ok') end
end)
