--[[
    SCRIPT MODULARIZADO E OTIMIZADO DE AUTO-PARRY
    Princípios:
    1. Usa RunService.Heartbeat para leveza.
    2. Filtra bolas a < 30 studs para reduzir cálculos.
    3. Usa previsão de vetor simples para mira (futurePos).
    4. Limita o movimento do jogador (MAX_MOVE_DISTANCE).
--]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Referências locais para evitar buscas repetidas (Melhoria #7)
local LocalPlayer = Players.LocalPlayer
local BallsFolder = Workspace:FindFirstChild("Balls")
local ParryRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress")

-- Variáveis de configuração
local FILTER_DISTANCE = 30     -- Distância máxima para considerar uma bola (Melhoria #2)
local PARRY_DISTANCE = 7       -- Distância para acionar o parry.
local MAX_MOVE_DISTANCE = 5    -- Movimento máximo por frame (Raio de Segurança - Melhoria #5)
local PREDICT_TIME = 0.05      -- Delta time para previsão de vetor (Melhoria #3)

getgenv().god = true -- Flag de controle global

---
### 🔍 Funções de Detecção e Previsão (Modularização - Melhoria #10)

-- Função para encontrar a bola mais relevante
local function DetectRelevantBall(hrpPosition)
    if not BallsFolder then return nil end

    local closestBall = nil
    local closestDistance = FILTER_DISTANCE + 1

    -- Melhores práticas: Usar ipairs para arrays, next para dicionários
    for _, ball in next, BallsFolder:GetChildren() do
        -- Verifica se é uma bola válida e se está mirando no player (Melhoria #4)
        local highlight = ball:FindFirstChild("Highlight")
        
        -- Otimização: Se a bola tiver atributo "target" e ele for o nome do player, use.
        -- Caso contrário, confie no highlight (que geralmente indica uma bola ativa).
        local isTargeting = ball:GetAttribute("target") == LocalPlayer.Name
        
        if ball and highlight and (isTargeting or ball.Velocity.Magnitude > 0) then
            local distance = (ball.Position - hrpPosition).Magnitude

            -- Filtra a bola por proximidade (Melhoria #2)
            if distance < FILTER_DISTANCE and distance < closestDistance then
                closestDistance = distance
                closestBall = ball
            end
        end
    end
    return closestBall
end

-- Função para prever a posição futura da bola (Melhoria #3)
local function PredictPosition(ball, predictTime)
    local predictedPos = ball.Position + ball.Velocity * predictTime
    return predictedPos
end

---
### 🏃 Funções de Movimento e Ação (Modularização - Melhoria #10)

local function MovePlayer(hrp, currentPos, targetPos, distance)
    
    -- 1. Olhar para a bola (Apenas Rotação)
    local lookCFrame = CFrame.new(currentPos, targetPos)
    -- Mantém a posição atual, aplica apenas a rotação para olhar para o alvo
    hrp.CFrame = CFrame.new(currentPos) * (lookCFrame - lookCFrame.Position)
    
    -- 2. Movimento dentro do raio seguro (Melhoria #5)
    if distance > PARRY_DISTANCE then
        local direction = (targetPos - currentPos).Unit
        
        -- Calcula o passo necessário para atingir o raio de parry
        local stepRequired = distance - PARRY_DISTANCE
        
        -- Limita o passo para o MAX_MOVE_DISTANCE por frame (evita teleporte)
        local moveStep = direction * math.min(stepRequired, MAX_MOVE_DISTANCE)
        
        -- Aplica o movimento
        hrp.CFrame = hrp.CFrame + moveStep
    end
end

local function PerformParry(distance)
    -- Aciona o parry apenas quando dentro do raio seguro (Melhoria #8)
    if distance <= PARRY_DISTANCE and ParryRemote then
        ParryRemote:Fire()
    end
end

---
### ⚙️ Loop Principal (RunService - Melhoria #1, #8)

local connection
connection = RunService.Heartbeat:Connect(function(deltaTime)
    -- Checagem de segurança (Melhoria #1)
    if not getgenv().god or not ParryRemote then
        if connection then connection:Disconnect() end
        return
    end

    -- Obter referências atuais (Melhoria #7 - mas ainda precisa checar se existe)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

    if not HRP then return end 

    local hrpPosition = HRP.Position

    -- 1. Detecção e Filtro (Melhoria #2)
    local targetBall = DetectRelevantBall(hrpPosition)

    if targetBall then
        -- 2. Previsão de Posição (Melhoria #3)
        local predictedPos = PredictPosition(targetBall, PREDICT_TIME)
        
        local distanceToPredicted = (predictedPos - hrpPosition).Magnitude

        -- 3. Movimentação e Parry (Melhoria #5)
        MovePlayer(HRP, hrpPosition, predictedPos, distanceToPredicted)
        PerformParry(distanceToPredicted)
    end
end)