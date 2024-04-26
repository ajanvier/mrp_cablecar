local QBCore = exports['qb-core']:GetCoreObject()
local ResourceName = GetCurrentResourceName()

local CableCars = {}

local function DeleteEntityIfExisting(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end

local function CleanupCablecarEntities(cablecar)
    DeleteEntityIfExisting(cablecar.cabinNetId)
    for i = 1, #cablecar.doorsNetIds do
        DeleteEntityIfExisting(cablecar.doorsNetIds[i])
    end
end

local function RemoveCablecar(cablecarId, failure)
    local cablecar = CableCars[cablecarId]
    if not cablecar then return end

    TriggerClientEvent(ResourceName..':client:CablecarRemoved', -1, cablecarId, cablecar.cabinNetId, failure)
    CableCars[cablecarId] = nil

    Wait(1000)
    CleanupCablecarEntities(cablecar)
end

RegisterNetEvent(ResourceName..':server:RegisterCablecar', function(cablecarId, cabinNetId, doorsNetIds)
    local src = source

    CableCars[cablecarId] = {
        cabinNetId = cabinNetId,
        doorsNetIds = doorsNetIds,
        object = NetworkGetEntityFromNetworkId(cabinNetId),
        owner = src,
        started = false
    }

    TriggerClientEvent(ResourceName..':client:CablecarRegistered', -1, cablecarId)

    -- Auto-cleanup after some amount of inactivity
    SetTimeout(Config.DelayToRemoveInactiveCablecar, function()
        if CableCars[cablecarId] and not CableCars[cablecarId].started then
            RemoveCablecar(cablecarId)
        end
    end)
end)

RegisterNetEvent(ResourceName..':server:StartCablecar', function(cablecarId)
    local src = source
    local cablecar = CableCars[cablecarId]

    if not cablecar or cablecar.owner ~= src then return end

    CableCars[cablecarId].started = true
    TriggerClientEvent(ResourceName..':client:CablecarStarting', -1, cablecarId, cablecar.cabinNetId)
end)

RegisterNetEvent(ResourceName..':server:EndCablecar', function(cablecarId)
    local src = source
    local cablecar = CableCars[cablecarId]

    if not cablecar or cablecar.owner ~= src then return end
    TriggerClientEvent(ResourceName..':client:CablecarEnding', -1, cablecarId)
end)

RegisterNetEvent(ResourceName..':server:RemoveCablecar', function(cablecarId)
    local src = source
    local cablecar = CableCars[cablecarId]

    if not cablecar or cablecar.owner ~= src then return end
    RemoveCablecar(cablecarId)
end)

QBCore.Functions.CreateCallback(ResourceName..':server:CanSpawnCablecar', function(source, cb, cablecarId)
    local Player = QBCore.Functions.GetPlayer(source)
    local success = false

    if not CableCars[cablecarId] then
        if Player.Functions.RemoveMoney('cash', Config.Price) then
            success = true
        else
            Player.Functions.Notify(Lang:t('error.not_enough_money'), 'error')
        end
    else
        Player.Functions.Notify(Lang:t('error.cablecar_in_use'), 'error')
    end

    cb(success)
end)

AddEventHandler('playerDropped', function ()
    local src = source

    -- Remove cablecar if owner disconnects
    for cablecarId, cablecar in pairs(CableCars) do
        if cablecar.owner == src then
            RemoveCablecar(cablecarId, true)
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= ResourceName then return end

    for cablecarId, cablecar in pairs(CableCars) do
        TriggerClientEvent(ResourceName..':client:CablecarRemoved', -1, cablecarId, cablecar.cabinNetId)
    end
end)