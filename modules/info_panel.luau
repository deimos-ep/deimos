local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local gui_util = require("../modules/gui_util")
local tools = require("../modules/tools")
local ms_data = require("../modules/ms_data")

local Level = workspace:WaitForChild("Level", math.huge)
local GameState = ReplicatedStorage:WaitForChild("GameState", math.huge)
local LoudStage = GameState:WaitForChild("Stage", math.huge)

local info_panel = {}

info_panel.content_holder = nil
info_panel.ms_info = nil
info_panel.ent_count = nil
info_panel.players_count = 0
info_panel.players_count_text = nil

info_panel.AddSection = function(section_name)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 0.048)
    label.FontFace = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    label.Text = section_name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = info_panel.content_holder

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.3, 0)
    UIPadding.PaddingLeft = UDim.new(0.01, 0)
    UIPadding.PaddingTop = UDim.new(0.1)
    UIPadding.Parent = label

    local line = Instance.new("Frame")
    line.Size = UDim2.fromScale(1, 0.08)
    line.Position = UDim2.fromScale(0, 1)
    line.BorderSizePixel = 0
    line.Parent = label
end

info_panel.AddTableCell = function(table_line, segments_count, cell_text)
    local CellText = Instance.new("TextLabel")
    CellText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CellText.FontFace = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    CellText.TextScaled = true
    CellText.Text = cell_text
    CellText.Size = UDim2.fromScale(1 / segments_count, 1)
    CellText.BackgroundTransparency = 1
    CellText.Parent = table_line

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.175, 0)
    UIPadding.PaddingTop = UDim.new(0.175, 0)
    UIPadding.Parent = CellText

    return CellText
end

info_panel.CreateTable = function(columns)
    local table_holder = Instance.new("Frame")
    table_holder.Size = UDim2.fromScale(1, 0.083)
    table_holder.BackgroundTransparency = 1
    table_holder.BorderSizePixel = 0
    table_holder.Parent = info_panel.content_holder

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = table_holder

    local labels_holder = Instance.new("Frame")
    labels_holder.Size = UDim2.fromScale(1, 0.497)
    labels_holder.BackgroundColor3 = Color3.fromRGB(30, 31, 37)
    labels_holder.BackgroundTransparency = 0.45
    labels_holder.BorderSizePixel = 0
    labels_holder.Parent = table_holder

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.Parent = labels_holder

    local values_holder = labels_holder:Clone()
    values_holder.BackgroundColor3 = Color3.fromRGB(39, 40, 48)
    values_holder.Parent = table_holder

    local values_labels = {}

    local segments_count = tools.GetDictLen(columns) 

    for _, data in ipairs(columns) do
        for label, value in pairs(data) do
            info_panel.AddTableCell(labels_holder, segments_count, label)
            local value_label = info_panel.AddTableCell(values_holder, segments_count, value)
            value_label.Name = label
            table.insert(values_labels, value_label)
        end
    end

    return values_labels
end

info_panel.CreatePairsPack = function(player_info, scale_x, scale_y, columns)
    local pairs_holder = Instance.new("Frame")
    pairs_holder.BackgroundTransparency = 1
    pairs_holder.Size = UDim2.fromScale(0.146, 0.688)
    pairs_holder.Position = UDim2.fromScale(scale_x, scale_y)
    pairs_holder.BorderSizePixel = 0
    pairs_holder.Parent = player_info

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = pairs_holder

    local values_labels = {}

    for _, data in ipairs(columns) do
        for label, value in pairs(data) do
            local pair_holder = Instance.new("Frame")
            pair_holder.BorderSizePixel = 0
            pair_holder.BackgroundTransparency = 1
            pair_holder.Size = UDim2.fromScale(1, 0.17)
            pair_holder.Parent = pairs_holder

            local label_text = gui_util.GetUbuntuText(label)
            label_text.Size = UDim2.fromScale(1, 1)
            label_text.TextXAlignment = Enum.TextXAlignment.Left
            label_text.Parent = pair_holder

            local value_text = label_text:Clone()
            value_text.Name = label
            value_text.Text = value
            value_text.TextXAlignment = Enum.TextXAlignment.Right
            value_text.Parent = pair_holder

            table.insert(values_labels, value_text)
        end
    end

    return values_labels
end

info_panel.AddPlayerInfo = function(player)
    local name = player.Name
    local display_name = player.DisplayName
    local user_id = player.UserId
    local headshot = Players:GetUserThumbnailAsync(user_id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

    local PlayerData = player:WaitForChild("PlayerData", math.huge)
    local chars_data = PlayerData:WaitForChild("Character", math.huge)
    local current_char = tostring(chars_data.Value)

    local char_data_obj = chars_data:WaitForChild("Char"..current_char)
    local char_data = char_data_obj.Value
    char_data = tools.unjsonify(char_data)
    local current_exp = char_data.EXP
    local current_level = tostring(math.floor(math.sqrt(tonumber(current_exp) / 320)))
    if current_level == "0" then current_level = "1" end
    local classes = " "
    for _, perk in ipairs(char_data.PRK) do
        if string.find(perk, "Base") then
            perk = string.gsub(string.lower(perk), "base", "")
            classes = classes..perk..", "
        end
    end
    classes = string.sub(classes, 0, -3)

    local money_obj = PlayerData:WaitForChild("Money", math.huge)
    local money = tostring(money_obj.Value)
    local pro_bonus_obj = PlayerData:WaitForChild("ProBonus", math.huge)
    local pro_bonus = tostring(pro_bonus_obj.Value)
    local join_date = nil
    local event_unlocks = nil -- PlayerData:WaitForChild("EventUnlocks", math.huge)
    local sw_data = nil -- PlayerData:WaitForChild("SWData", math.huge)
    --sw_data = tools.WaitForChildren(sw_data, "Wins", "Losses", "Kills", "Deaths", "Rating")

    local info_holder = Instance.new("Frame")
    info_holder.Size = UDim2.fromScale(1, 0.23)
    info_holder.BackgroundColor3 = Color3.fromRGB(30, 31, 37)
    info_holder.BackgroundTransparency = 0.45
    info_holder.BorderSizePixel = 0

    local separator = Instance.new("Frame")
    separator.Size = UDim2.fromScale(0.002, 0.897)
    separator.Position = UDim2.fromScale(0.494, 0.05)
    separator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    separator.BorderSizePixel = 0
    separator.Parent = info_holder

    local datapack1 = Instance.new("Frame")
    datapack1.BackgroundTransparency = 1
    datapack1.Size = UDim2.fromScale(0.472, 0.887)
    datapack1.Position = UDim2.fromScale(0.014, 0.06)
    datapack1.BorderSizePixel = 0
    datapack1.Parent = info_holder

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0.018, 0)
    UIListLayout.Parent = datapack1

    local Frame = Instance.new("Frame")
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.fromScale(1, 0.225)
    Frame.BackgroundTransparency = 1
    Frame.Parent = datapack1

    RunService.RenderStepped:Wait()

    local name_label = Instance.new("TextLabel")
    if name ~= display_name then
        name_label.Text = name.." ("..display_name..")"
    else
        name_label.Text = name
    end
    name_label.BackgroundTransparency = 1
    name_label.TextColor3 = Color3.fromRGB(255, 255, 255)
    name_label.Size = UDim2.fromScale(1, 0.5)
    name_label.FontFace = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    name_label.TextXAlignment = Enum.TextXAlignment.Left
    name_label.TextScaled = true
    name_label.Parent = Frame        

    local health_bg = Instance.new("Frame")
    health_bg.BorderSizePixel = 0
    health_bg.Size = UDim2.fromScale(0.845, 0.2)
    health_bg.Position = UDim2.fromScale(0, 0.7)
    health_bg.BackgroundColor3 = Color3.fromRGB(47, 49, 58)
    health_bg.Parent = Frame

    local health = health_bg:Clone()
    health.BackgroundColor3 = Color3.fromRGB(56, 129, 0)
    health.Position = UDim2.fromScale(0, 0)
    health.Size = UDim2.fromScale(1, 1)
    health.Parent = health_bg

    local health_value = Instance.new("TextLabel")
    health_value.Size = UDim2.fromScale(0.333, 0.4)
    health_value.Position = UDim2.fromScale(0.5099999904632568, 0.2)
    health_value.BackgroundTransparency = 1
    health_value.TextColor3 = Color3.fromRGB(255, 255, 255)
    health_value.FontFace = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    health_value.TextScaled = true
    health_value.Text = "N/A"
    health_value.TextXAlignment = Enum.TextXAlignment.Right
    health_value.Parent = Frame

    local player_headshot = Instance.new("ImageLabel")
    player_headshot.BorderSizePixel = 0
    player_headshot.Size = UDim2.fromScale(0.068, 1)
    player_headshot.AnchorPoint = Vector2.new(1, 0)
    player_headshot.Position = UDim2.fromScale(1, -0.1)
    player_headshot.BackgroundColor3 = Color3.fromRGB(47, 49, 58)
    player_headshot.Image = headshot
    player_headshot.Parent = Frame

    local Frame = Instance.new("Frame")
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.fromScale(1, 0.124)
    Frame.BackgroundTransparency = 1
    Frame.Parent = datapack1

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
    UIListLayout.Parent = Frame

    local level_text = gui_util.GetUbuntuText("level: 1 (320 exp)")
    level_text.TextXAlignment = Enum.TextXAlignment.Left
    level_text.Size = UDim2.fromScale(0.391, 1)
    level_text.Text = "level: "..current_level.." ("..current_exp.." exp)"
    level_text.Parent = Frame

    local money_text = gui_util.GetUbuntuText("money: 0")
    money_text.TextXAlignment = Enum.TextXAlignment.Center
    money_text.Size = UDim2.fromScale(0.327, 1)
    money_text.Text = "money: "..money
    money_text.Parent = Frame

    local pro_bonus_text = gui_util.GetUbuntuText("pro bonus: 0%")
    pro_bonus_text.TextXAlignment = Enum.TextXAlignment.Right
    pro_bonus_text.Size = UDim2.fromScale(0.238, 1)
    pro_bonus_text.Text = "pro bonus: "..pro_bonus.."%"
    pro_bonus_text.Parent = Frame

    local join_date_text = gui_util.GetUbuntuText("join date: no data")
    join_date_text.TextXAlignment = Enum.TextXAlignment.Left
    join_date_text.Size = UDim2.fromScale(1, 0.13)
    join_date_text.Text = "join date: no data"
    join_date_text.Parent = datapack1

    local classes_text = gui_util.GetUbuntuText("classes: no data")
    classes_text.TextXAlignment = Enum.TextXAlignment.Left
    classes_text.Size = UDim2.fromScale(1, 0.13)   
    classes_text.Text = "classes: "..classes
    classes_text.Parent = datapack1

    local event_unlocks_text = gui_util.GetUbuntuText("event unlocks: no data")
    event_unlocks_text.TextXAlignment = Enum.TextXAlignment.Left
    event_unlocks_text.Size = UDim2.fromScale(1, 0.13)
    event_unlocks_text.Parent = datapack1

    local shadow_war_text = gui_util.GetUbuntuText("shadow war: no data")
    shadow_war_text.TextXAlignment = Enum.TextXAlignment.Left
    shadow_war_text.Size = UDim2.fromScale(1, 0.13)
    shadow_war_text.Parent = datapack1

    local ms_data_label = gui_util.GetUbuntuText("Current Mission Data")
    ms_data_label.Size = UDim2.fromScale(0.4, 0.11)
    ms_data_label.Position = UDim2.fromScale(0.512, 0.06)
    ms_data_label.TextXAlignment = Enum.TextXAlignment.Left
    ms_data_label.Parent = info_holder

    local block1 = info_panel.CreatePairsPack(info_holder, 0.512, 0.209, {
        {["kills:"] = "0"},
        {["headshots:"] = "0"},
        {["knockouts:"] = "0"},
        {["holdups:"] = "0"},
        {["shots fired:"] = "0"},
        {["shots hit:"] = "0"}
    })

    local block2 = info_panel.CreatePairsPack(info_holder, 0.674, 0.209, {
        {["armed:"] = "false"},
        {["disguise:"] = "0"},
        {["intimidate:"] = "false"},
        {["weapon sup.:"] = "false"},
        {["suspicious:"] = "false"},
        {["threat mul.:"] = "1"}        
    })

    local block3 = info_panel.CreatePairsPack(info_holder, 0.837, 0.209, {
        {["trespassing:"] = "false"},
        {["caught tresp.:"] = "false"},
        {["final warning:"] = "false"},
        {["zone:"] = "N/A"}
    })

    RunService.RenderStepped:Wait()

    info_holder.Parent = info_panel.content_holder

    char_data_obj:GetPropertyChangedSignal("Value"):Connect(function()
        char_data = char_data_obj.Value

        current_exp = char_data.EXP
        current_level = tostring(math.floor(math.sqrt(tonumber(current_exp) / 320)))
        level_text.Text = "level: "..current_level.." ("..current_exp.." exp)"
    end)

    money_obj:GetPropertyChangedSignal("Value"):Connect(function()
        money = tostring(money_obj.Value)
        money_text.Text = "money: "..money
    end)

    pro_bonus_obj:GetPropertyChangedSignal("Value"):Connect(function()
        pro_bonus = tostring(pro_bonus_obj.Value)
        pro_bonus_text.Text = "pro bonus: "..pro_bonus.."%"
    end)

    task.spawn(function()
        join_date = PlayerData:WaitForChild("JoinDate", 2)
        if join_date ~= nil then
            join_date = DateTime.fromUnixTimestamp(join_date.Value):FormatUniversalTime("DD MMM YYYY, ddd, hh:mm:ss.SSS A UTC", "en-us")
            join_date_text.Text = "join date: "..join_date
        else
            join_date_text.Text = "join date: no data (old gen acc)"
        end
    end)

    task.spawn(function()
        event_unlocks = PlayerData:WaitForChild("EventUnlocks", 5)
        if not event_unlocks then return end

        local function internal()
            local unlocks = ""

            for _, accessory in ipairs(event_unlocks:GetChildren()) do
                unlocks = unlocks..accessory.Name..", "
            end

            unlocks = string.sub(unlocks, 0, -3)

            event_unlocks_text.Text = "event unlocks: "..unlocks
        end

        internal()

        local listener; listener = event_unlocks.ChildAdded:Connect(internal)
        task.wait(2)
        listener:Disconnect()
    end)

    task.spawn(function()
        sw_data = PlayerData:WaitForChild("SWData", 5)
        if not sw_data then return end
        sw_data = tools.WaitForChildren(sw_data, "Wins", "Losses", "Kills", "Deaths", "Rating")

        for index, data in ipairs(sw_data) do
            sw_data[index] = tostring(data.Value)
        end

        shadow_war_text.Text = "shadow war: wins - "..sw_data[1]..", losses - "..sw_data[2]..", kills - "..sw_data[3]..", deaths - "..sw_data[4]..", rating - "..sw_data[5]
    end)

    local player_status = player:WaitForChild("Status", math.huge)
    local player_stats = player_status:WaitForChild("Stats", math.huge)
    local stats_objs = tools.WaitForChildren(player_stats, "Kills", "Headshots", "Knockouts", "Holdups", "ShotsFired", "ShotsHit")
    for index = 1, 6, 1 do
        block1[index].Text = tostring(stats_objs[index].Value)
        stats_objs[index]:GetPropertyChangedSignal("Value"):Connect(function()
            block1[index].Text = tostring(stats_objs[index].Value)
        end)
    end

    local flags = Level:WaitForChild("Flags", math.huge):WaitForChild(name, math.huge)
    flags = tools.WaitForChildren(flags, "Armed", "Disguise", "Intimidate", "Suppressed", "Suspicious", "Threat")
    for index = 1, 6, 1 do
        if index ~= 6 then
            block2[index].Text = tostring(tools.ConvertBool(flags[index].Value))
            flags[index]:GetPropertyChangedSignal("Value"):Connect(function()
                block2[index].Text = tostring(tools.ConvertBool(flags[index].Value))
            end)
        else
            block2[index].Text = tostring(flags[index].Value)
            flags[index]:GetPropertyChangedSignal("Value"):Connect(function()
                block2[index].Text = tostring(flags[index].Value)
            end)
        end
    end

    local flags2 = Level:WaitForChild("Flags", math.huge):WaitForChild(name, math.huge)

    local trespassing = flags2:WaitForChild("Trespassing", math.huge)
    block3[1].Text = tostring(tools.ConvertBool(trespassing.Value))
    trespassing:GetPropertyChangedSignal("Value"):Connect(function()
        block3[1].Text = tostring(tools.ConvertBool(trespassing.Value))
    end)

    local trespass_detect = flags2:WaitForChild("TrespassDetect", math.huge)
    block3[2].Text = tostring(tools.ConvertBool(trespass_detect.Value ~= nil))
    trespass_detect:GetPropertyChangedSignal("Value"):Connect(function()
        block3[2].Text = tostring(tools.ConvertBool(trespass_detect.Value ~= nil))
    end)

    local final_warning = trespass_detect:WaitForChild("Final", math.huge)
    block3[3].Text = tostring(tools.ConvertBool(final_warning.Value))
    final_warning:GetPropertyChangedSignal("Value"):Connect(function()
        block3[3].Text = tostring(tools.ConvertBool(final_warning.Value))
    end)

    local current_zone = flags2:WaitForChild("Zone", math.huge)
    block3[4].Text = current_zone.Value
    current_zone:GetPropertyChangedSignal("Value"):Connect(function()
        block3[4].Text = current_zone.Value
    end)

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 5)
    local char_health = tostring(humanoid.Health)
    local char_max_health = tostring(humanoid.MaxHealth)
    health_value.Text = char_health.."/"..char_max_health

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        char_health = tostring(tools.RoundNumber(humanoid.Health))
        health_value.Text = char_health.."/"..char_max_health

        local x_scale = humanoid.Health / humanoid.MaxHealth
        health.Size = UDim2.fromScale(x_scale > 1 and 1 or x_scale, 1) 
    end)

    humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        char_health = tostring(humanoid.Health)
        char_max_health = tostring(humanoid.MaxHealth)
        health_value.Text = char_health.."/"..char_max_health
    end)
end

info_panel.Render = function()
    local panel_holder = Instance.new("Frame")
    panel_holder.BorderSizePixel = 0
    panel_holder.Size = UDim2.fromScale(0.336, 0.395)
    panel_holder.Position = UDim2.fromScale(0, 1)
    panel_holder.BackgroundColor3 = Color3.fromRGB(30, 31, 37)
    panel_holder.BackgroundTransparency = 0.15
    panel_holder.Parent = gui_util.gui_holder

    local is_opened = false

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode ~= Enum.KeyCode.Z or UserInputService:GetFocusedTextBox() ~= nil then return end

        is_opened = not is_opened

        TweenService:Create(
            panel_holder, 
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0), 
            {Position = UDim2.fromScale(0, is_opened == true and 0.6060000061988831 or 1)}
        ):Play()
    end)

    local content_holder = Instance.new("ScrollingFrame")
    content_holder.BorderSizePixel = 0
    content_holder.BackgroundTransparency = 1
    content_holder.Position = UDim2.fromScale(0.008, 0.018)
    content_holder.Size = UDim2.fromScale(0.981, 0.965)
    content_holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content_holder.CanvasSize = UDim2.fromScale(0, 1)
    content_holder.ScrollBarThickness = 2
    content_holder.ScrollingDirection = Enum.ScrollingDirection.Y
    content_holder.Parent = panel_holder

    info_panel.content_holder = content_holder

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0.02, 0)
    UIListLayout.Parent = content_holder

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingRight = UDim.new(0.015, 0)
    UIPadding.Parent = content_holder

    local decorative_label = Instance.new("TextLabel")
    decorative_label.BackgroundTransparency = 1
    decorative_label.TextColor3 = Color3.fromRGB(255, 255, 255)
    decorative_label.FontFace = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    decorative_label.Size = UDim2.fromScale(1, 0.031)
    decorative_label.Text = "Deimos v2.0.0 - SERVER_ID ["..game.JobId.."] PLACE_VERSION ["..game.PlaceVersion.."]"
    decorative_label.TextScaled = true
    decorative_label.TextXAlignment = Enum.TextXAlignment.Left
    decorative_label.Parent = content_holder

    info_panel.AddSection("Mission Info")
    info_panel.ms_info = info_panel.CreateTable({
        {["FFM"] = "0"}, 
        {["loud started"] = "no"}, 
        {["difficulty"] = "1"},
        {["no kills"] = "yes"},
        {["start time"] = "not started"},
        {["wave kills"] = "N/A"},
        {["current wave"] = "0"},
        {["wave state"] = "not started"}
    })

    task.spawn(function()
        local FriendlyFire = ReplicatedStorage:WaitForChild("FriendlyFire", 5)
        if not FriendlyFire then return end

        info_panel.ms_info[1].Text = tostring(FriendlyFire.Value)
    end)

    local difficulties = {
        "rookie",
        "professional",
        "operative",
        "elite",
        "legend"
    }

    local difficulty = GameState:WaitForChild("Difficulty", math.huge)
    while difficulty.Value == nil do task.wait() end

    info_panel.ms_info[3].Text = difficulty.Value == 0 and "N/A" or difficulties[difficulty.Value]
    difficulty:GetPropertyChangedSignal("Value"):Connect(function()
        info_panel.ms_info[3].Text = difficulties[difficulty.Value]
    end)

    local no_kills = GameState:WaitForChild("NoKills", math.huge)
    info_panel.ms_info[4].Text = tostring(tools.ConvertBool(no_kills.Value))
    no_kills:GetPropertyChangedSignal("Value"):Connect(function()
        info_panel.ms_info[4].Text = tostring(tools.ConvertBool(no_kills.Value))
    end)

    local start_time = GameState:WaitForChild("Start", math.huge)
    if start_time.Value == 0 then
        local listener; listener = start_time:GetPropertyChangedSignal("Value"):Connect(function()
            info_panel.ms_info[5].Text = tostring(tools.RoundNumber(start_time.Value)).."s"
            listener:Disconnect()
        end)
    else
        info_panel.ms_info[5].Text = tostring(tools.RoundNumber(start_time.Value))
    end

    LoudStage:GetPropertyChangedSignal("Value"):Connect(function()
        info_panel.ms_info[2].Text = tools.ConvertBool(true)
        if LoudStage.Value == 1 then
            info_panel.ms_info[8].Text = "intermission" 
        else
            info_panel.ms_info[8].Text = "in progress"
            info_panel.ms_info[7].Text = "1"
            info_panel.ms_info[6].Text = "0/"..tostring(ms_data.wave_amt - 3).." ("..tostring(ms_data.wave_amt)..")"
        end
    end)

    info_panel.AddSection("Entity Count")
    info_panel.ent_count = info_panel.CreateTable({
        {["allies"] = "0"},
        {["workers"] = "0"},
        {["guards"] = "0"},
        {["specials"] = "0"},
        {["civilians"] = "0"},
        {["enemies"] = "0"},
        {["snipers"] = "0"},
        {["all npcs"] = "0"},
        {["players"] = "1"}
    })

    info_panel.players_count_text = info_panel.ent_count[9]

    info_panel.AddSection("Players Info")

    for _, player in ipairs(Players:GetPlayers()) do
        info_panel.players_count += 1
        task.spawn(info_panel.AddPlayerInfo, player)
    end
    info_panel.players_count_text.Text = tostring(info_panel.players_count)

    Players.PlayerAdded:Connect(function(player)
        info_panel.players_count += 1
        info_panel.players_count_text.Text = tostring(info_panel.players_count)
        task.spawn(info_panel.AddPlayerInfo, player)
    end)

    Players.PlayerRemoving:Connect(function()
        info_panel.players_count -= 1
        info_panel.players_count_text.Text = tostring(info_panel.players_count)
    end)
end

return info_panel

