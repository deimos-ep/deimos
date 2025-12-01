local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

workspace.FallenPartsDestroyHeight = -50000

local tools = require("../modules/tools")
local ms_data = require("../modules/ms_data")
local info_panel = require("../modules/info_panel")
local cache = require("../modules/cache")
local rmts_mgr = require("../modules/rmts_mgr")

local GetRemote = rmts_mgr.GetRemote

local LocalPlayer = Players.LocalPlayer
local PlayerAttachment = nil
local Mouse = LocalPlayer:GetMouse()

local Level = game.Workspace:WaitForChild("Level", math.huge)
local GroundWeps = Level:WaitForChild("GroundWeps", math.huge)
local Actors = Level:WaitForChild("Actors", math.huge)
local ESP = Actors:WaitForChild("ESP", math.huge)
local Triggers = Level:WaitForChild("Triggers", math.huge)

local SnipersSpots = Triggers:FindFirstChild("Snipers")
local SniperPos = {}
if SnipersSpots ~= nil then
    for _, spot in ipairs(SnipersSpots:GetChildren()) do
        table.insert(SniperPos, spot.Position)
    end
end
local SniperSpotsCount = #SniperPos

local npc_mgr = {}

local ent_count = info_panel.ent_count

npc_mgr.wave_kills = 0
npc_mgr.wave_in_progress = false
npc_mgr.wave = 0
npc_mgr.enemy_spawned = false

local GameState = ReplicatedStorage:WaitForChild("GameState", math.huge)
local LoudStage = GameState:WaitForChild("Stage", math.huge)
local Difficulty = GameState:WaitForChild("Difficulty", math.huge)

LoudStage:GetPropertyChangedSignal("Value"):Connect(function()
    npc_mgr.wave = 1
    npc_mgr.wave_in_progress = true
end)

npc_mgr.npcs_data = {
    civilians = {npcs = {}, count = 0, count_text = ent_count[5]},
    allies = {npcs = {}, count = 0, count_text = ent_count[1]},
    workers = {npcs = {}, count = 0, count_text = ent_count[2]},
    guards = {npcs = {}, count = 0, count_text = ent_count[3]},
    specials = {npcs = {}, count = 0, count_text = ent_count[4]},
    enemies = {npcs = {}, count = 0, count_text = ent_count[6]},
    snipers = {npcs = {}, count = 0, count_text = ent_count[7]},
    all = {npcs = {}, count = 0, count_text = ent_count[8]},
}

cache.npcs_data = npc_mgr.npcs_data

npc_mgr.aliases = {
    c = npc_mgr.npcs_data.civilians.npcs,
    a = npc_mgr.npcs_data.allies.npcs,
    w = npc_mgr.npcs_data.workers.npcs,
    g = npc_mgr.npcs_data.guards.npcs,
    s = npc_mgr.npcs_data.specials.npcs,
    e = npc_mgr.npcs_data.enemies.npcs,
    sp = npc_mgr.npcs_data.snipers.npcs,
    all = npc_mgr.npcs_data.all.npcs,
}

npc_mgr.cache = {
    torsos = {}
}

npc_mgr.AssignTeam = function(npc, team, data)
    local old_data = npc_mgr.npcs_data['all'].npcs[npc]

    if old_data ~= nil then
        local old_team = old_data.team
        npc_mgr.npcs_data[old_team].npcs[npc] = nil
        npc_mgr.npcs_data[old_team].count -= 1
        npc_mgr.npcs_data[old_team].count_text.Text = tostring(npc_mgr.npcs_data[old_team].count)
        old_data.team = team
    else
        data.team = team
        npc_mgr.npcs_data['all'].npcs[npc] = data
        npc_mgr.npcs_data['all'].count += 1
        npc_mgr.npcs_data['all'].count_text.Text = tostring(npc_mgr.npcs_data['all'].count)
    end

    npc_mgr.npcs_data[team].npcs[npc] = data
    npc_mgr.npcs_data[team].count += 1
    npc_mgr.npcs_data[team].count_text.Text = tostring(npc_mgr.npcs_data[team].count)
    npc.Parent = ESP[team]
end

npc_mgr.GetNpcsFromTeamByAmt = function(team_aliase, amount)
    local npcs = {}
    local left = amount

    for npc, _ in pairs(npc_mgr.aliases[team_aliase]) do
        table.insert(npcs, npc)
        left -= 1
        if left == 0 then break end
    end

    return amount == 1 and npcs[1] or npcs
end

local count = 0

npc_mgr.RemoveTeam = function(npc)
    local data = npc_mgr.npcs_data['all'].npcs[npc]

    if not data then
        return
    end

    if data.aegis_unit == false and npc_mgr.wave_in_progress == true then
        npc_mgr.wave_kills += 1
        info_panel.ms_info[6].Text = tostring(npc_mgr.wave_kills).."/"..tostring(ms_data.wave_amt - 3 - ms_data.police_count).." ("..tostring(ms_data.wave_amt)..")"
        if npc_mgr.wave_kills >= ms_data.wave_amt - 3 - ms_data.police_count then
            npc_mgr.wave_in_progress = false
            task.spawn(function()
                tools.TimerInText(info_panel.ms_info[8], "break: (", ms_data.wavebreak, ")")
                npc_mgr.wave_kills = 0
                npc_mgr.wave_in_progress = true
                npc_mgr.wave += 1
                if npc_mgr.wave > 1 and Difficulty.Value == 3 then
                    ms_data.wave_amt = (ms_data.current.fraction_type == 1 and 3 or 4) * 10 + ms_data.police_count
                end
                info_panel.ms_info[7].Text = tostring(npc_mgr.wave)
                info_panel.ms_info[8].Text = "in progress"
                info_panel.ms_info[6].Text = "0/"..tostring(ms_data.wave_amt - 3 - ms_data.police_count).." ("..tostring(ms_data.wave_amt)..")"
            end)
        end
    end

    npc_mgr.npcs_data[data.team].npcs[npc] = nil
    npc_mgr.npcs_data[data.team].count -= 1
    npc_mgr.npcs_data[data.team].count_text.Text = tostring(npc_mgr.npcs_data[data.team].count)

    npc_mgr.npcs_data['all'].npcs[npc] = nil
    npc_mgr.npcs_data['all'].count -= 1
    npc_mgr.npcs_data['all'].count_text.Text = tostring(npc_mgr.npcs_data['all'].count)

    if data.beam ~= nil then
        data.beam.Enabled = false
    end
end

npc_mgr.checks = {
    ObjectName = function(name)
        for team, data in pairs(ms_data.current.sort_flags) do
            if data.name ~= nil and table.find(data.name, name.Value) then
                return team
            end
        end

        return nil
    end,
    IntelHolder = function()
        for team, data in pairs(ms_data.current.sort_flags) do
            if data.has_intel ~= nil then
                return team
            end
        end

        return nil
    end,
    Intel = function(intel)
        for team, data in pairs(ms_data.current.sort_flags) do
            if data.intel ~= nil and data.intel == intel.Value then
                return team
            end
        end

        return nil
    end,
    InventoryItem = function(inventory)
        local items = {}

        if inventory.ClassName == "Folder" then
            for _, item in ipairs(inventory:GetChildren()) do
                table.insert(items, item.Name)
            end
        elseif inventory.ClassName == "IntValue" then
            table.insert(items, inventory.Name)
        end

        for team, data in pairs(ms_data.current.sort_flags) do
            if data.inventory ~= nil and table.find(items, data.inventory) then
                return team
            end
        end

        return nil
    end,
    IsAegisUnit = function(name)
        return table.find({"SC Shredder", "Aegis Unit", "Juggernaut"}, name) ~= nil
    end,
    IsFinal = function(team)
        return table.find(ms_data.current.sort_flags.final, team) ~= nil
    end
}

npc_mgr.NoclipNPC = function(data, can_collide)
    if not data then return end
    local character = data.character
    if not character then return end
    
    local body_parts = tools.WaitForChildren(character, "HumanoidRootPart", "LowerTorso", "UpperTorso", "Head", "HeadM", "Hat")
    for _, body_part in ipairs(body_parts) do
        body_part.CanCollide = can_collide
    end
end

npc_mgr.MoveNPC = function(npc, pos)
    local data = npc_mgr.npcs_data["all"].npcs[npc]
    if data == nil or data.align_p == nil or data.align_o == nil then return end

    npc_mgr.NoclipNPC(data, false)

    data.align_p.Enabled = true
    data.align_p.Position = pos

    data.align_o.Enabled = true
    data.align_o.CFrame = CFrame.Angles(0, math.rad(math.random(0, 180)), 0)
end

npc_mgr.WaitForExactNpcPos = function(npc, pos, inaccuracy)
    local data = npc_mgr.npcs_data.all.npcs[npc]

    while data.hrp and ((data.hrp.Position - pos).Magnitude > inaccuracy or data.hrp.AssemblyLinearVelocity.Magnitude > 0.05) do
        task.wait()
    end
end

npc_mgr.WaitForRadioCallEnd = function(npc)
    local data = npc_mgr.npcs_data.all.npcs[npc]

    if data == nil then return end

    while data and data.character == nil do task.wait() end

    local radio = data.character:WaitForChild("Head", math.huge):WaitForChild("Investigate", math.huge):WaitForChild("Radio", math.huge)
    
    while radio and radio.Visible == true do
        task.wait()
    end
end

npc_mgr.VoidNPC = function(npc)
    npc_mgr.MoveNPC(npc, Vector3.new(0, -2500000, 0))
end

npc_mgr.HideNPC = function(npc)
    npc_mgr.MoveNPC(npc, ms_data.current.hide_spot)
end

npc_mgr.KillNPC = function(npc)
    local data = npc_mgr.npcs_data["all"].npcs[npc]
    data.humanoid.Health = 0
    --data.humanoid:Destroy()
end

npc_mgr.ListenForDeath = function(npc, character, humanoid)
    local parent_listener; parent_listener = npc:GetPropertyChangedSignal("Parent"):Connect(function()
        if not npc or npc.Parent == nil or not npc.Parent:IsDescendantOf(Actors) then
            --warn("npc parent changed, new parent:", npc.Parent)
            parent_listener:Disconnect()
            npc_mgr.RemoveTeam(npc)
        end
    end)

    local npc_child_listener; npc_child_listener = npc.ChildRemoved:Connect(function(child)
        if child.Name == "S97Shield" then return end
        npc_child_listener:Disconnect()
        npc_mgr.RemoveTeam(npc)
    end)

    local char_child_listener; char_child_listener = character.ChildRemoved:Connect(function(child)
        if child.Name == "Bullet" or child.Name == "Part" or child.Name == "Hat" then return end
        char_child_listener:Disconnect()
        npc_mgr.RemoveTeam(npc)
    end)

    local health_listener; health_listener = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health <= 0 then
            health_listener:Disconnect()
            npc_mgr.RemoveTeam(npc)
        end
    end)
end

npc_mgr.TorsosNoclipLoop = function()
    RunService.RenderStepped:Connect(function()
        for _, torso in ipairs(npc_mgr.cache.torsos) do
            if torso.CanCollide == true then
                torso.CanCollide = false
            end
        end
    end)
end

npc_mgr.GetNPCOnRay = function()
    local ray = Ray.new(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction * 1000)
	local IntersectionPart = game.Workspace:FindPartOnRayWithWhitelist(ray, {ESP})
	return IntersectionPart ~= nil and IntersectionPart.Parent.Parent or nil
end

npc_mgr.PostProcess = function(npc, team, data, sort)
    if team ~= nil then
        if team == "enemies" then
            data.aegis_unit = npc_mgr.checks.IsAegisUnit(data.name)
            
            if cache.flags.rmshields == true then
                task.spawn(function()
                    local shield = npc:WaitForChild("S97Shield", math.huge)
                    if shield == nil then return end
                    shield:Destroy()
                end)
            end

            if game.PlaceId == 2951213182 and npc_mgr.enemy_spawned == false and data.name ~= "Police" then
                npc_mgr.enemy_spawned = true

                for _, data in pairs(npc_mgr.npcs_data.enemies.npcs) do
                    if data.name == "Police" then
                        --ms_data.police_count += 1
                    end
                end

                info_panel.ms_info[6].Text = tostring(npc_mgr.wave_kills).."/"..tostring(ms_data.wave_amt - 3 - ms_data.police_count).." ("..tostring(ms_data.wave_amt)..")"
            end
        end
        
        npc_mgr.AssignTeam(npc, team, data)

        if cache.flags.killaura == true then 
            if cache.killaura_mode == 2 then
                while data and data.humanoid and data.humanoid.Health > 0 do
                    tools.SimulateKnifeHit(data.humanoid, data.hrp, 1000)
                    task.wait(0.25)
                end
            else
                if team ~= "snipers" then
                    npc_mgr.KillNPC(npc)
                end
            end
        else
            if team == "enemies" and cache.flags.loud == true then
                npc_mgr.MoveNPC(npc, Vector3.new(1e9, 1e9, 1e9))
            end
        end

        if team == "snipers" then
            if cache.flags.spkill == true and (cache.flags.killaura == false or (cache.flags.killaura == true and cache.killaura_mode ~= 2)) then
                task.spawn(function()
                    while data and data.humanoid and data.humanoid.Health > 0 do
                        tools.SimulateKnifeHit(data.humanoid, data.hrp, 1000) 
                        task.wait(0.25)
                    end
                end)
            end
        end

        if team == "allies" and cache.flags.allyimmunity == true then
            task.spawn(function()
                local Team = data.humanoid:WaitForChild("Team", math.huge)
                --warn("waiting for team...")
                if Team ~= nil then Team.Value = 1 end
            end)
        end

        if cache.flags.disarm == true and (table.find(cache.disarm, npc_mgr.aliases.all) or table.find(cache.disarm, npc_mgr.npcs_data[data.team].npcs)) then
            local function internal(data)
                while data.weapon.Value ~= nil and data.weapon.Value.Parent ~= nil do
                    GetRemote("AuthItemMove"):InvokeServer(data.weapon.Value, data.weapon.Value.Parent, nil)
                    task.wait(0.05)
                end
            end

            if data.weapon.Value == nil then
                data.weapon:GetPropertyChangedSignal("Value"):Connect(function()
                    if data.weapon.Value ~= nil then
                        task.spawn(internal, data)
                    end
                end)
            else
                task.spawn(internal, data)
            end
        end

        if npc_mgr.checks.IsFinal(team) == true then
            tools.StopTask(sort)
        end
    end
end

npc_mgr.SortNPC = function(npc)
    if npc.Name == "Helo" or npc.Name == "Turret" then return end
    
    local sort = coroutine.create(function(npc, sort)
        --warn("new npc detected")
        local data = {
            team = nil,
            humanoid = nil,
            hrp = nil,
            align_o = nil,
            align_p = nil,
            anti_fall = nil,
            character = nil,
            interact = nil,
            name = nil,
            beam = nil,
            active = nil
        }

        local character = tools.WaitWithCancel(npc, "Character", 3, sort)
        local humanoid = tools.WaitWithCancel(character, "Humanoid", 3, sort)
        local hrp = tools.WaitWithCancel(character, "HumanoidRootPart", 3, sort)
        local attachment = tools.WaitWithCancel(hrp, "RootRigAttachment", 3, sort)

        for _, body_part in ipairs({"LowerTorso", "UpperTorso"}) do
            tools.AsyncWait(character, body_part, 3, function()
                table.insert(npc_mgr.cache.torsos, character[body_part])
            end)
        end

        npc_mgr.ListenForDeath(npc, character, humanoid)

        data.character = character
        data.humanoid = humanoid

        data.anti_fall = humanoid.FallingDown:Connect(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)

        data.hrp = hrp        

        data.align_p = tools.AddAlignP(attachment, hrp)
        data.align_o = tools.AddAlignO(attachment, hrp)
        data.beam = tools.AddBeam(hrp, attachment)

        if PlayerAttachment ~= nil then
            data.beam.Attachment1 = PlayerAttachment
        end

        local interact = tools.WaitWithCancel(character, "Interact", 3, sort)
        data.interact = interact
        local active = tools.WaitWithCancel(interact, "Active", 3, sort)
        data.active = active
        if cache.flags.snaketouch == true then
            data.active.Value = true
        end
        local object_name = tools.WaitWithCancel(interact, "ObjectName", 3, sort)

        data.name = object_name.Value

        local Status = tools.WaitWithCancel(npc, "Status", 5, sort)
        data.status = Status

        local Primary = tools.WaitWithCancel(Status, "Primary", 3, sort)
        data.weapon = Primary

        if (object_name.Value == "SWAT" or object_name.Value == "TRU") and (game.PlaceId == 5862433299 or (SnipersSpots ~= nil and npc_mgr.npcs_data.snipers.count < SniperSpotsCount)) then
            while Primary.Value == nil do task.wait() end
            local Weapon = Primary.Value.Name

            if Weapon == "SwatSniper" then
                npc_mgr.PostProcess(npc, "snipers", data, sort)
            end
        end

        local team = npc_mgr.checks.ObjectName(object_name)
        npc_mgr.PostProcess(npc, team, data, sort)

        if not cache.flags.killaura then
            tools.AsyncWait(character, "Inventory", 3, function()
                local inventory = character.Inventory
                local team = npc_mgr.checks.InventoryItem(inventory)
                npc_mgr.PostProcess(npc, team, data, sort)
    
                inventory.ChildAdded:Connect(function(item)
                    local team = npc_mgr.checks.InventoryItem(item)
                    npc_mgr.PostProcess(npc, team, data, sort)
                end)
            end)
    
            tools.AsyncWait(interact, "Intel", 3, function()
                local intel = interact.Intel
                local team = npc_mgr.checks.IntelHolder(intel)
                npc_mgr.PostProcess(npc, team, data, sort)
    
                intel.ChildAdded:Connect(function(certain_intel)
                    local team = npc_mgr.checks.Intel(intel)
                    npc_mgr.PostProcess(npc, team, data, sort)
                end)
            end)
        end
    end)

    coroutine.resume(sort, npc, sort)
end

task.spawn(function()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart", math.huge)
    PlayerAttachment = Instance.new("Attachment", HRP)

    for _, data in pairs(npc_mgr.npcs_data.all.npcs) do
        if data.team == "snipers" then continue end
        data.beam.Attachment1 = PlayerAttachment
    end
end)

return npc_mgr