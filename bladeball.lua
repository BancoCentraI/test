getgenv().god = true

-- Referências Locais Otimizadas
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParryRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress")
local LocalPlayer = Players.LocalPlayer

-- Configuração de Distância
local MAX_CHECK_DISTANCE = 30 -- Distância máxima para considerar uma bola
local PARRY_DISTANCE = 15     -- Distância para tentar o parry (ajuste este valor)
local MIN_VELOCITY = 5        -- Velocidade mínima para considerar a bola uma ameaça

while getgenv().god and task.wait() do
    local BallsFolder = Workspace:FindFirstChild("Balls")
    
    if not BallsFolder or not ParryRemote then continue end

    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    
    if not HRP then continue end

    local hrpPosition = HRP.Position
    local isTargeted = Character:FindFirstChild("Highlight")

    local activeBall = nil
    local closestDistance = MAX_CHECK_DISTANCE + 1

    -- ETAPA 1: DETECÇÃO DA BOLA MAIS ATIVA E PRÓXIMA
    for _, ball in next, BallsFolder:GetChildren() do
        if ball and ball:IsA("BasePart") then
            local distance = (ball.Position - hrpPosition).Magnitude
            local velocity = ball.Velocity.Magnitude
            
            -- Filtra: Se a bola estiver perto E for rápida o suficiente
            if distance < MAX_CHECK_DISTANCE and distance < closestDistance and velocity > MIN_VELOCITY then
                closestDistance = distance
                activeBall = ball
            end
        end
    end

    -- ETAPA 2: LÓGICA DO PARRY (SEM MOVIMENTO)
    if activeBall then
        
        -- Checa a condição de parry:
        -- 1. O jogador está marcado (Highlight)
        -- OU
        -- 2. A bola está muito próxima e vindo na direção do jogador (simulação de alinhamento)
        local directionToBall = (activeBall.Position - hrpPosition).Unit
        local dotProduct = directionToBall:Dot(activeBall.Velocity.Unit)
        
        -- Condição de Disparo:
        -- - Deve estar perto do raio de parry E (
        --   - O jogador deve ser o alvo (Highlight) 
        --   OU
        --   - A bola está vindo diretamente para o jogador (DotProduct ~ -1)
        -- )
        if closestDistance <= PARRY_DISTANCE and (isTargeted or dotProduct < -0.9) then
            
            -- **Apenas Disparo do Evento**
            ParryRemote:Fire()
            
            -- Quebra o loop para evitar disparar o parry várias vezes no mesmo frame
            break 
        end
    end
end
