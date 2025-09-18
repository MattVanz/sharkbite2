-- Hi! Please don't forget leave a like:>
local lplr = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local CurrentCamera = workspace.CurrentCamera
local worldToViewportPoint = CurrentCamera.worldToViewportPoint

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 3, 0)


local esp_settings = {
    enabled = true,
    skel = true,
    skel_col = Color3.fromRGB(255, 255, 255),
    dot_size = 5
}

local player_drawings = {} 

local function createBoxEsp(v)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = v.TeamColor.Color
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false

    local hpbar = Drawing.new("Line")
    hpbar.Visible = false
    hpbar.Color = Color3.new(0, 1, 0)
    hpbar.Thickness = 2

    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.new(1, 1, 1)
    name.Size = 10
    name.Center = true
    name.Outline = true
    name.OutlineColor = Color3.new(0, 0, 0)

    local dist = Drawing.new("Text")
    dist.Visible = false
    dist.Color = Color3.new(1, 1, 1)
    dist.Size = 10
    dist.Center = true
    dist.Outline = true
    dist.OutlineColor = Color3.new(0, 0, 0)

    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = v.TeamColor.Color
    line.Thickness = 2

    game:GetService("RunService").RenderStepped:Connect(function()
        if esp_settings.enabled and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v ~= lplr and v.Character.Humanoid.Health > 0 then
            local vec, onScreen = camera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)

            local root = v.Character.HumanoidRootPart
            local head = v.Character.Head
            local rootPos, rootVis = worldToViewportPoint(CurrentCamera, root.Position)
            local headPos = worldToViewportPoint(CurrentCamera, head.Position + HeadOff)
            local legPos = worldToViewportPoint(CurrentCamera, root.Position - LegOff)

            box.Size = Vector2.new(1000 / rootPos.Z, headPos.Y - legPos.Y)
            box.Position = Vector2.new(rootPos.X - box.Size.X / 2, rootPos.Y - box.Size.Y / 2)

            local hp = v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth
            hpbar.From = Vector2.new(box.Position.X + box.Size.X + 5, box.Position.Y + box.Size.Y * (1 - hp))
            hpbar.To = Vector2.new(box.Position.X + box.Size.X + 5, box.Position.Y + box.Size.Y)
            hpbar.Color = Color3.new(1 - hp, hp, 0)

            name.Position = Vector2.new(box.Position.X + box.Size.X / 2, box.Position.Y - 20)
            name.Text = v.Name
            name.Visible = true

            dist.Position = Vector2.new(box.Position.X + box.Size.X / 2, box.Position.Y + box.Size.Y)
            dist.Text = tostring(math.floor((lplr.Character.HumanoidRootPart.Position - root.Position).Magnitude)) .. "m"
            dist.Visible = true

            local lplrHead = lplr.Character:FindFirstChild("Head")
            if lplrHead then
                local lplrHeadViewport = camera:worldToViewportPoint(lplrHead.Position)
                line.From = Vector2.new(lplrHeadViewport.X, lplrHeadViewport.Y)
                line.To = Vector2.new(rootPos.X, rootPos.Y)
            end

            if onScreen then
                box.Visible = true
                hpbar.Visible = true
                name.Visible = true
                dist.Visible = true
                line.Visible = true
            else
                box.Visible = false
                hpbar.Visible = false
                name.Visible = false
                dist.Visible = false
                line.Visible = false
            end
        else
            box.Visible = false
            hpbar.Visible = false
            name.Visible = false
            dist.Visible = false
            line.Visible = false
        end
    end)
end


local function draw(player, character)
    local skel_head = Drawing.new("Line")
    skel_head.Visible = false
    skel_head.Thickness = 2
    skel_head.Color = esp_settings.skel_col

    local skel_torso = Drawing.new("Line")
    skel_torso.Visible = false
    skel_torso.Thickness = 2
    skel_torso.Color = esp_settings.skel_col

    local skel_leftarm = Drawing.new("Line")
    skel_leftarm.Visible = false
    skel_leftarm.Thickness = 2
    skel_leftarm.Color = esp_settings.skel_col

    local skel_rightarm = Drawing.new("Line")
    skel_rightarm.Visible = false
    skel_rightarm.Thickness = 2
    skel_rightarm.Color = esp_settings.skel_col

    local skel_leftleg = Drawing.new("Line")
    skel_leftleg.Visible = false
    skel_leftleg.Thickness = 2
    skel_leftleg.Color = esp_settings.skel_col

    local skel_rightleg = Drawing.new("Line")
    skel_rightleg.Visible = false
    skel_rightleg.Thickness = 2
    skel_rightleg.Color = esp_settings.skel_col

    player_drawings[player] = {
        skel_head = skel_head,
        skel_torso = skel_torso,
        skel_leftarm = skel_leftarm,
        skel_rightarm = skel_rightarm,
        skel_leftleg = skel_leftleg,
        skel_rightleg = skel_rightleg
    }

    local function update()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if workspace:FindFirstChild(player.Name) and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health ~= 0 then
                local character_rootpart_3d = character.HumanoidRootPart.Position
                local character_rootpart_2d, rootpart_onscreen = camera:WorldToViewportPoint(character_rootpart_3d)

                if rootpart_onscreen and esp_settings.enabled then
                    local head, torso_upper, torso_lower, leftarm, rightarm, leftleg, rightleg

                    if character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
                        head = character:FindFirstChild("Head")
                        torso_upper = character:FindFirstChild("Torso")
                        torso_lower = torso_upper
                        leftarm = character:FindFirstChild("Left Arm")
                        rightarm = character:FindFirstChild("Right Arm")
                        leftleg = character:FindFirstChild("Left Leg")
                        rightleg = character:FindFirstChild("Right Leg")
                    else
                        head = character:FindFirstChild("Head")
                        torso_upper = character:FindFirstChild("UpperTorso")
                        torso_lower = character:FindFirstChild("LowerTorso")
                        leftarm = character:FindFirstChild("LeftUpperArm")
                        rightarm = character:FindFirstChild("RightUpperArm")
                        leftleg = character:FindFirstChild("LeftUpperLeg")
                        rightleg = character:FindFirstChild("RightUpperLeg")
                    end

                    if head and torso_upper and torso_lower and leftarm and rightarm and leftleg and rightleg then
                        local head_2d = camera:WorldToViewportPoint(head.Position)
                        local torso_upper_2d = camera:WorldToViewportPoint(torso_upper.Position + Vector3.new(0, 1.1, 0))
                        local torso_lower_2d = camera:WorldToViewportPoint(torso_lower.Position + Vector3.new(0, -1, 0))

                        local leftarm_2d = camera:WorldToViewportPoint(leftarm.Position + Vector3.new(0, -1, 0))
                        local rightarm_2d = camera:WorldToViewportPoint(rightarm.Position + Vector3.new(0, -1, 0))
                        local leftleg_2d = camera:WorldToViewportPoint(leftleg.Position + Vector3.new(0, -1, 0))
                        local rightleg_2d = camera:WorldToViewportPoint(rightleg.Position + Vector3.new(0, -1, 0))

                        skel_head.From = Vector2.new(head_2d.X, head_2d.Y)
                        skel_head.To = Vector2.new(torso_upper_2d.X, torso_upper_2d.Y)

                        skel_torso.From = Vector2.new(torso_upper_2d.X, torso_upper_2d.Y)
                        skel_torso.To = Vector2.new(torso_lower_2d.X, torso_lower_2d.Y)

                        skel_leftarm.From = Vector2.new(torso_upper_2d.X, torso_upper_2d.Y)
                        skel_leftarm.To = Vector2.new(leftarm_2d.X, leftarm_2d.Y)

                        skel_rightarm.From = Vector2.new(torso_upper_2d.X, torso_upper_2d.Y)
                        skel_rightarm.To = Vector2.new(rightarm_2d.X, rightarm_2d.Y)

                        skel_leftleg.From = Vector2.new(torso_lower_2d.X, torso_lower_2d.Y)
                        skel_leftleg.To = Vector2.new(leftleg_2d.X, leftleg_2d.Y)

                        skel_rightleg.From = Vector2.new(torso_lower_2d.X, torso_lower_2d.Y)
                        skel_rightleg.To = Vector2.new(rightleg_2d.X, rightleg_2d.Y)

                        skel_head.Visible = esp_settings.skel
                        skel_torso.Visible = esp_settings.skel
                        skel_leftarm.Visible = esp_settings.skel
                        skel_rightarm.Visible = esp_settings.skel
                        skel_leftleg.Visible = esp_settings.skel
                        skel_rightleg.Visible = esp_settings.skel
                    else
                        skel_head.Visible = false
                        skel_torso.Visible = false
                        skel_leftarm.Visible = false
                        skel_rightarm.Visible = false
                        skel_leftleg.Visible = false
                        skel_rightleg.Visible = false
                    end
                else
                    skel_head.Visible = false
                    skel_torso.Visible = false
                    skel_leftarm.Visible = false
                    skel_rightarm.Visible = false
                    skel_leftleg.Visible = false
                    skel_rightleg.Visible = false
                end
            else
                if player == nil then
                    connection:Disconnect()
                    connection = nil
                end

                skel_head.Visible = false
                skel_torso.Visible = false
                skel_leftarm.Visible = false
                skel_rightarm.Visible = false
                skel_leftleg.Visible = false
                skel_rightleg.Visible = false
            end
        end)

        player_drawings[player].connection = connection
    end
    coroutine.wrap(update)()
end

local function playeradded(player)
    if player.Character then
        coroutine.wrap(draw)(player, player.Character)
    end
    player.CharacterAdded:Connect(function(character)
        coroutine.wrap(draw)(player, character)
    end)
end

local function playerremoved(player)
    if player_drawings[player] then
        for _, drawing in pairs(player_drawings[player]) do
            if drawing.Remove then
                drawing:Remove()
            elseif drawing.Disconnect then
                drawing:Disconnect()
            end
        end
        player_drawings[player] = nil
    end
end


for i, v in pairs(game.Players:GetChildren()) do
    if v ~= lplr then
        createBoxEsp(v)
        playeradded(v)
    end
end


game.Players.PlayerAdded:Connect(function(v)
    createBoxEsp(v)
    playeradded(v)
end)

game.Players.PlayerRemoving:Connect(playerremoved)