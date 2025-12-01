local config = require("../modules/config")
local gui_util = require("../modules/gui_util")
local terminal = require("../modules/terminal")
local cache = require("../modules/cache")

local UserInputService = game:GetService("UserInputService")

local keybinds_config = config.config.keybinds

local keybinds = {}

keybinds.keys = {"O", "P", "K", "L", "M", "Y", "N", ",", "[", "]", "'", "."}

keybinds.Render = function()
    local window = gui_util.CreateWindow("root@kali: /terminal/keybinds")
    window.Position = UDim2.fromScale(0.26, 0.101)
    cache.keybinds_window = window
    gui_util.MakeWindowDraggable(window)
    local content_holder = gui_util.AddContentHolder(window)
    gui_util.SetContentEnv(content_holder)

    gui_util.AddSection("Set Keybinds")

    for _, key in ipairs(keybinds.keys) do
        local input = gui_util.CreateHotkeyInput(key, function(text)
            keybinds_config[key] = text
            config.Save()
        end)

        if keybinds_config[key] ~= nil and keybinds_config[key] ~= "" then
            input:ChangeText(keybinds_config[key])
        end
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode.Value > 255 or UserInputService:GetFocusedTextBox() ~= nil then return end
		local character = string.char(input.KeyCode.Value):upper()
		if keybinds_config[character] == nil or keybinds_config[character] == "" then return end

        terminal.ValidateCommand(keybinds_config[character], "terminal")
    end)
end

return keybinds