local QBCore = exports['qb-core']:GetCoreObject()

local heistState = {
    active = false,
    hacked = false,
    mainOpened = false,
    secondOpened = false,
    looted = false,
    onCooldown = false
}

local function debug(msg)
    if Config.Debug then
        print("^3[ICEBOX]^7 " .. msg)
        QBCore.Functions.Notify(msg, "primary", 2500)
    end
end

local function hasItem(itemName)
    return QBCore.Functions.HasItem(itemName, 1)
end

local function tryConsume(itemName)
    local itemCfg = nil
    for _, v in pairs(Config.Items) do
        if v.name == itemName then itemCfg = v break end
    end
    if itemCfg and itemCfg.consume then
        TriggerServerEvent('icebox:sv:consumeItem', itemName, 1)
    end
end

local function copsOnlineOk(cb)
    if (Config.MinPolice or 0) <= 0 then cb(true) return end
    QBCore.Functions.TriggerCallback('icebox:sv:getCops', function(count)
        cb(count >= (Config.MinPolice or 0))
    end)
end

RegisterNetEvent('icebox:cl:relockDoors', function()
    debug("Received relock request from server, relocking doors now.")
    QBCore.Functions.Notify("Security system: relocking doors...", "error", 3000)

    if Config and Config.Doors then
        for k, v in pairs(Config.Doors) do
            local doorId = v.doorlock or v
            TriggerServerEvent('qb-doorlock:server:updateState', doorId, true)
            TriggerServerEvent('qb-doorlock:server:updateState', doorId, true, false, false, true, true, true)
        end
    end
end)

RegisterNetEvent('icebox:cl:setCooldown', function(state)
    heistState.onCooldown = state
    if state then
        debug("Heist cooldown active.")
    else
        debug("Heist cooldown cleared.")
    end
end)

RegisterNetEvent('icebox:cl:resetHeist', function()
    heistState = {
        active = false,
        hacked = false,
        mainOpened = false,
        secondOpened = false,
        looted = false,
        onCooldown = false
    }
    debug("Heist state reset by server.")
end)

RegisterNetEvent('icebox:cl:resetLoot', function()
    heistState.looted = false
    debug("Loot flags reset.")
end)


local function debug(msg)
    if Config.Debug then
        print("^3[ICEBOX]^7 " .. msg)
        QBCore.Functions.Notify(msg, "primary", 2500)
    end
end

local function hasItem(itemName)
    return QBCore.Functions.HasItem(itemName, 1)
end

local function tryConsume(itemName)
    local itemCfg = nil
    for _, v in pairs(Config.Items) do
        if v.name == itemName then itemCfg = v break end
    end
    if itemCfg and itemCfg.consume then
        TriggerServerEvent('icebox:sv:consumeItem', itemName, 1)
    end
end

local function copsOnlineOk(cb)
    if Config.MinPolice <= 0 then cb(true) return end
    QBCore.Functions.TriggerCallback('icebox:sv:getCops', function(count)
        cb(count >= Config.MinPolice)
    end)
end

local function setDoorState(doorKeyOrId, locked)
    local doorId = doorKeyOrId
    if Config.Doors[doorKeyOrId] and Config.Doors[doorKeyOrId].doorlock then
        doorId = Config.Doors[doorKeyOrId].doorlock
    end
    TriggerServerEvent('qb-doorlock:server:updateState', doorId, locked, false, false, true, true, true)
end

RegisterNetEvent('icebox:cl:setCooldown', function(active)
    heistState.onCooldown = active
    if active then
        debug('Heist cooldown active.')
    else
        debug('Heist cooldown ended.')
    end
end)

RegisterNetEvent('icebox:cl:resetHeist', function()
    heistState = {
        active = false,
        hacked = false,
        mainOpened = false,
        secondOpened = false,
        looted = false,
        onCooldown = false
    }
    debug('Heist state reset.')
end)

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function startDrillAnim(ped)
    local animDict = "anim@heists@fleeca_bank@drilling"
    local animName = "drill_straight_idle"
    loadAnimDict(animDict)

    local drillModel = `hei_prop_heist_drill`
    RequestModel(drillModel)
    while not HasModelLoaded(drillModel) do Wait(10) end
    local drillObj = CreateObject(drillModel, GetEntityCoords(ped), true, true, true)
    AttachEntityToEntity(drillObj, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.02, 90.0, 180.0, 180.0, true, true, false, true, 1, true)

    TaskPlayAnim(ped, animDict, animName, 3.0, -1, -1, 49, 0, 0, 0, 0)

    return drillObj
end

local function stopDrillAnim(ped, drillObj)
    ClearPedTasks(ped)
    if DoesEntityExist(drillObj) then
        DeleteObject(drillObj)
    end
end

-- Main door drill
local function doDrillMainDoor()
    if heistState.onCooldown then return QBCore.Functions.Notify('The tools are cooling down...', 'error') end
    copsOnlineOk(function(ok)
        if not ok then return QBCore.Functions.Notify('Not enough police on duty.', 'error') end
        if heistState.mainOpened then return QBCore.Functions.Notify('Main door already opened.', 'error') end
        if not hasItem(Config.Items.drill.name) then return QBCore.Functions.Notify('You need a Drill.', 'error') end
        if not hasItem(Config.Items.table.name) then return QBCore.Functions.Notify('You need a Table.', 'error') end

        local ped = PlayerPedId()
        local drillObj = startDrillAnim(ped) 

        exports['boii_minigames']:button_mash({
            style = Config.Minigames.ButtonMash.style,
            difficulty = Config.Minigames.ButtonMash.difficulty
        }, function(success)
            stopDrillAnim(ped, drillObj) 

            if not success then return QBCore.Functions.Notify('You failed to keep the drill steady.', 'error') end
            setDoorState('MainLeft', false)
            setDoorState('MainRight', false)
            heistState.mainOpened = true
            tryConsume(Config.Items.drill.name)
            QBCore.Functions.Notify('Main doors unlocked!', 'success')
            TriggerServerEvent('police:server:policeAlert', 'Diamond store robbery in progress!')
        end)
    end)
end

-- HACK PANEL
local function doHackPanel()
    if heistState.hacked then return QBCore.Functions.Notify('Panel already hacked.', 'error') end
    if heistState.onCooldown then return QBCore.Functions.Notify('The kit is cooling down...', 'error') end
    if not hasItem(Config.Items.trojan.name) then return QBCore.Functions.Notify('You need a Trojan USB.', 'error') end
    if not hasItem(Config.Items.table.name) then return QBCore.Functions.Notify('You need a Tablet.', 'error') end

    copsOnlineOk(function(ok)
        if not ok then return QBCore.Functions.Notify('Not enough police on duty.', 'error') end
        exports['boii_minigames']:anagram({
            style = Config.Minigames.anagram.style,
            difficulty = Config.Minigames.anagram.difficulty
        }, function(success)
            if not success then return QBCore.Functions.Notify('Hack failed.', 'error') end
            heistState.hacked = true
            tryConsume(Config.Items.trojan.name)
            QBCore.Functions.Notify('Security bypassed. Drill the inner door.', 'success')
        end)
    end)
end

-- SECOND DOOR (drill after hack)
local function doDrillSecondDoor()
    if heistState.onCooldown then return QBCore.Functions.Notify('Your drill is overheating.', 'error') end
    if not heistState.hacked then return QBCore.Functions.Notify('Hack the panel first.', 'error') end
    if heistState.secondOpened then return QBCore.Functions.Notify('Door already open.', 'error') end
    if not hasItem(Config.Items.drill.name) then return QBCore.Functions.Notify('You need a Drill.', 'error') end
    if not hasItem(Config.Items.table.name) then return QBCore.Functions.Notify('You need a Table.', 'error') end

    local ped = PlayerPedId()
    local drillObj = startDrillAnim(ped) 

    exports['boii_minigames']:button_mash({
        style = Config.Minigames.ButtonMash.style,
        difficulty = Config.Minigames.ButtonMash.difficulty
    }, function(success)
        stopDrillAnim(ped, drillObj) 

        if not success then return QBCore.Functions.Notify('You slipped while drilling.', 'error') end
        setDoorState('Second', false)
        heistState.secondOpened = true
        tryConsume(Config.Items.drill.name)
        QBCore.Functions.Notify('Second door opened!', 'success')

        alertPolice("Drilling into the second door at the Icebox Jewelry Store!")
    end)
end

local function doLoot()
    if not heistState.secondOpened then 
        return QBCore.Functions.Notify('Get past the second door first.', 'error') 
    end
    if heistState.looted then 
        return QBCore.Functions.Notify('Already looted!', 'error') 
    end

    local ped = PlayerPedId()
    local animDict = "anim@heists@ornate_bank@grab_cash"
    local animName = "grab"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end

    local propModel = `prop_cs_heist_bag_01`
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do Wait(10) end
    local coords = GetEntityCoords(ped)
    local lootProp = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(lootProp, ped, GetPedBoneIndex(ped, 57005), 0.15, 0.02, -0.02, 220.0, 180.0, 0.0, true, true, false, true, 1, true)

    TaskPlayAnim(ped, animDict, animName, 3.0, -1, -1, 49, 0, 0, 0, 0)

    QBCore.Functions.Progressbar('icebox_loot', 'Collecting diamonds...', 12000, false, true, {
        disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
    }, {}, {}, {}, function()
        ClearPedTasks(ped)
        DeleteObject(lootProp)
        TriggerServerEvent('icebox:sv:giveReward')
        QBCore.Functions.Notify('You grabbed a bag of diamonds!', 'success')
        heistState.looted = true

        TriggerServerEvent('police:server:policeAlert', 'Diamond store robbery in progress!')
            TriggerServerEvent("npc-police:triggerCrime", "jewel-robbery", coords)


        QBCore.Functions.Notify(('Doors will lock in 60 seconds, escape quickly!'):format(Config.RelockTime), 'inform')
        SetTimeout(Config.RelockTime * 1000, function()
            setDoorState('MainLeft', true)
            setDoorState('MainRight', true)
            setDoorState('Second', true)
            QBCore.Functions.Notify('The doors have been locked again!', 'error')
        end)

        -- start cooldown
        TriggerServerEvent('icebox:sv:startCooldown')
    end, function()
        -- Cancel
        ClearPedTasks(ped)
        DeleteObject(lootProp)
        QBCore.Functions.Notify('You stopped looting.', 'error')
    end)
end

-- Targets
CreateThread(function()
    exports['qb-target']:AddCircleZone('icebox_main_door_drill', Config.Locations.DrillOffsets.MainLeft, 1.2, {
        name = 'icebox_main_door_drill', useZ = true, debugPoly = Config.Debug
    }, { options = {{ icon = Config.Target.icon, label = 'Drill Main Door', action = doDrillMainDoor, canInteract = function() return not heistState.mainOpened and not heistState.onCooldown end }}, distance = Config.Target.distance })

    exports['qb-target']:AddCircleZone('icebox_hack_spot', vec3(Config.Locations.HackSpot.x, Config.Locations.HackSpot.y, Config.Locations.HackSpot.z), 1.2, {
        name = 'icebox_hack_spot', useZ = true, debugPoly = Config.Debug
    }, { options = {{ icon = Config.Target.iconHack, label = 'Hack Security Panel', action = doHackPanel, canInteract = function() return not heistState.hacked and not heistState.onCooldown end }}, distance = Config.Target.distance })

    exports['qb-target']:AddCircleZone('icebox_second_door_drill', Config.Locations.DrillOffsets.SecondDoor, 1.2, {
        name = 'icebox_second_door_drill', useZ = true, debugPoly = Config.Debug
    }, { options = {{ icon = Config.Target.icon, label = 'Drill Second Door', action = doDrillSecondDoor, canInteract = function() return heistState.hacked and not heistState.secondOpened and not heistState.onCooldown end }}, distance = Config.Target.distance })

    exports['qb-target']:AddCircleZone('icebox_loot_spot', vec3(Config.Locations.LootSpot.x, Config.Locations.LootSpot.y, Config.Locations.LootSpot.z), 1.2, {
        name = 'icebox_loot_spot', useZ = true, debugPoly = Config.Debug
    }, { options = {{ icon = Config.Target.iconLoot, label = 'Loot Diamonds', action = doLoot, canInteract = function() return heistState.secondOpened and not heistState.looted and not heistState.onCooldown end }}, distance = Config.Target.distance })
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    exports['qb-target']:RemoveZone('icebox_main_door_drill')
    exports['qb-target']:RemoveZone('icebox_hack_spot')
    exports['qb-target']:RemoveZone('icebox_second_door_drill')
    exports['qb-target']:RemoveZone('icebox_loot_spot')
end)

