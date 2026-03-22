Config = {}

Config.InteractionDistance = 2.0


Config.EnableZones = false 
Config.ZoneRadius = 50.0   

Config.AllowedZones = {
    vector3(154.5, -1700.0, 29.2),
    vector3(442.22, -981.82, 30.68)
}

Config.EnableCopRequirement = false
Config.RequiredCops = 2
Config.CopJobs = {'police', 'sheriff'}

Config.PoliceCallChance = 30
Config.CallPolice = function()
    -- Insérez l'export de votre dispatch ici
    -- Exemple: exports['ps-dispatch']:SuspiciousActivity()
end


Config.FailReactions = {
    stealChance = 15,
    attackChance = 10
}


Config.EnableIRLTimeLimit = false
Config.SellStartHour = 20
Config.SellEndHour = 6


Config.EnableNightBonus = false
Config.NightBonusMultiplier = 1.2
Config.NightStartHour = 22
Config.NightEndHour = 5


Config.Items = {
    ['meth'] = {
        label = 'pochon de Meth',
        minPrice = 150,     -- Curseur du prix minimum
        maxPrice = 250,     -- Curseur du prix maximum
        defaultPrice = 200, -- Prix suggéré par défaut
        minQuantity = 1,    -- Demande minimale du PNJ
        maxQuantity = 10    -- Demande maximale du PNJ
    },
    ['cocaine'] = {
        label = 'pochon de Cocaïne',
        minPrice = 100,
        maxPrice = 200,
        defaultPrice = 150,
        minQuantity = 1,
        maxQuantity = 10
    },
    ['weed'] = {
        label = 'pochon de Weed',
        minPrice = 50,
        maxPrice = 110,
        defaultPrice = 80,
        minQuantity = 1,
        maxQuantity = 10
    }
}
