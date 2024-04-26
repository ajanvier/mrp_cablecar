local QBCore = exports['qb-core']:GetCoreObject()
local ResourceName = GetCurrentResourceName()

local AttachedToCablecar = nil
local CurrentCablecarOwned = nil
local InsideCablecar = nil

local CabinZones = {}
local Peds = {}
local PhoneDisabled = nil

-- Lerp, not to be confused with Liable Emerates Role Play
function Lerp(a, b, t)
	return a + (b - a) * t
end

-- Mass lerper
function VecLerp(x1, y1, z1, x2, y2, z2, l, clamp)
    if clamp then
        if l < 0.0 then l = 0.0 end
        if l > 1.0 then l = 1.0 end
    end
    local x = Lerp(x1, x2, l)
    local y = Lerp(y1, y2, l)
    local z = Lerp(z1, z2, l)
    return vec3(x, y, z)
end

function TeleportPlayerOnGround()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local groundFound, posZ = GetGroundZFor_3dCoord(pedCoords.x, pedCoords.y, pedCoords.z, true)

    local targetCoords
    if groundFound then
        targetCoords = vector3(pedCoords.x, pedCoords.y, posZ)
    else
        _, targetCoords = GetSafeCoordForPed(pedCoords.x, pedCoords.y, pedCoords.z, true, 0)
    end

    if Config.Debug then
        print(("^5Debug^7: Teleporting to %s, %s, %s^7)"):format(targetCoords.x, targetCoords.y, targetCoords.z))
    end

    SetEntityCoords(ped, targetCoords)
end

function ShowHelp(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function CreateProp(model, coords, freeze, synced)
    QBCore.Functions.LoadModel(model)
    local prop = CreateObject(model, coords.x, coords.y, coords.z-1.03, synced or false, synced or false, false)
    SetEntityAsMissionEntity(prop, true, true)
    SetEntityHeading(prop, coords.w)
    FreezeEntityPosition(prop, freeze or false)
    if Config.Debug then
        local formattedCoords = { string.format("%.2f", coords.x), string.format("%.2f", coords.y), string.format("%.2f", coords.z), (string.format("%.2f", coords.w or 0.0)) }
        print("^5Debug^7: ^1Prop ^2Created^7: '^6"..prop.."^7' | ^2Hash^7: ^7'^6"..model.."^7' | ^2Coord^7: ^5vec4^7(^6"..(formattedCoords[1]).."^7, ^6"..(formattedCoords[2]).."^7, ^6"..(formattedCoords[3]).."^7, ^6"..(formattedCoords[4]).."^7)")
    end
    return prop
end

function ReleaseRunningSound()
    if CurrentCablecarOwned and CurrentCablecarOwned.audio and CurrentCablecarOwned.audio ~= -1 then
        StopSound(CurrentCablecarOwned.audio)
        ReleaseSoundId(CurrentCablecarOwned.audio)
        CurrentCablecarOwned.audio = -1
    end
end

function SetCablecarDoors(state)
    if not CurrentCablecarOwned or CurrentCablecarOwned.state == 'MOVING' then return end

    local doorStart, doorDirect
    local doorClosePos = 0.95
	local doorOpenDist = 0.9
    if state == true then
        doorStart = doorClosePos
		doorDirect = 1
        PlaySoundFromEntity(-1, 'Arrive_Station', CurrentCablecarOwned.cabin, 'CABLE_CAR_SOUNDS', true, 0)
        PlaySoundFromEntity(-1, 'DOOR_OPEN', CurrentCablecarOwned.cabin, 'CABLE_CAR_SOUNDS', true, 0)
    else
        doorStart = doorClosePos + doorOpenDist
		doorDirect = -1
        PlaySoundFromEntity(-1, 'Leave_Station', CurrentCablecarOwned.cabin, 'CABLE_CAR_SOUNDS', true, 0)
        PlaySoundFromEntity(-1, 'DOOR_CLOSE', CurrentCablecarOwned.cabin, 'CABLE_CAR_SOUNDS', true, 0)
    end

	for i = 0, 100, 1 do
		local doorPos = doorStart + doorDirect * doorOpenDist * (i / 100)
		DetachEntity(CurrentCablecarOwned.doorLL, false, false)
		DetachEntity(CurrentCablecarOwned.doorLR, false, false)
		DetachEntity(CurrentCablecarOwned.doorRL, false, false)
		DetachEntity(CurrentCablecarOwned.doorRR, false, false)
		AttachEntityToEntity(CurrentCablecarOwned.doorLL, CurrentCablecarOwned.cabin, 0, 0.0, -doorPos, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
		AttachEntityToEntity(CurrentCablecarOwned.doorLR, CurrentCablecarOwned.cabin, 0, 0.0, doorPos, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
		AttachEntityToEntity(CurrentCablecarOwned.doorRL, CurrentCablecarOwned.cabin, 0, 0.0, doorPos, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 2, true)
		AttachEntityToEntity(CurrentCablecarOwned.doorRR, CurrentCablecarOwned.cabin, 0, 0.0, -doorPos, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 2, true)
		Wait(10)
	end
	Wait(2000)
end

function DisablePhone()
    if Config.DisablePhone then
        if GetResourceState('lb-phone') == 'started' then
            PhoneDisabled = exports['lb-phone']:IsDisabled()
            exports['lb-phone']:ToggleDisabled(true)
        end
    end
end

function EnablePhone()
    if Config.DisablePhone then
        if GetResourceState('lb-phone') == 'started' then
            exports['lb-phone']:ToggleDisabled(PhoneDisabled)
        end

        PhoneDisabled = nil
    end
end

function AttachPlayer(entity)
    if AttachedToCablecar then return end

    local ped = PlayerPedId()
    local cablecarPosition = GetEntityCoords(entity)
    FreezeEntityPosition(ped, true)
    AttachEntityToEntity(ped, entity, 0, (GetEntityCoords(ped) - cablecarPosition), GetEntityRotation(ped, 0), false, false, false, true, 0, false)

    -- Disable phone while attached
    DisablePhone()

    AttachedToCablecar = InsideCablecar
end

function DetachPlayer()
    if not AttachedToCablecar then return end

    EnablePhone()

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    DetachEntity(ped, false, false)
    AttachedToCablecar = nil
end

function KickOutOfCablecar(entity)
    local ped = PlayerPedId()
    local _, rightvec, _ = GetEntityMatrix(entity)
    local right = vector3(rightvec.x * 3.5, rightvec.y * 3.5, rightvec.z * 3.5)
    SetEntityCoords(ped, GetEntityCoords(entity) + right + vec3(0.0, 0.0, -5.3))
end

function StartCablecar()
    if not CurrentCablecarOwned or CurrentCablecarOwned.state ~= 'READY' then return end

    CurrentCablecarOwned.audio = GetSoundId()
    PlaySoundFromEntity(CurrentCablecarOwned.audio, 'Running', CurrentCablecarOwned.cabin, 'CABLE_CAR_SOUNDS', true, 0)
    TriggerServerEvent(ResourceName..':server:StartCablecar', CurrentCablecarOwned.id)

    CreateThread(function()
        SetCablecarDoors(false)
        CurrentCablecarOwned.state = 'MOVING'

        Wait(1000)

        local conf = Config.CableCars[CurrentCablecarOwned.id]

        local origin = conf.path[1]
        local destination = conf.path[#conf.path]

        local gradient = 0.0
        local runTimer = 0.0

        while CurrentCablecarOwned and CurrentCablecarOwned.currentStep < #conf.path do
            local cabinPosition = GetEntityCoords(CurrentCablecarOwned.cabin)

            local prevPoint = conf.path[CurrentCablecarOwned.currentStep]
            local nextPoint = conf.path[CurrentCablecarOwned.currentStep + 1]

            local distanceFromOrigin = #(origin - cabinPosition)
            local distanceFromDestin = #(destination - cabinPosition)

            gradient = gradient == 0.0 and #(prevPoint - nextPoint) or gradient

            local speed = ((1.0 / gradient) * Timestep()) * conf.maxSpeed
            if distanceFromOrigin <= conf.maxSpeedDist then
                speed = speed * math.abs(distanceFromOrigin + 1) / conf.maxSpeedDist
            elseif distanceFromDestin <= conf.maxSpeedDist then
                speed = speed * math.abs(distanceFromDestin + 1) / conf.maxSpeedDist
            end

            -- Add the speed to the timer
            runTimer += speed

            -- Add a bit of "hang" on the long segments since the cable sags slightly (ATTENTION TO DETAIL!! xd)
            local zLerp = 0.0
            if gradient > 30.0 then zLerp = (-1.0 + math.abs(Lerp(1.0, -1.0, runTimer))) * 0.25 end

            local targetCoords = VecLerp(prevPoint.x, prevPoint.y, prevPoint.z, nextPoint.x, nextPoint.y, nextPoint.z, runTimer, true) + conf.offset + vec3(0.0, 0.0, zLerp)

            -- Set the position of the car
            SetEntityCoords(CurrentCablecarOwned.cabin, targetCoords.x, targetCoords.y, targetCoords.z, true, false, false, true)

            if runTimer > 1.0 then
                CurrentCablecarOwned.currentStep += 1
                gradient = 0.0
                runTimer = 0.0
            end

            Wait(0)
        end

        EndCablecar()
    end)
end

function EndCablecar()
    if not CurrentCablecarOwned then return end

    CurrentCablecarOwned.state = 'ENDED'
    TriggerServerEvent(ResourceName..':server:EndCablecar', CurrentCablecarOwned.id)
    SetCablecarDoors(true)

    SetTimeout(Config.DelayToKickCablecarPassengers, RemoveCablecar)
end

function RemoveCablecar()
    if not CurrentCablecarOwned then return end

    TriggerServerEvent(ResourceName..':server:RemoveCablecar', CurrentCablecarOwned.id)
    DestroyCablecar()
end

function DestroyCablecar()
    if not CurrentCablecarOwned then return end

    local entities = {CurrentCablecarOwned.cabin, CurrentCablecarOwned.doorLL, CurrentCablecarOwned.doorLR, CurrentCablecarOwned.doorRL, CurrentCablecarOwned.doorRR}
    for i = 1, #entities do
        local entity = entities[i]
        SetEntityAsNoLongerNeeded(entity)
        DeleteEntity(entity)
    end

    CurrentCablecarOwned = nil
end

function SpawnCablecar(cablecarId)
    local cablecar = {}
    local conf = Config.CableCars[cablecarId]

    cablecar.id = cablecarId
    cablecar.state = 'READY'
    cablecar.currentStep = 1

    cablecar.cabin = CreateProp('p_cablecar_s', conf.cabinCoords, true, true)

    cablecar.doorLL = CreateProp('p_cablecar_s_door_l', conf.doorsCoords, true, true)
    cablecar.doorLR = CreateProp('p_cablecar_s_door_r', conf.doorsCoords, true, true)
    cablecar.doorRL = CreateProp('p_cablecar_s_door_l', conf.doorsCoords, true, true)
    cablecar.doorRR = CreateProp('p_cablecar_s_door_r', conf.doorsCoords, true, true)

    AttachEntityToEntity(cablecar.doorLL, cablecar.cabin, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
    AttachEntityToEntity(cablecar.doorLR, cablecar.cabin, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
    AttachEntityToEntity(cablecar.doorRL, cablecar.cabin, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 2, true)
    AttachEntityToEntity(cablecar.doorRR, cablecar.cabin, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 2, true)

    TriggerServerEvent(
        ResourceName..':server:RegisterCablecar',
        cablecar.id,
        NetworkGetNetworkIdFromEntity(cablecar.cabin),
        {
            NetworkGetNetworkIdFromEntity(cablecar.doorLL),
            NetworkGetNetworkIdFromEntity(cablecar.doorLR),
            NetworkGetNetworkIdFromEntity(cablecar.doorRL),
            NetworkGetNetworkIdFromEntity(cablecar.doorRR)
        }
    )

    CurrentCablecarOwned = cablecar

    SetEntityCoords(cablecar.cabin, conf.path[1] + conf.offset + vec3(0.0, 0.0, 0.0), 1, false, false, true)
    SetCablecarDoors(true)
    ReleaseRunningSound()

    CreateThread(function()
        while CurrentCablecarOwned and CurrentCablecarOwned.state == 'READY' do
            if InsideCablecar == CurrentCablecarOwned.id then
                ShowHelp(Lang:t('help.start'))
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent(ResourceName..':server:StartCablecar', CurrentCablecarOwned.id)
                    StartCablecar()
                end
            end

            Wait(0)
        end
    end)
end

function TryToSpawnCablecar(cablecarId)
    QBCore.Functions.TriggerCallback(ResourceName..':server:CanSpawnCablecar', function(canSpawn)
        if canSpawn then
            SpawnCablecar(cablecarId)
        end
    end, cablecarId)
end

function Initialize()
    -- Load models
    QBCore.Functions.LoadModel('p_cablecar_s')
    QBCore.Functions.LoadModel('p_cablecar_s_door_l')
    QBCore.Functions.LoadModel('p_cablecar_s_door_r')
    -- Load sounds
    RequestScriptAudioBank('CABLE_CAR', false)
    RequestScriptAudioBank('CABLE_CAR_SOUNDS', false)
    LoadStream('CABLE_CAR', 'CABLE_CAR_SOUNDS')
    LoadStream('CABLE_CAR_SOUNDS', 'CABLE_CAR')

    for cablecarId, cablecar in pairs(Config.CableCars) do
        if cablecar.ped and not Peds[cablecarId] then
            -- Create peds
            QBCore.Functions.LoadModel(cablecar.ped.model)
            local ped = CreatePed(0, cablecar.ped.model, cablecar.ped.coords.x, cablecar.ped.coords.y, cablecar.ped.coords.z, cablecar.ped.coords.w, false, false)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanPlayAmbientAnims(ped, true)

            if cablecar.ped.scenario then
                TaskStartScenarioInPlace(ped, cablecar.ped.scenario, 0, true)
            end

            exports.ox_target:addLocalEntity(ped, {
                label = Lang:t('target.call_cablecar', {price = Config.Price}),
                icon = 'fas fa-cable-car',
                distance = 2.0,
                onSelect = function()
                    TryToSpawnCablecar(cablecarId)
                end
            })

            Peds[cablecarId] = ped
        end
    end
end

local function Unload()
    SetModelAsNoLongerNeeded('p_cablecar_s')
    SetModelAsNoLongerNeeded('p_cablecar_s_door_l')
    SetModelAsNoLongerNeeded('p_cablecar_s_door_r')
    ReleaseScriptAudioBank()

    for _, ped in pairs(Peds) do
        DeletePed(ped)
    end

    Peds = {}
end

function CablecarRegistered(cablecarId)
    local cablecar = Config.CableCars[cablecarId]

    CabinZones[cablecarId..'_start'] = PolyZone:Create(cablecar.cabinStartZone.points, {
        name = ('%s__cabin_start_%s'):format(ResourceName, cablecarId),
        minZ = cablecar.cabinStartZone.minZ,
        maxZ = cablecar.cabinStartZone.maxZ,
        data = {
            id = cablecarId
        }
    })
    CabinZones[cablecarId..'_start']:onPlayerInOut(function(isPointInside)
        InsideCablecar = isPointInside and cablecarId or nil
    end)

    CabinZones[cablecarId..'_end'] = PolyZone:Create(cablecar.cabinEndZone.points, {
        name = ('%s__cabin_end_%s'):format(ResourceName, cablecarId),
        minZ = cablecar.cabinEndZone.minZ,
        maxZ = cablecar.cabinEndZone.maxZ,
        data = {
            id = cablecarId
        }
    })
    CabinZones[cablecarId..'_end']:onPlayerInOut(function(isPointInside)
        InsideCablecar = isPointInside and cablecarId or nil
    end)
end

function CablecarStarting(cablecarId, cabinNetId)
    if InsideCablecar and not AttachedToCablecar and InsideCablecar == cablecarId then
        local entity = NetworkGetEntityFromNetworkId(cabinNetId)
        AttachPlayer(entity)
    end
end

function CablecarEnding(cablecarId)
    if AttachedToCablecar and AttachedToCablecar == cablecarId then
        DetachPlayer()
    end
end

function CablecarRemoved(cablecarId, cabinNetId, failure)
    CablecarEnding(cablecarId)

    if failure then
        TeleportPlayerOnGround()
    elseif InsideCablecar and InsideCablecar == cablecarId then
        local entity = NetworkGetEntityFromNetworkId(cabinNetId)
        KickOutOfCablecar(entity)
    end

    if CurrentCablecarOwned and CurrentCablecarOwned.id == cablecarId then
        DestroyCablecar()
    end

    CabinZones[cablecarId..'_start']:destroy()
    CabinZones[cablecarId..'_end']:destroy()
end

RegisterNetEvent(ResourceName..':client:CablecarRegistered', CablecarRegistered)
RegisterNetEvent(ResourceName..':client:CablecarStarting', CablecarStarting)
RegisterNetEvent(ResourceName..':client:CablecarEnding', CablecarEnding)
RegisterNetEvent(ResourceName..':client:CablecarRemoved', CablecarRemoved)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Initialize()
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= ResourceName then return end
    Initialize()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= ResourceName then return end
	Unload()
end)

AddEventHandler('hospital:client:SetLaststandStatus', function(status)
    if status and AttachedToCablecar then
        -- Detach player in case of death
        DetachPlayer()
        TeleportPlayerOnGround()
    end
end)