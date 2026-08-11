-- Garante que o jogo carregou completamente
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- Remove um painel antigo caso você execute o script duas vezes
local playerGui = localPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("MeuPainelScript") then
    playerGui.MeuPainelScript:Destroy()
end

-- 1. Criação da Interface (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MeuPainelScript"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Janela Principal (Aumentei um pouco o tamanho para caber o novo botão)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 265)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -132)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Permite arrastar o painel pela tela
mainFrame.Parent = screenGui

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 8)
cornerMain.Parent = mainFrame

-- Barra de Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.Text = " Painel de Sobrevivência"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local cornerTitle = Instance.new("UICorner")
cornerTitle.CornerRadius = UDim.new(0, 8)
cornerTitle.Parent = titleLabel

-- 2. Função de Botão Genérica
local function criarBotao(nome, posicaoY, textoInicial)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 35)
    btn.Position = UDim2.new(0.5, -110, 0, posicaoY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = textoInicial
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = mainFrame

    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 6)
    cornerBtn.Parent = btn

    return btn
end

-- Botão 1: Noclip (Atravessar Inimigos)
local btnNoclip = criarBotao("Noclip", 50, "Ativar Noclip: [OFF]")
local noclipAtivo = false
local noclipConnection

btnNoclip.MouseButton1Click:Connect(function()
    noclipAtivo = not noclipAtivo
    if noclipAtivo then
        btnNoclip.Text = "Ativar Noclip: [ON]"
        btnNoclip.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        noclipConnection = RunService.Stepped:Connect(function()
            local char = localPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        btnNoclip.Text = "Ativar Noclip: [OFF]"
        btnNoclip.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

-- Botão 2: Anti-Touch (Apaga os TouchInterests / Hitboxes de toque dos monstros)
local btnAntiTouch = criarBotao("AntiTouch", 95, "Anti-Touch: [OFF]")
local antiTouchAtivo = false
local antiTouchConnection

btnAntiTouch.MouseButton1Click:Connect(function()
    antiTouchAtivo = not antiTouchAtivo
    if antiTouchAtivo then
        btnAntiTouch.Text = "Anti-Touch: [ON]"
        btnAntiTouch.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Remove imediatamente qualquer TouchInterest existente no Workspace
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") or obj.Name:lower():find("hitbox") or obj.Name:lower():find("touch") then
                pcall(function()
                    obj:Destroy()
                end)
            end
        end
        
        -- Fica monitorando caso novos monstros apareçam
        antiTouchConnection = workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("TouchTransmitter") or obj.Name:lower():find("hitbox") then
                pcall(function()
                    obj:Destroy()
                end)
            end
        end)
    else
        btnAntiTouch.Text = "Anti-Touch: [OFF]"
        btnAntiTouch.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if antiTouchConnection then
            antiTouchConnection:Disconnect()
        end
    end
end)

-- Botão 3: Dash de Fuga (Teleporte rápido para frente)
local btnDash = criarBotao("Dash", 140, "Dash de Fuga [Tecla E]")
btnDash.MouseButton1Click:Connect(function()
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 25)
    end
end)

-- Atalho de Teclado para o Dash (Aperte E)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.E then
        local char = localPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 25)
        end
    end
end)

-- Botão 4: Fechar / Ocultar Painel
local btnFechar = criarBotao("Fechar", 185, "Fechar Painel")
btnFechar.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
btnFechar.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

print("Painel atualizado com Anti-Touch carregado com sucesso!")
