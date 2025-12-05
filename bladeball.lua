getgenv().god = true

-- Referências locais para melhor performance e legibilidade
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParryRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress")
local LocalPlayer = Players.LocalPlayer

while getgenv().god and task.wait() do
    local BallsFolder = workspace:FindFirstChild("Balls")
    if not BallsFolder or not ParryRemote then continue end

    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    
    if not HRP then continue end

    -- Itera por todas as bolas na pasta
    for _, ball in next, BallsFolder:GetChildren() do
        if ball then
            
            -- Linha do CFrame de Rotação (REMOVIDA)
            -- if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            --     game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, ball.Position)
            -- end

            -- Início do Bloco de Parry
            if Character:FindFirstChild("Highlight") then 
                
                -- Linha do CFrame de Teleporte/Ajuste (REMOVIDA)
                -- game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = ball.CFrame * CFrame.new(0, 0, (ball.Velocity).Magnitude * -0.5)
                
                -- DISPARA O EVENTO DE PARRY
                ParryRemote:Fire()

                -- OTIMIZAÇÃO: Interrompe o loop após disparar o parry para a bola ativa.
                break 
            end
        end
    end
end
