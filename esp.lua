-- ESP sem GUI
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Array de cores possíveis
local colors = {
    Color3.fromRGB(255, 0, 0),    -- Vermelho
    Color3.fromRGB(0, 255, 0),    -- Verde
    Color3.fromRGB(0, 0, 255),    -- Azul
    Color3.fromRGB(255, 255, 0),  -- Amarelo
    Color3.fromRGB(255, 0, 255),  -- Magenta
    Color3.fromRGB(0, 255, 255)   -- Ciano
}

-- Cor atual do ESP
local espColor = colors[math.random(1, #colors)]

-- Estado do ESP
local espEnabled = false

-- Função para aplicar/remover highlight
local function highlightCharacter(character, enable)
    local highlight = character:FindFirstChildOfClass("Highlight")
    if enable then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Parent = character
        end
        highlight.FillColor = espColor
        highlight.OutlineColor = espColor
    else
        if highlight then
            highlight:Destroy()
        end
    end
end

-- Função para ativar/desativar ESP
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        espColor = colors[math.random(1, #colors)]
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            highlightCharacter(player.Character, espEnabled)
        end
    end
end

-- Atualiza ESP para novos jogadores
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if espEnabled then
            highlightCharacter(character, true)
        end
    end)
end)

-- Detecta tecla L para alternar ESP
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.L then
        toggleESP()
    end
end)
