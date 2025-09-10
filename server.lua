local QBCore = exports['qb-core']:GetCoreObject()

local cooldown = false
local lastStart = 0

-- Count cops
QBCore.Functions.CreateCallback('icebox:sv:getCops', function(src, cb)
    local count = 0
    for _, pid in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(pid)
        if Player and Player.PlayerData.job and Player.PlayerData.job.name == 'police' and Player.PlayerData.job.onduty then
            count = count + 1
        end
    end
    cb(count)
end)

-- Consume item
RegisterNetEvent('icebox:sv:consumeItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(item, amount or 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount or 1)
end)

local function startGlobalCooldown()
    if cooldown then return end
    cooldown = true
    lastStart = os.time()
    TriggerClientEvent('icebox:cl:setCooldown', -1, true)

    SetTimeout((Config.Cooldown or 1800) * 1000, function()
        cooldown = false
        TriggerClientEvent('icebox:cl:setCooldown', -1, false)
        TriggerClientEvent('icebox:cl:resetHeist', -1)
        TriggerClientEvent('icebox:cl:resetLoot', -1)
    end)
end

RegisterNetEvent('icebox:sv:giveReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- give configured rewards
    if Config and Config.Reward and Config.Reward.items then
        for _, entry in ipairs(Config.Reward.items) do
            local roll = math.random(1, 100)
            if roll <= (entry.chance or 100) then
                local qty = math.random(entry.min or 1, entry.max or 1)
                Player.Functions.AddItem(entry.name, qty)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[entry.name], 'add', qty)
            end
        end
    end

    startGlobalCooldown()

    if Config.ReLockDoor ~= false and (Config.ReLockTime and Config.ReLockTime > 0) then
        local delayMs = Config.ReLockTime * 1000
        SetTimeout(delayMs, function()
            TriggerClientEvent('icebox:cl:relockDoors', -1)
        end)
    end
end)

-- Optional: server-side event to manually start cooldown (kept for compatibility)
RegisterNetEvent('icebox:sv:startCooldown', function()
    startGlobalCooldown()
end)

-- Police alert (ps-dispatch or no-op)
RegisterNetEvent("icebox:server:policeAlert", function(coords, typ)
    -- if ps-dispatch exists, you can call export here; keep minimal to avoid crashes
    if GetResourceState("ps-dispatch") == "started" then
        exports['ps-dispatch']:CustomAlert({
            coords = coords,
            message = "Jewelry store robbery: "..(typ or "robbery"),
            dispatchCode = "10-90",
            description = "Icebox jewelry",
            radius = 0,
            sprite = 161,
            color = 1,
            scale = 1.0,
        })
    else
        print(("icebox: police alert (%s) at %s"):format(tostring(typ), tostring(coords)))
    end
end)
