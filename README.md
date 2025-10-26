# FX Serial
A comprehensive weapon registration and serial number checking system for ESX servers using ox_lib and ox_inventory.

## Features
- **Weapon Registration:** Players can register their weapons at an NPC location
- **Serial Number Checking:** Police can check weapon serial numbers and their owner using a serial checker item
- **Database Integration:** All registrations are stored in a MySQL database with timestamps
- **Police Authorization:** Only authorized police jobs can check and unregister weapons
- **Unregister Functionality:** Police can remove weapons from the registration database

## Requirements
- ESX Framework (`es_extended`)
- `ox_lib`
- `ox_inventory`
- `ox_target`
- `oxmysql`

## Installation
1. Download the script
2. Put the `fx_serial` folder into your `resources` directory
4. Open `config.lua` and configure settings to your preference
5. Add `ensure fx_serial` to your `server.cfg`
6. Add the `serial_checker` item to your ox_inventory items.lua:
```lua
	["serial_checker"] = {
		label = "Serial Checker",
		weight = 1300,
		stack = false,
		close = true,
    description = 'Police device for checking weapon serial numbers'
}
```
7. Restart your server

## Configuration
All settings are located in the `config.lua` file:

## Support
For issues, feature requests, or updates, visit the GitHub repository.
