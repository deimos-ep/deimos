local Players = game:GetService("Players")

local Level = game.Workspace:WaitForChild("Level", math.huge)
local Geometry = Level:WaitForChild("Geometry", math.huge)
local Doors = Geometry:WaitForChild("Doors", math.huge)
local GroundBags = Level:WaitForChild("GroundBags", math.huge)
local GroundItems = Level:WaitForChild("GroundItems", math.huge)
local GroundWeps = Level:WaitForChild("GroundWeps", math.huge)
local Triggers = Level:WaitForChild("Triggers", math.huge)

local tools = require("../modules/tools")
local cache = require("../modules/cache")
local esp_mgr = require("../modules/esp_mgr")

local obj_mgr = {}

obj_mgr.bags = {}
obj_mgr.items = {}
obj_mgr.weapons = {}
obj_mgr.lock_dirs = {}
obj_mgr.players = {}
obj_mgr.engineers = {}
obj_mgr.stashers = {}

obj_mgr.loud_triggers = {"DrillPosExpert", "DrillPosRookie", "Drill"}

cache.players_data = obj_mgr.players

obj_mgr.ProcessObject = function(obj, data)
    --print("ProcessObject called, obj:", obj:GetFullName())
    local base = obj:WaitForChild("Base", 3)
    if not base then return end
    --print("Got Base")

    local Attachment = Instance.new("Attachment")
    Attachment.Parent = base

    local obj_data = {
        align_o = tools.AddAlignO(Attachment, base),
        align_p = tools.AddAlignP(Attachment, base),
        base = base
    }

    if data[3] == "items" or data[3] == "weapons" then
        obj_data.esp = esp_mgr.AddItemAdornment(base, data[3])
    end

    --print("data[2] =", data[2])
    --print("cache.working_cmds[data[2]] =", cache.working_cmds[data[2]])
    --if not table.find({"870 MCS", "CZ75", "MP7", "RFB-C", "S97Shield", "SwatSniper", "UP9Shield"}, obj.Name) then
        obj_data.align_o.Enabled = cache.flags[data[2]]
        obj_data.align_p.Enabled = cache.flags[data[2]]

        data[1][obj] = obj_data
    --[[else
        obj_data.align_o.Enabled = true
        obj_data.align_p.Enabled = true

        obj_data.align_p.Position = Vector3.new(base.Position.X, -2500000, base.Position.Z)
    end]]--
end

obj_mgr.NoclipOBJ = function(obj, can_collide)
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("BasePart") == false then continue end
        child.CanCollide = can_collide
    end
end

obj_mgr.ProcessDoor = function(door)
    local Interact = door:WaitForChild("Interact", 3)
    if not Interact then return end
    local LockDir = Interact:WaitForChild("LockDir", 3)
    if not LockDir or LockDir.Value == 0 then return end

    obj_mgr.lock_dirs[LockDir] = LockDir.Value
    if cache.flags.gclearance == true then
        task.spawn(function()
            local chip_reader = door:WaitForChild("ChipReader", 1)
            if chip_reader then
                local interact = door.ChipReader:WaitForChild("Interact", math.huge)
                local DisguiseNeeded = interact:WaitForChild("DisguiseNeeded", 1)
                if DisguiseNeeded then DisguiseNeeded:Destroy() end
            end
        end)
    end

    task.spawn(function()
        local sensors = door:WaitForChild("Sensors", 1)
        if sensors == nil then return end

        local req_engineer = sensors:WaitForChild("Interact", math.huge):WaitForChild("ReqEngineer", math.huge)
        table.insert(obj_mgr.engineers, req_engineer)

        if cache.flags.unlockengi == true then
            req_engineer.Name = "ReqEngineer "
        end
    end)

    if cache.flags.opendoors == true then
        LockDir.Value = 0
    end
end

obj_mgr.ProcessPlayer = function(player)
    local data = {}
    data.character = player.Character or player.CharacterAdded:Wait()
    data.humanoid = data.character:WaitForChild("Humanoid", math.huge)
    data.head_collision = data.character:WaitForChild("HeadCollision", math.huge)

    if cache.weaponkey_cmds.teamheal == true then
        local cooldown = false
                    
        local function internal()
            if cooldown == true then return end
            local damage = tools.CalculateHealDamage(data)

            cooldown = true
            tools.SimulateKnifeHit(data.humanoid, data.head_collision, damage)
            task.wait(0.15)
            cooldown = false
        end

        internal()

        local listener = data.humanoid:GetPropertyChangedSignal("Health"):Connect(internal)
        table.insert(cache.conns.teamheal, listener)
    end

    data.armor = {
        AC = nil,
        AR = nil,
        ABH = nil,
        ABL = nil
    }

    task.spawn(function()
        local armor = tools.WaitForChildren(data.humanoid, "ArmorCap", "ArmorBlockHigh", "ArmorBlockLow", "ArmorRating")
        data.AC = armor[1]
        data.ABH = armor[2]
        data.ABL = armor[3]
        data.AR = armor[4]
    end)

    data.tools = player:WaitForChild("Status", math.huge):WaitForChild("Tools", math.huge)
    data.weapons = player:WaitForChild("Status", math.huge):WaitForChild("Weapons", math.huge)

    obj_mgr.players[player] = data
end

for parent, data in pairs({
        [GroundBags] = {obj_mgr.bags, "loopbag", "bags"}, 
        [GroundItems] = {obj_mgr.items, "loopitem", "items"}, 
        [GroundWeps] = {obj_mgr.weapons, "loopwep", "weapons"}
    }) do
    for _, obj in ipairs(parent:GetChildren()) do
        task.spawn(obj_mgr.ProcessObject, obj, data)
    end

    parent.ChildAdded:Connect(function(obj)
        --print("Detected new child in", parent:GetFullName(), "child:", obj:GetFullName())
        obj_mgr.NoclipOBJ(obj, not cache.flags[data[2]])

        task.spawn(function()
            local listener; listener = obj.ChildAdded:Connect(function(child)
                if child:IsA("BasePart") == false then return end
                child.CanCollide = not cache.flags[data[2]]
            end)

            task.wait(1)

            listener:Disconnect()
        end)

        local listener; listener = obj:GetPropertyChangedSignal("Parent"):Connect(function()
            if obj.Parent == parent then return end
           -- print("Object", obj, "is removing")
            data[obj] = nil
            listener:Disconnect()
        end)

        obj_mgr.ProcessObject(obj, data)
    end)
end

for _, door in ipairs(Doors:GetChildren()) do
    task.spawn(obj_mgr.ProcessDoor, door)
end

Doors.ChildAdded:Connect(obj_mgr.ProcessDoor)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(obj_mgr.ProcessPlayer, player)
end

Players.PlayerAdded:Connect(obj_mgr.ProcessPlayer)

local function DoorTamper(trigger)
    if trigger.Name ~= "DoorTamper" then return end
        
    local interact = trigger:WaitForChild("Interact", 1)
    if not interact then return end

    local req_engineer = interact:WaitForChild("ReqEngineer", 1)
    if req_engineer ~= nil then
        table.insert(obj_mgr.engineers, req_engineer)

        if cache.flags.unlockengi == true then
            req_engineer.Name = "ReqEngineer "
        end
    end
end

for _, trigger in ipairs(Triggers:GetChildren()) do
    task.spawn(DoorTamper, trigger)
end

Triggers.ChildAdded:Connect(DoorTamper)

for _, obj in ipairs(Geometry:GetDescendants()) do
    if obj.Name == "BodyStash" then
        table.insert(obj_mgr.stashers, obj)
    end
end

Geometry.DescendantAdded:Connect(function(obj)
    if obj.Name == "BodyStash" then
        table.insert(obj_mgr.stashers, obj)
    end
end)

return obj_mgr