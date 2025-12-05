--// SERVICES

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

--// PLAYER VARIABLES

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

--// CONFIG & STATE

local Speeds = 1
local IsFlying = false
local tpwalking = false -- Usado para o loop de teleport (Heartbeat)
local MaxSpeed = 50 -- Velocidade máxima para BodyVelocity Fly

--// FLY GUI V4 - DARK THEME

local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speedText = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closeButton = Instance.new("TextButton")
local miniButton = Instance.new("TextButton")
local maxiButton = Instance.new("TextButton") -- Renomeado mini2 para maxiButton

--// GUI SETUP

main.Name = "FlyGUI"
main.Parent = PlayerGui
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- FRAME (Container)
Frame.Parent = main
Frame.Name = "Frame"
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark Background
Frame.BorderColor3 = Color3.fromRGB(0, 200, 255) -- Cyan/Blue Border
Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
Frame.Size = UDim2.new(0, 190, 0, 80) -- Aumentei um pouco a altura
Frame.Active = true
Frame.Draggable = true

-- TITLE LABEL
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Blue Header
TextLabel.Position = UDim2.new(0, 0, 0, 0)
TextLabel.Size = UDim2.new(1, 0, 0, 28)
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.Text = "FLY GUI V4 - DARK"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 18
TextLabel.TextWrapped = true

-- UP BUTTON
up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark Gray
up.BorderColor3 = Color3.fromRGB(0, 0, 0)
up.Position = UDim2.new(0, 0, 0.35, 0)
up.Size = UDim2.new(0, 44, 0, 26)
up.Font = Enum.Font.SourceSans
up.Text = "UP"
up.TextColor3 = Color3.fromRGB(200, 200, 200)
up.TextSize = 14

-- DOWN BUTTON
down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark Gray
down.BorderColor3 = Color3.fromRGB(0, 0, 0)
down.Position = UDim2.new(0, 0, 0.675, 0)
down.Size = UDim2.new(0, 44, 0, 26)
down.Font = Enum.Font.SourceSans
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(200, 200, 200)
down.TextSize = 14

-- PLUS BUTTON
plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Lighter Gray
plus.BorderColor3 = Color3.fromRGB(0, 0, 0)
plus.Position = UDim2.new(0.24, 0, 0.35, 0)
plus.Size = UDim2.new(0, 45, 0, 26)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green for Plus
plus.TextScaled = true
plus.TextSize = 20

-- MINUS BUTTON
mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Lighter Gray
mine.BorderColor3 = Color3.fromRGB(0, 0, 0)
mine.Position = UDim2.new(0.24, 0, 0.675, 0)
mine.Size = UDim2.new(0, 45, 0, 26)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red for Minus
mine.TextScaled = true
mine.TextSize = 20

-- SPEED DISPLAY
speedText.Name = "speed"
speedText.Parent = Frame
speedText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedText.BorderColor3 = Color3.fromRGB(0, 0, 0)
speedText.Position = UDim2.new(0.49, 0, 0.35, 0)
speedText.Size = UDim2.new(0, 44, 0, 26)
speedText.Font = Enum.Font.SourceSans
speedText.Text = Speeds
speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
speedText.TextScaled = true
speedText.TextSize = 14

-- ON/OFF TOGGLE
onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 150, 0) -- Orange/Yellow Off Color
onof.BorderColor3 = Color3.fromRGB(0, 0, 0)
onof.Position = UDim2.new(0.74, 0, 0.35, 0)
onof.Size = UDim2.new(0, 47, 0, 58)
onof.Font = Enum.Font.SourceSansBold
onof.Text = "FLY\nOFF"
onof.TextColor3 = Color3.fromRGB(255, 255, 255)
onof.TextSize = 18

-- CLOSE BUTTON (Top Right)
closeButton.Name = "Close"
closeButton.Parent = Frame
closeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Dark Red
closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Text = "X"
closeButton.TextSize = 20
closeButton.Position = UDim2.new(1, -28, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- MINIMIZE BUTTON (Top Middle-Right)
miniButton.Name = "minimize"
miniButton.Parent = Frame
miniButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
miniButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
miniButton.Font = Enum.Font.SourceSansBold
miniButton.Size = UDim2.new(0, 28, 0, 28)
miniButton.Text = "—"
miniButton.TextSize = 20
miniButton.Position = UDim2.new(1, -56, 0, 0)
miniButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- MAXIMIZE BUTTON (Hidden)
maxiButton.Name = "maximize"
maxiButton.Parent = Frame
maxiButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
maxiButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
maxiButton.Font = Enum.Font.SourceSansBold
maxiButton.Size = UDim2.new(0, 28, 0, 28)
maxiButton.Text = "☐" -- Quadrado para representar maximizar
maxiButton.TextSize = 20
maxiButton.Position = UDim2.new(1, -56, 0, 0)
maxiButton.Visible = false
maxiButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Speed Label for Minimized State (Moved speed display logic)
local minimizedSpeedLabel = Instance.new("TextLabel")
minimizedSpeedLabel.Parent = Frame
minimizedSpeedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minimizedSpeedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
minimizedSpeedLabel.Position = UDim2.new(0, 0, 0, 28)
minimizedSpeedLabel.Size = UDim2.new(1, -56, 0, 52) -- Ocupa o espaço onde os botões estariam
minimizedSpeedLabel.Font = Enum.Font.SourceSansBold
minimizedSpeedLabel.Text = ""
minimizedSpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
minimizedSpeedLabel.TextScaled = true
minimizedSpeedLabel.TextSize = 18
minimizedSpeedLabel.Visible = false


--// INITIAL NOTIFICATION

StarterGui:SetCore("SendNotification", { 
	Title = "FLY GUI V4 - DARK";
	Text = "BY XNEO (IMPROVED)";
	Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
})

--// CORE FLY LOGIC (BodyVelocity/BodyGyro)

local function flyLoop(torsoPart)
    local Camera = workspace.CurrentCamera
    local bg = Instance.new("BodyGyro", torsoPart)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = torsoPart.CFrame
    
    local bv = Instance.new("BodyVelocity", torsoPart)
    bv.Velocity = Vector3.new(0, 0.1, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    Humanoid.PlatformStand = true
    
    local ctrl = {f = 0, b = 0, l = 0, r = 0}
    local lastctrl = {f = 0, b = 0, l = 0, r = 0}
    local currentSpeed = 0
    
    -- Function to handle player input for movement while flying
    local function onMove(inputObject, gameProcessed)
        if gameProcessed then return end
        
        local key = inputObject.KeyCode
        local isDown = inputObject.UserInputState == Enum.UserInputState.Begin
        
        if key == Enum.KeyCode.W then ctrl.f = isDown and MaxSpeed or 0 end
        if key == Enum.KeyCode.S then ctrl.b = isDown and -MaxSpeed or 0 end
        if key == Enum.KeyCode.A then ctrl.l = isDown and -MaxSpeed or 0 end
        if key == Enum.KeyCode.D then ctrl.r = isDown and MaxSpeed or 0 end
    end
    
    local inputConnection = RunService.RenderStepped:Connect(function()
        if not IsFlying or Humanoid.Health <= 0 then 
            bg:Destroy()
            bv:Destroy()
            Humanoid.PlatformStand = false
            return 
        end

        local isMoving = ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0

        -- Acceleration/Deceleration
        if isMoving then
            currentSpeed = currentSpeed + 0.5 + (currentSpeed / MaxSpeed)
            if currentSpeed > MaxSpeed then currentSpeed = MaxSpeed end
        elseif currentSpeed ~= 0 then
            currentSpeed = currentSpeed - 1
            if currentSpeed < 0 then currentSpeed = 0 end
        end

        -- Velocity Calculation
        if isMoving then
            local moveVector = (Camera.CFrame.lookVector * (ctrl.f + ctrl.b)) + ((Camera.CFrame * CFrame.new(ctrl.l + ctrl.r, 0, 0)).p - Camera.CFrame.p)
            bv.Velocity = moveVector.unit * currentSpeed
            lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
        elseif currentSpeed ~= 0 then
            local moveVector = (Camera.CFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((Camera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, 0, 0)).p - Camera.CFrame.p)
            bv.Velocity = moveVector.unit * currentSpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end

        -- Gyro (Keeps player facing camera direction)
        bg.CFrame = Camera.CFrame
    end)
    
    -- Wait until flying stops
    while IsFlying and Humanoid.Health > 0 do
        RunService.RenderStepped:Wait() 
    end
    
    inputConnection:Disconnect()
    bg:Destroy()
    bv:Destroy()
    Humanoid.PlatformStand = false
end

--// MOVEMENT LOGIC (Teleport on MoveDirection)
local function teleportWalkLoop()
    tpwalking = true
    
    -- Cria um loop de Heartbeat separado para o Teleport Walk
    local hbConnection = RunService.Heartbeat:Connect(function()
        if tpwalking and IsFlying and Humanoid.MoveDirection.Magnitude > 0 then
            -- Multiplica a translação pela velocidade atual para torná-lo útil
            Character:TranslateBy(Humanoid.MoveDirection * Speeds)
        end
    end)
    
    -- Espera que o IsFlying/tpwalking seja desativado
    while IsFlying and tpwalking do
        RunService.Heartbeat:Wait()
    end
    
    hbConnection:Disconnect()
    tpwalking = false
end

--// MAIN TOGGLE FUNCTION

local function toggleFly()
    IsFlying = not IsFlying
    
    if IsFlying then
        onof.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Green On Color
        onof.Text = "FLY\nON"
        
        -- Disable Humanoid States (Prevent movement/falling interference)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        Humanoid:ChangeState(Enum.HumanoidStateType.Swimming) -- Change state to something stable
        
        -- Start the Teleport Walk logic
        spawn(teleportWalkLoop)
        
        -- Start the Physics Fly logic (R6/R15 check)
        local torsoPart = Humanoid.RigType == Enum.HumanoidRigType.R6 and Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
        if torsoPart then
            spawn(function() flyLoop(torsoPart) end)
        end

    else
        onof.BackgroundColor3 = Color3.fromRGB(255, 150, 0) -- Orange/Yellow Off Color
        onof.Text = "FLY\nOFF"
        
        -- Re-enable Humanoid States
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        
        -- Stop Teleport Walk loop
        tpwalking = false
    end
end

--// BUTTON CONNECTIONS

-- Fly Toggle
onof.MouseButton1Down:Connect(toggleFly)

-- Variable for continuous Up/Down movement
local continuousMoveConnection = nil

-- Up Button (Continuous vertical movement)
up.MouseButton1Down:Connect(function()
    if continuousMoveConnection then return end
    
    continuousMoveConnection = RunService.RenderStepped:Connect(function()
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, 0) -- Increased speed slightly
        end
    end)
end)

up.MouseButton1Up:Connect(function()
    if continuousMoveConnection then
        continuousMoveConnection:Disconnect()
        continuousMoveConnection = nil
    end
end)

-- Down Button (Continuous vertical movement)
down.MouseButton1Down:Connect(function()
    if continuousMoveConnection then return end

    continuousMoveConnection = RunService.RenderStepped:Connect(function()
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1.5, 0) -- Increased speed slightly
        end
    end)
end)

down.MouseButton1Up:Connect(function()
    if continuousMoveConnection then
        continuousMoveConnection:Disconnect()
        continuousMoveConnection = nil
    end
end)

-- Plus Button (Increase speed)
plus.MouseButton1Down:Connect(function()
    Speeds = Speeds + 1
    speedText.Text = Speeds
end)

-- Minus Button (Decrease speed)
mine.MouseButton1Down:Connect(function()
    if Speeds > 1 then
        Speeds = Speeds - 1
        speedText.Text = Speeds
    else
        speedText.Text = 'MIN SPEED'
        wait(0.5)
        speedText.Text = Speeds
    end
end)

-- Close Button
closeButton.MouseButton1Click:Connect(function()
    if IsFlying then toggleFly() end
    main:Destroy()
end)

-- Minimize Button
miniButton.MouseButton1Click:Connect(function()
    up.Visible = false
    down.Visible = false
    onof.Visible = false
    plus.Visible = false
    speedText.Visible = false
    mine.Visible = false
    miniButton.Visible = false
    maxiButton.Visible = true
    
    -- Adjust Frame size to minimized state
    Frame.Size = UDim2.new(0, 190, 0, 28) 
    
    -- Show Speed label in minimized state
    minimizedSpeedLabel.Text = "FLY SPEED: " .. Speeds
    minimizedSpeedLabel.Visible = true
end)

-- Maximize Button
maxiButton.MouseButton1Click:Connect(function()
    up.Visible = true
    down.Visible = true
    onof.Visible = true
    plus.Visible = true
    speedText.Visible = true
    mine.Visible = true
    miniButton.Visible = true
    maxiButton.Visible = false
    
    -- Adjust Frame size back to normal
    Frame.Size = UDim2.new(0, 190, 0, 80)
    
    -- Hide minimized speed label
    minimizedSpeedLabel.Visible = false
end)

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    
    -- Reseta o estado do Fly ao spawnar
    if IsFlying then
        IsFlying = false
        toggleFly() 
    end
end)