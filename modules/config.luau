local tools = require("../modules/tools")

local config = {}

config.config = nil

config.template = {
    keybinds = {
        ["O"] = "",
        ["P"] = "",
        ["K"] = "",
        ["L"] = "",
        ["M"] = "",
        ["Y"] = "",
        ["N"] = "",
        [","] = "",
        ["["] = "",
        ["]"] = "",
        ["'"] = "",
        ["."] = ""
    },
    startup_cmds = {},
    first_time = true,
    scr_settings = {
        startup_response = false,
        af_loud_behaviour = "reset",
        af_time_exceed_behaviour = "reset"
    }
}

config.Save = function()
    if not isfolder("deimos") then
        makefolder("deimos")
    end
    writefile("deimos/config.json", tools.jsonify(config.config))
end

config.Read = function()
    if not isfolder("deimos") or not isfile("deimos/config.json") then return nil end
    return tools.unjsonify(readfile("deimos/config.json"))
end

local saved_config = config.Read()

if saved_config ~= nil and saved_config ~= "" then
    config.config = saved_config

    for key, value in pairs(config.template) do
        if config.config[key] == nil then
            config.config[key] = typeof(value) == "table" and table.clone(value) or value
        end
    end
else
    config.config = config.template
    config.Save()
end

return config