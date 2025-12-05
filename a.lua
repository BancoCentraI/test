-- MENU PREMIUM DARK CLEAN ------------------------------------------------------

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Tela
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- Janela Principal (tema preto + cinza)
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 360)
frame.Position = UDim2.new(0.5, -160, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
frame.Visible = false

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Linha cinza superior
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 40)
topbar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topbar.BorderSizePixel = 0
topbar.Parent = frame
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 12)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Script Loader"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = topbar

-- Botão fechar
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 90, 90)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = topbar

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

close.MouseEnter:Connect(function()
    TweenService:Create(close, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(65,65,65)
    }):Play()
end)

close.MouseLeave:Connect(function()
    TweenService:Create(close, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(50,50,50)
    }):Play()
end)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Área dos botões
local holder = Instance.new("Frame")
holder.Size = UDim2.new(1, -40, 1, -70)
holder.Position = UDim2.new(0, 20, 0, 55)
holder.BackgroundTransparency = 1
holder.Parent = frame

local list = Instance.new("UIListLayout")
list.Parent = holder
list.Padding = UDim.new(0, 12)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- FUNÇÃO GLOBAL DE BOTÕES (SINCRONIZADA)
local function novoBotao(texto, url)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Parent = holder

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(90, 90, 90)
    stroke.Thickness = 1
    stroke.Transparency = 0.35

    -- Hover sincronizado
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        }):Play()

        TweenService:Create(stroke, TweenInfo.new(0.15), {
            Transparency = 0
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        }):Play()

        TweenService:Create(stroke, TweenInfo.new(0.15), {
            Transparency = 0.35
        }):Play()
    end)

    -- Carregar Script
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
    end)
end

-- BOTÕES ------------------------------------------------------
novoBotao("Aimbot",       "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/aimbot.lua")
novoBotao("ESP",          "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/esp.lua")
novoBotao("Fly",          "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/fly.lua")
novoBotao("TouchFling",    "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/touchfling.lua")
novoBotao("Stalker",    "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/stalker.lua")
novoBotao("TpPlayer",    "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/tpplayer.lua")
novoBotao("NobanVoice",    "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/voiceremoveban5minutos.lua")
----------------------------------------------------------------

-- Abrir / Fechar com RightShift
UIS.InputBegan:Connect(function(key, g)
    if not g and key.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

