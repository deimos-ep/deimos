local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

while Players.LocalPlayer == nil do task.wait() end
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local gui_util = {}

gui_util.gui_holder = nil
gui_util.content_env = nil
gui_util.dropdowns_holders = {}
gui_util.dropdowns_labels = {}
gui_util.dropdowns_options = {}

gui_util.notification = nil

gui_util.notif_stack = {}
gui_util.notif_busy = false

gui_util.zindexes = {
    window_holder = 1,
    app_name_holder = 2,
    app_name_content = 3,
    section = 2,
    dropdown_holder = 2,
    dropdown_label_holder = 5,
    dropdown_label_content = 6,
    dropdown_options_holder = 3,
    dropdown_option = 4,
    element_frame = 2,
    element_content = 3
}

gui_util.ScaleElements = function()
    while gui_util.gui_holder == nil do task.wait() end
    local gh_size = gui_util.gui_holder.AbsoluteSize

    for _, label in ipairs(gui_util.dropdowns_labels) do
        label.Size = UDim2.new(1, 0, 0, gh_size.Y / 31.7352)
    end

    for _, option in ipairs(gui_util.dropdowns_options) do
        option.Size = UDim2.new(1, 0, 0, gh_size.Y / 73.2727)
    end

    for _, holder in ipairs(gui_util.dropdowns_holders) do
        holder.Size = UDim2.new(1, 0, 0, gh_size.Y / 32.3538)
    end

    for _, notif_data in pairs(gui_util.notif_stack) do
        notif_data.Body.TextSize = (gh_size.X + gh_size.Y) / 272.63
        gui_util.notification.Body.TextSize = (gh_size.X + gh_size.Y) / 272.63
    end
end

gui_util.GetUbuntuText = function(text)
    local UbuntuText = Instance.new("TextLabel")
    UbuntuText.BackgroundTransparency = 1
    UbuntuText.TextColor3 = Color3.fromRGB(255, 255, 255)
    UbuntuText.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    UbuntuText.Text = text
    UbuntuText.TextScaled = true

    return UbuntuText
end

gui_util.InitGUIHolder = function()
    local hidden_ui = game:GetService("CoreGui") --gethui and gethui() or game:GetService("CoreGui")
    local GUIHolder = Instance.new("ScreenGui")
    GUIHolder.IgnoreGuiInset = true

    local ds_invite = gui_util.GetUbuntuText("discord.gg/AsWAVd5dqf")
    ds_invite.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    ds_invite.AnchorPoint = Vector2.new(1, 0)
    ds_invite.Position = UDim2.fromScale(0.9965000152587891, 0.005)
    ds_invite.Size = UDim2.fromScale(0.074, 0.014)
    ds_invite.RichText = true
    ds_invite.Parent = GUIHolder

    GUIHolder.Parent = hidden_ui

    GUIHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(gui_util.ScaleElements)

    local system_message = "Press ; to open the command prompt.\nPress Z to open the info panel about the players."
    StarterGui:SetCore("ChatMakeSystemMessage", {Text = system_message, Color = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold}) 
    TextChatService:WaitForChild("TextChannels", math.huge):WaitForChild("RBXGeneral", math.huge):DisplaySystemMessage(system_message)

    gui_util.gui_holder = GUIHolder
end

gui_util.CreateWindow = function(app_name)
    local WindowHolder = Instance.new("Frame")
    WindowHolder.BorderSizePixel = 0
    WindowHolder.Size = UDim2.fromScale(0.182390004, 0.36800000071525574)
    WindowHolder.BackgroundColor3 = Color3.fromRGB(30, 31, 37)
    WindowHolder.Position = UDim2.fromScale(0.2, 0.2)
    WindowHolder.Visible = false
    WindowHolder.Parent = gui_util.gui_holder

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.02, 0)
    UICorner.Parent = WindowHolder

    local AppNameHolder = Instance.new("Frame")
    AppNameHolder.BorderSizePixel = 0
    AppNameHolder.Size = UDim2.fromScale(1, 0.064290002)
    AppNameHolder.BackgroundColor3 = Color3.fromRGB(25, 26, 31)
    AppNameHolder.Name = "app_name_holder"
    AppNameHolder.Parent = WindowHolder

    local AppName = Instance.new("TextLabel")
    AppName.Size = UDim2.fromScale(1, 1)
    AppName.BackgroundTransparency = 1
    AppName.Text = app_name
    AppName.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    AppName.TextScaled = true
    AppName.TextColor3 = Color3.fromRGB(255, 255, 255)
    AppName.Name = "app_name"
    AppName.Parent = AppNameHolder

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.28025999665260315, 0)
    UIPadding.PaddingTop = UDim.new(0.28025999665260315, 0)
    UIPadding.Parent = AppName

    local UICorner2 = UICorner:Clone()
    UICorner2.CornerRadius = UDim.new(0.2, 0)
    UICorner2.Parent = AppNameHolder

    local SquareCornerRight = Instance.new("Frame")
    SquareCornerRight.BorderSizePixel = 0
    SquareCornerRight.Size = UDim2.fromScale(0.0250000004, 0.400000006)
    SquareCornerRight.BackgroundColor3 = Color3.fromRGB(25, 26, 31)
    SquareCornerRight.Position = UDim2.fromScale(0, 0.6)
    SquareCornerRight.BorderSizePixel = 0
    SquareCornerRight.Parent = AppNameHolder

    local SquareCornerLeft = SquareCornerRight:Clone()
    SquareCornerLeft.Position = UDim2.fromScale(0.975, 0.6)
    SquareCornerLeft.Parent = AppNameHolder

    local CloseButton = Instance.new("ImageButton")
    CloseButton.Size = UDim2.fromScale(0.029, 0.85)
    CloseButton.Position = UDim2.fromScale(0.944999993, 0)
    CloseButton.Image = "http://www.roblox.com/asset/?id=18469798055"
    CloseButton.BackgroundTransparency = 1
    CloseButton.Name = "close_button"
    CloseButton.Parent = AppName

    CloseButton.MouseButton1Click:Connect(function()
        WindowHolder.Visible = false
    end)

    return WindowHolder
end

gui_util.MakeWindowDraggable = function(window)
    local holding = false
	local InitialX, InitialY, UIInitialPos

	window.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		holding = true

		InitialX, InitialY, UIInitialPos = Mouse.X, Mouse.Y, window.Position
		while holding and RunService.RenderStepped:Wait() do 
            window.Position = UIInitialPos - UDim2.fromOffset(InitialX - Mouse.X, InitialY - Mouse.Y)	
        end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		holding = false
	end)
end

gui_util.AddContentHolder = function(window)
    local ContentHolder = Instance.new("ScrollingFrame")
    ContentHolder.BorderSizePixel = 0
    ContentHolder.Size = UDim2.fromScale(0.0233299993, 0.0862499997)
    ContentHolder.Position = UDim2.fromScale(0.023, 0.086)
    ContentHolder.Size = UDim2.fromScale(0.949999988079071, 0.8921800255775452)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentHolder.CanvasSize = UDim2.fromScale(0, 1)
    ContentHolder.ScrollBarThickness = 2
    ContentHolder.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentHolder.BorderSizePixel = 0
    ContentHolder.Parent = window

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0.015, 0)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ContentHolder

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingRight = UDim.new(0.021, 0)
    UIPadding.Parent = ContentHolder

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if UIListLayout.AbsoluteContentSize.Y > ContentHolder.AbsoluteSize.Y then
            UIListLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceBetween
        end
    end)

    return ContentHolder
end

gui_util.SetContentEnv = function(content_holder)
    gui_util.content_env = content_holder
end

gui_util.AddElementFrame = function()
    local ElementFrame = Instance.new("Frame")
    ElementFrame.BorderSizePixel = 0
    ElementFrame.Size = UDim2.fromScale(1, 0.091)
    ElementFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    ElementFrame.Parent = gui_util.content_env

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.15, 0)
    UICorner.Parent = ElementFrame

    return ElementFrame
end

gui_util.AddClickableElementFrame = function(onclick)
    local ElementFrame = Instance.new("ImageButton")
    ElementFrame.Size = UDim2.fromScale(1, 0.091)
    ElementFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    ElementFrame.AutoButtonColor = false
    ElementFrame.Parent = gui_util.content_env 

    ElementFrame.MouseButton1Click:Connect(function()
        onclick()
    end)

    ElementFrame.MouseButton1Click:Connect(function()
        onclick()
    end)

    ElementFrame.MouseEnter:Connect(function()
        TweenService:Create(
            ElementFrame,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(38, 38, 43)}
        ):Play()
    end)

    ElementFrame.MouseLeave:Connect(function()
        TweenService:Create(
            ElementFrame,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(22, 22, 25)}
        ):Play()
    end)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.15, 0)
    UICorner.Parent = ElementFrame

    return ElementFrame
end

gui_util.AddSection = function(section_name)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.fromScale(1, 0.05)
    Label.Position = UDim2.fromScale(0.038, 0.116)
    Label.BackgroundTransparency = 1
    Label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Label.TextScaled = true
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Text = section_name
    Label.Parent = gui_util.content_env

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.3, 0)
    UIPadding.Parent = Label

    return Label
end

gui_util.AddHelpSection = function(section_name)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.fromScale(1, 0.058)
    Label.BackgroundColor3 = Color3.fromRGB(47, 49, 58)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Label.Text = section_name
    Label.TextScaled = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BorderSizePixel = 0
    Label.Parent = gui_util.content_env

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.15626999735832214, 0)
    UIPadding.PaddingTop = UDim.new(0.15626999735832214, 0)
    UIPadding.PaddingLeft = UDim.new(0.028669999912381172, 0)
    UIPadding.Parent = Label

    return Label
end

gui_util.AddHelpButton = function(button_name, onclick)
    local was_clicked = false
    local hovered = false

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromScale(1, 0.054999999701976776)
    Button.BackgroundColor3 = Color3.fromRGB(41, 47, 67)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Button.Text = button_name
    Button.AutoButtonColor = false
    Button.BorderSizePixel = 0
    Button.Parent = gui_util.content_env

    Button.MouseButton1Click:Connect(function()
        onclick()

        was_clicked = true
        local Tween = TweenService:Create(
            Button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(57, 65, 93)}
        )
        Tween:Play()
        Tween.Completed:Wait()
        was_clicked = false

        TweenService:Create(
            Button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = hovered == true and Color3.fromRGB(33, 38, 54) or Color3.fromRGB(41, 47, 67)}
        ):Play()
    end)

    Button.MouseEnter:Connect(function()
        hovered = true

        if was_clicked then return end

        TweenService:Create(
            Button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(33, 38, 54)}
        ):Play()
    end)

    Button.MouseLeave:Connect(function()
        hovered = false

        if was_clicked then return end

        TweenService:Create(
            Button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(41, 47, 67)}
        ):Play()
    end)

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.15000000596046448, 0)
    UIPadding.PaddingTop = UDim.new(0.15000000596046448, 0)
    UIPadding.Parent = Button
end

gui_util.AddTextBlock = function(text, y_scale)
    local TextBlock = Instance.new("TextLabel")
    TextBlock.Size = UDim2.fromScale(1, y_scale)
    TextBlock.BackgroundTransparency = 1
    TextBlock.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBlock.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    TextBlock.Text = text
    TextBlock.TextScaled = true
    TextBlock.TextXAlignment = Enum.TextXAlignment.Left
    TextBlock.LineHeight = 1.3
    TextBlock.Parent = gui_util.content_env

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0.035840000957250595, 0) 
    UIPadding.Parent = TextBlock
end

gui_util.AddElementLabel = function(element, label, x_scale, y_scale)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.fromScale(0.529, 0.375)
    Label.Position = UDim2.fromScale(x_scale or 0.04, y_scale or 0.3)
    Label.BackgroundTransparency = 1
    Label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Label.TextScaled = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Text = label
    Label.Parent = element

    return Label
end

gui_util.AddElementInput = function(element, plc_text, onfocuslost)
    local Input = Instance.new("TextBox")
    Input.Size = UDim2.fromScale(0.23656000196933746, 0.5311899781227112)
    Input.Position = UDim2.fromScale(0.7239999771118164, 0.23240000009536743)
    Input.Text = ""
    Input.PlaceholderText = plc_text or ""
    Input.BackgroundColor3 = Color3.fromRGB(34, 35, 45)
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.ClearTextOnFocus = true
    Input.TextScaled = true
    Input.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Input.Parent = element

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.25, 0)
    UICorner.Parent = Input

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.16561999917030334, 0)
    UIPadding.PaddingTop = UDim.new(0.16561999917030334, 0)
    UIPadding.Parent = Input

    local focus_lost = function()
        onfocuslost(Input.Text)
    end

    Input.FocusLost:Connect(focus_lost)

    return Input, focus_lost
end

gui_util.AddElementButton = function(element, button_text, onclick)
    local hovered = false
    local was_clicked = false

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromScale(0.23656000196933746, 0.5311899781227112)
    Button.Position = UDim2.fromScale(0.7239999771118164, 0.23240000009536743)
    Button.Text = button_text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(62, 85, 137)
    Button.TextScaled = true
    Button.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Button.AutoButtonColor = false
    Button.Parent = element

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.25, 0)
    UICorner.Parent = Button

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.16561999917030334, 0)
    UIPadding.PaddingTop = UDim.new(0.16561999917030334, 0)
    UIPadding.Parent = Button

    Button.MouseButton1Click:Connect(function()
        onclick()

        was_clicked = true
        local Tween = TweenService:Create(
            Button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(42, 58, 92)}
        )
        Tween:Play()
        Tween.Completed:Wait()
        was_clicked = false

        TweenService:Create(
            Button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = hovered == true and Color3.fromRGB(50, 69, 110) or Color3.fromRGB(62, 85, 137)}
        ):Play()
    end)

    Button.MouseEnter:Connect(function()
        hovered = true

        if was_clicked then return end

        TweenService:Create(
            Button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(50, 69, 110)}
        ):Play()
    end)

    Button.MouseLeave:Connect(function()
        hovered = false

        if was_clicked then return end

        TweenService:Create(
            Button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(62, 85, 137)}
        ):Play()
    end)

    return Button
end

gui_util.AddElementKeyLabel = function(element, key)
    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Size = UDim2.fromScale(0.07168000191450119, 0.6639900207519531)
    KeyLabel.Position = UDim2.fromScale(0.02800000086426735, 0.16699999570846558)
    KeyLabel.TextScaled = true
    KeyLabel.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    KeyLabel.BackgroundColor3 = Color3.fromRGB(47, 49, 58)
    KeyLabel.Text = key
    KeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyLabel.Parent = element

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = KeyLabel

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.13249999284744263, 0)
    UIPadding.PaddingTop = UDim.new(0.13249999284744263, 0)
    UIPadding.Parent = KeyLabel
end

gui_util.CreateDropdown = function(dropdown_name)
    local opened = false

    local dropdown = {}

    local frame_holder = Instance.new("Frame")
    frame_holder.BorderSizePixel = 0
    frame_holder.Size = UDim2.fromScale(1, 0.089)
    frame_holder.BackgroundColor3 = Color3.fromRGB(32, 33, 42)
    frame_holder.Parent = gui_util.content_env

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.05, 0)
    UICorner.Parent = frame_holder

    local options_holder = Instance.new("ScrollingFrame")
    options_holder.BorderSizePixel = 0
    options_holder.Size = UDim2.fromScale(0.962, 0.67)
    options_holder.Position = UDim2.fromScale(0.028, 0.268)
    options_holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    options_holder.CanvasSize = UDim2.fromScale(0, 1)
    options_holder.ScrollBarThickness = 3
    options_holder.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    options_holder.ScrollingDirection = Enum.ScrollingDirection.Y
    options_holder.ScrollingEnabled = false
    options_holder.BackgroundTransparency = 1    
    options_holder.BorderSizePixel = 0
    options_holder.Parent = frame_holder

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingRight = UDim.new(0.025, 0)
    UIPadding.Parent = options_holder

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0.085, 0)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.Parent = options_holder

    local dropdown_holder = gui_util.AddElementFrame()
    gui_util.AddElementLabel(dropdown_holder, dropdown_name)
    dropdown_holder.Size = UDim2.new(1, 0, 0, gui_util.gui_holder.AbsoluteSize.Y / 32.3538)
    dropdown_holder.Parent = frame_holder
    table.insert(gui_util.dropdowns_holders, dropdown_holder)

    local choice = gui_util.AddElementLabel(dropdown_holder, ". . .")
    choice.Size = UDim2.fromScale(0.48, 0.375)
    choice.Position = UDim2.fromScale(0.4, 0.3)
    choice.TextColor3 = Color3.fromRGB(100, 100, 100)
    choice.TextXAlignment = Enum.TextXAlignment.Right
    choice.Name = "Choice"

    local Arrow = Instance.new("ImageButton")
    Arrow.Size = UDim2.fromScale(0.045, 0.4705899953842163)
    Arrow.Position = UDim2.fromScale(0.9063000082969666, 0.2639400064945221)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "http://www.roblox.com/asset/?id=18476657075"
    Arrow.Parent = dropdown_holder

    Arrow.MouseButton1Click:Connect(function()
        opened = not opened
        gui_util.dropdowns_holders[options_holder] = opened
        options_holder.ScrollingEnabled = opened

        TweenService:Create(
            Arrow,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Rotation = opened == true and 180 or 0}
        ):Play()

        TweenService:Create(
            frame_holder,
            TweenInfo.new(0.2, opened == true and Enum.EasingStyle.Back or Enum.EasingStyle.Sine, opened == true and Enum.EasingDirection.Out or Enum.EasingDirection.InOut), 
            {Size = opened == true and UDim2.fromScale(1, 0.41) or UDim2.fromScale(1, 0.089)}
        ):Play()

        TweenService:Create(
            UIListLayout,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), 
            {Padding = opened == true and UDim.new(0.05, 0) or UDim.new(0.085, 0)}
        ):Play()
    end)

    dropdown.ClearChoice = function(_)
        choice.Text = ". . ."
    end

    dropdown.SetChoice = function(choice_text)
        choice.Text = choice_text
    end

    dropdown.ApplyVerticalFlex = function(_)
        options_holder.UIListLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceBetween
    end

    dropdown.options_holder = options_holder

    return dropdown
end

gui_util.AddDropdownOption = function(dropdown, option_name, onclick)
    local hovered = false
    local was_clicked = false

    local Option = Instance.new("TextButton")
    Option.Size = UDim2.new(1, 0, 0, gui_util.gui_holder.AbsoluteSize.Y / 73.2727)
    Option.BackgroundColor3 = Color3.fromRGB(49, 51, 65)
    Option.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Option.TextColor3 = Color3.fromRGB(255, 255, 255)
    Option.Text = option_name
    Option.AutoButtonColor = false
    Option.BorderSizePixel = 0
    Option.TextScaled = true
    Option.Parent = dropdown.options_holder

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingBottom = UDim.new(0.125, 0)
    UIPadding.PaddingTop = UDim.new(0.125, 0)
    UIPadding.Parent = Option

    Option.MouseButton1Click:Connect(function()
        if not gui_util.dropdowns_holders[dropdown.options_holder] then return end
        onclick()
        dropdown.options_holder.Parent.Frame.Choice.Text = option_name

        was_clicked = true
        local Tween = TweenService:Create(
            Option,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(75, 79, 100)}
        )
        Tween:Play()
        Tween.Completed:Wait()
        was_clicked = false

        TweenService:Create(
            Option,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = hovered == true and Color3.fromRGB(33, 35, 44) or Color3.fromRGB(49, 51, 65)}
        ):Play()
    end)

    Option.MouseEnter:Connect(function()
        if not gui_util.dropdowns_holders[dropdown.options_holder] then return end
        hovered = true

        if was_clicked then return end

        TweenService:Create(
            Option,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(33, 35, 44)}
        ):Play()
    end)

    Option.MouseLeave:Connect(function()
        hovered = false

        if was_clicked then return end

        TweenService:Create(
            Option,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = Color3.fromRGB(49, 51, 65)}
        ):Play()
    end)

    table.insert(gui_util.dropdowns_options, Option)

    if dropdown.options_holder.UIListLayout.AbsoluteContentSize.Y > dropdown.options_holder.AbsoluteSize.Y then
        dropdown.options_holder.UIListLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceBetween
    end

    return Option
end

gui_util.AddElementToggle = function(element, ontoggle)
    local enabled = false

    local Toggle = Instance.new("ImageButton")
    Toggle.Size = UDim2.fromScale(0.06758999824523926, 0.6451799869537354)
    Toggle.Position = UDim2.fromScale(0.8909400105476379, 0.1759600043296814)
    Toggle.BackgroundColor3 = Color3.fromRGB(34, 35, 45)
    Toggle.AutoButtonColor = false
    Toggle.Parent = element

    local press = function()
        enabled = not enabled

        TweenService:Create(
            Toggle,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundColor3 = enabled == true and Color3.fromRGB(62, 85, 137) or Color3.fromRGB(34, 35, 45)}
        ):Play()

        ontoggle(enabled)
    end
    
    Toggle.MouseButton1Click:Connect(press)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = Toggle

    return press
end

gui_util.CreateToggle = function(toggle_name, ontoggle)
    local toggle = {}

    local toggle_holder = gui_util.AddElementFrame()
    gui_util.AddElementLabel(toggle_holder, toggle_name)
    local press_func = gui_util.AddElementToggle(toggle_holder, ontoggle)

    toggle.Call = press_func

    return toggle
end

gui_util.CreateInput = function(input_name, plc_text, onfocuslost)
    local input = {}

    local input_holder = gui_util.AddElementFrame()
    gui_util.AddElementLabel(input_holder, input_name)
    local textbox, focus_lost_func = gui_util.AddElementInput(input_holder, plc_text, onfocuslost)

    input.Call = focus_lost_func

    input.ChangePlcText = function(_, text)
        textbox.PlaceholderText = text
    end

    input.ChangeText = function(_, text)
        textbox.Text = text
    end

    return input
end

gui_util.InitGUIHolder()

local notification_holder = Instance.new("Frame")
notification_holder.BorderSizePixel = 0
notification_holder.Size = UDim2.fromScale(0.215, 0.0885)
notification_holder.BackgroundColor3 = Color3.fromRGB(34, 35, 41)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.075, 0)
UICorner.Parent = notification_holder

local TimeBar = Instance.new("Frame")
TimeBar.BorderSizePixel = 0
TimeBar.Size = UDim2.fromScale(0.95, 0.02)
TimeBar.Position = UDim2.fromScale(0.025, 0.91)
TimeBar.Name = "TimeBar"
TimeBar.Parent = notification_holder

local Label = gui_util.GetUbuntuText("")
Label.TextScaled = true
Label.Size = UDim2.fromScale(1, 0.131)
Label.Position = UDim2.fromScale(0, 0.082)
Label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Name = "Label"
Label.Parent = notification_holder

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0.025, 0)
UIPadding.Parent = Label

local size = gui_util.gui_holder.AbsoluteSize

local Body = gui_util.GetUbuntuText("")
Body.TextWrapped = true
Body.TextXAlignment = Enum.TextXAlignment.Left
Body.TextYAlignment = Enum.TextYAlignment.Top
Body.Size = UDim2.fromScale(1, 0.787)
Body.Position = UDim2.fromScale(0, 0.213)
Body.TextScaled = false
Body.TextSize = (size.X + size.Y) / 272.63
Body.Name = "Body"
Body.Parent = notification_holder

local UIPadding2 = Instance.new("UIPadding")
UIPadding2.PaddingLeft = UDim.new(0.025, 0)
UIPadding2.PaddingRight = UDim.new(0.025, 0)
UIPadding2.PaddingTop = UDim.new(0.05, 0)
UIPadding2.Parent = Body

gui_util.notification = notification_holder

gui_util.SendNotification = function(label_text, body_text, timeout)
    while gui_util.notif_busy == true do task.wait() end
    gui_util.notif_busy = true 

    local Notification = gui_util.notification:Clone()
    Notification.Position = UDim2.fromScale(1, 0.21)
    Notification.Parent = gui_util.gui_holder

    local Label = Notification.Label
    Label.Text = label_text
    local Body = Notification.Body
    Body.Text = body_text

    local last_frame_tween = nil

    for notif, notif_data in pairs(gui_util.notif_stack) do
        notif_data.needed_pos -= 0.1
        notif_data.needed_bgt += 0.1
        notif_data.needed_tt += 0.25

        last_frame_tween = TweenService:Create(
            notif, 
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
            {Position = UDim2.fromScale(0.781, notif_data.needed_pos)}
        )

        last_frame_tween:Play()

        TweenService:Create(
            notif, 
            TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {BackgroundTransparency = notif_data.needed_bgt}
        ):Play()

        TweenService:Create(
            notif_data.label, 
            TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {TextTransparency = notif_data.needed_tt}
        ):Play()

        TweenService:Create(
            notif_data.body, 
            TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {TextTransparency = notif_data.needed_tt}
        ):Play()
    end

    if last_frame_tween ~= nil then
        last_frame_tween.Completed:Wait()
    end

    gui_util.notif_stack[Notification] = {
        label = Label,
        body = Body,
        needed_pos = 0.21,
        needed_bgt = 0,
        needed_tt = 0
    }

    local init_tween = TweenService:Create(
        Notification, 
        TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Position = UDim2.fromScale(0.781, 0.21)}
    )

    init_tween:Play(); init_tween.Completed:Wait()

    TweenService:Create(
        Notification.TimeBar, 
        TweenInfo.new(timeout, Enum.EasingStyle.Linear, Enum.EasingDirection.In), 
        {Size = UDim2.fromScale(0, 0.02)}
    ):Play()

    gui_util.notif_busy = false
    
    task.wait(timeout)

    local destroying_tween = TweenService:Create(
        Notification, 
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
        {Position = UDim2.fromScale(0.781, -0.1)}
    )

    destroying_tween:Play(); destroying_tween.Completed:Wait()
    gui_util.notif_stack[Notification] = nil
    Notification:Destroy()
end

gui_util.CreateHotkeyInput = function(key, onfocuslost)
    local input = {}

    local input_holder = gui_util.AddElementFrame()
    gui_util.AddElementLabel(input_holder, "Key", 0.135)
    gui_util.AddElementKeyLabel(input_holder, key)
    local textbox, focus_lost_func = gui_util.AddElementInput(input_holder, "command", onfocuslost)

    input.Call = focus_lost_func

    input.ChangeText = function(_, text)
        textbox.Text = text
    end

    return input
end

gui_util.CreateButton = function(button_label, button_text, onclick)
    local button = {}

    local button_holder = gui_util.AddElementFrame()
    gui_util.AddElementLabel(button_holder, button_label)
    gui_util.AddElementButton(button_holder, button_text, onclick)

    button.Call = onclick

    return button
end

gui_util.CreateClickableInput = function(input_name, plc_text, onfocuslost, onclick)
    local input = {}

    local input_holder = gui_util.AddClickableElementFrame(onclick)
    gui_util.AddElementLabel(input_holder, input_name)
    local textbox, focus_lost_func = gui_util.AddElementInput(input_holder, plc_text, onfocuslost)
    textbox.Focused:Connect(function()
        onfocuslost(textbox.Text)
    end)

    input.Call = focus_lost_func

    input.holder = input_holder
    input.textbox = textbox

    input.ChangePlcText = function(_, text)
        textbox.PlaceholderText = text
    end

    input.ChangeText = function(_, text)
        textbox.Text = text
    end

    return input
end

return gui_util

