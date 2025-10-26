local version = '1.0'

local function checkversion()
    CreateThread(function()
        PerformHttpRequest('https://raw.githubusercontent.com/fluxcz/versions/refs/heads/main/all.json', function(err, text, headers)
            if text then
                local data = json.decode(text)
                if data and data['fx-serial'] then
                    local newestversion = data['fx-serial'].latest
                    if newestversion and newestversion > version then
                        print('^1-------------------------------------------------^7')
                        print('^6New Version Released for fx_serial^7')
                        print('')
                        print(string.format('^1Your Version: ^7%s', version))
                        print(string.format('^6Newest Version: ^7%s', newestversion))
                        print('')
                        print('^6Changelog^7')
                        for i, change in ipairs(data['fx-serial'].changelog) do
                            print(string.format('^7%s', change))
                        end
                        print('^1-------------------------------------------------^7')
                    else
                        print('^6[fx_serial] You are running the latest version.^7')
                    end
                end
            else
                print('^1[fx_serial] Could not check for new version.^7')
            end
        end, 'GET', '', {})
    end)
end

local function initializedatabase()
    CreateThread(function()
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `fx_guns` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `identifier` varchar(64) NOT NULL,
                `weapon` varchar(64) NOT NULL,
                `serial` varchar(64) NOT NULL,
                `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                UNIQUE KEY `serial` (`serial`),
                KEY `identifier` (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
 
    end)
end

local function converttotimezone(mysqltimestamp)
    if not mysqltimestamp then
        return fx.messages.unknown
    end
    
    if type(mysqltimestamp) == 'string' then
        local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
        local year, month, day, hour, min, sec = mysqltimestamp:match(pattern)
        
        if year then
            return string.format("%s-%s-%s %s:%s", year, month, day, hour, min)
        end
    end
    
    if type(mysqltimestamp) == 'number' then
        local offsetseconds = (fx.timezone.offset or 0) * 3600
        local localtimestamp = mysqltimestamp + offsetseconds
        return os.date('%Y-%m-%d %H:%M', localtimestamp)
    end
    
    return fx.messages.unknown
end

local function getplayerweapons(source, cb)
    local xplayer = ESX.GetPlayerFromId(source)
    if not xplayer then 
        cb({})
        return 
    end

    local weapons = {}
    local inventory = exports.ox_inventory:GetInventoryItems(source)

    if not inventory then
        cb({})
        return
    end

    for _, item in pairs(inventory) do
        if item.name and item.metadata and item.metadata.serial then
            for _, supportedweapon in ipairs(fx.supportedweapons) do
                if string.upper(item.name) == supportedweapon then
                    table.insert(weapons, item.name)
                    break
                end
            end
        end
    end

    cb(weapons)
end

local function registerweapon(source, weapon, serial)
    local xplayer = ESX.GetPlayerFromId(source)
    if not xplayer then return end

    local issupported = false
    for _, supportedweapon in ipairs(fx.supportedweapons) do
        if string.upper(weapon) == supportedweapon then
            issupported = true
            break
        end
    end

    if not issupported then
        TriggerClientEvent('fx_serial:notify', source, 'Registration', fx.messages.registration_failed, 'error')
        return
    end

    MySQL.single('SELECT id FROM fx_guns WHERE serial = ?', {serial}, function(result)
        if result then
            TriggerClientEvent('fx_serial:notify', source, 'Registration', fx.messages.duplicate_serial, 'error')
            return
        end

        MySQL.insert('INSERT INTO fx_guns (identifier, weapon, serial) VALUES (?, ?, ?)', {
            xplayer.identifier,
            weapon,
            serial
        }, function(insertid)
            if insertid then
                TriggerClientEvent('fx_serial:notify', source, 'Registration', fx.messages.registration_success, 'success')
                
            else
                TriggerClientEvent('fx_serial:notify', source, 'Registration', fx.messages.registration_failed, 'error')
            end
        end)
    end)
end

local function checkserial(source, serial)
    local xplayer = ESX.GetPlayerFromId(source)
    if not xplayer then 
        TriggerClientEvent('fx_serial:stopanimation', source)
        return 
    end

    local ispolice = false
    for _, job in ipairs(fx.policejobs) do
        if xplayer.job.name == job then
            ispolice = true
            break
        end
    end

    if not ispolice then
        TriggerClientEvent('fx_serial:notify', source, 'Serial Checker', fx.messages.not_police, 'error')
        TriggerClientEvent('fx_serial:stopanimation', source)
        return
    end

    MySQL.single('SELECT * FROM fx_guns WHERE serial = ?', {serial}, function(result)
        if result then
            MySQL.single('SELECT firstname, lastname FROM users WHERE identifier = ?', {result.identifier}, function(user)
                local ownername = fx.messages.unknown
                if user then
                    ownername = user.firstname .. ' ' .. user.lastname
                end

                local formatteddate = converttotimezone(result.time)
                
                local dataToSend = {
                    registered = true,
                    owner = ownername,
                    weapon = result.weapon,
                    date = formatteddate or "2025-10-25 23:34",
                    serial = serial
                }

                TriggerClientEvent('fx_serial:showweaponinfo', source, dataToSend)
            end)
        else
            TriggerClientEvent('fx_serial:showweaponinfo', source, {
                registered = false
            })
        end
    end)
end

local function unregisterweapon(source, serial)
    local xplayer = ESX.GetPlayerFromId(source)
    if not xplayer then 
        TriggerClientEvent('fx_serial:stopanimation', source)
        return 
    end

    local ispolice = false
    for _, job in ipairs(fx.policejobs) do
        if xplayer.job.name == job then
            ispolice = true
            break
        end
    end

    if not ispolice then
        TriggerClientEvent('fx_serial:notify', source, 'Unregister', fx.messages.not_police, 'error')
        TriggerClientEvent('fx_serial:stopanimation', source)
        return
    end

    MySQL.single('SELECT * FROM fx_guns WHERE serial = ?', {serial}, function(result)
        if result then
            MySQL.query('DELETE FROM fx_guns WHERE serial = ?', {serial}, function(deleteResult)
                if deleteResult and deleteResult.affectedRows > 0 then
                    TriggerClientEvent('fx_serial:notify', source, 'Weapon Unregistered', 
                        string.format('You have unregistered the weapon with serial: %s', serial), 
                        'success')
                else
                    TriggerClientEvent('fx_serial:notify', source, 'Unregister', fx.messages.unregister_failed, 'error')
                end
            end)
        else
            TriggerClientEvent('fx_serial:notify', source, 'Unregister', fx.messages.unregister_failed, 'error')
        end
    end)
end

local function usechecker(source)
    local xplayer = ESX.GetPlayerFromId(source)
    if not xplayer then return end

    local ispolice = false
    for _, job in ipairs(fx.policejobs) do
        if xplayer.job.name == job then
            ispolice = true
            break
        end
    end

    if not ispolice then
        TriggerClientEvent('fx_serial:notify', source, 'Serial Checker', fx.messages.not_police, 'error')
        return
    end

    TriggerClientEvent('fx_serial:usechecker', source)
end

checkversion()
initializedatabase()

ESX.RegisterServerCallback('fx_serial:getplayerweapons', function(source, cb)
    getplayerweapons(source, cb)
end)

RegisterNetEvent('fx_serial:registerweapon', function(weapon, serial)
    registerweapon(source, weapon, serial)
end)

RegisterNetEvent('fx_serial:checkserial', function(serial)
    checkserial(source, serial)
end)

RegisterNetEvent('fx_serial:unregisterweapon', function(serial)
    unregisterweapon(source, serial)
end)

ESX.RegisterUsableItem(fx.checkeritem, function(source)
    usechecker(source)
end)
