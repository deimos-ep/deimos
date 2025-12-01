local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Level = game.Workspace:WaitForChild("Level", math.huge)
local PlrModels = Level:WaitForChild("Players", math.huge)
local Glass = Level:WaitForChild("Glass", math.huge)
local Actors = Level:WaitForChild("Actors", math.huge)
local esp_holder = nil

local cache = require("../modules/cache")

local esp_mgr = {}

esp_mgr.settings = {
    civilians = {
        FillColor = Color3.fromRGB(0, 0, 0),
        FillTransparency = 0.5,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineTransparency = 0.5
    },
    workers = {
        FillColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineTransparency = 0.5
    },
    guards = {
        FillColor = Color3.fromRGB(255, 0, 0),
        FillTransparency = 0.5,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineTransparency = 0.5
    },
    specials = {
        FillColor = Color3.fromRGB(0, 0, 255),
        FillTransparency = 0.5,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineTransparency = 0.5
    },
    enemies = {
        FillColor = Color3.fromRGB(255, 0, 0),
        FillTransparency = 0.25,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineTransparency = 0.5
    },
    snipers = {
        FillColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 0
    },
    allies = {
        FillColor = Color3.fromRGB(255, 171, 0),
        FillTransparency = 0.5,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineTransparency = 0.5
    },
    cams = {
        FillColor = Color3.fromRGB(0, 255, 0),
        FillTransparency = 0.5,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineTransparency = 0.5
    },
    players = {
        FillColor = Color3.fromRGB(255, 165, 0),
        FillTransparency = 0.75,
        OutlineColor = Color3.fromRGB(255, 165, 0),
        OutlineTransparency = 0 
    },
    objects = {
        FillColor = Color3.fromRGB(255, 255, 0),
        FillTransparency = 0.75,
        OutlineColor = Color3.fromRGB(255, 255, 0),
        OutlineTransparency = 0
    },
    items = {
        Color3 = Color3.fromRGB(30, 223, 0),
        Radius = 0.1,
        AlwaysOnTop = true
    },
    weapons = {
        Color3 = Color3.fromRGB(255, 217, 0),
        Radius = 0.1,
        AlwaysOnTop = true
    }
}

esp_mgr.data = {
    esps = {}
}

esp_mgr.AddNPCsESP = function()
    local ESPModel = Instance.new("Model")
    ESPModel.Name = "ESP"
    ESPModel.Parent = Actors
    esp_holder = ESPModel

    for _, team in ipairs({"civilians", "workers", "guards", "specials", "enemies", "snipers", "allies"}) do
        local ESPGroup = Instance.new("Model")
        ESPGroup.Name = team
        ESPGroup.Parent = ESPModel

        local ESP = Instance.new("Highlight")
        for property, value in pairs(esp_mgr.settings[team]) do
            ESP[property] = value
        end
        ESP.Enabled = cache.flags and cache.flags.esp or false
        ESP.Adornee = ESPGroup
        ESP.Parent = ESPGroup
        table.insert(esp_mgr.data.esps, ESP)
    end
end

esp_mgr.AddCamsESP = function()
    local ESPGroup = Instance.new("Model")
    ESPGroup.Name = "cams"
    ESPGroup.Parent = esp_holder

    local ESP = Instance.new("Highlight")
    for property, value in pairs(esp_mgr.settings["cams"]) do
        ESP[property] = value
    end
    ESP.Enabled = cache.flags and cache.flags.esp or false
    ESP.Adornee = ESPGroup
    ESP.Parent = ESPGroup
    table.insert(esp_mgr.data.esps, ESP)

    for _, obj in ipairs(Glass:GetChildren()) do
        if obj.Name == "ExteriorCam" then
            obj.Parent = ESPGroup
        end
    end

    Glass.ChildAdded:Connect(function(obj)
        if obj.Name == "ExteriorCam" then
            task.wait(0.5)
            obj.Parent = ESPGroup
        end
    end)

    task.spawn(function()
        for i = 0, 8, 0.25 do
            ESP.Adornee = nil
            task.wait(0.25)
            ESP.Adornee = ESPGroup
        end
    end)
end

esp_mgr.AddPlayersESP = function()
    local function internal(character)
        if character.Name == LocalPlayer.Name then return end

        local ESP = Instance.new("Highlight")
        for property, value in pairs(esp_mgr.settings["players"]) do
            ESP[property] = value
        end

        ESP.Enabled = cache.flags and cache.flags.esp or false
        ESP.Adornee = character
        ESP.Parent = character

        table.insert(esp_mgr.data.esps, ESP)

        task.spawn(function()
            for i = 0, 2, 0.25 do
                ESP.Adornee = nil
                task.wait(0.25)
                ESP.Adornee = character
            end
        end)
    end

    for _, player in ipairs(PlrModels:GetChildren()) do
        if player == LocalPlayer then continue end
        task.spawn(internal, player)
    end

    PlrModels.ChildAdded:Connect(internal)
end

esp_mgr.AddItemAdornment = function(base, group_name)
    local ESP =  Instance.new("SphereHandleAdornment")
    for property, value in pairs(esp_mgr.settings[group_name]) do
        ESP[property] = value
    end
    ESP.ZIndex = 1
    ESP.Adornee = base
    ESP.Visible = cache.flags and cache.flags.esp or false
    ESP.Parent = base
    table.insert(esp_mgr.data.esps, ESP)
end

esp_mgr.AddObjectESP = function(parent)
    local ESP = Instance.new("Highlight")
    for property, value in pairs(esp_mgr.settings["objects"]) do
        ESP[property] = value
    end

    ESP.Enabled = cache.flags and cache.flags.esp or false
    ESP.Adornee = parent
    ESP.Parent = parent

    table.insert(esp_mgr.data.esps, ESP)
end

return esp_mgr