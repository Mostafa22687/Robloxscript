-- الخدمات
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

------------------------------------------------
-- GUI رئيسي
------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- زر فتح/اغلاق القائمة
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "سكربت ابو الصوف"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = screenGui

-- الإطار الرئيسي
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(212, 175, 55) -- جولد
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- شريط التبويبات
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.BackgroundColor3 = Color3.fromRGB(160, 130, 40) -- جولد داكن
tabBar.Parent = mainFrame

-- محتوى التبويبات
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- أسود خفيف
contentFrame.Parent = mainFrame

------------------------------------------------
-- دالة إنشاء التبويبات
------------------------------------------------
local tabs = {}
local tabIndex = 0
local function createTab(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 1, 0)
    button.Position = UDim2.new(0, tabIndex * 100, 0, 0)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(0,0,0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = tabBar

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = contentFrame

    tabs[name] = {Button = button, Frame = frame}

    button.MouseButton1Click:Connect(function()
        for _, tab in pairs(tabs) do
            tab.Frame.Visible = false
        end
        frame.Visible = true
    end)

    tabIndex += 1
end

-- إنشاء التبويبات
createTab("Home")
createTab("ESP")
createTab("Server")
createTab("Settings") -- آخر قسم

-- زر إظهار/إخفاء القائمة
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

------------------------------------------------
-- دالة تشغيل الصوت عند تفعيل أو إيقاف الخاصية
-- تفعيل: 5852470908 | إيقاف: 2865227271
------------------------------------------------
local function playToggleSound(isEnabled)
    local sound = Instance.new("Sound")
    sound.SoundId = isEnabled and "rbxassetid://5852470908" or "rbxassetid://2865227271"
    sound.Parent = workspace
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

------------------------------------------------
-- قسم Home
------------------------------------------------
local homeFrame = tabs["Home"].Frame

-- Fly / Jump Power مع Cooldown
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 150, 0, 40)
flyButton.Position = UDim2.new(0, 10, 0, 10)
flyButton.Text = "Fly (Jump Power): OFF"
flyButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
flyButton.TextColor3 = Color3.fromRGB(255,255,255)
flyButton.Parent = homeFrame

local flyEnabled = false
local jumpCooldown = 0.5
local lastJump = 0

-- رسالة تحذير
local warningLabel = Instance.new("TextLabel")
warningLabel.Size = UDim2.new(1, 0, 0, 30)
warningLabel.Position = UDim2.new(0, 0, 0, -35)
warningLabel.Text = ""
warningLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
warningLabel.TextScaled = true
warningLabel.BackgroundTransparency = 1
warningLabel.Parent = screenGui

flyButton.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyButton.Text = flyEnabled and "Fly (Jump Power): ON" or "Fly (Jump Power): OFF"
    playToggleSound(flyEnabled)
end)

uis.JumpRequest:Connect(function()
    if flyEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        local currentTime = tick()
        if currentTime - lastJump < jumpCooldown then
            warningLabel.Text = "مصطفى: لا تكرر القفز باستمرار"
            delay(2, function()
                warningLabel.Text = ""
            end)
            return
        end
        lastJump = currentTime
        local humanoid = player.Character.Humanoid
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        humanoid.UseJumpPower = true
        humanoid.JumpPower = 80
    end
end)

-- Auto Click (Laser Cape)
local autoClickButton = Instance.new("TextButton")
autoClickButton.Size = UDim2.new(0, 150, 0, 40)
autoClickButton.Position = UDim2.new(0, 10, 0, 60)
autoClickButton.Text = "Laser Click: OFF"
autoClickButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
autoClickButton.TextColor3 = Color3.fromRGB(255,255,255)
autoClickButton.Parent = homeFrame

local autoClickEnabled = false
local equippedTool = nil

autoClickButton.MouseButton1Click:Connect(function()
    autoClickEnabled = not autoClickEnabled
    autoClickButton.Text = autoClickEnabled and "Laser Click: ON" or "Laser Click: OFF"
    playToggleSound(autoClickEnabled)

    if not autoClickEnabled and equippedTool then
        equippedTool.Parent = player.Backpack
        equippedTool = nil
    end
end)

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closestPlayer = plr
            end
        end
    end
    return closestPlayer
end

runService.RenderStepped:Connect(function()
    if autoClickEnabled then
        local char = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if char and backpack then
            local tool = char:FindFirstChild("Laser Cape")
            if not tool then
                local toolInBackpack = backpack:FindFirstChild("Laser Cape")
                if toolInBackpack then
                    toolInBackpack.Parent = char
                    equippedTool = toolInBackpack
                    tool = toolInBackpack
                end
            end

            local closest = getClosestPlayer()
            if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                local cam = workspace.CurrentCamera
                cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Character.HumanoidRootPart.Position)

                if tool and tool:IsA("Tool") then
                    tool:Activate()
                end
            end
        end
    end
end)

-- Speed Boost
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0, 150, 0, 40)
speedButton.Position = UDim2.new(0, 10, 0, 110)
speedButton.Text = "Speed Boost: OFF"
speedButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
speedButton.TextColor3 = Color3.fromRGB(255,255,255)
speedButton.Parent = homeFrame

local speedEnabled = false
local normalSpeed = 16
local boostSpeed = 24

speedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedButton.Text = speedEnabled and "Speed Boost: ON" or "Speed Boost: OFF"
    playToggleSound(speedEnabled)

    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speedEnabled and boostSpeed or normalSpeed
    end
end)

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if speedEnabled then
        char.Humanoid.WalkSpeed = boostSpeed
    end
end)

------------------------------------------------
-- قسم ESP
------------------------------------------------
local espFrame = tabs["ESP"].Frame

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 150, 0, 40)
espButton.Position = UDim2.new(0, 10, 0, 10)
espButton.Text = "ESP Players: OFF"
espButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
espButton.TextColor3 = Color3.fromRGB(255,255,255)
espButton.Parent = espFrame

local espEnabled = false
local highlights = {}

local function createHighlight(plr, color)
    if plr.Character and not highlights[plr] then
        local hl = Instance.new("Highlight")
        hl.Adornee = plr.Character
        hl.FillTransparency = 0.6
        hl.OutlineTransparency = 0.5
        hl.FillColor = color or Color3.fromRGB(255,0,0)
        hl.OutlineColor = color or Color3.fromRGB(255,0,0)
        hl.Parent = workspace
        highlights[plr] = hl
    end
end

local function removeHighlights()
    for _, hl in pairs(highlights) do
        if hl then hl:Destroy() end
    end
    highlights = {}
end

runService.RenderStepped:Connect(function()
    if espEnabled then
        local hue = tick() % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        for _, hl in pairs(highlights) do
            if hl then
                hl.FillColor = rainbowColor
                hl.OutlineColor = rainbowColor
            end
        end
    end
end)

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP Players: ON" or "ESP Players: OFF"
    playToggleSound(espEnabled)
    if espEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                createHighlight(plr)
            end
        end
    else
        removeHighlights()
    end
end)

Players.PlayerAdded:Connect(function(plr)
    if espEnabled and plr ~= player then
        createHighlight(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then
        highlights[plr]:Destroy()
        highlights[plr] = nil
    end
end)

-- Best Brainrot ESP
local bestBrainrotEspButton = Instance.new("TextButton")
bestBrainrotEspButton.Size = UDim2.new(0, 150, 0, 40)
bestBrainrotEspButton.Position = UDim2.new(0, 10, 0, 60)
bestBrainrotEspButton.Text = "Best Brainrot ESP: OFF"
bestBrainrotEspButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
bestBrainrotEspButton.TextColor3 = Color3.fromRGB(255,255,255)
bestBrainrotEspButton.Parent = espFrame

local bestEspEnabled = false
local brainrotValues = {
    ["Brainrot God"] = 1000000,
    ["La Vacca Staturno Saturnita"] = 500000,
    ["Nuclearo Dinossauro"] = 250000,
}

local function highlightBestBrainrot()
    local bestValue = 0
    local bestPlayer = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local name = plr.Name
            local value = brainrotValues[name] or 0
            if value > bestValue then
                bestValue = value
                bestPlayer = plr
            end
        end
    end
    if bestPlayer then
        createHighlight(bestPlayer, Color3.fromRGB(255,255,255))
    end
end

bestBrainrotEspButton.MouseButton1Click:Connect(function()
    bestEspEnabled = not bestEspEnabled
    bestBrainrotEspButton.Text = bestEspEnabled and "Best Brainrot ESP: ON" or "Best Brainrot ESP: OFF"
    playToggleSound(bestEspEnabled)

    if bestEspEnabled then
        highlightBestBrainrot()
    else
        removeHighlights()
    end
end)

------------------------------------------------
-- قسم Server
------------------------------------------------
local serverFrame = tabs["Server"].Frame

-- زر إعادة الدخول
local rejoinButton = Instance.new("TextButton")
rejoinButton.Size = UDim2.new(0, 150, 0, 40)
rejoinButton.Position = UDim2.new(0, 10, 0, 10)
rejoinButton.Text = "Rejoin"
rejoinButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
rejoinButton.TextColor3 = Color3.fromRGB(255,255,255)
rejoinButton.Parent = serverFrame

rejoinButton.MouseButton1Click:Connect(function()
    playToggleSound(true)
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, player)
end)

-- زر تبديل السيرفر
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 150, 0, 40)
teleportButton.Position = UDim2.new(0, 10, 0, 60)
teleportButton.Text = "Teleport to New Server"
teleportButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
teleportButton.TextColor3 = Color3.fromRGB(255,255,255)
teleportButton.Parent = serverFrame

teleportButton.MouseButton1Click:Connect(function()
    playToggleSound(true)
    local servers = {}
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and data and data.data then
        for _, v in pairs(data.data) do
            if v.id ~= game.JobId and v.playing < v.maxPlayers then
                table.insert(servers, v.id)
            end
        end
    end
    if #servers > 0 then
        local newServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, newServer, player)
    end
end)

------------------------------------------------
-- قسم Settings
------------------------------------------------
local settingsFrame = tabs["Settings"].Frame

local languageButton = Instance.new("TextButton")
languageButton.Size = UDim2.new(0, 150, 0, 40)
languageButton.Position = UDim2.new(0, 10, 0, 10)
languageButton.Text = "Language: English"
languageButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
languageButton.TextColor3 = Color3.fromRGB(255,255,255)
languageButton.Parent = settingsFrame

local currentLanguage = "English"

languageButton.MouseButton1Click:Connect(function()
    if currentLanguage == "English" then
        currentLanguage = "Arabic"
        languageButton.Text = "اللغة: العربية"

        -- ترجمة أزرار Home
        flyButton.Text = flyEnabled and "القفز: مفعل" or "القفز: معطل"
        autoClickButton.Text = autoClickEnabled and "ضغط الليزر: مفعل" or "ضغط الليزر: معطل"
        speedButton.Text = speedEnabled and "سرعة: مفعل" or "سرعة: معطل"

        -- ترجمة أزرار ESP
        espButton.Text = espEnabled and "ESP اللاعبين: مفعل" or "ESP اللاعبين: معطل"
        bestBrainrotEspButton.Text = bestEspEnabled and "أفضل براينروت: مفعل" or "أفضل براينروت: معطل"

        -- ترجمة أزرار Server
        rejoinButton.Text = "إعادة الدخول"
        teleportButton.Text = "تبديل السيرفر"
    else
        currentLanguage = "English"
        languageButton.Text = "Language: English"

        flyButton.Text = flyEnabled and "Fly (Jump Power): ON" or "Fly (Jump Power): OFF"
        autoClickButton.Text = autoClickEnabled and "Laser Click: ON" or "Laser Click: OFF"
        speedButton.Text = speedEnabled and "Speed Boost: ON" or "Speed Boost: OFF"

        espButton.Text = espEnabled and "ESP Players: ON" or "ESP Players: OFF"
        bestBrainrotEspButton.Text = bestEspEnabled and "Best Brainrot ESP: ON" or "Best Brainrot ESP: OFF"

        rejoinButton.Text = "Rejoin"
        teleportButton.Text = "Teleport to New Server"
    end
end)

------------------------------------------------
-- افتراضياً فتح تبويب Home
------------------------------------------------
tabs["Home"].Frame.Visible = true
