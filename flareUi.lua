-- Full UI Library local HyperUI = {} local CoreGui = game:GetService("CoreGui") local TweenService = game:GetService("TweenService") local UIS = game:GetService("UserInputService")

local function CreateInstance(class, props) local obj = Instance.new(class) for k, v in pairs(props) do obj[k] = v end return obj end

function HyperUI:CreateWindow(options) options = options or {} local title = options.Title or "HyperUI"

local ScreenGui = CreateInstance("ScreenGui", {
    Name = "HyperUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui
})

local MainFrame = CreateInstance("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    Size = UDim2.new(0, 500, 0, 350),
    Position = UDim2.new(0.5, -250, 0.5, -175),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true
})

local TopBar = CreateInstance("Frame", {
    Name = "TopBar",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Size = UDim2.new(1, 0, 0, 30)
})

local TitleLabel = CreateInstance("TextLabel", {
    Name = "TitleLabel",
    Parent = TopBar,
    Text = title,
    Font = Enum.Font.Gotham,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left
})

local CloseButton = CreateInstance("TextButton", {
    Parent = TopBar,
    Text = "X",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    Size = UDim2.new(0, 30, 1, 0),
    Position = UDim2.new(1, -35, 0, 0)
})

local MinimizeButton = CreateInstance("TextButton", {
    Parent = TopBar,
    Text = "_",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundColor3 = Color3.fromRGB(100, 100, 100),
    Size = UDim2.new(0, 30, 1, 0),
    Position = UDim2.new(1, -70, 0, 0)
})

local ContentFrame = CreateInstance("Frame", {
    Name = "ContentFrame",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, -30),
    Position = UDim2.new(0, 0, 0, 30)
})

local TabsHolder = CreateInstance("Frame", {
    Name = "TabsHolder",
    Parent = ContentFrame,
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    Size = UDim2.new(0, 100, 1, 0),
    BorderSizePixel = 0
})

local PagesHolder = CreateInstance("Frame", {
    Name = "PagesHolder",
    Parent = ContentFrame,
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 100, 0, 0),
    BorderSizePixel = 0
})

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    PagesHolder.Visible = not PagesHolder.Visible
end)

local function CreateTab(tabName)
    local TabButton = CreateInstance("TextButton", {
        Parent = TabsHolder,
        Text = tabName,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Size = UDim2.new(1, 0, 0, 30)
    })

    local TabPage = CreateInstance("ScrollingFrame", {
        Parent = PagesHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 1, 0),
        Visible = false
    })

    local Layout = CreateInstance("UIListLayout", {
        Parent = TabPage,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in ipairs(PagesHolder:GetChildren()) do
            if tab:IsA("ScrollingFrame") then
                tab.Visible = false
            end
        end
        TabPage.Visible = true
    end)

    local tabFuncs = {}

    function tabFuncs:AddLabel(text)
        CreateInstance("TextLabel", {
            Parent = TabPage,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 20)
        })
    end

    function tabFuncs:AddButton(text, callback)
        local btn = CreateInstance("TextButton", {
            Parent = TabPage,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Size = UDim2.new(1, -10, 0, 30)
        })
        btn.MouseButton1Click:Connect(callback)
    end

    function tabFuncs:AddToggle(text, callback)
        local toggled = false
        local toggleBtn = CreateInstance("TextButton", {
            Parent = TabPage,
            Text = "[ OFF ] " .. text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Size = UDim2.new(1, -10, 0, 30)
        })
        toggleBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            toggleBtn.Text = toggled and "[ ON ] " .. text or "[ OFF ] " .. text
            callback(toggled)
        end)
    end

    return tabFuncs
end

return {
    CreateTab = CreateTab
}

end

return HyperUI

