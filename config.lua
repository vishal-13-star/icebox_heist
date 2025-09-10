Config = {}

-- General
Config.Debug = false
Config.Cooldown = 5 * 60            -- seconds (global heist cooldown after loot)
Config.MinPolice = 0                 -- set >0 to require cops online
Config.Doorlock = 'qb'               -- 'qb' or 'ox'

-- Re-lock timing AFTER loot (lets robbers exit first)
Config.ReLockDoor = true
Config.ReLockTime = 60               -- seconds to wait before auto re-lock

-- Required items
Config.Items = {
    drill  = { name = 'drill',      consume = true },
    table  = { name = 'tablet',     consume = false },
    trojan = { name = 'trojan_usb', consume = true }
}

-- Rewards
Config.Reward = {
    items = {
        { name = 'diamond',      min = 10, max = 20, chance = 70 },
        { name = 'diamond_ring', min = 5, max = 15, chance = 30 }
    }
}

-- Locations
Config.Locations = {
    HackSpot  = vec4(-1256.5663, -811.2831, 17.8377, 308.5493),
    LootSpot  = vec4(-1257.8313, -822.7795, 17.1010, 213.3763),
    DrillOffsets = {
        MainLeft   = vec3(-1230.656738, -800.096558, 18.008320),
        MainRight  = vec3(-1232.228271, -798.019653, 18.008320),
        SecondDoor = vec3(-1258.020142, -820.688293, 17.181341)
    }
}

-- Door definitions (qb-doorlock IDs)
Config.Doors = {
    MainLeft  = { doorlock = 'ice-box-main left side'  },
    MainRight = { doorlock = 'ice-box-main right side' },
    Second    = { doorlock = 'ice-box-2nd door'        }
}

-- Minigames
Config.Minigames = {
    ButtonMash = { style = 'default', difficulty = 10 },
    anagram    = { style = 'default', difficulty = 10 }
}

-- Target
Config.Target = {
    icon     = 'fas fa-lock',
    iconHack = 'fas fa-microchip',
    iconLoot = 'fas fa-gem',
    distance = 1.6
}
