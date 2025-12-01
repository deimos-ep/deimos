local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local gui_util = require("../modules/gui_util")
local ms_data = require("../modules/ms_data")
local tools = require("../modules/tools")

local music = {}

music.window = nil

music.stealth = {
    dropdowns = {},
    pending = nil,
    conn = nil
}

music.loud = {
    dropdowns = {},
    pending = nil,
    conn = nil
}

music.always_loud = {
    pending = nil,
    conn = nil
}

music.soundtracks = {
    ["Stealth Soundtracks"] = {
		["The Setup - Solitary Quest (a)"] = "rbxassetid://1841579249",
		["The Lockup - Tension Mounts"] = "rbxassetid://1838628050",
		["The Blacksite - Breathless Suspense (b)"] = "rbxassetid://1841578568",
		["The Financier - Lock & Load"] = "rbxassetid://1843470912",
		["The Auction - Metro Pulse (a)"] = "rbxassetid://1841578846",
		["The Gala - Bass Motion"] = "rbxassetid://1836764457",
		["The Deposit - The Final Thrust (b)"] = "rbxassetid://1841579381",
		["The Withdrawal - Aftermath"] = "rbxassetid://1843471196",
		["The Lakehouse - Under Surveillance - Underscore"] = "rbxassetid://1838617097",
		["The Cache - Hard As Iron"] = "rbxassetid://1841579363",
		["The Scientist - Looking For A Clue - Underscore"] = "rbxassetid://1838642607",
		["The SCRS - Unusual Suspect"] = "rbxassetid://1838641186",
		["Black Dusk - Restless Tension (a)"] = "rbxassetid://1841164575",
		["The Killhouse - Covert Ops (a)"] = "rbxassetid://1841694216",
		["Concept - The Final Thrust (a)"] = "rbxassetid://1841579325",
	},

	["Loud Soundtracks"] = {
		["The Lockup - Here It Comes"] = "rbxassetid://1837807597",
		["The Score - Pound For Pound - Underscore"] = "rbxassetid://1842802303",
		["The Score - Pound For Pound"] = "rbxassetid://1842802203",
		["The Blacksite - Snapped"] = "rbxassetid://1842940253",
		["The Financier - See You In Hell"] = "rbxassetid://1837853076",
		["The Deposit - High Velocity"] = "rbxassetid://1839898469",
		["The Withdrawal - Assault Complex"] = "rbxassetid://1842940193",
		["The Lakehouse - Complete The Mission"] = "rbxassetid://1838627720",
		["The Scientist - Lethal Conflict"] = "rbxassetid://1842934882",
		["The Scientist - Lethal Conflict - Underscore"] = "rbxassetid://1842801894",
		["The SCRS - Hijacked"] = "rbxassetid://1842559618",
		["Black Dusk - Full Force"] = "rbxassetid://1842801942",
		["The Killhouse - The Vault (a)"] = "rbxassetid://1840083133",
		["The Killhouse - No More Time (a)"] = "rbxassetid://1847027481",
	},

	["Alternate Soundtracks"] = {
		["The Lockup - Pushing Me Closer"] = "rbxassetid://1836789312",
		["The Score - Best Laid Plans - Alternative"] = "rbxassetid://1836808611",
		["The Score - Best Laid Plans"] = "rbxassetid://1837025066",
		["The Blacksite - Suicide Mission"] = "rbxassetid://1837844069",
		["The Financier - There Will Be Blood"] = "rbxassetid://1843513001",
		["The Deposit - Terminal Velocity"] = "rbxassetid://1842802436",
		["The Withdrawal - Pushing The Limits"] = "rbxassetid://1838627011",
		["The Lakehouse - Fight Or Flight"] = "rbxassetid://1842940300",
		["The Scientist - Phoenix Rising"] = "rbxassetid://1837798316",
		["The Scientist - Phoenix Rising - Drums And Bass"] = "rbxassetid://1837798598",
		["The SCRS - We Go Hard"] = "rbxassetid://1842940420",
		["Black Dusk - Victory Is Ours"] = "rbxassetid://1842802498",
	},

	["Removed Soundtracks"] = {
		["The Killhouse - Chaos"] = "rbxassetid://1843497734",
		["The Financier - Mindwinder (b)"] = "rbxassetid://1838075732",
		["The Scientist - Riding High"] = "rbxassetid://1837807484",
		["The Scientist - Riding High - Drums And Bass"] = "rbxassetid://1837807505",
		["Halloween Hitlist 2020 - Ambience"] = "rbxassetid://3097850155",
		["Halloween Hitlist 2020 - Burning Action"] = "rbxassetid://1838626744",
	},
}

music.Render = function()
    music.window = gui_util.CreateWindow("root@kali: /terminal/music")
    music.window.Position = UDim2.fromScale(0.067, 0.101)
    gui_util.MakeWindowDraggable(music.window)
    local content_holder = gui_util.AddContentHolder(music.window)
    gui_util.SetContentEnv(content_holder)

    gui_util.AddSection("General")

    local toggle = gui_util.CreateToggle("Loud music is always alternative", function(is_enabled)
        if is_enabled == true then
            local alt_music = ms_data.current.alt_music
            if alt_music == nil then return end

            tools.ClearTableConn(music.loud, "conn")
            tools.ClearTableTask(music.loud, "pending")

            music.always_loud.pending = tools.CreatePendingTask(function()
                local loud = PlayerGui:WaitForChild("SpectateGui", math.huge):WaitForChild("Music", math.huge):WaitForChild("Loud", math.huge)
    
                loud.SoundId = alt_music
                music.always_loud.conn = loud:GetPropertyChangedSignal("SoundId"):Connect(function()
                    loud.SoundId = alt_music
                end)
            end)
        else
            tools.ClearTableConn(music.always_loud, "conn")
            tools.ClearTableTask(music.always_loud, "pending")
        end
    end)

    for i = 1, 2, 1 do
        local section = i == 1 and "Change Stealth Music To:" or "Change Loud Music To:"
        local music_type = i == 1 and "stealth" or "loud"
        local sound_instance = i == 1 and "Stealth" or "Loud"

        gui_util.AddSection(section)

        for dropdown_name, dropdown_data in pairs(music.soundtracks) do
            local dropdown = gui_util.CreateDropdown(dropdown_name)
            table.insert(music[music_type].dropdowns, dropdown)
            for music_name, music_id in pairs(dropdown_data) do
                gui_util.AddDropdownOption(dropdown, music_name, function()
                    for _, dropdown_data in ipairs(music[music_type].dropdowns) do
                        if dropdown_data ~= dropdown then
                            dropdown_data:ClearChoice()
                        end
                    end

                    tools.ClearTableConn(music[music_type], "conn")
                    tools.ClearTableTask(music[music_type], "pending")

                    if music_type == "loud" then
                        tools.ClearTableConn(music.always_loud, "conn")
                        tools.ClearTableTask(music.always_loud, "pending")
                    end

                    music[music_type].pending = tools.CreatePendingTask(function()
                        local sound = PlayerGui:WaitForChild("SpectateGui", math.huge):WaitForChild("Music", math.huge):WaitForChild(sound_instance, math.huge)
    
                        sound.SoundId = music_id
                        music[music_type].conn = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
                            sound.SoundId = music_id
                        end)
                    end)
                end)
            end
            dropdown.ApplyVerticalFlex()
        end

        gui_util.CreateInput("Custom Music ID", "ID", function(ID)
            for _, dropdown_data in ipairs(music[music_type].dropdowns) do
                dropdown_data:ClearChoice()
            end

            tools.ClearTableConn(music[music_type], "conn")
            tools.ClearTableTask(music[music_type], "pending")

            music[music_type].pending = tools.CreatePendingTask(function()
                local sound = PlayerGui:WaitForChild("SpectateGui", math.huge):WaitForChild("Music", math.huge):WaitForChild(sound_instance, math.huge)

                sound.SoundId = "rbxassetid://"..ID
                music[music_type].conn = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
                    sound.SoundId = "rbxassetid://"..ID
                end)
            end)
        end)
    end
end

return music
