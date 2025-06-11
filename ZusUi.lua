--[[

Orion-Like UI Library (Custom)
Created for exploit usage in Roblox (Krnl, Fluxus, Synapse X, etc.)
Supports: Window, Tab, Section, Button, Toggle, Dropdown, Slider

--]]

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

-- Create the main UI window
function Library:CreateWindow(config)
    local Title = config.Name or "Orion Custom UI"
    local Window = {}

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "OrionCustomUI_" .. tostring(math.random(1000, 9999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 500, 0, 400)
    Main.Position = UDim2.new(0.5, -250, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Name = "Main"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

    local Header = Instance.new("TextLabel", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Text = Title
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 18
    Header.TextXAlignment = Enum.TextXAlignment.Center

    local TabContainer = Instance.new("Frame", Main)
    TabContainer.Position = UDim2.new(0, 10, 0, 50)
    TabContainer.Size = UDim2.new(0, 140, 1, -60)
    TabContainer.BackgroundTransparency = 1

    local TabButtonsLayout = Instance.new("UIListLayout", TabContainer)
    TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabButtonsLayout.Padding = UDim.new(0, 4)

    local ContentContainer = Instance.new("Frame", Main)
    ContentContainer.Position = UDim2.new(0, 160, 0, 50)
    ContentContainer.Size = UDim2.new(1, -170, 1, -60)
    ContentContainer.BackgroundTransparency = 1

    local Tabs = {}

    function Window:CreateTab(tabName)
        local Tab = {}
        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.Text = tabName
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14

        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        local TabFrame = Instance.new("ScrollingFrame", ContentContainer)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabFrame.ScrollBarThickness = 6
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Name = tabName:gsub("%s+", "_")

        local SectionLayout = Instance.new("UIListLayout", TabFrame)
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SectionLayout.Padding = UDim.new(0, 8)

        Button.MouseButton1Click:Connect(function()
            for _, tab in pairs(ContentContainer:GetChildren()) do
                if tab:IsA("ScrollingFrame") then
                    tab.Visible = false
                end
            end
            TabFrame.Visible = true
        end)

        function Tab:CreateSection(sectionName)
            local Section = {}
            local Frame = Instance.new("Frame", TabFrame)
            Frame.Size = UDim2.new(1, 0, 0, 30)
            Frame.BackgroundTransparency = 1

            local Title = Instance.new("TextLabel", Frame)
            Title.Size = UDim2.new(1, 0, 0, 30)
            Title.BackgroundTransparency = 1
            Title.Text = "  " .. sectionName
            Title.TextColor3 = Color3.fromRGB(200, 200, 200)
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 14
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local SectionFrame = Instance.new("Frame", TabFrame)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Size = UDim2.new(1, 0, 0, 1)

            local SectionLayout = Instance.new("UIListLayout", SectionFrame)
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 4)

            function Section:CreateButton(text, callback)
                local Btn = Instance.new("TextButton", SectionFrame)
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Btn.Text = text
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 14
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

                Btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
            end

            function Section:CreateToggle(text, default, callback)
                local Toggle = Instance.new("TextButton", SectionFrame)
                Toggle.Size = UDim2.new(1, 0, 0, 30)
                Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Toggle.Text = ""
                Toggle.AutoButtonColor = false

                local State = Instance.new("Frame", Toggle)
                State.Size = UDim2.new(0, 30, 0, 30)
                State.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(70, 70, 70)
                Instance.new("UICorner", State).CornerRadius = UDim.new(1, 0)

                local Label = Instance.new("TextLabel", Toggle)
                Label.Position = UDim2.new(0, 40, 0, 0)
                Label.Size = UDim2.new(1, -40, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.Font = Enum.Font.Gotham
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local toggled = default
                Toggle.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    State.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(70, 70, 70)
                    pcall(callback, toggled)
                end)
            end

            function Section:CreateDropdown(text, options, callback)
                local Dropdown = Instance.new("TextButton", SectionFrame)
                Dropdown.Size = UDim2.new(1, 0, 0, 30)
                Dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Dropdown.Text = text .. " ▼"
                Dropdown.Font = Enum.Font.Gotham
                Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
                Dropdown.TextSize = 14

                Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 6)

                local List = Instance.new("Frame", SectionFrame)
                List.Size = UDim2.new(1, 0, 0, #options * 30)
                List.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                List.Visible = false

                local Layout = Instance.new("UIListLayout", List)
                Layout.SortOrder = Enum.SortOrder.LayoutOrder

                for _, opt in pairs(options) do
                    local OptBtn = Instance.new("TextButton", List)
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.Text = opt
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

                    OptBtn.MouseButton1Click:Connect(function()
                        Dropdown.Text = text .. ": " .. opt
                        List.Visible = false
                        pcall(callback, opt)
                    end)
                end

                Dropdown.MouseButton1Click:Connect(function()
                    List.Visible = not List.Visible
                end)
            end

            function Section:CreateSlider(text, min, max, default, callback)
                local Frame = Instance.new("Frame", SectionFrame)
                Frame.Size = UDim2.new(1, 0, 0, 30)
                Frame.BackgroundTransparency = 1

                local Label = Instance.new("TextLabel", Frame)
                Label.Size = UDim2.new(1, 0, 0.5, 0)
                Label.Text = text .. ": " .. tostring(default)
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 14
                Label.BackgroundTransparency = 1

                local Slider = Instance.new("Frame", Frame)
                Slider.Position = UDim2.new(0, 0, 0.5, 0)
                Slider.Size = UDim2.new(1, 0, 0.5, 0)
                Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

                local Fill = Instance.new("Frame", Slider)
                Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                Fill.Name = "Fill"

                local dragging = false
                Slider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                Slider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                        Fill.Size = UDim2.new(pos, 0, 1, 0)
                        local value = math.floor((min + (max - min) * pos) + 0.5)
                        Label.Text = text .. ": " .. tostring(value)
                        pcall(callback, value)
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Library
