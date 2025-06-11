local HyperUILib = {}

local CoreGui = game:GetService("CoreGui")

local function createBaseGui(name)
	local gui = Instance.new("ScreenGui", CoreGui)
	gui.Name = name or "HyperUILib"
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	return gui
end

local function createWindow(title)
	local gui = createBaseGui()

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 350, 0, 400)
	main.Position = UDim2.new(0.3, 0, 0.3, 0)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	main.Active = true
	main.Draggable = true
	main.BorderSizePixel = 0

	local top = Instance.new("Frame", main)
	top.Size = UDim2.new(1, 0, 0, 30)
	top.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

	local titleLabel = Instance.new("TextLabel", top)
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.Text = title or "Hyper Window"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.TextSize = 16
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local close = Instance.new("TextButton", top)
	close.Size = UDim2.new(0, 30, 1, 0)
	close.Position = UDim2.new(1, -35, 0, 0)
	close.Text = "X"
	close.Font = Enum.Font.Gotham
	close.TextSize = 14
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	local container = Instance.new("Frame", main)
	container.Name = "Container"
	container.Size = UDim2.new(1, -20, 1, -40)
	container.Position = UDim2.new(0, 10, 0, 35)
	container.BackgroundTransparency = 1

	return {
		GUI = gui,
		Container = container,
		AddLabel = function(self, text)
			local label = Instance.new("TextLabel", self.Container)
			label.Size = UDim2.new(1, 0, 0, 25)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.Font = Enum.Font.Gotham
			label.TextSize = 14
		end,

		AddButton = function(self, text, callback)
			local btn = Instance.new("TextButton", self.Container)
			btn.Size = UDim2.new(1, 0, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			btn.Text = text
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.MouseButton1Click:Connect(callback)
		end,

		AddToggle = function(self, text, callback)
			local toggle = Instance.new("TextButton", self.Container)
			toggle.Size = UDim2.new(1, 0, 0, 30)
			toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			toggle.Text = "[ OFF ] " .. text
			toggle.Font = Enum.Font.Gotham
			toggle.TextSize = 14
			toggle.TextColor3 = Color3.fromRGB(255, 255, 255)

			local state = false
			toggle.MouseButton1Click:Connect(function()
				state = not state
				toggle.Text = state and ("[ ON ] " .. text) or ("[ OFF ] " .. text)
				if callback then callback(state) end
			end)
		end
	}
end

function HyperUILib:AddWindow(title)
	return createWindow(title)
end

return HyperUILib
