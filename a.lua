-- =========================
-- Script Loader GUI Profissional
-- =========================

-- Criar GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptLoaderMenu"
ScreenGui.Parent = game.CoreGui

-- Frame principal
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- fundo preto fosco
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Frame.Visible = false

-- Título do menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- cinza escuro
Title.BorderSizePixel = 0
Title.Text = "Script Loader"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

-- Botão de fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- vermelho discreto
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Frame

CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

-- Função para criar botões de script
local function criarBotao(texto, posicao, url)
    local Botao = Instance.new("TextButton")
    Botao.Size = UDim2.new(0, 180, 0, 40)
    Botao.Position = posicao
    Botao.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- cinza escuro
    Botao.TextColor3 = Color3.fromRGB(255, 255, 255)
    Botao.Font = Enum.Font.GothamSemibold
    Botao.TextSize = 14
    Botao.Text = texto
    Botao.BorderSizePixel = 0
    Botao.Parent = Frame

    -- Hover suave
    Botao.MouseEnter:Connect(function()
        Botao.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    end)
    Botao.MouseLeave:Connect(function()
        Botao.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)

    -- Carregar script
    Botao.MouseButton1Click:Connect(function()
        local sucesso, resultado = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if not sucesso then
            warn("Erro ao carregar script: "..resultado)
        end
    end)
end

-- Criar botões
criarBotao("Carregar Aimbot", UDim2.new(0, 10, 0, 40), "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/aimbot.lua")
criarBotao("Carregar ESP", UDim2.new(0, 10, 0, 85), "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/esp.lua")
criarBotao("Carregar Fly", UDim2.new(0, 10, 0, 130), "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/fly.lua")
criarBotao("Carregar TouchFling", UDim2.new(0, 10, 0, 130), "https://raw.githubusercontent.com/BancoCentraI/test/refs/heads/main/touchfling.lua")

-- Abrir/fechar menu com Right Shift
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    end
end)

