--Create By HikmattXD. 
--Fuck you recode.
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "SharkBite 2 • HikmatXD.",
    LoadingTitle = "SharkBite 2 MattTzy.",
    LoadingSubtitle = "by HikmatXD.",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "SharkConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

local clickCount = 0
local Tab = Window:CreateTab("Main", 4483362458)
localplayer = game:GetService("Players").LocalPlayer.Name
local remote = nil
local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local sharkName = nil
local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Projectiles"):WaitForChild("Events"):WaitForChild("Weapons"):WaitForChild("remotes")

local function antiAFK()
    while true do
        virtualInputManager:SendMouseMoveEvent(1, 1, 0, 0, game)
        task.wait(30)
    end
end

local function hookRemote(remoteObject)
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self == remoteObject and (method == "FireServer" or method == "InvokeServer") then
            remote = self.Name
        end
        return oldNamecall(self, ...)
    end)
end

for _, child in ipairs(remotesFolder:GetChildren()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        hookRemote(child)
    end
end

remotesFolder.ChildAdded:Connect(function(child)
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        hookRemote(child)
    end
end)

local function getShark()
    local sharksFolder = workspace:FindFirstChild("Sharks")
    if sharksFolder then
        for _, shark in ipairs(sharksFolder:GetChildren()) do
            if shark:IsA("Model") then
                sharkName = shark.Name
                return
            end
        end
    end
    sharkName = nil
end

local function KillShark()
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = character
        end
    end
    for j = 1, 40 do
        if sharkName and remote then
            local shark = workspace:WaitForChild("Sharks"):FindFirstChild(sharkName)
            game:GetService("ReplicatedStorage")
                :WaitForChild("Projectiles")
                :WaitForChild("Events")
                :WaitForChild("Weapons")
                :WaitForChild("remotes")
                :WaitForChild(remote):FireServer(shark)
        end
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local center = Vector3.new(0, -100, 0)
local radius = 1000
local speed = math.pi * 2
local angle = 0
local hrp

local function updateHRP()
    character = player.Character or player.CharacterAdded:Wait()
    backpack = player:WaitForChild("Backpack")
    hrp = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(updateHRP)
if player.Character then updateHRP() end

local runningConnection
local Toggle

Toggle = Tab:CreateToggle({
    Name = "auto kill sharks [tembak sharks untuk aktifkan fitur]",
    CurrentValue = false,
    Flag = "AutoKillSharks",
    Callback = function(on)
    antiAFK() 
        if on then
            local lastNotify = 0
            runningConnection = RunService.Heartbeat:Connect(function(dt)
                if player.Team and player.Team.Name ~= "Shark" and hrp then
                    if not remote then
                        if tick() - lastNotify >= 3 then
                            Rayfield:Notify({
                                Title = "tunggu sharks keluar, baru kamu tembak",
                                Content = "tembak sharks untuk aktifkan fitur",
                                Duration = 3
                            })
                            lastNotify = tick()
                        end
                        return
                    end
                    KillShark()
                    getShark()
                    if not sharkName then
                        local chinook = workspace:FindFirstChild("Chinook")
                        local interior = chinook and chinook:FindFirstChild("interior")
                        if interior then
                            hrp.CFrame = interior.CFrame
                        end
                    else
                        angle += speed * dt
                        local t = (angle % (math.pi * 2)) / (math.pi * 2)
                        local offset
                        if t < 0.25 then
                            offset = Vector3.new(radius, 0, -radius + 8 * radius * t)
                        elseif t < 0.5 then
                            offset = Vector3.new(radius - 8 * radius * (t - 0.25), 0, radius)
                        elseif t < 0.75 then
                            offset = Vector3.new(-radius, 0, radius - 8 * radius * (t - 0.5))
                        else
                            offset = Vector3.new(-radius + 8 * radius * (t - 0.75), 0, -radius)
                        end
                        hrp.CFrame = CFrame.new(center + offset, center)
                    end
                end
            end)
            player.CharacterAdded:Connect(updateHRP)
        else
            if runningConnection then
                runningConnection:Disconnect()
                runningConnection = nil
            end
        end
    end,
})

local AutoWinConnection

local function getNearestAliveSurvivor()
    local nearestPlayer = nil
    local nearestDist = math.huge
    local myPos = hrp and hrp.Position or Vector3.zero
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Team and plr.Team.Name == "Survivor" then
            local char = plr.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            local hrpTarget = char and char:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and hrpTarget then
                local dist = (hrpTarget.Position - myPos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPlayer = plr
                end
            end
        end
    end
    return nearestPlayer
end

Tab:CreateToggle({
    Name = "auto kill player [jika kamu menjadi sharks]",
    CurrentValue = false,
    Flag = "AutoKillPlayer",
    Callback = function(state)
        if state then
            AutoWinConnection = RunService.Heartbeat:Connect(function()
                if player.Team and player.Team.Name == "Shark" and hrp then
                    local targetPlayer = getNearestAliveSurvivor()
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPos = targetPlayer.Character.HumanoidRootPart.Position
                        local sharksFolder = workspace:WaitForChild("Sharks")
                        for _, shark in ipairs(sharksFolder:GetChildren()) do
                            for _, part in ipairs(shark:GetDescendants()) do
                                if part:IsA("BasePart") and part.Name == "Ball" then
                                    part.CFrame = CFrame.new(targetPos)
                                end
                            end
                        end
                    end
                end
            end)
            player.CharacterAdded:Connect(updateHRP)
        else
            if AutoWinConnection then
                AutoWinConnection:Disconnect()
                AutoWinConnection = nil
            end
        end
    end
})

local sharkESPConnection = {}
local function setSharkESP(enabled)
    local sharksFolder = workspace:FindFirstChild("Sharks")
    if not sharksFolder then return end
    for _, conn in ipairs(sharkESPConnection) do
        conn:Disconnect()
    end
    table.clear(sharkESPConnection)
    for _, shark in ipairs(sharksFolder:GetDescendants()) do
        if shark:IsA("Highlight") then
            if enabled then
                shark.Enabled = true
                shark.OutlineTransparency = 1
                table.insert(sharkESPConnection, shark:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if not shark.Enabled then
                        shark.Enabled = true
                    end
                end))
                table.insert(sharkESPConnection, shark:GetPropertyChangedSignal("OutlineTransparency"):Connect(function()
                    if shark.OutlineTransparency ~= 1 then
                        shark.OutlineTransparency = 1
                    end
                end))
            else
                shark.Enabled = false
                shark.OutlineTransparency = 1
                table.insert(sharkESPConnection, shark:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if shark.Enabled then
                        shark.Enabled = false
                    end
                end))
                table.insert(sharkESPConnection, shark:GetPropertyChangedSignal("OutlineTransparency"):Connect(function()
                    if shark.OutlineTransparency ~= 1 then
                        shark.OutlineTransparency = 1
                    end
                end))
            end
        end
    end
end

local function watchForNewSharks(toggleState)
    local sharksFolder = workspace:FindFirstChild("Sharks")
    if sharksFolder then
        table.insert(sharkESPConnection, sharksFolder.DescendantAdded:Connect(function(desc)
            if desc:IsA("Highlight") then
                setSharkESP(toggleState)
            end
        end))
    end
end



local function setPlayerESP()
    local folder = Instance.new("Folder", game.CoreGui.esp)
    folder.Name = "survivors"
    for __,v in pairs(game.Players:GetDescendants()) do
         if v.Name ~= localplayer and v.Team.Name == "Survivor" then
            survivors = {}
            table.insert(survivors, v.Name)
            for __ = 1, #survivors do
                local esp = Instance.new("BillboardGui",game.CoreGui.esp.survivors)
                esp.Adornee = game.Players[v.Name].Character
                esp.AlwaysOnTop=true
                esp.ResetOnSpawn=false
                esp.Size = UDim2.new(1,1,1,1)
                esp.Name = v.Name
                local tag = Instance.new("TextLabel", esp)
                tag.Size = UDim2.new(5,5,5,5)
                tag.Text = "Survivor"
                tag.TextColor3 = Color3.new(0, 255, 0)
                tag.BackgroundTransparency = 1
            end
         end
    end
end


Tab:CreateToggle({
    Name = "highlight sharks [esp]",
    CurrentValue = false,
    Flag = "sharkesp",
    Callback = function(state)
        setSharkESP(state)
        watchForNewSharks(state)
    end
}) 
