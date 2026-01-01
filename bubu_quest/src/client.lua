local ESX = exports.es_extended:getSharedObject()

local jobActive = false
local RedZonActive = false
local canClaimReward = false
local policeAlertSent = false

local redBlip, redRadiusBlip
local spawnedBil = nil
local abdiPed = nil
local suspectBlip = nil

local function SpawnNPC(data)
    RequestModel(data.model)
    while not HasModelLoaded(data.model) do Wait(0) end

    local ped = CreatePed(0, data.model, data.coords.xyz, data.coords.w, false, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    return ped
end

local function PlayRewardAnimation()
    local ped = PlayerPedId()

    RequestAnimDict('mp_common')
    while not HasAnimDictLoaded('mp_common') do Wait(0) end

    FreezeEntityPosition(ped, true)
    TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, 3000, 49, 0, false, false, false)

    Wait(3000)
    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)
end

local function SpawnAbdi()
    if abdiPed and DoesEntityExist(abdiPed) then return end

    abdiPed = SpawnNPC(Config.Abdi)

    exports.ox_target:addLocalEntity(abdiPed, {
        {
            label = Config.Text.abdi_label,
            icon = 'fa-solid fa-comments',
            onSelect = function()
                if jobActive then return end

                jobActive = true
                policeAlertSent = false
                canClaimReward = false

                SpawnJobBil()
                TriggerServerEvent('bubu_quest:jobStarted')
                ESX.ShowNotification(Config.Text.start_hide)
                StartRedZon()
            end
        }
    })
end

local function DeleteAbdi()
    if abdiPed and DoesEntityExist(abdiPed) then
        DeleteEntity(abdiPed)
        abdiPed = nil
    end
end

function SpawnJobBil()
    local model = joaat(Config.Bil.model)

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    ClearAreaOfVehicles(
        Config.Bil.spawnCoords.x,
        Config.Bil.spawnCoords.y,
        Config.Bil.spawnCoords.z,
        5.0,
        false, false, false, false, false
    )

    spawnedBil = CreateVehicle(
        model,
        Config.Bil.spawnCoords.x,
        Config.Bil.spawnCoords.y,
        Config.Bil.spawnCoords.z,
        Config.Bil.spawnCoords.w,
        true,
        false
    )

    SetVehicleOnGroundProperly(spawnedBil)
    SetPedIntoVehicle(PlayerPedId(), spawnedBil, -1)
    SetVehicleEngineOn(spawnedBil, true, true)
    SetVehicleHasBeenOwnedByPlayer(spawnedBil, true)
    SetModelAsNoLongerNeeded(model)
end

CreateThread(function()
    local ped = SpawnNPC(Config.StartNPC)

    exports.ox_target:addLocalEntity(ped, {
        {
            label = Config.Text.reward_label,
            icon = 'fa-solid fa-sack-dollar',
            canInteract = function()
                return canClaimReward
            end,
            onSelect = function()
                if not spawnedBil or not DoesEntityExist(spawnedBil) then
                    ESX.ShowNotification(Config.Text.Bil_missing)
                    return
                end

                local distance = #(GetEntityCoords(spawnedBil) - Config.StartNPC.coords.xyz)
                if distance > Config.Bil.returnDistance then
                    ESX.ShowNotification(Config.Text.Bil_not_close)
                    return
                end

                PlayRewardAnimation()
                TriggerServerEvent('bubu_quest:reward')
                ESX.ShowNotification(Config.Text.reward_received)

                DeleteEntity(spawnedBil)
                spawnedBil = nil
                canClaimReward = false
                jobActive = false
            end
        },
        {
            label = Config.Text.start_job_label,
            icon = 'fa-solid fa-briefcase',
            canInteract = function()
                return not jobActive and not canClaimReward and not abdiPed
            end,
            onSelect = function()
                ESX.TriggerServerCallback('bubu_quest:canStartJob', function(canStart, remaining)
                    if not canStart then
                        local minutes = math.ceil(remaining / 60)
                        ESX.ShowNotification(string.format(Config.Text.cooldown, minutes))
                        return
                    end

                    SpawnAbdi()
                    ESX.ShowNotification(Config.Text.go_to_abdi)
                    SetNewWaypoint(Config.Abdi.coords.x, Config.Abdi.coords.y)
                end)
            end
        }
    })
end)

function StartRedZon()
    RedZonActive = true

    redRadiusBlip = AddBlipForRadius(Config.RedZon.coords.xyz, Config.RedZon.radius)
    SetBlipColour(redRadiusBlip, 1)
    SetBlipAlpha(redRadiusBlip, 150)


    CreateThread(function()
        local timer = Config.RedZon.duration
        while timer > 0 do
            Wait(1000)
            timer -= 1
            CheckZone()
        end
        EndRedZon()
    end)
end

function CheckZone()
    if not RedZonActive then return end
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= spawnedBil then return end

    local dist = #(GetEntityCoords(PlayerPedId()) - Config.RedZon.coords.xyz)
    if dist > Config.RedZon.radius and not policeAlertSent then
        policeAlertSent = true
        TriggerServerEvent('bubu_quest:outOfZone', GetEntityCoords(PlayerPedId()))
    end
end

RegisterNetEvent('bubu_quest:PolisRedZon', function()
    if redRadiusBlip then return end

    redRadiusBlip = AddBlipForRadius(
        Config.RedZon.coords.x,
        Config.RedZon.coords.y,
        Config.RedZon.coords.z,
        Config.RedZon.radius
    )

    SetBlipColour(redRadiusBlip, 1)
    SetBlipAlpha(redRadiusBlip, 120)
end)

RegisterNetEvent('bubu_quest:TaBortPolisRedZon', function()
    if redRadiusBlip then
        RemoveBlip(redRadiusBlip)
        redRadiusBlip = nil
    end
end)

RegisterNetEvent('bubu_quest:trackSuspect', function(targetId)
    local ped = GetPlayerPed(GetPlayerFromServerId(targetId))
    if not ped or ped == -1 then return end

    suspectBlip = AddBlipForEntity(ped)
    SetBlipSprite(suspectBlip, 42)
    SetBlipColour(suspectBlip, 1)
    SetBlipScale(suspectBlip, 1.2)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Misstänkt fordon')
    EndTextCommandSetBlipName(suspectBlip)
end)

RegisterNetEvent('bubu_quest:clearSuspect', function()
    if suspectBlip then
        RemoveBlip(suspectBlip)
        suspectBlip = nil
    end
end)

function CheckZone()
    if not RedZonActive then return end
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= spawnedBil then return end

    local dist = #(GetEntityCoords(PlayerPedId()) - Config.RedZon.coords.xyz)

    if dist > Config.RedZon.radius then
        if not policeAlertSent then
            policeAlertSent = true
            TriggerServerEvent('bubu_quest:outOfZone')
        end
    else
        if policeAlertSent then
            policeAlertSent = false
            TriggerServerEvent('bubu_quest:backInZone')
        end
    end
end

function EndRedZon()
    RedZonActive = false
    canClaimReward = true
    DeleteAbdi()

    if redRadiusBlip then
        RemoveBlip(redRadiusBlip)
        redRadiusBlip = nil
    end

    if policeAlertSent then
        policeAlertSent = false
        TriggerServerEvent('bubu_quest:backInZone')
    end

    ESX.ShowNotification(Config.Text.return_reward)
    SetNewWaypoint(Config.StartNPC.coords.x, Config.StartNPC.coords.y)
end