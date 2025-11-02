fx = {}

fx.npc = {
    model = 's_m_y_sheriff_01',
    coords = vector4(1818.5820, 3672.5400, 34.7124, 129.8359), --Update these coords to match your police station, these are from https://gn.studio/package/sheriff-department
    scenario = 'WORLD_HUMAN_CLIPBOARD'
}

fx.policejobs = {
    'police',
    'sheriff'
}

fx.checkeritem = 'serial_checker'

fx.timezone = {
    offset = 0,
    -- Offsets:
    -- -8 = Pacific Standard Time (PST)
    -- -7 = Mountain Standard Time (MST)
    -- -6 = Central Standard Time (CST)
    -- -5 = Eastern Standard Time (EST)
    -- 0 = Greenwich Mean Time (GMT)
    -- 1 = Central European Time (CET)
    -- 2 = Eastern European Time (EET)
    -- 8 = China Standard Time (CST)
    -- 9 = Japan Standard Time (JST)
    -- 10 = Australian Eastern Standard Time (AEST)
}

fx.supportedweapons = {
    {weapon = 'WEAPON_PISTOL', label = 'Pistol'},
    {weapon = 'WEAPON_COMBATPISTOL', label = 'Combat Pistol'},
}

fx.target = {
    label = 'Register Firearm',
    icon = 'fas fa-clipboard',
    distance = 2.5
}

fx.animation = { --credits: https://github.com/Scullyy/scully_emotemenu/blob/main/shared/data/emotes/prop_emotes.lua
    label = 'Tablet',
    command = 'tablet',
    animation = 'base',
    dictionary = 'amb@world_human_tourist_map@male@base',
    options = {
        flags = {
            loop = true,
            move = true,
        },
        props = {
            {
                bone = 28422,
                name = 'prop_cs_tablet',
                placement = {
                    vec3(0.0, -0.03, 0.0),
                    vec3(20.0, -90.0, 0.0),
                },
            },
        },
    },
}

fx.messages = {
    no_weapons = 'You have no weapons to register',
    select_weapon = 'Select Weapon to Register',
    enter_serial = 'Enter Weapon Serial Number',
    serial_placeholder = 'ABC123456',
    registration_success = 'Weapon registered successfully!',
    registration_failed = 'Failed to register weapon',
    duplicate_serial = 'This serial number is already registered',
    invalid_serial = 'Invalid serial number',
    not_police = 'You are not authorized to use this device',
    enter_serial_check = 'Enter Serial Number to Check',
    check_failed = 'Failed to check weapon serial',
    no_serial = 'No serial number entered',
    registered_title = 'Registered Weapon',
    not_registered_title = 'Unknown Weapon',
    owner_label = 'Owner Name',
    weapon_label = 'Weapon Type',
    date_label = 'Registration Date',
    status_label = 'Status',
    status_registered = 'Legally Registered',
    status_not_registered = 'Not Registered',
    unknown = 'Unknown',
    unregister_button = 'Unregister Weapon',
    unregister_success = 'Weapon unregistered successfully!',
    unregister_failed = 'Failed to unregister weapon',
    unregister_confirm_title = 'Confirm Unregistration',
    unregister_confirm_description = 'Are you sure you want to unregister this weapon?'
}
