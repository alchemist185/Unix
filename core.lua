local Unix = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "UnixUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local dragToggle, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "Unix UI"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.TextSize = 18
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.Text = "-"
MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Font = Enum.Font.Gotham
MinimizeBtn.TextSize = 18
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, 0, 1, -30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundTransparency = 1

local Tabs = {}
function Unix:CreateWindow(config)
    Title.Text = config.Title or "Unix UI"
    MainFrame.Visible = true

    local window = {}

    function window:CreateTab(name, icon)
        local Tab = Instance.new("ScrollingFrame", TabContainer)
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 6
        Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", Tab)
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        Tabs[name] = Tab

        local methods = {}

        function methods:CreateButton(text, callback)
            local Button = Instance.new("TextButton", Tab)
            Button.Size = UDim2.new(0, 460, 0, 35)
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.Text = text
            Button.MouseButton1Click:Connect(callback)
        end

        function methods:CreateToggle(text, default, callback)
            local Toggle = Instance.new("TextButton", Tab)
            Toggle.Size = UDim2.new(0, 460, 0, 35)
            Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            Toggle.Font = Enum.Font.Gotham
            Toggle.TextSize = 14
            Toggle.Text = text .. ": " .. tostring(default)
            local state = default
            Toggle.MouseButton1Click:Connect(function()
                state = not state
                Toggle.Text = text .. ": " .. tostring(state)
                callback(state)
            end)
        end

        function methods:CreateSlider(text, options, callback)
            local value = options.Default or options.Min
            local Label = Instance.new("TextLabel", Tab)
            Label.Text = text .. ": " .. value
            Label.Size = UDim2.new(0, 460, 0, 20)
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14

            local Slider = Instance.new("TextButton", Tab)
            Slider.Size = UDim2.new(0, 460, 0, 20)
            Slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Slider.Text = ""
            Slider.AutoButtonColor = false

            Slider.MouseButton1Down:Connect(function()
                local conn
                conn = game:GetService("RunService").RenderStepped:Connect(function()
                    local x = math.clamp(Mouse.X - Slider.AbsolutePosition.X, 0, Slider.AbsoluteSize.X)
                    local percent = x / Slider.AbsoluteSize.X
                    local val = math.floor((options.Min + (options.Max - options.Min) * percent) + 0.5)
                    Label.Text = text .. ": " .. val
                    callback(val)
                end)
                game:GetService("UserInputService").InputEnded:Wait()
                conn:Disconnect()
            end)
        end

        return methods
    end

    return window
end

function Unix:Notify(title, message)
    local Notification = Instance.new("TextLabel", ScreenGui)
    Notification.Text = title .. "\n" .. message
    Notification.Size = UDim2.new(0, 300, 0, 60)
    Notification.Position = UDim2.new(0.5, -150, 0, -100)
    Notification.TextColor3 = Color3.new(1, 1, 1)
    Notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Notification.Font = Enum.Font.Gotham
    Notification.TextSize = 14
    Notification.TextWrapped = true
    Notification.ZIndex = 999
    Notification.AnchorPoint = Vector2.new(0.5, 0)
    wait(2)
    Notification:Destroy()
end

return Unix
