-- Auto-Parry Otimizado
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Variável global para ligar/desligar
getgenv().god = true

-- Função de auto-parry
local function AutoParry()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    for _, ball in ipairs(workspace.Balls:GetChildren()) do
        -- Checa se a bola está mirando no player (Highlight ou Target)
        if (ball:GetAttribute("target") == player.Name) or (player.Character:FindFirstChild("Highlight")) then
            -- Dispara o parry sem mover ou girar o personagem
            if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress") then
                ReplicatedStorage.Remotes.ParryButtonPress:Fire()
            end
        end
    end
end

-- Loop leve usando Heartbeat
RunService.Heartbeat:Connect(function()
    if getgenv().god then
        AutoParry()
    end
end)
