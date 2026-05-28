loadstring([[
--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

-- Конфигурация
local isFlying = false
local flySpeed = 60
local connection: RBXScriptConnection? = nil

-- Обновление ссылок при респавне
localPlayer.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart") :: BasePart
	humanoid = newCharacter:WaitForChild("Humanoid") :: Humanoid
end)

-- Создание интерфейса
local existingUI = CoreGui:FindFirstChild("FlightControlUI") or localPlayer:WaitForChild("PlayerGui"):FindFirstChild("FlightControlUI")
if existingUI then existingUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightControlUI"
screenGui.ResetOnSpawn = false

local success, targetParent = pcall(function() return CoreGui end)
if success and targetParent then
	screenGui.Parent = CoreGui
else
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Flight Control v3"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 160, 0, 35)
toggleButton.Position = UDim2.new(0.5, -80, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.Text = "Fly: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = toggleButton

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 85)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. tostring(flySpeed)
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14
speedLabel.Parent = mainFrame

local decreaseButton = Instance.new("TextButton")
decreaseButton.Size = UDim2.new(0, 40, 0, 25)
decreaseButton.Position = UDim2.new(0, 20, 0, 110)
decreaseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
decreaseButton.Text = "-"
decreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseButton.Font = Enum.Font.SourceSansBold
decreaseButton.TextSize = 16
decreaseButton.Parent = mainFrame

local decCorner = Instance.new("UICorner")
decCorner.CornerRadius = UDim.new(0, 4)
decCorner.Parent = decreaseButton

local increaseButton = Instance.new("TextButton")
increaseButton.Size = UDim2.new(0, 40, 0, 25)
increaseButton.Position = UDim2.new(1, -60, 0, 110)
increaseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
increaseButton.Text = "+"
increaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseButton.Font = Enum.Font.SourceSansBold
increaseButton.TextSize = 16
increaseButton.Parent = mainFrame

local incCorner = Instance.new("UICorner")
incCorner.CornerRadius = UDim.new(0, 4)
incCorner.Parent = increaseButton

-- Логика полета через CFrame
local function startFlight()
	if connection then connection:Disconnect() end
	
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		if not isFlying or not humanoidRootPart or not character then return end
		
		local camera = workspace.CurrentCamera
		if not camera then return end
		
		-- Убираем падение персонажа
		humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		
		local movementVector = Vector3.new(0, 0, 0)
		local cameraCFrame = camera.CFrame
		
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			movementVector += cameraCFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			movementVector -= cameraCFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			movementVector -= cameraCFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			movementVector += cameraCFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			movementVector += Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			movementVector -= Vector3.new(0, 1, 0)
		end
		
		if movementVector.Magnitude > 0 then
			humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + (movementVector.Unit * flySpeed * deltaTime)) * CFrame.Angles(cameraCFrame:ToEulerAnglesXYZ())
		else
			humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(cameraCFrame:ToEulerAnglesXYZ())
		end
	end)
end

local function setFlightState(state: boolean)
	isFlying = state
	if isFlying then
		toggleButton.Text = "Fly: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		humanoid.PlatformStand = true
		startFlight()
	else
		toggleButton.Text = "Fly: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		humanoid.PlatformStand = false
		if connection then 
			connection:Disconnect() 
			connection = nil
		end
	end
end

toggleButton.MouseButton1Click:Connect(function()
	setFlightState(not isFlying)
end)

increaseButton.MouseButton1Click:Connect(function()
	flySpeed = math.clamp(flySpeed + 10, 10, 500)
	speedLabel.Text = "Speed: " .. tostring(flySpeed)
end)

decreaseButton.MouseButton1Click:Connect(function()
	flySpeed = math.clamp(flySpeed - 10, 10, 500)
	speedLabel.Text = "Speed: " .. tostring(flySpeed)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		setFlightState(not isFlying)
	end
end)
]])()
