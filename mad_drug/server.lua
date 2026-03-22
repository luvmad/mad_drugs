local ESX = exports['es_extended']:getSharedObject()
local sellCooldowns = {}

ESX.RegisterServerCallback('drogue:canSellConditions', function(source, cb)
    if Config.EnableIRLTimeLimit then
        local date = os.date("*t")
        local currentHour = date.hour
        local canSell = false
        
        if Config.SellStartHour > Config.SellEndHour then
            if currentHour >= Config.SellStartHour or currentHour < Config.SellEndHour then canSell = true end
        else
            if currentHour >= Config.SellStartHour and currentHour < Config.SellEndHour then canSell = true end
        end
        
        if not canSell then
            cb(false, "~r~Les acheteurs ne se montrent qu'entre "..Config.SellStartHour.."h et "..Config.SellEndHour.."h (IRL).")
            return
        end
    end
    
    if Config.EnableCopRequirement then
        local copsOnline = 0
        for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
            for _, job in ipairs(Config.CopJobs) do
                if xPlayer.job.name == job then
                    copsOnline = copsOnline + 1
                    break
                end
            end
        end
        
        if copsOnline < Config.RequiredCops then
            cb(false, ("~r~Pas assez de forces de l'ordre en ville (%s/%s)."):format(copsOnline, Config.RequiredCops))
            return
        end
    end
    
    cb(true, "")
end)

ESX.RegisterServerCallback('drogue:attemptSell', function(source, cb, itemName, quantity, price, chance)
    local _source = source
    
    if sellCooldowns[_source] and os.time() - sellCooldowns[_source] < 2 then
        cb('refuse')
        return
    end
    sellCooldowns[_source] = os.time()
    if Config.EnableZones then
        local ped = GetPlayerPed(_source)
        local plyCoords = GetEntityCoords(ped)
        local inZone = false
        for _, zoneCoords in ipairs(Config.AllowedZones) do
            if #(plyCoords - zoneCoords) <= Config.ZoneRadius + 5.0 then 
                inZone = true
                break
            end
        end
        if not inZone then
            print(("Anti-Cheat: %s a tenté de vendre hors de la zone permise."):format(GetPlayerName(_source)))
            DropPlayer(_source, "Tentative de vente illégale hors zone.")
            cb('refuse')
            return
        end
    end
    
    local cfg = Config.Items[itemName]
    if type(quantity) ~= "number" or quantity <= 0 or not cfg then 
        cb('refuse')
        return 
    end
    
    if type(price) ~= "number" or price > cfg.maxPrice or price < cfg.minPrice then
        TriggerClientEvent('esx:showNotification', _source, "~r~Erreur: Prix invalide ou tentative de triche.")
        cb('refuse')
        return
    end
    
    if type(chance) ~= "number" or chance < 0 or chance > 100 then
        cb('refuse')
        return
    end
    
    local item = exports.ox_inventory:GetItem(_source, itemName)
    if not item or item.count < quantity then
        TriggerClientEvent('esx:showNotification', _source, "~r~Vous n'avez pas cette quantité.")
        cb('refuse')
        return
    end
    
    local roll = math.random(1, 100)
    
    if roll <= chance then
        local reward = price * quantity
        
        if Config.EnableNightBonus then
            local inGameHour = GetClockHours()
            local isNight = false
            
            if Config.NightStartHour > Config.NightEndHour then
                if inGameHour >= Config.NightStartHour or inGameHour < Config.NightEndHour then isNight = true end
            else
                if inGameHour >= Config.NightStartHour and inGameHour < Config.NightEndHour then isNight = true end
            end
            
            if isNight then
                reward = math.floor(reward * Config.NightBonusMultiplier)
            end
        end
        
        if exports.ox_inventory:RemoveItem(_source, itemName, quantity) then
            exports.ox_inventory:AddItem(_source, 'black_money', reward)
            TriggerClientEvent('esx:showNotification', _source, ("~g~Vente réussie ! ~s~Vous avez gagné ~r~$%s"):format(reward))
            cb('success')
        else
            cb('refuse')
        end
    else
        local reactionRoll = math.random(1, 100)
        
        if reactionRoll <= Config.FailReactions.stealChance then
            exports.ox_inventory:RemoveItem(_source, itemName, quantity)
            cb('steal')
        elseif reactionRoll <= (Config.FailReactions.stealChance + Config.FailReactions.attackChance) then
            cb('attack')
        else
            cb('refuse')
        end
    end
end)

