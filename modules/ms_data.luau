local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PlayerWeapons = nil
local WeaponGui = nil
local ObjectivesHolder = nil
local ObjectiveManagment = nil
local PlayerObjectives = nil

local GameState = ReplicatedStorage:WaitForChild("GameState", math.huge)
local LoudStage = GameState:WaitForChild("Stage", math.huge)
local Difficulty = GameState:WaitForChild("Difficulty", math.huge).Value

task.spawn(function()
	PlayerWeapons = PlayerGui:WaitForChild("Weapons", math.huge)
	WeaponGui = PlayerWeapons:WaitForChild("WeaponGui", math.huge)
	ObjectivesHolder = WeaponGui:WaitForChild("Objectives", math.huge)
	ObjectiveManagment = ObjectivesHolder:WaitForChild("ObjectiveManagment", math.huge)
	PlayerObjectives = ObjectiveManagment:WaitForChild("Objectives", math.huge)
end)

local Weapons = ReplicatedStorage:WaitForChild("Weapons", math.huge)
local Objectives = Weapons:WaitForChild("Objectives", math.huge)

local tools = require("../modules/tools")
local esp_mgr = require("../modules/esp_mgr")
local rmts_mgr = require("../modules/rmts_mgr")
local cache = require("../modules/cache")

local Level = workspace:WaitForChild("Level", math.huge)
local GroundBags = Level:WaitForChild("GroundBags", math.huge)
local GroundItems = Level:WaitForChild("GroundItems", math.huge)
local Geometry = Level:WaitForChild("Geometry", math.huge)
local Triggers = Level:WaitForChild("Triggers", math.huge)
local Doors = Geometry:WaitForChild("Doors", math.huge)
local Actors = Level:WaitForChild("Actors", math.huge)

local ms_data; ms_data = {
	[3200010305] = { -- blacksite
        sort_flags = {
            guards = {
                name = {"SC Guard"}
            },
            specials = {
                name = {"SC Commander"}
            },
            enemies = {
                name = {"SC Soldier", "SC Shredder"}
            },
            allies = {
                name = {"Rose"}
            },
            final = {"guards", "specials", "enemies", "allies"}
        },
		fraction_type = 2,
		alt_music = "rbxassetid://1837844069",
		hide_spot = Vector3.new(70.85807037353516, 20.098060607910156, 199.99752807617188),
		objects_esp = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				if string.find(obj.Name, "Room") and obj:FindFirstChild("Computer") then
					esp_mgr.AddObjectESP(obj.Computer)
				end
			end
		end,
	},
	[2797881676] = { -- financier
        sort_flags = {
            guards = {
                name = {"Guard"}
            },
            specials = {
                name = {"Ryan"}
            },
            enemies = {
                name = {"SWAT", "Aegis Unit"}
            },
            final = {"guards", "specials", "snipers"}
        },
		fraction_type = 1,
		alt_music = "rbxassetid://1843513001",
		hide_spot = Vector3.new(-51.04850769042969, 14.899995803833008, -56.45438003540039),
		pb_amt = (function() if Difficulty >= 4 and Difficulty <= 5 then return 3 elseif Difficulty >= 2 and Difficulty <= 3 then return 2 else return 1 end end)(),
		objects_esp = function()
			tools.ChildCounter(ms_data[game.PlaceId].pb_amt + 1, Geometry, function(child)
				if child.Name == "Computer" or child.Name == "PowerBox" then
					esp_mgr.AddObjectESP(child)
					return true
				else
					return false
				end
			end)

			rmts_mgr.GetRemote("ChangeStageTarget").OnClientEvent:Connect(function(...)
				local args = {...}

				if not args[4] or args[4].Name ~= "Part" then return end

				esp_mgr.AddObjectESP(args[4])
			end)
		end,
	},
	[2625195454] = { -- deposit
        sort_flags = {
            civilians = {
                name = {"Civilian"}
            },
            workers = {
                name = {"Employee"}
            },
            guards = {
                name = {"Guard"}
            },
            specials = {
                name = {"Manager"}
            },
            enemies = {
                name = {"SWAT", "Aegis Unit"}
            },
            final = {"guards", "specials", "snipers"}
        },
		fraction_type = 1,
		hide_spot = Vector3.new(165.1376190185547, 173.49996948242188, -160.21685791015625),
		alt_music = "rbxassetid://1842802436",
		objects_esp = function()
			local ManagerComputer = Geometry:WaitForChild("ManagerComputer", math.huge)
			local Safe = Geometry:WaitForChild("Safe", math.huge)
			local AccComputers = Geometry:WaitForChild("AccComputers", math.huge)

			esp_mgr.AddObjectESP(ManagerComputer)
			esp_mgr.AddObjectESP(Safe)

			for _, computer in ipairs(AccComputers:GetChildren()) do
				task.spawn(function()
					if computer:WaitForChild("Interact", 3) ~= nil then
						esp_mgr.AddObjectESP(computer)
					end
				end)
			end
		end,
	},
	[3590667014] = { -- lakehouse
        sort_flags = {
            workers = {
                has_intel = true
            },
            guards = {
                name = {"Phoenix Operative"}
            },
            specials = {
                inventory = "KeycardBlue"
            },
            enemies = {
                name = {"SC Soldier", "SC Shredder"}
            },
            final = {"workers", "specials", "enemies"}
        },
		fraction_type = 2,
		alt_music = "rbxassetid://1842940300",
		hide_spot = Vector3.new(21.38668441772461, 18.50002670288086, -32.37154006958008),
		kill_boss = function()
			local Helicopter = Actors:WaitForChild("Helo", math.huge)
			local Base = Helicopter:WaitForChild("Base", math.huge)
			local Health = Helicopter:WaitForChild("ObjectHealth", math.huge)

			while Health.Value > 0 do
				tools.SimulateShoot(Base, 50000)
				task.wait(1)
			end
		end,
		get_door_unlocker = function()
			tools.WaitForChildWithIndex(Geometry, 1827)

			for _, obj in ipairs(Geometry:GetChildren()) do
				if obj:FindFirstChild("Escape") then
					return obj.Escape:WaitForChild("Interact", math.huge):WaitForChild("Active", math.huge)
				end
			end

			return nil
		end,
		instagrab = function(is_enabled)
			local function internal(objective)
				while objective.Adornee == nil do task.wait() end

				local obj = objective.Adornee
				if obj.Name ~= "Union" then return end

				obj.Parent.Parent:WaitForChild("ServerPickup", math.huge):WaitForChild("PickupTime", math.huge).Value = is_enabled and 0 or 6
			end

			while PlayerObjectives == nil do task.wait() end

			for _, objective in ipairs(PlayerObjectives:GetChildren()) do
				internal(objective)
			end

			PlayerObjectives.ChildAdded:Connect(function(objective)
				internal(objective)
			end)
		end,
		objects_esp = function()
			esp_mgr.AddObjectESP(Geometry:WaitForChild("PowerBox", math.huge))
			esp_mgr.AddObjectESP(ms_data.current.get_door_unlocker().Parent.Parent.Parent)

			tools.ChildCounter(3, Geometry, function(obj)
				if obj.Name ~= "FileFolder" then return false end
				esp_mgr.AddObjectESP(obj)
				return true
			end)
		end,
	},
	[2951213182] = { -- withdrawal
        sort_flags = {
			civilians = {
				name = {"Civilian"}
			},
            workers = {
                name = {"Employee"}
            },
            guards = {
                name = {"Guard"}
            },
            specials = {
                name = {"Manager"}
            },
            enemies = {
                name = {"Police", "SWAT", "Aegis Unit"}
            },
            final = {"workers", "guards", "specials", "snipers"}
        },
		fraction_type = 1,
		alt_music = "rbxassetid://1838627011",
		hide_spot = Vector3.new(39.4105339050293, 3.4001095294952393, 113.61088562011719),
		get_door_unlocker = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				if obj.Name ~= "FireDoor" or obj.WorldPivot.LookVector.X < 0 then continue end
				local OpenTrig = obj:WaitForChild("OpenTrig", math.huge)
				OpenTrig:WaitForChild("Part", math.huge).Size = Vector3.new(5, 7, 2)
				local Interact = OpenTrig:WaitForChild("Interact", math.huge)
				local ObjectTip = Interact:WaitForChild("ObjectTip", math.huge)
				local Active = Interact:WaitForChild("Active", math.huge)
				Active:GetPropertyChangedSignal("Value"):Connect(function()
					if Active.Value == false then
						ObjectTip.Value = "Bypass the sensors first"
					else
						ObjectTip.Value = "Hit [F] to open"
					end
				end)
				return Active
			end

			return nil
		end,
		instagrab = function(is_enabled)
			local count = 0
			for _, bag in ipairs(GroundBags:GetChildren()) do
				if bag.Name ~= "Cash" then continue end
				count += 1
				bag:WaitForChild("PickupTime", math.huge).Value = is_enabled and 0 or 6
			end

			if count < 6 then
				local listener = GroundBags.ChildAdded:Connect(function(bag)
					if bag.Name ~= "Cash" then return end
					bag:WaitForChild("PickupTime", math.huge).Value = is_enabled and 0 or 6
				end)
			end
		end,
		objects_esp = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				if obj.Name == "ServerRoom" then
					esp_mgr.AddObjectESP(obj.Computer)
				end
			end

			esp_mgr.AddObjectESP(tools.WaitForChildWithIndex(Geometry, 1229))
		end,
	},
	[4518266946] = { -- scientist
        sort_flags = {
            workers = {
                inventory = "KeycardHS"
            },
            guards = {
                name = {"Halcyon Operative"}
            },
            specials = {
                name = {"Falcon"}
            },
            allies = {
                name = {"Rivera"}
            },
            enemies = {
                name = {"TRU", "Aegis Unit"}
            },
            final = {"specials", "snipers"}
        },
		fraction_type = 1,
		alt_music = "rbxassetid://1837798598",
		hide_spot = Vector3.new(-21.118181228637695, 3.500000476837158, -20.95203971862793),
		objects_esp = function()
			for _, obj in ipairs(Doors:GetChildren()) do
				if obj:FindFirstChild("ServerUnlock") then
					esp_mgr.AddObjectESP(obj)
				end
			end
		end,
	},
	[4661507759] = { -- SCRS
        sort_flags = {
            workers = {
                name = {"Analyst", "Tech"}
            },
            guards = {
                name = {"Security", "Janitor"}
            },
            specials = {
                name = {"Agent Nightshade", "Agent Hemlock"}
            },
            enemies = {
                name = {"ETF", "Aegis Unit"}
            },
            final = {"workers", "guards", "specials", "enemies"}
        },
		fraction_type = 1,
		alt_music = "rbxassetid://1842940420",
		hide_spot = Vector3.new(52.52033233642578, 15, 188.01849365234375),
		boss_health = {
			[1] = 10500,
			[2] = 14000,
			[3] = 17500,
			[4] = 2100,
			[5] = 24500
		},
		kill_boss = function()
			local Helicopter = Actors:WaitForChild("Helo", math.huge)
			local Base = Helicopter:WaitForChild("Base", math.huge)
			local Health = Helicopter:WaitForChild("ObjectHealth", math.huge)

			local last_health = ms_data.current.boss_health[Difficulty]

			while Health.Value ~= 0  do
				tools.SimulateShoot(Base, 50000)
				task.wait(1)
			end
		end,
		objects_esp = function()
			local RightColor = Geometry:WaitForChild("MetalDetector0", math.huge):WaitForChild("Wire", math.huge).Color
			
			local pc_found = false

			for _, obj in ipairs(Geometry:GetChildren()) do
				if obj.Name == "Model" then
					if (obj:FindFirstChild("SafeDoor") or (obj:FindFirstChild("PowerBoxDoor") and obj:WaitForChild("Wire", math.huge).Color == RightColor)) then
						esp_mgr.AddObjectESP(obj)
					else
						for _, obj_child in ipairs(obj:GetChildren()) do
							if obj_child.Name ~= "Model" or
								not obj_child:FindFirstChild("Interact") or 
								not obj_child.Interact:FindFirstChild("ObjectTip") 
							then continue end

							pc_found = true
							esp_mgr.AddObjectESP(obj)
						end
					end
				end
			end

			if pc_found == false then
				local listener; listener = Geometry.DescendantAdded:Connect(function(obj)
					if obj.Name ~= "ObjectTip" then return end
					while obj.Value == nil or obj.Value == "" do task.wait() end
					if obj.Value ~= "Hold [F] to authorize" then return end

					esp_mgr.AddObjectESP(obj.Parent.Parent)
					listener:Disconnect()
				end)
			end
		end,
	},
	[4768829954] = { -- Black Dusk
        sort_flags = {
            workers = {
                name = {"Workshop Tech", "Programmer", "Tech"}
            },
            guards = {
                name = {"Base Security"}
            },
            specials = {
                name = {"Elite Operative", "Onyx Unit"}
            },
            enemies = {
                name = {"Halcyon Operative", "Juggernaut"}
            },
            final = {"workers", "guards", "specials", "enemies"}
        },
		fraction_type = 2,
		alt_music = "rbxassetid://1842802498",
		hide_spot = Vector3.new(94.17521667480469, 21.497360229492188, 216.7227325439453),
	},
	[2215221144] = { -- Killhouse
        sort_flags = {
            guards = {
                name = {"Guard"}
            },
            specials = {
                inventory = "KeycardRed"
            },
            enemies = {
                name = {"SWAT", "Aegis Unit"}
            },
            final = {"specials", "enemies"}
        },
		fraction_type = 1,
		alt_music = "rbxassetid://1843497734",
		hide_spot = Vector3.new(20.715, 7.23954, 62.0234),
		objects_esp = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				if obj.Name == "PowerBox" then
					esp_mgr.AddObjectESP(obj)
				end
			end
		end,
	},
	[4134003540] = { -- Auction
        sort_flags = {
			civilians = {
				name = {"Civilian"}
			},
            workers = {
                name = {"Staff"}
            },
            guards = {
                name = {"Guard"}
            },
            specials = {
                name = {"Auctioneer"}
            },
            final = {"workers", "guards", "specials"}
        },
		fraction_type = 1,
		hide_spot = Vector3.new(37.45741271972656, 3.4001107215881348, 98.5108871459961),
		objects_esp = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				if obj.Name == "Clipboard" or obj.Name == "Computer" then
					esp_mgr.AddObjectESP(obj)
				end
			end
		end,
	},
	[3925577908] = { -- Gala
        sort_flags = {
			civilians = {
				name = {"Civilian"}
			},
            workers = {
                name = {"Staff"}
            },
            guards = {
                name = {"Guard"}
            },
            specials = {
                inventory = "KeycardRed",
                intel = "KeypadCode"
            },
            final = {"workers", "specials"}
        },
		fraction_type = 1,
		hide_spot = Vector3.new(-4.096112251281738, 7.500090599060059, -54.025657653808594),
		objects_esp = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				if obj:FindFirstChild("SafeDoor") or obj:FindFirstChild("Case") or (obj:FindFirstChild("Interact") and (table.find({"Keypad", [["Artifact"]], "Circuit Box"}, obj.Interact.ObjectName.Value))) then
					esp_mgr.AddObjectESP(obj)
				end
			end
		end,
		instagrab = function(_)
			for _, obj in ipairs(Geometry:GetChildren()) do
				if obj.Name ~= "CaseArtifact" then continue end
				obj:WaitForChild("PickupTime", math.huge):Destroy()
				obj:WaitForChild("Interact", math.huge).Value = true
			end

			for _, bag in ipairs(GroundBags:GetChildren()) do
				if bag.Name ~= "CrateArtifact" then continue end
				bag:WaitForChild("PickupTime", math.huge):Destroy()
				bag:WaitForChild("Interact", math.huge).Value = true
			end

			GroundBags.ChildAdded:Connect(function(bag)
				if bag.Name ~= "CrateArtifact" then return end
				bag:WaitForChild("PickupTime", math.huge):Destroy() 
				bag:WaitForChild("Interact", math.huge).Value = true                
			end)
		end,
	},
	[4388762338] = { -- Cache
        sort_flags = {
            guards = {
                name = {"Guard"}
            },
            final = {"guards"}
        },
		fraction_type = 1,
		hide_spot = Vector3.new(165.1376190185547, 173.49996948242188, -160.21685791015625),
		objects_esp = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				if table.find({"Keypad", "PowerBox", "CameraPanel", "DoorLockPanel", "Toolbox"}, obj.Name) then
					esp_mgr.AddObjectESP(obj)
				elseif obj.Name == "Servers" then
					esp_mgr.AddObjectESP(obj.Computer)
				end
			end
		end,
	},
	[5071816792] = { -- Setup
        sort_flags = {
            guards = {
                name = {"Guard"}
            },
            final = {"guards"}
        },
		fraction_type = 1,
		hide_spot = Vector3.new(88.99303436279297, 23.910255432128906, -1.1216182708740234),
		objects_esp = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				if (obj.Name == "PowerBox" or obj:FindFirstChild("SafeDoor")) or (obj:FindFirstChild("Interact") and obj.Interact.ObjectName.Value == "Files") then
					esp_mgr.AddObjectESP(obj)
				elseif obj:FindFirstChild("Desk") and obj.Desk:FindFirstChild("Computer") then
					esp_mgr.AddObjectESP(obj.Desk.Computer)
				end
			end
		end,
		instagrab = function(is_enabled)
			GroundBags:WaitForChild("CashBag", math.huge):WaitForChild("PickupTime", math.huge).Value = is_enabled and 0 or 6
		end,
	},
	[5188855685] = { -- Lockup
        sort_flags = {
			civilians = {
				name = {"Civilian"}
			},
            guards = {
                name = {"Police", "Detective"}
            },
            specials = {
                name = {"Evidence Custodian", "Police Captain"}
            },
            enemies = {
                name = {"SWAT", "Aegis Unit"}
            },
            allies = {
                name = {"Jade"}
            },
            final = {"guards", "specials", "snipers", "allies"}
        },
		hide_spot = Vector3.new(2.96498, 3.48513, 90.5891),
		fraction_type = 1,
		alt_music = "rbxassetid://1836789312",
		objects_esp = function()
			for _, obj in ipairs(Geometry:GetChildren()) do
				task.spawn(function()
					if obj:WaitForChild("Interact", 10) and obj.Interact:WaitForChild("ObjectName", 10) and table.find({"File", "Radio"}, obj.Interact.ObjectName.Value) then
						esp_mgr.AddObjectESP(obj)
					end
				end)
			end
		end,
	},
	[5862433299] = { -- Score
        sort_flags = {
            enemies = {
                name = {"SWAT", "Aegis Unit"}
            },
			allies = {
				name = {"Jade"}
			},
            final = {"allies", "snipers"}
        },
		fraction_type = 1,
		alt_music = "rbxassetid://1836808611",
		hide_spot = Vector3.new(237.0268096923828, 16.700029373168945, 45.57285690307617),
		kill_boss = function()
			for count = 1, 2, 1 do
				local Turret = Actors:WaitForChild("Turret", math.huge)
				local Base = Turret:WaitForChild("Gun", math.huge)
				local Health = Turret:WaitForChild("ObjectHealth", math.huge)

				while Health.Value > 0 do
					tools.SimulateShoot(Base, 50000)
					task.wait(1)
				end

				Turret.Name = "Turret "
			end
		end,
		instagrab = function(_)
			for _, bag in ipairs(GroundBags:GetChildren()) do
				if bag.Name ~= "Gold" then continue end
				task.spawn(function()
					bag:WaitForChild("PickupTime", math.huge):Destroy()
				end)
			end

			GroundBags.ChildAdded:Connect(function(bag)
				if bag.Name ~= "Gold" then return end
				bag:WaitForChild("PickupTime", math.huge):Destroy()
			end)
		end,
	},
	[7799530284] = { -- Concept
        sort_flags = {
			civilians = {
				name = {"Civilian"}
			},
            workers = {
                name = {"Employee"}
            },
            guards = {
                name = {"Guard", "Elite Guard"}
            },
            specials = {
                name = {"Manager", "Manager's Assistant"}
            },
            final = {"workers", "guards", "specials"}
        },
		hide_spot = Vector3.new(46.8819, 5.31316, 5.74569),
		fraction_type = 1,
		instagrab = function()
			for _, bag in ipairs(GroundBags:GetChildren()) do
				if not string.find(bag.Name, "Cash") then continue end
				bag:WaitForChild("PickupTime", math.huge).Value = 0
			end

			GroundBags.ChildAdded:Connect(function(bag)
				if not string.find(bag.Name, "Cash") then return end
				bag:WaitForChild("PickupTime", math.huge).Value = 0
			end)
		end,
	},
}

ms_data.current = ms_data[game.PlaceId]
local current = ms_data.current

ms_data.wave_amt = (current.fraction_type == 1 and 3 or 4) * (Difficulty <= 3 and 6 or 10)
ms_data.wavebreak = (current.fraction_type == 1 and 28 or 14)
ms_data.police_count = 0
ms_data.wave = 0

return ms_data
