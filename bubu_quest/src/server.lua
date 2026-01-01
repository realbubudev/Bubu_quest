local ESX = exports.es_extended:getSharedObject()

local jobCooldowns = {}
local activeJobs = {}
local policeTracking = {}

RegisterNetEvent('bubu_quest:outOfZone', function(coords)
    local src = source
    if not activeJobs[src] then return end
    if policeTracking[src] then return end

    policeTracking[src] = true

    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent('esx:showNotification', xPlayer.source, Config.Text.police_alert)
        TriggerClientEvent('bubu_quest:trackSuspect', xPlayer.source, src)
    end
end)

RegisterNetEvent('bubu_quest:backInZone', function()
    local src = source
    if not activeJobs[src] then return end
    if not policeTracking[src] then return end

    policeTracking[src] = nil

    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent('bubu_quest:clearSuspect', xPlayer.source)
    end
end)

ESX.RegisterServerCallback('bubu_quest:canStartJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end

    local identifier = xPlayer.identifier
    local lastTime = jobCooldowns[identifier]

    if not lastTime then return cb(true) end

    local now = os.time()
    local remaining = Config.Cooldown.job - (now - lastTime)
    if remaining <= 0 then
        jobCooldowns[identifier] = nil
        return cb(true)
    end

    cb(false, remaining)
end)

RegisterNetEvent('bubu_quest:jobStarted', function()
    local src = source
    activeJobs[src] = true

    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent('bubu_quest:PolisRedZon', xPlayer.source)
    end
end)

RegisterNetEvent('bubu_quest:reward', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    xPlayer.addMoney(Config.Reward)
    jobCooldowns[xPlayer.identifier] = os.time()
    activeJobs[src] = nil
    policeTracking[src] = nil

    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayerPolice in pairs(xPlayers) do
        TriggerClientEvent('bubu_quest:clearSuspect', xPlayerPolice.source)
        TriggerClientEvent('bubu_quest:TaBortPolisRedZon', xPlayerPolice.source)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeJobs[src] = nil
    policeTracking[src] = nil
end)