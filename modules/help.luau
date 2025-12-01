local gui_util = require("../modules/gui_util")
local cmds_mgr = require("../modules/cmds_mgr")
local cache = require("../modules/cache")

local help = {}

help.desc = nil
help.usage_example = nil

help.Render = function()
    help.window = gui_util.CreateWindow("root@kali: /terminal/help")
    help.window.Position = UDim2.fromScale(0.453, 0.101)
    cache.help_window = help.window

    gui_util.MakeWindowDraggable(help.window)
    local content_holder = gui_util.AddContentHolder(help.window)
    gui_util.SetContentEnv(content_holder)

    gui_util.AddHelpSection("Arguments Explanation")
    gui_util.AddTextBlock("What is an argument? The argument is the value(s) that you type after the command. They determine how the command will act. For example, when you type loopws 50, \"50\" is the argument of command loopws, and when you execute this command, it will set the walk speed of your character to 50.\nIn the command description, you can see the \"call\" line, which shows which values with which data types the arguments of a particular command should be.\nSome arguments in commands description has symbols \"?\" and \"+\", that's what they mean:\n\t? - this command argument is optional, and if it is not specified, this argument will be replaced with the default value in the command. If this character isn't present, then this command argument is required.\n\t+ - this command argument can be entered several times in a row with different values. For example: kill <npc_group: text>+ - kill w g s c.", 0.8)
    
    gui_util.AddHelpSection("Commands Types Explanation")
    gui_util.AddTextBlock("The types of commands are divided according to how they are execute and behave.\n• switch - the first command call makes the changes, and the second command call reverts these changes.\n• one time - every command call does some changes.\n• visible - the changes caused by this command may be directly or indirectly visible to your teammates.\n• invisible - the changes caused by this command may be visible only for you.\n• reversible - the consequences caused by this command are reversible.\n• irreversible - the consequences caused by this command are irreversible.\n• network ownership dependent - in Roblox, \"network ownership\" is a technology in which physical computations are distributed between the server (game) and all connected clients (players). To control an object, for example npc or bag, you must be the closest player to it.\n• can be executed only before the mission start - in order for this command to work correctly and stably, it must be executed before the mission starts.", 0.85)

    gui_util.AddHelpSection("NPCs Groups Legend")
    gui_util.AddTextBlock("a - allies (Rose, Rivera, Jade)\nw - workers (employee, staff, tech, etc.)\ng - guards (guards, base security, security, etc.)\ns - specials (manager, falcon, ryan, etc.)\ne - enemies (SWAT, aegis unit, SC shredder, etc.)\nc - civilians\nsp - snipers (doesn't works with most commands)\nall - all npcs (excluding snipers)\n\nitem - ground items (thermite, lockpick, etc.)\nbag - ground bags (equipment bag, cash, gold, etc.)", 0.45)

    local cmds_section = gui_util.AddHelpSection("Avalable Commands")

    local count = 0
    for _, data in ipairs(cmds_mgr.cmds) do
        count += 1
        gui_util.AddHelpButton(data.name, function() help.desc.Text = data.desc or "no command description."; help.usage_example.Text = data.usage_example or "no usage example." end)
    end
    cmds_section.Text = "Avalable Commands ["..tonumber(count).."]"

    local cmd_desc = gui_util.CreateWindow("Command Description")
    cmd_desc.Size = UDim2.fromScale(1, 1)
    cmd_desc.Position = UDim2.fromScale(1.02, 0)
    cmd_desc.Visible = true
    cmd_desc:WaitForChild("app_name_holder", math.huge):WaitForChild("app_name", math.huge):WaitForChild("close_button", math.huge):Destroy()
    cmd_desc.Parent = help.window

    gui_util.SetContentEnv(cmd_desc)

    local gh_size = gui_util.gui_holder.AbsoluteSize

    local section1 = gui_util.AddHelpSection("Command Description")
    section1.Size = UDim2.fromScale(0.931, 0.052)
    section1.Position = UDim2.fromScale(0.034, 0.086)

    local desc = gui_util.GetUbuntuText("")
    desc.BackgroundTransparency = 0
    desc.TextScaled = false
    desc.TextWrapped = true
    desc.BackgroundColor3 = Color3.fromRGB(25, 26, 31)
    desc.Size = UDim2.fromScale(0.929, 0.517)
    desc.Position = UDim2.fromScale(0.034, 0.16)
    desc.TextSize = (gh_size.X + gh_size.Y) / 250
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.LineHeight = 1.3
    desc.BorderSizePixel = 0
    desc.Parent = cmd_desc

    help.desc = desc

    local section2 = gui_util.AddHelpSection("Usage Example")
    section2.Size = UDim2.fromScale(0.931, 0.052)
    section2.Position = UDim2.fromScale(0.034, 0.702)

    local usage_example = desc:Clone()
    usage_example.Size = UDim2.fromScale(0.929, 0.188)
    usage_example.Position = UDim2.fromScale(0.034, 0.783)
    usage_example.TextSize = (gh_size.X + gh_size.Y) / 250
    usage_example.Parent = cmd_desc

    help.usage_example = usage_example

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.025, 0)
    UIPadding.PaddingLeft = UDim.new(0.025, 0)
    UIPadding.PaddingRight = UDim.new(0.025, 0)
    UIPadding.PaddingTop = UDim.new(0.025, 0)
    UIPadding.Parent = desc

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0.075, 0)
    UIPadding.PaddingLeft = UDim.new(0.025, 0)
    UIPadding.PaddingRight = UDim.new(0.025, 0)
    UIPadding.Parent = usage_example

    gui_util.gui_holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        desc.TextSize = (gh_size.X + gh_size.Y) / 250
        usage_example.TextSize = (gh_size.X + gh_size.Y) / 250
    end)
end

return help