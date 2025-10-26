local npcped = nil
local npcspawned = false
local isanimating = false
local animationprop = nil

local function cleanup()
    if isanimating then
        isanimating = false
    end
    
    if animationprop and DoesEntityExist(animationprop) then
        DeleteEntity(animationprop)
        animationprop = nil
    end
    
    local playerped = PlayerPedId()
    ClearPedTasks(playerped)
end

local function startanimation()
    if isanimating then return end
    
    local playerped = PlayerPedId()
    
    RequestAnimDict(fx.animation.dictionary)
    while not HasAnimDictLoaded(fx.animation.dictionary) do
        Wait(100)
    end
    
    RequestModel(fx.animation.options.props[1].name)
    while not HasModelLoaded(fx.animation.options.props[1].name) do
        Wait(100)
    end
    
    animationprop = CreateObject(GetHashKey(fx.animation.options.props[1].name), 0.0, 0.0, 0.0, true, true, true)
    local boneindex = GetPedBoneIndex(playerped, fx.animation.options.props[1].bone)
    
    AttachEntityToEntity(
        animationprop,
        playerped,
        boneindex,
        fx.animation.options.props[1].placement[1].x,
        fx.animation.options.props[1].placement[1].y,
        fx.animation.options.props[1].placement[1].z,
        fx.animation.options.props[1].placement[2].x,
        fx.animation.options.props[1].placement[2].y,
        fx.animation.options.props[1].placement[2].z,
        true, true, false, true, 1, true
    )
    
    TaskPlayAnim(playerped, fx.animation.dictionary, fx.animation.animation, 8.0, -8.0, -1, 49, 0, false, false, false)
    
    isanimating = true
    
    CreateThread(function()
        while isanimating do
            Wait(1000)
            if not IsEntityPlayingAnim(playerped, fx.animation.dictionary, fx.animation.animation, 3) then
                TaskPlayAnim(playerped, fx.animation.dictionary, fx.animation.animation, 8.0, -8.0, -1, 49, 0, false, false, false)
            end
        end
        
        if animationprop and DoesEntityExist(animationprop) then
            DeleteEntity(animationprop)
            animationprop = nil
        end
        ClearPedTasks(PlayerPedId())
    end)
end

local function stopanimation()
    cleanup()
end

local function openregistrationmenu()
    ESX.TriggerServerCallback('fx_serial:getplayerweapons', function(weapons)
        if not weapons or #weapons == 0 then
            lib.notify({
                title = 'Registration',
                description = fx.messages.no_weapons,
                type = 'error'
            })
            return
        end

        local weaponoptions = {}
        for _, weapon in ipairs(weapons) do
            table.insert(weaponoptions, {
                value = weapon,
                label = weapon
            })
        end

        local input = lib.inputDialog('Weapon Registration', {
            {
                type = 'select',
                label = fx.messages.select_weapon,
                options = weaponoptions,
                required = true
            },
            {
                type = 'input',
                label = fx.messages.enter_serial,
                placeholder = fx.messages.serial_placeholder,
                required = true,
                min = 5,
                max = 20
            }
        })

        if not input then return end

        local weapon = input[1]
        local serial = input[2]

        if not weapon or not serial or serial == '' then
            lib.notify({
                title = 'Registration',
                description = fx.messages.invalid_serial,
                type = 'error'
            })
            return
        end
        local playerped = PlayerPedId()
        RequestAnimDict('misscarsteal4@actor')
        while not HasAnimDictLoaded('misscarsteal4@actor') do
            Wait(100)
        end
        TaskPlayAnim(playerped, 'misscarsteal4@actor', 'actor_berating_loop', 8.0, -8.0, -1, 49, 0, false, false, false)
        if lib.progressBar({
            duration = 5000,
            label = 'Registering weapon...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
        }) then
            ClearPedTasks(playerped)
            TriggerServerEvent('fx_serial:registerweapon', weapon, serial)
        else
            ClearPedTasks(playerped)
            lib.notify({
                title = 'Registration',
                description = 'Registration cancelled',
                type = 'error'
            })
        end
    end)
end

CreateThread(function()
    RequestModel(fx.npc.model)
    while not HasModelLoaded(fx.npc.model) do
        Wait(100)
    end

    npcped = CreatePed(4, fx.npc.model, fx.npc.coords.x, fx.npc.coords.y, fx.npc.coords.z - 1.0, fx.npc.coords.w, false, true)
    
    SetEntityHeading(npcped, fx.npc.coords.w)
    FreezeEntityPosition(npcped, true)
    SetEntityInvincible(npcped, true)
    SetBlockingOfNonTemporaryEvents(npcped, true)
    TaskStartScenarioInPlace(npcped, fx.npc.scenario, 0, true)

    exports.ox_target:addLocalEntity(npcped, {
        {
            name = 'weapon_registration',
            label = fx.target.label,
            icon = fx.target.icon,
            distance = fx.target.distance,
            onSelect = function()
                openregistrationmenu()
            end
        }
    })

    npcspawned = true
end)

AddEventHandler('onResourceStop', function(resourcename)
    if GetCurrentResourceName() ~= resourcename then return end
    
    cleanup()
    
    if DoesEntityExist(npcped) then
        DeleteEntity(npcped)
    end
end)

RegisterNetEvent('fx_serial:usechecker', function()
    startanimation()
    
    Wait(500)
    
    local input = lib.inputDialog('Weapon Serial Checker', {
        {
            type = 'input',
            label = fx.messages.enter_serial_check,
            placeholder = fx.messages.serial_placeholder,
            required = true,
            min = 5,
            max = 20
        }
    })

    if not input or not input[1] or input[1] == '' then
        stopanimation()
        lib.notify({
            title = 'Serial Checker',
            description = fx.messages.no_serial,
            type = 'error'
        })
        return
    end

    TriggerServerEvent('fx_serial:checkserial', input[1])
end)

RegisterNetEvent('fx_serial:showweaponinfo', function(data)
    
    local menuoptions = {}
    
    if data.registered then
        table.insert(menuoptions, {
            title = fx.messages.owner_label,
            description = data.owner or fx.messages.unknown,
            icon = 'user',
            readOnly = true
        })
        table.insert(menuoptions, {
            title = fx.messages.weapon_label,
            description = data.weapon or fx.messages.unknown,
            icon = 'gun',
            readOnly = true
        })
        table.insert(menuoptions, {
            title = fx.messages.date_label,
            description = tostring(data.date or fx.messages.unknown),
            icon = 'calendar',
            readOnly = true
        })
        table.insert(menuoptions, {
            title = fx.messages.status_label,
            description = fx.messages.status_registered,
            icon = 'check-circle',
            iconColor = '#00FF00',
            readOnly = true
        })
        table.insert(menuoptions, {
            title = fx.messages.unregister_button,
            icon = 'trash',
            iconColor = '#FF0000',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = fx.messages.unregister_confirm_title,
                    content = fx.messages.unregister_confirm_description,
                    centered = true,
                    cancel = true
                })
                
                if alert == 'confirm' then
                    TriggerServerEvent('fx_serial:unregisterweapon', data.serial)
                    stopanimation()
                end
            end

        })
        
        lib.registerContext({
            id = 'oxinfo',
            title = fx.messages.registered_title,
            onExit = function()
                stopanimation()
            end,
            options = menuoptions
        })
    else
        table.insert(menuoptions, {
            title = fx.messages.owner_label,
            description = fx.messages.unknown,
            icon = 'user',
            readOnly = true
        })
        table.insert(menuoptions, {
            title = fx.messages.weapon_label,
            description = fx.messages.unknown,
            icon = 'gun',
            readOnly = true
        })
        table.insert(menuoptions, {
            title = fx.messages.date_label,
            description = fx.messages.unknown,
            icon = 'calendar',
            readOnly = true
        })
        table.insert(menuoptions, {
            title = fx.messages.status_label,
            description = fx.messages.status_not_registered,
            icon = 'times-circle',
            iconColor = '#FF0000',
            readOnly = true

        })
        
        lib.registerContext({
            id = 'oxinfo',
            title = fx.messages.not_registered_title,
            onExit = function()
                stopanimation()
            end,
            options = menuoptions
        })
    end

    lib.showContext('oxinfo')
    
    CreateThread(function()
        while isanimating do
            Wait(100)
            if not lib.getOpenContextMenu() then
                stopanimation()
                break
            end
        end
    end)
end)

RegisterNetEvent('fx_serial:stopanimation', function()
    stopanimation()
end)

RegisterNetEvent('fx_serial:notify', function(title, message, type)
    lib.notify({
        title = title,
        description = message,
        type = type
    })
end)
