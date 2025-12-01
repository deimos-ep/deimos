local cache = {}

cache.flags = {}
cache.conns = {}

cache.hide_spot = nil
cache.flash_effects = {}
cache.doors = nil
cache.shoot_cooldown = false
cache.tools_initted = false
cache.SendResponse = nil
cache.ValidateCommand = nil
cache.help_window = nil
cache.keybinds_window = nil
cache.startup_window = nil
cache.interact_objects = {}
cache.players_data = nil
cache.killaura_mode = nil
cache.GetRemote = nil
cache.GetWeaponKey = nil
cache.weaponkey_cmds = {
    spkill = false,
    teamheal = false
}
cache.npcs_in_tower = {}
cache.npcs_in_orbit = {}
cache.npcs_data = {}
cache.complex_cmds = {
    killboss = nil,
    autofarm = nil,
    lockinteract = nil,
    unlockinteract = nil
}
cache.locked_interacts = {}
cache.disarm = {}
cache.commands_holder = nil

return cache