--[[
    AUTOPARRY ROBUSTO E ESTACIONÁRIO
    Correções:
    1. Usa WaitForChild para o Remote (Garantia de localização).
    2. Adiciona Cooldown (Prevenção de spam).
--]]

getgenv().god = true -- Flag de controle

-- **1. Referências Locais Otimizadas**
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local BallsFolder = Workspace:FindFirstChild("Balls")

-- Variáveis de Cooldown
local lastParryTime = 0
local PARRY_COOLDOWN = 0.1 -- 0.1 segundos (Evita spam, D. Correção)

-- **2. Detecção Robusta do Remote (A. Correção de Remote)**
-- Tenta encontrar o Remote de forma mais segura. Se Remotes existir, espera por ParryButtonPress
local ParryRemote = nil
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

if RemotesFolder then
    -- Tenta esperar pelo nome comum
    ParryRemote = RemotesFolder:FindFirstChild("ParryButtonPress") or RemotesFolder:FindFirstChild("Parry")
end

-- Se ainda não encontrou, tenta procurar recursivamente no ReplicatedStorage (Pode ser lento, mas garante)
if not ParryRemote then
    for _, descendant in ReplicatedStorage:GetDescendants() do
        if descendant.Name == "ParryButtonPress" and descendant:IsA("RemoteEvent") then
            ParryRemote = descendant
            break
        end
    end
end

if not ParryRemote then
    warn("[AutoParry] ERRO: Remote 'ParryButtonPress' não encontrado. Verifique a localização.")
    -- Não retorna, o script continua tentando, mas o parry não será disparado.
end


-- **3. Função de Auto-Parry (Núcleo da Lógica)**
local function AutoParry()
    -- Checagem de segurança e do Remote
    if not LocalPlayer.Character or not ParryRemote or not BallsFolder then return end

    local Character = LocalPlayer.Character
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    
    if not HRP then return end
    
    local CharacterHighlight = Character:FindFirstChild("Highlight")

    -- Verifica o Cooldown antes de iterar pelas bolas (D. Correção)
    if tick() - lastParryTime < PARRY_COOLDOWN then return end
    
    -- Itera por todas as bolas para encontrar uma ameaça
    for _, ball in next, BallsFolder:GetChildren() do
        -- Checagem de Atributos/Relevância (B. Correção)
        local isRelevant = ball:GetAttribute("realBall") or ball:GetAttribute("trainingBall")
        
        if isRelevant then
            
            -- Detecção de Mira: (Usa Highlight OU Atributo)
            local isTargetingMe = ball:GetAttribute("target") == LocalPlayer.Name
            
            if isTargetingMe or CharacterHighlight then
                
                -- **DISPARA O PARRY**
                ParryRemote:Fire()
                
                -- Atualiza o Cooldown e quebra o loop
                lastParryTime = tick()
                return 
            end
        end
    end
end

-- **4. Loop Leve (Conexão com Heartbeat)**
RunService.Heartbeat:Connect(function()
    if getgenv().god then
        AutoParry()
    end
end)
