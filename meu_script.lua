-- Garante que o jogo carregou completamente
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Remove um painel antigo caso você execute o script duas vezes
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("MimicPainelScript") then
    playerGui.MimicPainelScript:Destroy()
end

-- 1. Criação da Interface (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MimicPainelScript"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Janela Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 410)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -205)
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
titleLabel.Text = " Painel The Mimic"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
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
    btn.Size = UDim2.new(0, 220, 0, 32)
    btn.Position = UDim2.new(0.5, -110, 0, posicaoY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = textoInicial
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = mainFrame

    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 6)
    cornerBtn.Parent = btn

    return btn
end

-- Configurações e Estados
local Settings = {
    AutoWin = false,
    AutoKill = false,
    AutoTP = false,
    AutoEscape = false,
    FullBright = false,
    AutoClicks = false,
    ESP = false,
    DeleteMonsters = false,
    NoKeys = false,
}

local FlyEnabled = false
local FlySpeed = 50
local FlyBodyVelocity = nil
local FlyBodyGyro = nil

-- Funções Utilitárias do Código Original
local function getRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function tpTo(partOrCFrame)
    local rootPart = getRootPart()
    if not rootPart then return end
    if typeof(partOrCFrame) == "Instance" and partOrCFrame:IsA("BasePart") then
        rootPart.CFrame = partOrCFrame.CFrame + Vector3.new(0, 5, 0)
    elseif typeof(partOrCFrame) == "CFrame" then
        rootPart.CFrame = partOrCFrame + Vector3.new(0, 5, 0)
    end
end

-- Botão 1: FullBright
local btnFullBright = criarBotao(50, "FullBright: [OFF]")
btnFullBright.MouseButton1Click:Connect(function()
    Settings.FullBright = not Settings.FullBright
    if Settings.FullBright then
        btnFullBright.Text = "FullBright: [ON]"
        btnFullBright.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    else
        btnFullBright.Text = "FullBright: [OFF]"
        btnFullBright.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 10000
    end
end)

-- Botão 2: ESP (Monstros e Jogadores)[cite: 1]
local btnEsp = criarBotao(87, "ESP Monstros/Players: [OFF]")
local ESPMonsters = {}
local ESPPlayers = {}

local function createESP(target)
    if target:FindFirstChild("HumanoidRootPart") and not target.HumanoidRootPart:FindFirstChild("BoxHandleAdornment") then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = target.HumanoidRootPart
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = Vector3.new(4, 6, 4)
        box.Transparency = 0.5
        box.Color3 = Color3.new(1, 0, 0)
        box.Parent = target.HumanoidRootPart
        return box
    end
    return nil
end

local function limparEsp()
    for _, box in pairs(ESPMonsters) do if box then box:Destroy() end end
    for _, box in pairs(ESPPlayers) do if box then box:Destroy() end end
    ESPMonsters = {}
    ESPPlayers = {}
end

btnEsp.MouseButton1Click:Connect(function()
    Settings.ESP = not Settings.ESP
    if Settings.ESP then
        btnEsp.Text = "ESP Monstros/Players: [ON]"
        btnEsp.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        btnEsp.Text = "ESP Monstros/Players: [OFF]"
        btnEsp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        limparEsp()
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.ESP then
        local monstersFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Monster")
        if monstersFolder then
            for _, monster in pairs(monstersFolder:GetChildren()) do
                if not ESPMonsters[monster] and monster:FindFirstChild("HumanoidRootPart") then
                    ESPMonsters[monster] = createESP(monster)
                end
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not ESPPlayers[player] then
                ESPPlayers[player] = createESP(player.Character)
            end
        end
    end
end)

-- Botão 3: Auto Win (Objetivo)[cite: 1]
local btnAutoWin = criarBotao(124, "Auto Win (Objetivo): [OFF]")
btnAutoWin.MouseButton1Click:Connect(function()
    Settings.AutoWin = not Settings.AutoWin
    if Settings.AutoWin then
        btnAutoWin.Text = "Auto Win (Objetivo): [ON]"
        btnAutoWin.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        btnAutoWin.Text = "Auto Win (Objetivo): [OFF]"
        btnAutoWin.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-- Botão 4: Auto Kill Bosses[cite: 1]
local btnAutoKill = criarBotao(161, "Auto Kill Monstros: [OFF]")
btnAutoKill.MouseButton1Click:Connect(function()
    Settings.AutoKill = not Settings.AutoKill
    if Settings.AutoKill then
        btnAutoKill.Text = "Auto Kill Monstros: [ON]"
        btnAutoKill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        btnAutoKill.Text = "Auto Kill Monstros: [OFF]"
        btnAutoKill.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-- Botão 5: Auto Escape[cite: 1]
local btnAutoEscape = criarBotao(198, "Fuga Automática (<20m): [OFF]")
btnAutoEscape.MouseButton1Click:Connect(function()
    Settings.AutoEscape = not Settings.AutoEscape
    if Settings.AutoEscape then
        btnAutoEscape.Text = "Fuga Automática (<20m): [ON]"
        btnAutoEscape.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        btnAutoEscape.Text = "Fuga Automática (<20m): [OFF]"
        btnAutoEscape.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-- Botão 6: Deletar Monstros[cite: 1]
local btnDeleteMonsters = criarBotao(235, "Deletar Monstros Mapa: [OFF]")
btnDeleteMonsters.MouseButton1Click:Connect(function()
    Settings.DeleteMonsters = not Settings.DeleteMonsters
    if Settings.DeleteMonsters then
        btnDeleteMonsters.Text = "Deletar Monstros Mapa: [ON]"
        btnDeleteMonsters.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        btnDeleteMonsters.Text = "Deletar Monstros Mapa: [OFF]"
        btnDeleteMonsters.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-- Botão 7: Sem Chaves (No Keys)[cite: 1]
local btnNoKeys = criarBotao(272, "Remover Chaves (NoKeys): [OFF]")
btnNoKeys.MouseButton1Click:Connect(function()
    Settings.NoKeys = not Settings.NoKeys
    if Settings.NoKeys then
        btnNoKeys.Text = "Remover Chaves (NoKeys): [ON]"
        btnNoKeys.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        btnNoKeys.Text = "Remover Chaves (NoKeys): [OFF]"
        btnNoKeys.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-- Botão 8: Voar (Fly - com suporte a Q e E)
local btnVoar = criarBotao(309, "Voar (Q/E): [OFF]")
local flyConnection

btnVoar.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    local rootPart = getRootPart()
    local humanoid = getHumanoid()
    
    if FlyEnabled then
        btnVoar.Text = "Voar (Q/E): [ON]"
        btnVoar.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        if rootPart and humanoid then
            humanoid.PlatformStand = true
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            FlyBodyVelocity.Parent = rootPart
            
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            FlyBodyGyro.CFrame = rootPart.CFrame
            FlyBodyGyro.Parent = rootPart
            
            flyConnection = RunService.Heartbeat:Connect(function()
                if not FlyEnabled or not rootPart then return end
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir + Vector3.new(0, 1, 0) end -- Sobe com Q
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir - Vector3.new(0, 1, 0) end -- Desce com E
                
                FlyBodyVelocity.Velocity = moveDir.Unit * FlySpeed
                FlyBodyGyro.CFrame = camera.CFrame
            end)
        end
    else
        btnVoar.Text = "Voar (Q/E): [OFF]"
        btnVoar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if flyConnection then flyConnection:Disconnect() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if humanoid then humanoid.PlatformStand = false end
    end
end)

-- Botão 9: Fechar Painel
local btnFechar = criarBotao(346, "Fechar Painel")
btnFechar.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
btnFechar.MouseButton1Click:Connect(function()
    limparEsp()
    if flyConnection then flyConnection:Disconnect() end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    screenGui:Destroy()
end)

-- Loop principal executando as funções automáticas ativadas no painel
task.spawn(function()
    while true do
        task.wait(1)
        
        -- Auto Win / Objetivo[cite: 1]
        if Settings.AutoWin then
            local objective = Workspace:FindFirstChild("Objective") or Workspace:FindFirstChild("ObjectivePart")
            if objective then tpTo(objective) end
        end
        
        -- Auto Kill Monstros[cite: 1]
        if Settings.AutoKill then
            local monstersFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Monster")
            if monstersFolder then
                for _, monster in pairs(monstersFolder:GetChildren()) do
                    local hum = monster:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
        end
        
        -- Auto Escape (Fuga se monstro < 20m)[cite: 1]
        if Settings.AutoEscape then
            local rootPart = getRootPart()
            local monstersFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Monster")
            if rootPart and monstersFolder then
                for _, monster in pairs(monstersFolder:GetChildren()) do
                    local mRoot = monster:FindFirstChild("HumanoidRootPart")
                    if mRoot then
                        local dist = (rootPart.Position - mRoot.Position).Magnitude
                        if dist < 20 then
                            tpTo(CFrame.new(0, 50, 0))
                        end
                    end
                end
            end
        end
        
        -- Deletar Monstros[cite: 1]
        if Settings.DeleteMonsters then
            local monstersFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Monster")
            if monstersFolder then
                for _, monster in pairs(monstersFolder:GetChildren()) do
                    monster:Destroy()
                end
            end
        end
        
        -- Remover Chaves[cite: 1]
        if Settings.NoKeys then
            local keysFolder = Workspace:FindFirstChild("Keys") or Workspace:FindFirstChild("KeyItems")
            if keysFolder then
                for _, key in pairs(keysFolder:GetChildren()) do
                    key:Destroy()
                end
            end
        end
    end
end)

print("Painel completo do The Mimic carregado com sucesso!")
