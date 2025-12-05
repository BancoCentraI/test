-- GUI CLEAN PROFISSIONAL ----------------------------------------------------

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Tela
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- Janela Principal
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 260)
frame.Position = UDim2.new(0.5, -130, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
frame.Visible = false

-- Arredondamento
Instance.new("UICorner", frame)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.BorderSizePixel = 0
title.Text = "📜 Script Loader"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame
Instance.new("UICorner", title)

-- Fechar
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -40, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = frame
Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Layout de botões
local holder = Instance.new("Frame")
holder.Size = UDim2.new(1, -20, 1, -60)
holder.Position = UDim2.new(0, 10, 0, 50)
holder.BackgroundTransparency = 1
holder.Parent = frame

local list = Instance.new("UIListLayout")
list.Parent = holder
list.Padding = UDim.new(0, 10)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Criador de botões
local function addButton(nome, url)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.Parent = holder
    Instance.new("UICorner", btn)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
    end)
end

-- Botões reais
addButton("🎯 Aimbot",       "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/aimbot.lua")
addButton("👁 ESP",          "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/esp.lua")
addButton("🕊 Fly",          "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/fly.lua")
addButton("⚡ TouchFling",    "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/touchfling.lua")

-- Atalhos
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

-- Animação Fade-in
frame.BackgroundTransparency = 1
title.BackgroundTransparency = 1
holder.BackgroundTransparency = 1

task.wait(0.1)

for _, obj in ipairs(frame:GetDescendants()) do
    if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
        obj.BackgroundTransparency = 1
        TweenService:Create(obj, TweenInfo.new(.3), {BackgroundTransparency = 0}):Play()
    end
end

TweenService:Create(frame, TweenInfo.new(.3), {BackgroundTransparency = 0}):Play()
