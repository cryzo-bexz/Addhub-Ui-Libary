-- Custom Roblox UI Library
-- Professional-grade UI system with modern design and animations

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Library Configuration
local Library = {
    Theme = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(100, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Border = Color3.fromRGB(60, 60, 70),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Font = Enum.Font.SourceSans,
    AnimationSpeed = 0.3,
    Windows = {}
}

-- Utility Functions
local Utils = {}

function Utils:Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property == "Parent" then
            continue
        end
        instance[property] = value
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utils:Tween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or Library.AnimationSpeed,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils:CreateCorner(parent, radius)
    return Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

function Utils:CreateStroke(parent, color, thickness)
    return Utils:Create("UIStroke", {
        Color = color or Library.Theme.Border,
        Thickness = thickness or 1,
        Parent = parent
    })
end

function Utils:CreateGradient(parent, colors, rotation)
    return Utils:Create("UIGradient", {
        Color = ColorSequence.new(colors or {
            ColorSequenceKeypoint.new(0, Library.Theme.Background),
            ColorSequenceKeypoint.new(1, Library.Theme.Secondary)
        }),
        Rotation = rotation or 0,
        Parent = parent
    })
end

function Utils:MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                update(input)
            end
        end
    end)
end

function Utils:CreateIcon(parent, imageId, size)
    return Utils:Create("ImageLabel", {
        Size = UDim2.new(0, size or 16, 0, size or 16),
        BackgroundTransparency = 1,
        Image = imageId,
        ImageColor3 = Library.Theme.Text,
        Parent = parent
    })
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)
    
    self.Title = title or "UI Library"
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsMinimized = false
    self.IsDestroyed = false
    
    self:CreateUI()
    self:SetupAnimations()
    
    table.insert(Library.Windows, self)
    return self
end

function Window:CreateUI()
    -- Main ScreenGui
    self.ScreenGui = Utils:Create("ScreenGui", {
        Name = "CustomUILibrary_" .. self.Title,
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Frame
    self.MainFrame = Utils:Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    
    Utils:CreateCorner(self.MainFrame, 12)
    Utils:CreateStroke(self.MainFrame, Library.Theme.Border, 1)
    
    -- Drop Shadow Effect
    local shadow = Utils:Create("Frame", {
        Name = "Shadow",
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = -1,
        Parent = self.MainFrame
    })
    Utils:CreateCorner(shadow, 12)
    
    -- Title Bar
    self.TitleBar = Utils:Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    Utils:CreateCorner(self.TitleBar, 12)
    Utils:CreateGradient(self.TitleBar, {
        ColorSequenceKeypoint.new(0, Library.Theme.Secondary),
        ColorSequenceKeypoint.new(1, Library.Theme.Accent)
    }, 45)
    
    -- Fix corner clipping
    local titleBarFix = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.TitleBar
    })
    
    -- Title Text
    self.TitleLabel = Utils:Create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = Library.Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Library.Font,
        FontWeight = Enum.FontWeight.SemiBold,
        Parent = self.TitleBar
    })
    
    -- Control Buttons Container
    local controlsContainer = Utils:Create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 80, 0, 30),
        Position = UDim2.new(1, -90, 0, 10),
        BackgroundTransparency = 1,
        Parent = self.TitleBar
    })
    
    -- Minimize Button
    self.MinimizeButton = Utils:Create("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = Library.Theme.Text,
        TextSize = 18,
        Font = Library.Font,
        FontWeight = Enum.FontWeight.Bold,
        Parent = controlsContainer
    })
    Utils:CreateCorner(self.MinimizeButton, 6)
    
    -- Close Button
    self.CloseButton = Utils:Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundColor3 = Library.Theme.Error,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Library.Theme.Text,
        TextSize = 20,
        Font = Library.Font,
        FontWeight = Enum.FontWeight.Bold,
        Parent = controlsContainer
    })
    Utils:CreateCorner(self.CloseButton, 6)
    
    -- Content Area
    self.ContentFrame = Utils:Create("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })
    
    -- Tab Container
    self.TabContainer = Utils:Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.ContentFrame
    })
    
    Utils:CreateStroke(self.TabContainer, Library.Theme.Border, 1)
    
    -- Tab List
    self.TabList = Utils:Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.TabContainer
    })
    
    local tabListLayout = Utils:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = self.TabList
    })
    
    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content Panel
    self.ContentPanel = Utils:Create("Frame", {
        Name = "ContentPanel",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = self.ContentFrame
    })
    
    -- Make draggable
    Utils:MakeDraggable(self.MainFrame, self.TitleBar)
    
    -- Setup button events
    self:SetupEvents()
end

function Window:SetupEvents()
    -- Minimize Button
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Close Button
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Button hover effects
    local function setupButtonHover(button, hoverColor)
        button.MouseEnter:Connect(function()
            Utils:Tween(button, {BackgroundTransparency = 0}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            Utils:Tween(button, {BackgroundTransparency = 0.3}, 0.2)
        end)
    end
    
    setupButtonHover(self.MinimizeButton)
    setupButtonHover(self.CloseButton)
end

function Window:SetupAnimations()
    -- Initial entrance animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.BackgroundTransparency = 1
    
    Utils:Tween(self.MainFrame, {
        Size = UDim2.new(0, 600, 0, 400),
        BackgroundTransparency = 0
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Window:ToggleMinimize()
    if self.IsMinimized then
        -- Restore
        self.IsMinimized = false
        self.MinimizeButton.Text = "−"
        
        Utils:Tween(self.MainFrame, {
            Size = UDim2.new(0, 600, 0, 400)
        }, Library.AnimationSpeed)
        
        Utils:Tween(self.ContentFrame, {
            Size = UDim2.new(1, 0, 1, -50)
        }, Library.AnimationSpeed)
    else
        -- Minimize
        self.IsMinimized = true
        self.MinimizeButton.Text = "□"
        
        Utils:Tween(self.MainFrame, {
            Size = UDim2.new(0, 600, 0, 50)
        }, Library.AnimationSpeed)
        
        Utils:Tween(self.ContentFrame, {
            Size = UDim2.new(1, 0, 0, 0)
        }, Library.AnimationSpeed)
    end
end

function Window:AddTab(tabName)
    local tab = Tab.new(self, tabName)
    self.Tabs[tabName] = tab
    
    if not self.CurrentTab then
        self:SwitchToTab(tabName)
    end
    
    return tab
end

function Window:SwitchToTab(tabName)
    if self.CurrentTab then
        self.CurrentTab:Hide()
    end
    
    self.CurrentTab = self.Tabs[tabName]
    if self.CurrentTab then
        self.CurrentTab:Show()
    end
end

function Window:Destroy()
    if self.IsDestroyed then return end
    
    self.IsDestroyed = true
    
    -- Animate out
    Utils:Tween(self.MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }, Library.AnimationSpeed)
    
    wait(Library.AnimationSpeed)
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    -- Remove from library windows
    for i, window in ipairs(Library.Windows) do
        if window == self then
            table.remove(Library.Windows, i)
            break
        end
    end
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Tab.new(window, name)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Name = name
    self.Elements = {}
    self.IsVisible = false
    
    self:CreateUI()
    return self
end

function Tab:CreateUI()
    -- Tab Button
    self.TabButton = Utils:Create("TextButton", {
        Name = self.Name .. "Tab",
        Size = UDim2.new(1, -10, 0, 35),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Text = self.Name,
        TextColor3 = Library.Theme.TextSecondary,
        TextSize = 14,
        Font = Library.Font,
        FontWeight = Enum.FontWeight.Medium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Window.TabList
    })
    
    Utils:CreateCorner(self.TabButton, 6)
    
    -- Tab button padding
    local tabPadding = Utils:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = self.TabButton
    })
    
    -- Tab Content
    self.Content = Utils:Create("ScrollingFrame", {
        Name = self.Name .. "Content",
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = self.Window.ContentPanel
    })
    
    local contentLayout = Utils:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = self.Content
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab button events
    self.TabButton.MouseButton1Click:Connect(function()
        self.Window:SwitchToTab(self.Name)
    end)
    
    self.TabButton.MouseEnter:Connect(function()
        if not self.IsVisible then
            Utils:Tween(self.TabButton, {BackgroundColor3 = Library.Theme.Secondary}, 0.2)
        end
    end)
    
    self.TabButton.MouseLeave:Connect(function()
        if not self.IsVisible then
            Utils:Tween(self.TabButton, {BackgroundColor3 = Library.Theme.Background}, 0.2)
        end
    end)
end

function Tab:Show()
    self.IsVisible = true
    self.Content.Visible = true
    
    -- Update tab button appearance
    Utils:Tween(self.TabButton, {
        BackgroundColor3 = Library.Theme.Accent,
        TextColor3 = Library.Theme.Text
    }, 0.2)
end

function Tab:Hide()
    self.IsVisible = false
    self.Content.Visible = false
    
    -- Update tab button appearance
    Utils:Tween(self.TabButton, {
        BackgroundColor3 = Library.Theme.Background,
        TextColor3 = Library.Theme.TextSecondary
    }, 0.2)
end

function Tab:AddButton(name, callback)
    local button = Utils:Create("TextButton", {
        Name = name .. "Button",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        Font = Library.Font,
        FontWeight = Enum.FontWeight.Medium,
        Parent = self.Content
    })
    
    Utils:CreateCorner(button, 8)
    Utils:CreateStroke(button, Library.Theme.Border, 1)
    
    -- Button hover effect
    button.MouseEnter:Connect(function()
        Utils:Tween(button, {BackgroundColor3 = Library.Theme.Accent}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Utils:Tween(button, {BackgroundColor3 = Library.Theme.Secondary}, 0.2)
    end)
    
    -- Button click
    button.MouseButton1Click:Connect(function()
        -- Click animation
        button.BackgroundColor3 = Library.Theme.Text
        wait(0.1)
        Utils:Tween(button, {BackgroundColor3 = Library.Theme.Accent}, 0.2)
        
        if callback then
            callback()
        end
    end)
    
    table.insert(self.Elements, button)
    return button
end

function Tab:AddToggle(name, default, callback)
    local toggleFrame = Utils:Create("Frame", {
        Name = name .. "Toggle",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.Content
    })
    
    Utils:CreateCorner(toggleFrame, 8)
    Utils:CreateStroke(toggleFrame, Library.Theme.Border, 1)
    
    local toggleLabel = Utils:Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Library.Font,
        FontWeight = Enum.FontWeight.Medium,
        Parent = toggleFrame
    })
    
    local toggleButton = Utils:Create("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = default and Library.Theme.Success or Library.Theme.Border,
        BorderSizePixel = 0,
        Text = "",
        Parent = toggleFrame
    })
    
    Utils:CreateCorner(toggleButton, 10)
    
    local toggleIndicator = Utils:Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Library.Theme.Text,
        BorderSizePixel = 0,
        Parent = toggleButton
    })
    
    Utils:CreateCorner(toggleIndicator, 8)
    
    local isToggled = default
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        Utils:Tween(toggleButton, {
            BackgroundColor3 = isToggled and Library.Theme.Success or Library.Theme.Border
        }, 0.2)
        
        Utils:Tween(toggleIndicator, {
            Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }, 0.2)
        
        if callback then
            callback(isToggled)
        end
    end)
    
    table.insert(self.Elements, toggleFrame)
    return toggleFrame
end

function Tab:AddLabel(text)
    local label = Utils:Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Library.Theme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Library.Font,
        FontWeight = Enum.FontWeight.Regular,
        TextWrapped = true,
        Parent = self.Content
    })
    
    local labelPadding = Utils:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = label
    })
    
    table.insert(self.Elements, label)
    return label
end

-- Library Main Functions
function Library:CreateWindow(title)
    return Window.new(title)
end

function Library:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        if self.Theme[key] then
            self.Theme[key] = value
        end
    end
end

function Library:DestroyAll()
    for _, window in ipairs(self.Windows) do
        window:Destroy()
    end
    self.Windows = {}
end

-- Return the library
return Library
