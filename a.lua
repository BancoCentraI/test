-- MENU PREMIUM GLASS UI ------------------------------------------------------

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Tela
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- Efeito Blur no fundo
local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 0

-- Janela Principal (Glass Style)
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 360)
frame.Position = UDim2.new(0.5, -160, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true
frame.Visible = false

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

-- Borda neon
local glow = Instance.new("UIStroke", frame)
glow.Thickness = 2
glow.Color = Color3.fromRGB(0, 140, 255)
glow.Transparency = 0.15

-- Título superior
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "⭐ Premium Script Loader"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

-- Botão fechar
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -40, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
    TweenService:Create(blur, TweenInfo.new(0.4), {Size = 0}):Play()
end)

-- Área para botões
local holder = Instance.new("Frame")
holder.Size = UDim2.new(1, -40, 1, -90)
holder.Position = UDim2.new(0, 20, 0, 70)
holder.BackgroundTransparency = 1
holder.Parent = frame

local list = Instance.new("UIListLayout")
list.Parent = holder
list.Padding = UDim.new(0, 12)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Criador de botões bonitos
local function novoBotao(texto, url)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(180, 200, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 17
    btn.Parent = holder
    btn.BorderSizePixel = 0

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local neon = Instance.new("UIStroke", btn)
    neon.Thickness = 1.8
    neon.Color = Color3.fromRGB(0, 120, 255)
    neon.Transparency = 0.4

    -- Hover bonito
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()

        TweenService:Create(neon, TweenInfo.new(0.15), {
            Transparency = 0
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        }):Play()

        TweenService:Create(neon, TweenInfo.new(0.15), {
            Transparency = 0.4
        }):Play()
    end)

    -- Ao clicar, carregar script
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
    end)
end

-- BOTÕES -------------------------------
novoBotao("🎯 Aimbot",       "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/aimbot.lua")
novoBotao("👁 ESP",          "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/esp.lua")
novoBotao("🕊 Fly",          "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/fly.lua")
novoBotao("⚡ TouchFling",    "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/touchfling.lua")
-----------------------------------------

-- Abrir / Fechar com RightShift + Animação
UIS.InputBegan:Connect(function(key, g)
    if not g and key.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible

        if frame.Visible then
            TweenService:Create(blur, TweenInfo.new(0.4), {Size = 15}):Play()
        else
            TweenService:Create(blur, TweenInfo.new(0.4), {Size = 0}):Play()
        end
    end
end)

-- Fade-in inicial
for _, obj in ipairs(frame:GetDescendants()) do
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("Frame") then
        obj.TextTransparency = 1
        obj.BackgroundTransparency = obj.BackgroundTransparency + 0.3

        TweenService:Create(obj, TweenInfo.new(0.4), {
            TextTransparency = 0,
            BackgroundTransparency = obj.BackgroundTransparency - 0.3
        }):Play()
    end
end
