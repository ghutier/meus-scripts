--[[
    Loadstring for beating The Mimic - Fully featured script with auto win, auto kill, auto tp, escape, fullbright, auto clicks, ESP, emotes with songs, fly toggle, respawn, monster deletion, no keys
    Usage: paste into a LocalScript or execute via loadstring in Roblox Studio or executor.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Settings
local Settings = {
    AutoWin = true,
    AutoKill = true,
    AutoTP = true,
    AutoEscape = true,
    FullBright = true,
    AutoClicks = true,
    ESP = true,
    EmotesWithSongs = true,
    FlyToggleKey = Enum.KeyCode.F,
    Respawn = true,
    DeleteMonsters = true,
    NoKeys = true,
}

-- Variables
local FlyEnabled = false
local FlySpeed = 50
local FlyBodyVelocity = nil
local FlyBodyGyro = nil

-- Utility Functions
local function tpTo(partOrCFrame)
    if typeof(partOrCFrame) == "Instance" and partOrCFrame:IsA("BasePart") then
        RootPart.CFrame = partOrCFrame.CFrame + Vector3.new(0, 5, 0)
    elseif typeof(partOrCFrame) == "CFrame" then
        RootPart.CFrame = partOrCFrame + Vector3.new(0, 5, 0)
    end
end

local function safeTweenTo(pos)
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(RootPart, tweenInfo, {CFrame = CFrame.new(pos) * CFrame.new(0, 5, 0)})
    tween:Play()
    tween.Completed:Wait()
end

-- FullBright Implementation
if Settings.FullBright then
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
end

-- ESP Implementation
local function createESP(target)
    if target:FindFirstChild("HumanoidRootPart") then
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

local ESPMonsters = {}
local ESPPlayers = {}

if Settings.ESP then
    -- ESP for monsters (assumed monsters are under Workspace.Monsters or similar)
    local function addESPForMonsters()
        local monstersFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Monster")
        if monstersFolder then
            for _, monster in pairs(monstersFolder:GetChildren()) do
                if not ESPMonsters[monster] and monster:FindFirstChild("HumanoidRootPart") then
                    ESPMonsters[monster] = createESP(monster)
                end
            end
        end
    end

    -- ESP for players
    local function addESPForPlayers()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not ESPPlayers[player] then
                ESPPlayers[player] = createESP(player.Character)
            end
        end
    end

    -- Refresh ESP periodically
    RunService.Heartbeat:Connect(function()
        if Settings.ESP then
            addESPForMonsters()
            addESPForPlayers()
        end
    end)
end

-- Auto Win / Auto TP / Auto Kill / Auto Clicks / Auto Escape Implementation
-- These depend highly on the game's structure. Below is a generic approach that tries to cover typical objectives in The Mimic chapters.
-- Adjust paths/names/events as per the actual game.

local MimicFolder = Workspace:WaitForChild("Mimic") or Workspace -- Adjust if needed

local function autoWinCurrentObjective()
    -- Teleport to objective part or trigger objective completion
    -- Example: find an objective part by name and teleport to it
    local objective = Workspace:FindFirstChild("Objective") or Workspace:FindFirstChild("ObjectivePart")
    if objective then
        tpTo(objective)
        wait(0.5)
        -- Try to fire touch event or simulate interaction if needed
        -- This depends on the game implementation, so simulate click or fire remote events if accessible
    end
end

local function autoKillBosses()
    -- Try to delete or kill boss monsters
    local monstersFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Monster")
    if monstersFolder then
        for _, monster in pairs(monstersFolder:GetChildren()) do
            if monster:FindFirstChild("Humanoid") then
                monster.Humanoid.Health = 0
            end
        end
    end
end

local function autoTPToNextPart()
    -- Teleport to next trigger part to activate next cutscene
    local triggersFolder = Workspace:FindFirstChild("Triggers") or Workspace:FindFirstChild("CutsceneTriggers")
    if triggersFolder then
        for _, trigger in pairs(triggersFolder:GetChildren()) do
            if trigger:IsA("BasePart") then
                tpTo(trigger)
                wait(0.5)
            end
        end
    end
end

local function autoEscapeFromMonster()
    -- Detect monsters near player and teleport away instantly
    local monstersFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Monster")
    if monstersFolder then
        for _, monster in pairs(monstersFolder:GetChildren()) do
            if monster:FindFirstChild("HumanoidRootPart") then
                local dist = (RootPart.Position - monster.HumanoidRootPart.Position).Magnitude
                if dist < 20 then -- monster chase proximity threshold
                    -- Teleport far away
                    tpTo(CFrame.new(0, 50, 0))
                    wait(0.5)
                end
            end
        end
    end
end

local function autoClicks()
    -- Auto click interactive parts / escape monster cutscenes
    -- Example: click all ClickDetectors in workspace
    for _, clickDetector in pairs(Workspace:GetDescendants()) do
        if clickDetector:IsA("ClickDetector") then
            clickDetector:Click()
            wait(0.1)
        end
    end
end

-- Emotes with songs feature (simplified)
local function playEmoteWithSong()
    -- Assuming mimic emotes are replicated in ReplicatedStorage.Emotes or similar
    local emotesFolder = ReplicatedStorage:FindFirstChild("Emotes")
    local emoteRemote = ReplicatedStorage:FindFirstChild("PlayEmote") or ReplicatedStorage:FindFirstChild("EmoteRemote")
    local soundFolder = ReplicatedStorage:FindFirstChild("EmoteSounds")

    if emotesFolder and emoteRemote and soundFolder then
        for _, emote in pairs(emotesFolder:GetChildren()) do
            if emote:IsA("StringValue") then
                -- Fire emote event
                emoteRemote:FireServer(emote.Value)
                -- Play sound if exists
                local sound = soundFolder:FindFirstChild(emote.Value)
                if sound then
                    local soundClone = sound:Clone()
                    soundClone.Parent = LocalPlayer.Character
                    soundClone:Play()
                    soundClone.Ended:Wait()
                    soundClone:Destroy()
                end
                wait(1)
            end
        end
    end
end

-- Fly toggle implementation
local function toggleFly()
    if FlyEnabled then
        FlyEnabled = false
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        Humanoid.PlatformStand = false
    else
        FlyEnabled = true
        FlyBodyVelocity = Instance.new("BodyVelocity", RootPart)
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        FlyBodyGyro = Instance.new("BodyGyro", RootPart)
        FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        Humanoid.PlatformStand = true
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Settings.FlyToggleKey then
        toggleFly()
    end
end)

-- Fly control update
RunService.Heartbeat:Connect(function()
    if FlyEnabled then
        local moveDirection = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0,1,0) end

        FlyBodyVelocity.Velocity = moveDirection.Unit * FlySpeed
        FlyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end
end)

-- Respawn Implementation
if Settings.Respawn then
    LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid")
        RootPart = char:WaitForChild("HumanoidRootPart")
    end)
end

local function respawnPlayer()
    LocalPlayer:LoadCharacter()
end

-- Delete monster rigs/models
local function deleteMonsters()
    local monstersFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Monster")
    if monstersFolder then
        for _, monster in pairs(monstersFolder:GetChildren()) do
            monster:Destroy()
        end
    end
end

-- No keys - remove key requirements if possible
local function removeKeys()
    local keysFolder = Workspace:FindFirstChild("Keys") or Workspace:FindFirstChild("KeyItems")
    if keysFolder then
        for _, key in pairs(keysFolder:GetChildren()) do
            key:Destroy()
        end
    end
end

-- Main loop
spawn(function()
    while true do
        if Settings.AutoWin then autoWinCurrentObjective() end
        if Settings.AutoKill then autoKillBosses() end
        if Settings.AutoTP then autoTPToNextPart() end
        if Settings.AutoEscape then autoEscapeFromMonster() end
        if Settings.AutoClicks then autoClicks() end
        if Settings.DeleteMonsters then deleteMonsters() end
        if Settings.NoKeys then removeKeys() end
        wait(1)
    end
end)

-- Optional: Trigger emotes with songs on demand
if Settings.EmotesWithSongs then
    spawn(function()
        while true do
            playEmoteWithSong()
            wait(10)
        end
    end)
end

print("The Mimic helper script loaded. Press "..Settings.FlyToggleKey.Name.." to toggle fly.")
