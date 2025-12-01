local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local PlayerData = LocalPlayer:WaitForChild("PlayerData", math.huge)
local CharactersData = PlayerData:WaitForChild("Character", math.huge)
local CharacterData = CharactersData:WaitForChild("Char"..tostring(CharactersData.Value))

local LobbyBase = PlayerGui:WaitForChild("LobbyGui", math.huge):WaitForChild("LobbyBase", math.huge)

local gui_util = require("../modules/gui_util")
local rmts_mgr = require("../modules/rmts_mgr")
local tools = require("../modules/tools")

local GetRemote = rmts_mgr.GetRemote

local lobby = {}

lobby.canJoinGame = nil

lobby.mission_names = {
    {["The Blacksite"] = "_Blacksite"},
    {["The Financier"] = "_Financier"},
    {["The Deposit"] = "_Deposit"},
    {["The Lakehouse"] = "_Lakehouse"},
    {["The Withdrawal"] = "_Withdrawal"},
    {["The Scientist"] = "_Scientist"},
    {["The SCRS"] = "_SCRS"},
    {["Black Dusk"] = "_BlackDusk"},
    {["The Killhouse"] = "_Killhouse"},
    {["Concept"] = "_Concept"},
    {["The Auction"] = "_Auction"},
    {["The Gala"] = "_Gala"},
    {["The Cache"] = "_Cache"},
    {["The Setup"] = "_Setup"},
    {["The Lockup"] = "_Lockup"},
    {["The Score"] = "_Tuscon"},
    {["\"Mission\""] = "_Mission"},
    {["Ironman Mode"] = "_Ironman"}
}

lobby.current_lobby_data = nil
lobby.lobby_settings = {
    CharacterData, -- character
    "_Deposit", -- mission
    1, -- level_cap
    false, -- is_friends_only
    1, -- difficulty
    1, -- lobby_type_image
    4, -- lobby_size
    false, -- is_speedrun
    1, -- speedrun_seed
    false -- is_daily_challenge
}

lobby.Render = function()
    lobby.window = gui_util.CreateWindow("root@kali: /terminal/music")
    lobby.window.Position = UDim2.fromScale(0.26, 0.509)
    gui_util.MakeWindowDraggable(lobby.window)
    local content_holder = gui_util.AddContentHolder(lobby.window)
    gui_util.SetContentEnv(content_holder)

    gui_util.AddSection("General")
    local toggle; toggle = gui_util.CreateToggle("Show All Lobbies", function(is_enabled)
        if getsenv == nil or clonefunction == nil then
            if is_enabled == true then
                gui_util.SendNotification("Lobby", "Your executor doesn't supports this action.", 3)
                toggle.Call()
            end
        else
            local env = getsenv(LobbyBase)

            if lobby.canJoinGame == nil then
                lobby.canJoinGame = clonefunction(env.canJoinGame)
            end

            if is_enabled == true then
                env.canJoinGame = function(data) 
                    data:WaitForChild("PlayerMax", math.huge)
                    return true 
                end
            else
                env.canJoinGame = lobby.canJoinGame
            end

            env.resetLobbyListCursor()
        end
    end)

    gui_util.AddSection("Lobby Settings")
    gui_util.CreateInput("Character", "1 - 12", function(character_num)
        local character_data = CharactersData:WaitForChild("Char"..character_num, 0.5)

        if not character_data then 
            gui_util.SendNotification("Lobby", "Make sure you specified a right character.", 3)
            return
        end
        
        lobby.lobby_settings[1] = character_data
    end)

    local dropdown = gui_util.CreateDropdown("Mission Name")
    for _, mission_names in ipairs(lobby.mission_names) do
        for visual_name, real_name in pairs(mission_names) do
            gui_util.AddDropdownOption(dropdown, visual_name, function()
                lobby.lobby_settings[2] = real_name
            end)
        end
    end
    dropdown.ApplyVerticalFlex()

    gui_util.CreateInput("Level Cap", "number", function(level_cap)
        level_cap = tonumber(level_cap)

        if not level_cap or level_cap < 0 then 
            gui_util.SendNotification("Lobby", "Level cap must be a positive integer.", 3)
            return
        end
        
        lobby.lobby_settings[3] = level_cap
    end)

    gui_util.CreateToggle("Friends Only", function(is_enabled)
        lobby.lobby_settings[4] = is_enabled
    end)

    gui_util.CreateInput("Difficulty", "0 - 5", function(difficulty)
        difficulty = tonumber(difficulty)

        if not difficulty or (difficulty < 0 or difficulty > 5) then 
            gui_util.SendNotification("Lobby", "Difficulty must be an integer in the range from 0 to 5.", 3)
            return
        end
        
        lobby.lobby_settings[5] = difficulty
    end)

    gui_util.CreateInput("Lobby Type Image", "0 - 3", function(lobby_type_image)
        lobby_type_image = tonumber(lobby_type_image)

        if not lobby_type_image or (lobby_type_image < 0 or lobby_type_image > 3) then 
            gui_util.SendNotification("Lobby", "Lobby type image must be an integer in the range from 0 to 3.", 3)
            return
        end
        
        lobby.lobby_settings[6] = lobby_type_image
    end)

    gui_util.CreateInput("Lobby Size", "number", function(lobby_size)
        lobby_size = tonumber(lobby_size)

        if not lobby_size or lobby_size <= 0 then 
            gui_util.SendNotification("Lobby", "Lobby size must be the positive integer more than 0.", 3)
            return
        end
        
        lobby.lobby_settings[7] = lobby_size
    end)

    gui_util.CreateToggle("Speedrun Mode", function(is_enabled)
        lobby.lobby_settings[8] = is_enabled
    end)

    gui_util.CreateInput("Speedrun Seed", "number", function(speedrun_seed)
        speedrun_seed = tonumber(speedrun_seed)

        if not speedrun_seed or speedrun_seed < 0 then 
            gui_util.SendNotification("Lobby", "Speedrun seed must be a positive integer.", 3)
            return
        end
        
        lobby.lobby_settings[9] = speedrun_seed
    end)

    gui_util.CreateToggle("Daily Challenge", function(is_enabled)
        lobby.lobby_settings[10] = is_enabled
    end)

    gui_util.AddSection("Manage Lobby")

    gui_util.CreateButton("Create The Lobby", "+ Add New", function()
        lobby.current_lobby_data = GetRemote("CreateLobby"):InvokeServer(unpack(lobby.lobby_settings))
    end)

    gui_util.CreateButton("Open Lobby Gui", "Open", function()
        if lobby.current_lobby_data == nil then return end
        
        if getsenv == nil then
            gui_util.SendNotification("Lobby", "Your executor doesn't supports this action.", 3)
        else
            local env = getsenv(LobbyBase)
            env.optionsToLobby(true)
            env.killGamepadLevelCapControls()
            env.enterLobby(lobby.current_lobby_data)
            env.putCharacterOnLobbyGui(
                PlayerGui:WaitForChild("LobbyGui", math.huge):WaitForChild("LobbyPlayers", math.huge):WaitForChild("MainPlayer", math.huge),
                lobby.lobby_settings[1]
            )
            env.getCodename(lobby.lobby_settings[1])
            env.listToLobby()
        end
    end)

    gui_util.CreateButton("Start The Game", "Start", function()
        GetRemote("StartGame"):FireServer()
    end)

    gui_util.CreateButton("Leave The Lobby", "Leave", function()
        GetRemote("LeaveLobby"):FireServer()
    end)

    local plr_dropdown = gui_util.CreateDropdown("Kick Player")
    local lobby_players = {
        Crew1 = nil,
        Crew2 = nil,
        Crew3 = nil
    }

    local function internal(lobby_data)
        for _, teammate_spot in ipairs(tools.WaitForChildren(lobby_data, "Crew1", "Crew2", "Crew3")) do
            teammate_spot:GetPropertyChangedSignal("Value"):Connect(function()
                if teammate_spot.Value ~= nil then
                    local label = teammate_spot.Value.Parent.Parent.Parent.Name.." [level: "
                    local char_data = tools.unjsonify(teammate_spot.Value.Value)
                    local exp = char_data.EXP
                    local level = tostring(math.floor(math.sqrt(tonumber(exp) / 320)))
                    if level == "0" then level = "1" end
                    label = label..level..", classes: "
                    local classes = " "
                    for _, perk in ipairs(char_data.PRK) do
                        if string.find(perk, "Base") then
                            perk = string.gsub(string.lower(perk), "base", "")
                            classes = classes.perk..", "
                        end
                    end
                    classes = string.sub(classes, 0, -3)
                    label = label..classes.."]"

                    lobby_players[teammate_spot.Name] = gui_util.AddDropdownOption(plr_dropdown, label, function()
                        GetRemote("KickPlayer"):FireServer(teammate_spot.Value)
                    end)
                else
                    lobby_players[teammate_spot.Name]:Destroy()
                end
            end)

            teammate_spot:GetPropertyChangedSignal("Parent"):Connect(function()
                if teammate_spot.Parent == nil then
                    for spot, option in pairs(lobby_players) do
                        option:Destroy()
                        lobby_players[teammate_spot.Name] = nil
                    end

                    dropdown:ClearChoice()

                    lobby_players = {
                        Crew1 = nil,
                        Crew2 = nil,
                        Crew3 = nil
                    }
                end
            end)
        end
    end

    local LobbyList = ReplicatedStorage:WaitForChild("Lobby", math.huge):WaitForChild("List", math.huge)
    local CurrentLobby = LobbyList:FindFirstChild(LocalPlayer.Name)
    if CurrentLobby then internal(CurrentLobby) end
    LobbyList.ChildAdded:Connect(function(NewLobby)
        if NewLobby.Name == LocalPlayer.Name then
            internal(NewLobby)
        end
    end)
end

return lobby