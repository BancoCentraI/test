--// SERVICES

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService") -- Adicionado

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

--// FLY GUI V6 - DARK ENHANCED

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
local maxiButton = Instance.new("TextButton")

--// GUI SETUP

main.Name = "FlyGUI"
main.Parent = PlayerGui
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

--// --- CONFIGURAÇÃO VISUAL ENHANCED (SEU CÓDIGO) ---

-- Aplicar cantos arredondados
local function addCorners(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

-- Aplicar hover suave
local function addHoverEffect(button, defaultColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor}):Play()
    end)
end

-- FRAME (Container)
Frame.Parent = main
Frame.Name = "Frame"
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Fundo Ultra Escuro
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
Frame.Size = UDim2.new(0, 190, 0, 80)
Frame.Active = true
Frame.Draggable = true
addCorners(Frame, 8) -- Cantos Arredondados

-- TITLE LABEL
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Header Cinza Escuro
TextLabel.Position = UDim2.new(0, 0, 0, 0)
TextLabel.Size = UDim2.new(1, 0, 0, 28)
TextLabel.Font = Enum.Font.GothamBold -- Fonte alterada
TextLabel.Text = "FLY GUI V6 - DARK"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 18
TextLabel.TextWrapped = true
addCorners(TextLabel, 6)

-- UP BUTTON
up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
up.BorderColor3 = Color3.fromRGB(0, 0, 0)
up.Position = UDim2.new(0, 0, 0.35, 0)
up.Size = UDim2.new(0, 44, 0, 26)
up.Font = Enum.Font.SourceSans
up.Text = "UP"
up.TextColor3 = Color3.fromRGB(255, 255, 255)
up.TextSize = 14

-- DOWN BUTTON
down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
down.BorderColor3 = Color3.fromRGB(0, 0, 0)
down.Position = UDim2.new(0, 0, 0.675, 0)
down.Size = UDim2.new(0, 44, 0, 26)
down.Font = Enum.Font.SourceSans
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(255, 255, 255)
down.TextSize = 14

-- PLUS BUTTON
plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
plus.BorderColor3 = Color3.fromRGB(0, 0, 0)
plus.Position = UDim2.new(0.24, 0, 0.35, 0)
plus.Size = UDim2.new(0, 45, 0, 26)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(255, 255, 255)
plus.TextScaled = true
plus.TextSize = 20

-- MINUS BUTTON
mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mine.BorderColor3 = Color3.fromRGB(0, 0, 0)
mine.Position = UDim2.new(0.24, 0, 0.675, 0)
mine.Size = UDim2.new(0, 45, 0, 26)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(255, 255, 255)
mine.TextScaled = true
mine.TextSize = 20

-- SPEED DISPLAY
speedText.Name = "speed"
speedText.Parent = Frame
speedText.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedText.BorderColor3 = Color3.fromRGB(0, 0, 0)
speedText.Position = UDim2.new(0.49, 0, 0.35, 0)
speedText.Size = UDim2.new(0, 44, 0, 26)
speedText.Font = Enum.Font.SourceSans
speedText.Text = Speeds
speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
speedText.TextScaled = true
speedText.TextSize = 14
addCorners(speedText, 5)

-- ON/OFF TOGGLE
onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 120, 0) -- Laranja (Para o estado OFF inicial)
onof.BorderColor3 = Color3.fromRGB(0, 0, 0)
onof.Position = UDim2.new(0.74, 0, 0.35, 0)
onof.Size = UDim2.new(0, 47, 0, 58)
onof.Font = Enum.Font.SourceSansBold
onof.Text = "FLY\nOFF"
onof.TextColor3 = Color3.fromRGB(255, 255, 255)
onof.TextSize = 18
addCorners(onof, 6)

-- CLOSE BUTTON (Top Right)
closeButton.Name = "Close"
closeButton.Parent = Frame
closeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Text = "X"
closeButton.TextSize = 20
closeButton.Position = UDim2.new(1, -28, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addCorners(closeButton, 6)

-- MINIMIZE BUTTON (Top Middle-Right)
miniButton.Name = "minimize"
miniButton.Parent = Frame
miniButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
miniButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
miniButton.Font = Enum.Font.SourceSansBold
miniButton.Size = UDim2.new(0, 28, 0, 28)
miniButton.Text = "—"
miniButton.TextSize = 20
miniButton.Position = UDim2.new(1, -56, 0, 0)
miniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addCorners(miniButton, 6)

-- MAXIMIZE BUTTON (Hidden)
maxiButton.Name = "maximize"
maxiButton.Parent = Frame
maxiButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
maxiButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
maxiButton.Font = Enum.Font.SourceSansBold
maxiButton.Size = UDim2.new(0, 28, 0, 28)
maxiButton.Text = "☐"
maxiButton.TextSize = 20
maxiButton.Position = UDim2.new(1, -56, 0, 0)
maxiButton.Visible = false
maxiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addCorners(maxiButton, 6)

-- Speed Label for Minimized State
local minimizedSpeedLabel = Instance.new("TextLabel")
minimizedSpeedLabel.Parent = Frame
minimizedSpeedLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
minimizedSpeedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
minimizedSpeedLabel.Position = UDim2.new(0, 0, 0, 28)
minimizedSpeedLabel.Size = UDim2.new(1, -56, 0, 52)
minimizedSpeedLabel.Font = Enum.Font.SourceSansBold
minimizedSpeedLabel.Text = ""
minimizedSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedSpeedLabel.TextScaled = true
minimizedSpeedLabel.TextSize = 18
minimizedSpeedLabel.Visible = false
addCorners(minimizedSpeedLabel, 8) -- Arredondar também o label minimizado


--// --- HOVER EFFECTS (SEU CÓDIGO APLICADO) ---

-- Botões UP/DOWN/PLUS/MINUS
local defaultUpColor = up.BackgroundColor3
local defaultDownColor = down.BackgroundColor3
local defaultPlusColor = plus.BackgroundColor3
local defaultMineColor = mine.BackgroundColor3
local hoverGray = Color3.fromRGB(50,50,50)

addHoverEffect(up, defaultUpColor, hoverGray)
addHoverEffect(down, defaultDownColor, hoverGray)
addHoverEffect(plus, defaultPlusColor, hoverGray)
addHoverEffect(mine, defaultMineColor, hoverGray)

-- ON/OFF
local defaultOnOfColor = onof.BackgroundColor3 -- Laranja
local hoverOnOfColor = Color3.fromRGB(255,150,0)
addHoverEffect(onof, defaultOnOfColor, hoverOnOfColor)

-- Close Button
local defaultCloseColor = closeButton.BackgroundColor3 -- Vermelho escuro
local hoverCloseColor = Color3.fromRGB(200,0,0)
addHoverEffect(closeButton, defaultCloseColor, hoverCloseColor)

-- Mini Button
local defaultMiniColor = miniButton.BackgroundColor3 -- Cinza escuro
local hoverMiniColor = Color3.fromRGB(40,40,40)
addHoverEffect(miniButton, defaultMiniColor, hoverMiniColor)

--// INITIAL NOTIFICATION

StarterGui:SetCore("SendNotification", { 
	Title = "FLY GUI";
	Text = "DESIGN BY USER HAX";
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
    
    local inputConnection = RunService.RenderStepped:Connect(function()
        if not IsFlying or Humanoid.Health <= 0 then 
            bg:Destroy()
            bv:Destroy()
            Humanoid.PlatformStand = false
            return 
        end

        -- Coletar Inputs (A, W, S, D) em tempo real
        local input = game:GetService("UserInputService")
        ctrl.f = input:IsKeyDown(Enum.KeyCode.W) and MaxSpeed or 0
        ctrl.b = input:IsKeyDown(Enum.KeyCode.S) and -MaxSpeed or 0
        ctrl.l = input:IsKeyDown(Enum.KeyCode.A) and -MaxSpeed or 0
        ctrl.r = input:IsKeyDown(Enum.KeyCode.D) and MaxSpeed or 0

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

