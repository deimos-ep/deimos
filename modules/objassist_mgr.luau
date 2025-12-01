local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tools = require("../modules/tools")
local npcs_mgr = require("../modules/npc_mgr")
local rmts_mgr = require("../modules/rmts_mgr")

local Level = workspace:WaitForChild("Level", math.huge)
local Geometry = Level:WaitForChild("Geometry", math.huge)
local Triggers = Level:WaitForChild("Triggers", math.huge)
local GroundItems = Level:WaitForChild("GroundItems", math.huge)

local Doors = Geometry:WaitForChild("Doors", math.huge)

local GameState = ReplicatedStorage:WaitForChild("GameState", math.huge)
local Difficulty = GameState:WaitForChild("Difficulty", math.huge).Value

local objassist_mgr = {}

objassist_mgr[3200010305] = function() -- The Blacksite
    local cells_data = {
        ["A"] = {
            drill = nil,
            blowtorch = nil,
            panel = nil,
            triggers_area = Vector3.new(-60.943, 8.716, 67.282),
            checked = false
        },
        ["B"] = {
            drill = nil,
            blowtorch = nil,
            panel = nil,
            triggers_area = Vector3.new(-35.982, 18.717, 24.057),
            checked = false
        },
        ["C"] = {
            drill = nil,
            blowtorch = nil,
            panel = nil,
            triggers_area = Vector3.new(14.018, 8.715, 24.056),
            checked = false
        },
        ["D"] = {
            drill = nil,
            blowtorch = nil,
            panel = nil,
            triggers_area = Vector3.new(28.944, 8.715, 49.017),
            checked = false
        },
    }
    
    tools.ChildCounter(4, Geometry, function(obj)
        if obj.Name ~= "CellScreen" then return false end

        local ObjectName = obj:WaitForChild("Interact", math.huge):WaitForChild("ObjectName", math.huge).Value
        local PanelLetter = string.sub(ObjectName, 6, 6)
        cells_data[PanelLetter].panel = obj

        return true
    end)

    local windows_count = 4
    local panel_teleported = false
    
    tools.ChildCounter(8, Triggers, function(trigger)
        if not table.find({"Drill", "Blowtorch"}, trigger.Name) then return false end
        local HalfTrigger = trigger:WaitForChild("HalfTrigger", 2)
        if not HalfTrigger then return false end

        for letter, data in pairs(cells_data) do
            if tools.ComparePositions(data.triggers_area, HalfTrigger.Position, 2) == true then
                local name = trigger.Name == "Drill" and "drill" or "blowtorch"
                if name == "drill" then
                    trigger:GetPropertyChangedSignal("Parent"):Once(function()
                        windows_count -= 1
                        data.checked = true
                        if windows_count == 1 and Geometry:WaitForChild("RoseCellModel", 1) == nil then
                            panel_teleported = true
                            for _, data in pairs(cells_data) do
                                if data.checked == true then continue end
                                data.panel.PrimaryPart = data.panel.Screen
                                data.panel:SetPrimaryPartCFrame(CFrame.new(Vector3.new(-9.792, 8.367, 66.436)) * CFrame.Angles(0, 0, math.rad(-90)))
                            end
                        end
                    end)
                end
                data[name] = trigger
                return true
            end
        end

        return false
    end)

    local drill_start = CFrame.new(Vector3.new(-9.943, 8.333, 68.902))
    local blowtorch_start = CFrame.new(Vector3.new(-9.943, 7.167, 68.902))
    local trigger_offset = 0

    for _, letter in ipairs({"A", "B", "C", "D"}) do
        for _, trigger in ipairs({cells_data[letter].drill, cells_data[letter].blowtorch}) do
            trigger.PrimaryPart = trigger.HalfTrigger
            local start_pos = trigger.Name == "Drill" and drill_start or blowtorch_start
            trigger:SetPrimaryPartCFrame((start_pos - Vector3.new(0, 0, trigger_offset)) * CFrame.Angles(0, math.rad(-90), 0))
        end
        trigger_offset += 1
    end

    local CutsceneTrigger = Geometry:WaitForChild("RoseCellModel", math.huge):WaitForChild("CutsceneTrigger", math.huge)
    if panel_teleported == false then
        for _, data in pairs(cells_data) do
            if tools.ComparePositions(data.triggers_area, CutsceneTrigger.Position, 5) == true then
                data.panel.PrimaryPart = data.panel.Screen
                data.panel:SetPrimaryPartCFrame(CFrame.new(Vector3.new(-9.792, 8.367, 66.436)) * CFrame.Angles(0, 0, math.rad(-90)))
                break
            end
        end
    end

    local listener; listener = rmts_mgr.GetRemote("ChangeStageTarget").OnClientEvent:Connect(function(_, stage_num, _, _)
        if stage_num ~= 3 then return end
        listener:Disconnect()

        tools.FireTouchTrigger(CutsceneTrigger)
    end)

    tools.FireTouchTrigger(Triggers:WaitForChild("FindTrigger", math.huge))

    while npcs_mgr.npcs_data.allies.count == 0 do task.wait() end

    for npc, _ in pairs(npcs_mgr.npcs_data.allies.npcs) do
        npcs_mgr.MoveNPC(npc, Vector3.new(-10.703288078308105, 16.325841903686523, 55.9881591796875))
        npcs_mgr.WaitForExactNpcPos(npc, Vector3.new(-10.703288078308105, 16.325841903686523, 55.9881591796875), 0.075)

        local ExitDoor = Geometry:WaitForChild("ExitDoor", math.huge)
        local Hinge = ExitDoor:WaitForChild("Hinge", math.huge)

        while Hinge.Rotation.Y < 23 do task.wait() end

        npcs_mgr.MoveNPC(npc, Vector3.new(-111.1818618774414, 28.858070373535156, -44.721500396728516))
    end

    for _, obj in ipairs(Geometry:GetChildren()) do
        if not string.find(obj.Name, "Room") or not obj:FindFirstChild("Computer") then continue end

        local Computer = obj.Computer
        local Screen = Computer:WaitForChild("Screen", math.huge)

        for _, door in ipairs(Geometry.Doors:GetChildren()) do
            if not door:FindFirstChild("Center") or not tools.ExactPosBetweenVectors(Screen.Position, door.Center.Position, 23.4, 1) then
                continue 
            end

            door.PrimaryPart = door.Center
            door:SetPrimaryPartCFrame(CFrame.new(-114.722, 29.898, 49.447) * CFrame.Angles(0, 0, 0))
            break
        end

        Computer.PrimaryPart = Screen
        Computer:SetPrimaryPartCFrame(CFrame.new(-110.772, 29.123, 49.448) * CFrame.Angles(0, math.rad(0), 0))

        break
    end
end

objassist_mgr[2797881676] = function() -- The Financier
    local z_offset = 0
    local count = 0
    local required_count = 0

    if Difficulty >= 4 then
        required_count = 3
    elseif Difficulty >= 2 and Difficulty <= 3 then
        required_count = 2
    else
        required_count = 1
    end

    tools.ChildCounter(required_count, Geometry, function(obj)
        if obj.Name ~= "PowerBox" then return false end

        local case = obj:WaitForChild("Case", math.huge)
        case:WaitForChild("Interact", math.huge):WaitForChild("Time", math.huge).Value = 5
        obj.PrimaryPart = case:WaitForChild("BasePart", math.huge)
        obj:SetPrimaryPartCFrame(CFrame.new(-3.205, 5.9, -30.888 + z_offset) * CFrame.Angles(0, math.rad(90), 0))
        z_offset += 2

        return true
    end)

    local HardDrive = GroundItems:WaitForChild("HardDrive", math.huge)
    local Data = HardDrive:WaitForChild("Data", math.huge)
    while HardDrive ~= nil do
        rmts_mgr.GetRemote("TryPickup"):Invoke(Data)
        task.wait(0.25)
    end
end

objassist_mgr[2625195454] = function() -- The Deposit
    local ManagerComputer = Geometry:WaitForChild("ManagerComputer", math.huge)
    ManagerComputer.PrimaryPart = ManagerComputer:WaitForChild("Screen", math.huge)
    ManagerComputer:SetPrimaryPartCFrame(CFrame.new(209.09, 190.65, 115.679) * CFrame.Angles(0, math.rad(90), 0))
    ManagerComputer:WaitForChild("Interact", math.huge):WaitForChild("Time", math.huge).Value = 2.5

    local AccComputers = Geometry:WaitForChild("AccComputers", math.huge)
    tools.WaitForChildWithIndex(AccComputers, 4)
    for _, computer in ipairs(AccComputers:GetChildren()) do
        task.spawn(function()
            if computer:WaitForChild("Interact", 3) ~= nil then
                computer.PrimaryPart = computer:WaitForChild("Screen", math.huge)
                computer:SetPrimaryPartCFrame(CFrame.new(206.19, 190.65, 115.679) * CFrame.Angles(0, math.rad(90), 0))
            end
        end)
    end

    local SafeDoor = Geometry:WaitForChild("Safe", math.huge):WaitForChild("SafeDoor", math.huge)
    local Base = SafeDoor:WaitForChild("Base", math.huge)

    local safe_triggers = {}

    tools.ChildCounter(3, Triggers, function(trigger)
        if not table.find({"Drill", "Blowtorch", "Safecrack"}, trigger.Name) then return false end
        local HalfTrigger = trigger:WaitForChild("HalfTrigger", 2)
        if not HalfTrigger then return false end

        if tools.ComparePositions(Base.Position, HalfTrigger.Position, 3) == true then
            table.insert(safe_triggers, trigger)
            return true
        end

        return false
    end)

    SafeDoor.PrimaryPart = Base
    SafeDoor:SetPrimaryPartCFrame(CFrame.new(203.454, 190.344, 115.579) * CFrame.Angles(0, math.rad(180), 0))

    for _, trigger in ipairs(safe_triggers) do
        trigger.PrimaryPart = trigger.HalfTrigger
        local cframe = nil
        if trigger.Name == "Drill" then
            cframe = CFrame.new(Vector3.new(202.623, 191.167, 115.298))
        elseif trigger.Name == "Blowtorch" then
            cframe = CFrame.new(Vector3.new(202.623, 190.487, 115.298))
        elseif trigger.Name == "Safecrack" then
            cframe = CFrame.new(Vector3.new(203.303, 191.167, 115.298))
        end
        cframe *= CFrame.Angles(0, 0, 0)
        trigger:SetPrimaryPartCFrame(cframe)
    end

    task.spawn(function()
        local KeycardRed = GroundItems:WaitForChild("KeycardRed", math.huge)
        local Data = KeycardRed:WaitForChild("Data", math.huge)
        while KeycardRed.Parent ~= nil do
            rmts_mgr.GetRemote("TryPickup"):Invoke(Data)
            task.wait(0.25)
        end
    end)

    local VaultKeypad = Geometry:WaitForChild("VaultKeypad", math.huge)
    VaultKeypad:WaitForChild("Interact", math.huge):WaitForChild("Time", math.huge).Value = 2
    VaultKeypad.PrimaryPart = VaultKeypad:WaitForChild("Union", math.huge)
    VaultKeypad:SetPrimaryPartCFrame(CFrame.new(209.94, 188.44, 115.559) * CFrame.Angles(0, 0, 0))

    local BoxLoc = nil

    local listener = rmts_mgr.GetRemote("ChangeStageTarget").OnClientEvent:Connect(function(_, stage_num, _, obj)
        if stage_num ~= 4 then return end
        BoxLoc = obj
    end)

    local listener2 = rmts_mgr.GetRemote("AddStage").OnClientEvent:Connect(function(_, stage_num, _, obj)
        if stage_num ~= 4 then return end
        BoxLoc = obj
    end)

    while BoxLoc == nil do task.wait() end

    listener:Disconnect()
    listener2:Disconnect()

    local BoxTriggers = {}

    tools.ChildCounter(2, Triggers, function(trigger)
        if not table.find({"Drill", "Lockpick"}, trigger.Name) then return false end
        local HalfTrigger = trigger:WaitForChild("HalfTrigger", 2)
        if not HalfTrigger then return false end

        if tools.ComparePositions(BoxLoc.Position, HalfTrigger.Position, 1.2) == true then
            table.insert(BoxTriggers, trigger)
            return true
        end

        return false
    end)

    for _, trigger in ipairs(BoxTriggers) do
        trigger.PrimaryPart = trigger.HalfTrigger
        local cframe = nil
        if trigger.Name == "Drill" then
            cframe = CFrame.new(Vector3.new(207.296, 188.5, 115.659))
        elseif trigger.Name == "Lockpick" then
            cframe = CFrame.new(Vector3.new(208.373, 188.5, 115.659))
        end
        cframe *= CFrame.Angles(0, 0, 0)
        trigger:SetPrimaryPartCFrame(cframe)
    end

    local PhoenixStash = GroundItems:WaitForChild("PhoenixStash", math.huge)
    local Data = PhoenixStash:WaitForChild("Data", math.huge)
    while PhoenixStash ~= nil do
        rmts_mgr.GetRemote("TryPickup"):Invoke(Data)
        task.wait(0.25)
    end
end

objassist_mgr[2951213182] = function() -- The Withdrawal
    for npc, _ in pairs(npcs_mgr.npcs_data.specials.npcs) do
        npcs_mgr.MoveNPC(npc, Vector3.new(40.61, 3.3, 42.009))
    end

    local ServerRoom = Geometry:WaitForChild("ServerRoom", math.huge)
    tools.FireTouchTrigger(ServerRoom:FindFirstChild("FindTrigger"))

    local Door = tools.WaitForChildWithIndex(Doors, 18)
    Door.PrimaryPart = Door:WaitForChild("Center", math.huge)
    Door:SetPrimaryPartCFrame(CFrame.new(28.69, 4.4, 98.687) * CFrame.Angles(0, math.rad(-90), 0))
    Door:WaitForChild("Interact", math.huge):WaitForChild("LockDir", math.huge).Value = 0

    Door.Interact:GetPropertyChangedSignal("Value"):Connect(function()
        local Computer = ServerRoom:WaitForChild("Computer", math.huge)
        Computer.PrimaryPart = Computer:WaitForChild("Center", math.huge)
        Computer:SetPrimaryPartCFrame(CFrame.new(28.794, 5.047, 97.739) * CFrame.Angles(0, math.rad(90), 0))
        Computer:WaitForChild("Interact", math.huge):WaitForChild("Time", math.huge).Value = 9
    end)

    local PowerBox = tools.WaitForChildWithIndex(Geometry, 1229)
    PowerBox:WaitForChild("InteractArea", math.huge).Name = "InteractArea "
    PowerBox.PrimaryPart = PowerBox:WaitForChild("Case", math.huge):WaitForChild("BasePart", math.huge)
    PowerBox:SetPrimaryPartCFrame(CFrame.new(29.149, 4.897, 100.267) * CFrame.Angles(0, math.rad(90), 0))
    PowerBox:WaitForChild("InteractArea", math.huge):WaitForChild("Part", math.huge).CFrame = PowerBox.PrimaryPart.CFrame - Vector3.new(0.2, 0, 0)

    local Interact = PowerBox.InteractArea:WaitForChild("Interact", math.huge)
    local ObjectTip = Interact:WaitForChild("ObjectTip", math.huge)
    Interact:WaitForChild("Time", math.huge).Value = ObjectTip.Value == "Hold [F] to inspect" and 4 or 8

    ObjectTip:GetPropertyChangedSignal("Value"):Once(function()
        Interact.Time.Value = Interact.ObjectTip.Value == "Hold [F] to inspect" and 4 or 8
    end)
end

return objassist_mgr