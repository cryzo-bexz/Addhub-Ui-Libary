-- Custom Roblox UI Library - Fixed Version
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Library
local Library = {}
Library.__index = Library

-- Default Theme
local DefaultTheme = {
    Background = Color3.fromRGB(25, 25, 30),
    Secondary = Color3.fromRGB(35, 35, 40),
    Accent = Color3.fromRGB(88, 166, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(60, 60, 65),
    Font = Enum.Font.GothamMedium
}

-- Utility Functions
local function CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function CreateStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 65)
    stroke.Thickness = thickness or 1
    return stroke
end

local function CreatePadding(all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all or 8)
    padding.PaddingBottom = UDim.new(0, all or 8)
    padding.PaddingLeft = UDim.new(0, all or 8)
    padding.PaddingRight = UDim.new(0, all or 8)
    return padding
end

local function TweenObject(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(settings)
    local self = setmetatable({}, Window)
    
    self.Title = settings.Title or "UI Library"
    self.Icon = settings.Icon or ""
    self.Size = settings.Size or UDim2.new(0, 500, 0, 400)
    self.Theme = settings.Theme or {}
    self.Draggable = settings.Draggable ~= false
    
    -- Merge theme
    for key, value in pairs(DefaultTheme) do
        if not self.Theme[key] then
            self.Theme[key] = value
        end
    end
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsMinimized = false
    
    self:CreateWindow()
    self:SetupDragging()
    
    return self
end

function Window:CreateWindow()
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "FlareUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = PlayerGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.Size
    self.MainFrame.Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2)
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    CreateCorner(12).Parent = self.MainFrame
    CreateStroke(self.Theme.Border).Parent = self.MainFrame
    
    -- Top Bar
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, 40)
    self.TopBar.BackgroundColor3 = self.Theme.Secondary
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.MainFrame
    
    local topCorner = CreateCorner(12)
    topCorner.Parent = self.TopBar
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = self.Theme.Text
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = self.Theme.Font
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TopBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.TextSize = 16
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.TopBar
    
    CreateCorner(15).Parent = self.CloseButton
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, -40)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 40)
    self.TabContainer.BackgroundColor3 = self.Theme.Secondary
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    
    CreatePadding(8).Parent = self.TabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = self.TabContainer
    
    -- Content Container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -150, 1, -40)
    self.ContentContainer.Position = UDim2.new(0, 150, 0, 40)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.Parent = self.MainFrame
    
    CreatePadding(12).Parent = self.ContentContainer
    
    -- Setup close button
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function Window:SetupDragging()
    if not self.Draggable then return end
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Window:AddTab(name)
    local tab = Tab.new(self, name)
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self.CurrentTab = tab
        tab:Show()
    end
    
    return tab
end

function Window:SwitchTab(tab)
    if self.CurrentTab then
        self.CurrentTab:Hide()
    end
    self.CurrentTab = tab
    tab:Show()
end

function Window:Destroy()
    self.ScreenGui:Destroy()
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Tab.new(window, name)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Name = name
    self.Elements = {}
    
    self:CreateTab()
    
    return self
end

function Tab:CreateTab()
    -- Tab Button
    self.TabButton = Instance.new("TextButton")
    self.TabButton.Name = self.Name
    self.TabButton.Size = UDim2.new(1, 0, 0, 35)
    self.TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    self.TabButton.BorderSizePixel = 0
    self.TabButton.Text = self.Name
    self.TabButton.TextColor3 = self.Window.Theme.SubText
    self.TabButton.TextSize = 12
    self.TabButton.Font = self.Window.Theme.Font
    self.TabButton.Parent = self.Window.TabContainer
    
    CreateCorner(6).Parent = self.TabButton
    
    -- Tab Content
    self.TabContent = Instance.new("ScrollingFrame")
    self.TabContent.Name = self.Name .. "_Content"
    self.TabContent.Size = UDim2.new(1, 0, 1, 0)
    self.TabContent.BackgroundTransparency = 1
    self.TabContent.BorderSizePixel = 0
    self.TabContent.ScrollBarThickness = 4
    self.TabContent.ScrollBarImageColor3 = self.Window.Theme.Accent
    self.TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabContent.Visible = false
    self.TabContent.Parent = self.Window.ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = self.TabContent
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- Tab Button Click
    self.TabButton.MouseButton1Click:Connect(function()
        self.Window:SwitchTab(self)
    end)
end

function Tab:Show()
    self.TabContent.Visible = true
    self.TabButton.BackgroundColor3 = self.Window.Theme.Accent
    self.TabButton.TextColor3 = self.Window.Theme.Text
end

function Tab:Hide()
    self.TabContent.Visible = false
    self.TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    self.TabButton.TextColor3 = self.Window.Theme.SubText
end

function Tab:AddLabel(text)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Window.Theme.Text
    label.TextSize = 12
    label.Font = self.Window.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.TabContent
    
    return label
end

function Tab:AddButton(name, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = self.Window.Theme.Secondary
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = self.Window.Theme.Text
    button.TextSize = 12
    button.Font = self.Window.Theme.Font
    button.Parent = self.TabContent
    
    CreateCorner(6).Parent = button
    CreateStroke(self.Window.Theme.Border).Parent = button
    
    button.MouseButton1Click:Connect(function()
        if callback then
            spawn(callback)
        end
    end)
    
    button.MouseEnter:Connect(function()
        TweenObject(button, {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        TweenObject(button, {BackgroundColor3 = self.Window.Theme.Secondary}, 0.2)
    end)
    
    return button
end

function Tab:AddToggle(name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundColor3 = self.Window.Theme.Secondary
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = self.TabContent
    
    CreateCorner(6).Parent = toggleFrame
    CreateStroke(self.Window.Theme.Border).Parent = toggleFrame
    CreatePadding(10).Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(1, -50, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = self.Window.Theme.Text
    toggleLabel.TextSize = 12
    toggleLabel.Font = self.Window.Theme.Font
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -40, 0.5, -10)
    toggleButton.BackgroundColor3 = default and self.Window.Theme.Accent or Color3.fromRGB(70, 70, 75)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    CreateCorner(10).Parent = toggleButton
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleButton
    
    CreateCorner(8).Parent = toggleCircle
    
    local isToggled = default
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        if isToggled then
            TweenObject(toggleButton, {BackgroundColor3 = self.Window.Theme.Accent}, 0.2)
            TweenObject(toggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
        else
            TweenObject(toggleButton, {BackgroundColor3 = Color3.fromRGB(70, 70, 75)}, 0.2)
            TweenObject(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
        end
        
        if callback then
            spawn(function() callback(isToggled) end)
        end
    end)
    
    return toggleFrame
end

-- Library Functions
function Library:CreateWindow(settings)
    return Window.new(settings)
end

function Library:Destroy()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name == "FlareUI" then
            gui:Destroy()
        end
    end
end

return Library
