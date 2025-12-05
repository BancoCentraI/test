getgenv().god = true
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParryRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress")

while getgenv().god and task.wait() do
    -- Checa se o Remote e a pasta Balls existem antes de iterar (Melhoria de estabilidade)
    local BallsFolder = workspace:FindFirstChild("Balls")
    if not BallsFolder or not ParryRemote then continue end

    local Character = Players.LocalPlayer.Character
    
    -- Checa se o personagem está carregado
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then continue end

    -- Itera por todas as bolas na pasta
    for _, ball in next, BallsFolder:GetChildren() do
        -- Verifica se o objeto é uma bola válida
        if ball then
            
            -- LÓGICA DO PARRY:
            -- Ação 1: Checa se o personagem está marcado/highlighted (indicando que a bola está vindo para ele)
            if Character:FindFirstChild("Highlight") then 
                
                -- Se o Highlight existe, a bola está vindo para o jogador.
                
                -- **LINHA REMOVIDA:** CFrame de rotação (para parar de olhar para a bola)
                -- game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(...)
                
                -- **LINHA REMOVIDA:** CFrame de ajuste de posição (para parar de correr/teleportar)
                -- game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = ball.CFrame * CFrame.new(...)
                
                -- Ação 2: Dispara o evento de Parry.
                ParryRemote:Fire()
                
                -- Quebra o loop assim que uma bola ativa for encontrada e o parry for disparado
                break 
            end
            
            -- **LINHA REMOVIDA:** CFrame de rotação (estava aqui no código original, movida para o topo)
            -- if game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            --     game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, ball.Position)
            -- end
            
        end
    end
end
