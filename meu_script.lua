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

-- Janela Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 220)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -110)
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
local btnNoclip = criarBotao("Noclip", 55, "Ativar Noclip: [OFF]")
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

-- Botão 2: Dash de Fuga (Teleporte rápido para frente)
local btnDash = criarBotao("Dash", 100, "Dash de Fuga [Tecla E]")
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

-- Botão 3: Fechar / Ocultar Painel
local btnFechar = criarBotao("Fechar", 145, "Fechar Painel")
btnFechar.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
btnFechar.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

print("Painel carregado com sucesso!")