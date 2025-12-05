--[[
    SCRIPT OTIMIZADO - MANTENDO O PADRÃO while/task.wait()
    Utiliza:
    1. Referências locais para eficiência.
    2. Previsão de vetor simples para mira.
    3. Movimento limitado (raio de segurança) para evitar teleporte/anti-cheat.
--]]

getgenv().god = true -- Flag de controle global

-- Referências Locais (Melhoria de Performance)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local BallsFolder = Workspace:FindFirstChild("Balls")
local ParryRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress")

-- Variáveis de Configuração
local FILTER_DISTANCE = 30     -- Distância máxima para considerar uma bola
local PARRY_DISTANCE = 7       -- Distância para acionar o parry.
local MAX_MOVE_DISTANCE = 5    -- Movimento máximo por iteração (Raio de Segurança)
local PREDICT_TIME = 0.05      -- Delta time para previsão de vetor

-- **LOOP PRINCIPAL** (Mantendo o Padrão Solicitado)
while getgenv().god and task.wait() do
    
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

    if not HRP or not BallsFolder or not ParryRemote then 
        -- Continua no loop, mas espera até que os componentes estejam prontos
        continue 
    end

    local hrpPosition = HRP.Position
    local targetBall = nil
    local closestDistance = FILTER_DISTANCE + 1

    -- 1. Detecção e Filtro (Filtra apenas bolas próximas < 30 studs)
    for _, ball in next, BallsFolder:GetChildren() do
        -- Apenas processa se for um objeto válido e se for relevante (ex: com Highlight)
        if ball and ball:FindFirstChild("Highlight") then 
            local distance = (ball.Position - hrpPosition).Magnitude

            if distance < FILTER_DISTANCE and distance < closestDistance then
                closestDistance = distance
                targetBall = ball
            end
        end
    end

    -- 2. Lógica de Movimento e Ação
    if targetBall then
        -- Previsão da Posição Futura (Evita a necessidade de teleportar)
        local predictedPos = targetBall.Position + targetBall.Velocity * PREDICT_TIME
        local distanceToPredicted = (predictedPos - hrpPosition).Magnitude
        
        -- Ação 1: Olhar para o Alvo (Substitui a primeira linha do seu original)
        local lookCFrame = CFrame.new(hrpPosition, predictedPos)
        -- Aplica apenas a rotação para olhar para a bola, sem mover a posição.
        HRP.CFrame = CFrame.new(hrpPosition) * (lookCFrame - lookCFrame.Position)

        -- Ação 2: Movimentar dentro do Raio de Segurança (Melhoria de Anti-Cheat)
        if distanceToPredicted > PARRY_DISTANCE then
            local direction = (predictedPos - hrpPosition).Unit
            local stepRequired = distanceToPredicted - PARRY_DISTANCE
            
            -- Limita o passo para o MAX_MOVE_DISTANCE por iteração (Evita o teleporte brusco)
            local moveStep = direction * math.min(stepRequired, MAX_MOVE_DISTANCE)
            
            -- Aplica o movimento gradual
            HRP.CFrame = HRP.CFrame + moveStep
        end
        
        -- Ação 3: Parry (Substitui as linhas if/CFrame/Fire do seu original)
        if distanceToPredicted <= PARRY_DISTANCE then
            -- Note: A lógica CFrame de ajuste de distância `ball.CFrame * CFrame.new(0, 0, (ball.Velocity).Magnitude * -0.5)`
            -- é substituída aqui pelo sistema de Movimento Gradual e Predição de Posição,
            -- que é muito mais seguro e preciso.
            ParryRemote:Fire()
        end
    end
end
