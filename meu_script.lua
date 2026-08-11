-- Garante que o jogo carregou completamente
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

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
mainFrame.Size = UDim2.new(0, 260, 0, 310)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 8)
cornerMain.Parent = mainFrame

-- Barra de Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.Text = " Painel Global + ESP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local cornerTitle = Instance.new("UICorner")
cornerTitle.CornerRadius = UDim.new(0, 8)
cornerTitle.Parent = titleLabel

-- Ícone Flutuante para reabrir quando minimizado
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 45, 0, 45)
openButton.Position = UDim2.new(0, 20, 0.5, -22)
openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
openButton.TextColor3 = Color3.fromRGB(0, 255, 128)
openButton.Text = "👁️"
openButton.TextSize = 20
openButton.Visible = false
openButton.Active = true
openButton.Draggable = true
openButton.Parent = screenGui

local cornerOpen = Instance.new("UICorner")
cornerOpen.CornerRadius = UDim.new(1, 0)
cornerOpen.Parent = openButton

-- Botão Minimizar (-)
local btnMinimize = Instance.new("TextButton")
btnMinimize.Size = UDim2.new(0, 30, 0, 30)
btnMinimize.Position = UDim2.new(1, -35, 0, 5)
btnMinimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnMinimize.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinimize.Text = "-"
btnMinimize.TextSize = 16
btnMinimize.Font = Enum.Font.GothamBold
btnMinimize.Parent = titleLabel

local cornerMin = Instance.new("UICorner")
cornerMin.CornerRadius = UDim.new(0, 6)
cornerMin.Parent = btnMinimize

btnMinimize.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openButton.Visible = false
end)

-- Função de Botão Padrão
local function criarBotao(posicaoY, textoInicial)
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

-- Botão 1: Noclip Global
local btnNoclip = criarBotao(50, "Noclip Global: [OFF]")
local noclipAtivo = false
local noclipConnection

btnNoclip.MouseButton1Click:Connect(function()
    noclipAtivo = not noclipAtivo
    if noclipAtivo then
        btnNoclip.Text = "Noclip Global: [ON]"
        btnNoclip.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        noclipConnection = RunService.Stepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        btnNoclip.Text = "Noclip Global: [OFF]"
        btnNoclip.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if noclipConnection then noclipConnection:Disconnect() end
    end
end)

-- Botão 2: Anti-Touch Global
local btnAntiTouch = criarBotao(95, "Anti-Touch Global: [OFF]")
local antiTouchAtivo = false
local antiTouchConnection

btnAntiTouch.MouseButton1Click:Connect(function()
    antiTouchAtivo = not antiTouchAtivo
    if antiTouchAtivo then
        btnAntiTouch.Text = "Anti-Touch Global: [ON]"
        btnAntiTouch.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") or obj.Name:lower():find("hitbox") or obj.Name:lower():find("touch") then
                pcall(function() obj:Destroy() end)
            end
        end
        antiTouchConnection = workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("TouchTransmitter") or obj.Name:lower():find("hitbox") then
                pcall(function() obj:Destroy() end)
            end
        end)
    else
        btnAntiTouch.Text = "Anti-Touch Global: [OFF]"
        btnAntiTouch.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if antiTouchConnection then antiTouchConnection:Disconnect() end
    end
end)

-- Botão 3: Ver Inimigos Perto (ESP / Distância)
local btnEsp = criarBotao(140, "Ver Inimigos Perto: [OFF]")
local espAtivo = false
local espDrawings = {}

local function limparEsp()
    for _, drawing in pairs(espDrawings) do
        if drawing then drawing:Remove() end
    end
    espDrawings = {}
end

btnEsp.MouseButton1Click:Connect(function()
    espAtivo = not espAtivo
    if espAtivo then
        btnEsp.Text = "Ver Inimigos Perto: [ON]"
        btnEsp.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        btnEsp.Text = "Ver Inimigos Perto: [OFF]"
        btnEsp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        limparEsp()
    end
end)

RunService.RenderStepped:Connect(function()
    limparEsp()
    if not espAtivo then return end

    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Varre o Workspace procurando por monstros (humanoides ou modelos com Humanoid que não sejam jogadores)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= myChar then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            
            -- Confere se é um NPC/Monstro (tem Humanoid e não está na pasta de Players)
            if humanoid and rootPart and not Players:GetPlayerFromCharacter(obj) then
                local vector, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local distancia = math.floor((myRoot.Position - rootPart.Position).Magnitude)
                    
                    -- Cria um texto flutuante na tela indicando o nome e a distância do monstro
                    local textoEsp = Drawing.new("Text")
                    textoEsp.Visible = true
                    textoEsp.Center = true
                    textoEsp.Outline = true
                    textoEsp.Font = 2
                    textoEsp.Size = 15
                    textoEsp.Color = Color3.fromRGB(255, 50, 50)
                    textoEsp.Text = "⚠️ " .. obj.Name .. " [" .. distancia .. "m]"
                    textoEsp.Position = Vector2.new(vector.X, vector.Y - 20)
                    
                    table.insert(espDrawings, textoEsp)
                end
            end
        end
    end
end)

-- Botão 4: Dash em Grupo
local btnDash = criarBotao(185, "Dash em Grupo [Tecla E]")
local function executarDash()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 25)
        end
    end
end

btnDash.MouseButton1Click:Connect(executarDash)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.E then
        executarDash()
    end
end)

-- Botão 5: Fechar Painel
local btnFechar = criarBotao(230, "Fechar Painel")
btnFechar.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
btnFechar.MouseButton1Click:Connect(function()
    limparEsp()
    screenGui:Destroy()
end)

print("Painel com ESP e Minimizar carregado com sucesso!")
