local HyperUILib = {}

local CoreGui = game:GetService("CoreGui")

local function create(instance, props)
	for i, v in pairs(props) do
		instance[i] = v
	end
	return instance
end

local function newFont()
	return Enum.Font.Gotham
end

function HyperUILib:CreateWindow(options)
	local title = options.Title or "Hyper UI"

	local gui = create(Instance.new("ScreenGui", CoreGui), {
		Name = "HyperUILib_" .. title,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
	})

	local main = create(Instance.new("Frame", gui), {
		Size = UDim2.new(0, 450, 0, 350),
		Position = UDim2.new(0.5, -225, 0.5, -175),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		Active = true,
		Draggable = true,
		Name = "MainFrame"
	})

	local top = create(Instance.new("Frame", main), {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
	})

	create(Instance.new("TextLabel", top), {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = newFont(),
		TextSize = 16
	})

	local minimize = create(Instance.new("TextButton", top), {
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -65, 0, 0),
		Text = "_",
		Font = newFont(),
		TextSize = 16,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})

	local close = create(Instance.new("TextButton", top), {
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -35, 0, 0),
		Text = "X",
		Font = newFont(),
		TextSize = 16,
		BackgroundColor3 = Color3.fromRGB(200, 50, 50),
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})

	local tabHolder = create(Instance.new("Frame", main), {
		Size = UDim2.new(0, 100, 1, -30),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0
	})

	local pages = create(Instance.new("Frame", main), {
		Size = UDim2.new(1, -100, 1, -30),
		Position = UDim2.new(0, 100, 0, 30),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Name = "Pages"
	})

	local currentPage = nil

	local function switchPage(page)
		for _, p in pairs(pages:GetChildren()) do
			if p:IsA("ScrollingFrame") then
				p.Visible = false
			end
		end
		page.Visible = true
	end

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	minimize.MouseButton1Click:Connect(function()
		main.Visible = not main.Visible
	end)

	local function createTab(name)
		local button = create(Instance.new("TextButton", tabHolder), {
			Size = UDim2.new(1, 0, 0, 30),
			Text = name,
			Font = newFont(),
			TextSize = 14,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
		})

		local page = create(Instance.new("ScrollingFrame", pages), {
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			Visible = false
		})

		local layout = create(Instance.new("UIListLayout", page), {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		button.MouseButton1Click:Connect(function()
			switchPage(page)
		end)

		if not currentPage then
			switchPage(page)
			currentPage = page
		end

		local tabFunctions = {}

		function tabFunctions:AddLabel(text)
			create(Instance.new("TextLabel", page), {
				Size = UDim2.new(1, -10, 0, 25),
				Text = text,
				Font = newFont(),
				TextSize = 14,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
			})
		end

		function tabFunctions:AddButton(text, callback)
			local btn = create(Instance.new("TextButton", page), {
				Size = UDim2.new(1, -10, 0, 30),
				Text = text,
				Font = newFont(),
				TextSize = 14,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			})

			btn.MouseButton1Click:Connect(callback)
		end

		function tabFunctions:AddToggle(text, callback)
			local toggle = create(Instance.new("TextButton", page), {
				Size = UDim2.new(1, -10, 0, 30),
				Text = "[ OFF ] " .. text,
				Font = newFont(),
				TextSize = 14,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			})

			local state = false

			toggle.MouseButton1Click:Connect(function()
				state = not state
				toggle.Text = (state and "[ ON ] " or "[ OFF ] ") .. text
				callback(state)
			end)
		end

		return tabFunctions
	end

	local window = {}

	function window:CreateTab(name)
		return createTab(name)
	end

	return window
end

return HyperUILib
