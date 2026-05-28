--!strict
local Players: Players = game:GetService("Players")
local UserInputService: UserInputService = game:GetService("UserInputService")
local RunService: RunService = game:GetService("RunService")
local TweenService: TweenService = game:GetService("TweenService")

local localPlayer: Player = Players.LocalPlayer
local character: Model = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart: BasePart = character:WaitForChild("HumanoidRootPart") :: BasePart

-- State variables
local isFlying: boolean = false
local flySpeed: number = 60

-- Physics setup
local bodyVelocity: BodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.Parent = humanoidRootPart

local bodyGyro: BodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(0, 0, 0)
bodyGyro.CFrame = humanoidRootPart.CFrame
bodyGyro.Parent = humanoidRootPart

localPlayer.CharacterAdded:Connect(function(newCharacter: Model)
	character = newCharacter
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart") :: BasePart
	bodyVelocity.Parent = humanoidRootPart
	bodyGyro.Parent = humanoidRootPart
end)

-- Screen UI creation
local screenGui: ScreenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightControlUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame: Frame = Instance.new("Frame")
mainFrame.Size = UUDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner: UICorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel: TextLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Flight Control"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local toggleButton: TextButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 160, 0, 35)
toggleButton.Position = UDim2.new(0.5, -80, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.Text = "Fly: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Parent = mainFrame

local buttonCorner: UICorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = toggleButton

local speedLabel: TextLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 85)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. tostring(flySpeed)
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14
speedLabel.Parent = mainFrame

local decreaseButton: TextButton = Instance.new("TextButton")
decreaseButton.Size = UDim2.new(0, 40, 0, 25)
decreaseButton.Position = UDim2.new(0, 20, 0, 110)
decreaseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
decreaseButton.Text = "-"
decreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseButton.Font = Enum.Font.SourceSansBold
decreaseButton.TextSize = 16
decreaseButton.Parent = mainFrame

local decCorner: UICorner = Instance.new("UICorner")
decCorner.CornerRadius = UDim.new(0, 4)
decCorner.Parent = decreaseButton

local increaseButton: TextButton = Instance.new("TextButton")
increaseButton.Size = UDim2.new(0, 40, 0, 25)
increaseButton.Position = UDim2.new(1, -60, 0, 110)
increaseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
increaseButton.Text = "+"
increaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseButton.Font = Enum.Font.SourceSansBold
increaseButton.TextSize = 16
increaseButton.Parent = mainFrame

local incCorner: UICorner = Instance.new("UICorner")
incCorner.CornerRadius = UDim.new(0, 4)
incCorner.Parent = increaseButton

-- Toggle mechanic logic
local function setFlightState(state: boolean): ()
	isFlying = state
	if isFlying then
		bodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
		bodyGyro.MaxTorque = Vector3.new(4e4, 4e4, 4e4)
		toggleButton.Text = "Fly: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	else
		bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyGyro.MaxTorque = Vector3.new(0, 0, 0)
		toggleButton.Text = "Fly: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
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

-- Handling hotkey (E) alignment with UI state
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean): ()
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		setFlightState(not isFlying)
	end
end)

-- Physics looping
RunService.RenderStepped:Connect(function(): ()
	if not isFlying or not character or not humanoidRootPart then return end

	local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = true
	end

	local camera: Camera? = workspace.CurrentCamera
	if not camera then return end

	local movementVector: Vector3 = Vector3.new(0, 0, 0)
	local cameraCFrame: CFrame = camera.CFrame

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
		bodyVelocity.Velocity = movementVector.Unit * flySpeed
	else
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	end

	bodyGyro.CFrame = cameraCFrame
end)
