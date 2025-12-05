--[[
    AUTOPARRY ESTACIONÁRIO E LEVE
    - Usa RunService.Heartbeat (Loop mais eficiente).
    - Detecta bolas de jogo real e treino usando Attributes.
    - Dispara o parry sem mover ou girar o personagem.
--]]

getgenv().god = true -- Variável global para ligar/desligar

-- **1. Referências Locais Otimizadas**
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local BallsFolder = Workspace:FindFirstChild("Balls")

-- Tenta obter a referência do Remote com segurança apenas uma vez
local ParryRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress")

-- **2. Função de Auto-Parry (Núcleo da Lógica)**
local function AutoParry()
    -- Checagem de segurança inicial
    if not LocalPlayer.Character or not ParryRemote or not BallsFolder then return end

    local Character = LocalPlayer.Character
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    
    if not HRP then return end
    
    local CharacterHighlight = Character:FindFirstChild("Highlight")

    -- Itera por todas as bolas para encontrar uma ameaça
    for _, ball in next, BallsFolder:GetChildren() do
        -- Otimização: next em vez de ipairs é tipicamente mais rápido para dicionários/listas mistas.
        
        -- Checa se a bola é de jogo ou treino (Baseado nos seus atributos)
        local isRelevant = ball:GetAttribute("realBall") or ball:GetAttribute("trainingBall")
        
        if isRelevant then
            -- Detecção de Mira:
            local isTargetingMe = ball:GetAttribute("target") == LocalPlayer.Name
            
            if isTargetingMe or CharacterHighlight then
                
                -- **DISPARA O PARRY (Ação Sem Movimento)**
                ParryRemote:Fire()
                
                -- Otimização: Para o loop imediatamente após disparar
                return 
            end
        end
    end
end

-- **3. Loop Leve (Conexão com Heartbeat)**
RunService.Heartbeat:Connect(function()
    if getgenv().god then
        AutoParry()
    end
end)
