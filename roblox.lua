-- الخدمات
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- إعدادات اللغة
local language = "EN" -- "AR" للغة العربية
local function lang(textEn, textAr)
    return language == "AR" and textAr or textEn
end

-- GUI رئيسي
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- زر فتح/اغلاق القائمة
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "سكربت ابو الصوف"
toggleButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleButton.TextColor3 = Color3.fromRGB(255,215,0)
toggleButton.Parent = screenGui

-- الإطار الرئيسي
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 400)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255,215,0)
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- شريط التبويبات
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
tabBar.Parent = mainFrame

-- محتوى التبويبات
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
contentFrame.Parent = mainFrame

-- الأصوات
local function playSound(on)
    local sound = Instance.new("Sound")
    sound.SoundId = on and "rbxassetid://5852470908" or "rbxassetid://2865227271"
    sound.Parent = Workspace
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

-- نظام تبويبات
local tabs = {}
local tabIndex = 0
local function createTab(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 1, 0)
    button.Position = UDim2.new(0, tabIndex*100, 0, 0)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(0,0,0)
    button.TextColor3 = Color3.fromRGB(255,215,0)
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(255,215,0)
    button.Parent = tabBar

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = contentFrame

    tabs[name] = {Button=button, Frame=frame}

    button.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.Frame.Visible=false end
        frame.Visible=true
    end)

    tabIndex +=1
end

-- إنشاء التبويبات
createTab(lang("Home","الرئيسية"))
createTab(lang("ESP","ESP"))
createTab(lang("Server","السيرفر"))
createTab(lang("Settings","الإعدادات"))

-- زر إظهار/إخفاء القائمة
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- رسالة تحذير القفز
local warningLabel = Instance.new("TextLabel")
warningLabel.Size = UDim2.new(1,0,0,30)
warningLabel.Position = UDim2.new(0,0,0,-35)
warningLabel.Text = ""
warningLabel.TextColor3 = Color3.fromRGB(255,0,0)
warningLabel.TextScaled = true
warningLabel.BackgroundTransparency = 1
warningLabel.Parent = screenGui

-- ======== HOME TAB ========
local home = tabs[lang("Home","الرئيسية")].Frame

-- Fly
local flyButton = Instance.new("TextButton")
flyButton.Size=UDim2.new(0,150,0,40)
flyButton.Position=UDim2.new(0,10,0,10)
flyButton.Text=lang("Fly (Jump Power): OFF","طيران: إيقاف")
flyButton.BackgroundColor3=Color3.fromRGB(0,0,0)
flyButton.TextColor3=Color3.fromRGB(255,215,0)
flyButton.BorderColor3=Color3.fromRGB(255,215,0)
flyButton.BorderSizePixel=2
flyButton.Parent=home
local flyEnabled=false
local jumpCooldown=0.5
local lastJump=0

flyButton.MouseButton1Click:Connect(function()
    flyEnabled=not flyEnabled
    flyButton.Text=flyEnabled and lang("Fly (Jump Power): ON","طيران: تشغيل") or lang("Fly (Jump Power): OFF","طيران: إيقاف")
    flyButton.BackgroundColor3=flyEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,0)
    playSound(flyEnabled)
end)

UserInputService.JumpRequest:Connect(function()
    if flyEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        local currentTime=tick()
        if currentTime-lastJump<jumpCooldown then
            warningLabel.Text=lang("Don't spam jump","لا تكرر القفز")
            delay(2,function() warningLabel.Text="" end)
            return
        end
        lastJump=currentTime
        local humanoid=player.Character.Humanoid
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        humanoid.UseJumpPower=true
        humanoid.JumpPower=80
    end
end)

-- Speed Boost
local speedButton=Instance.new("TextButton")
speedButton.Size=UDim2.new(0,150,0,40)
speedButton.Position=UDim2.new(0,10,0,60)
speedButton.Text=lang("Speed Boost: OFF","زيادة السرعة: إيقاف")
speedButton.BackgroundColor3=Color3.fromRGB(0,0,0)
speedButton.TextColor3=Color3.fromRGB(255,215,0)
speedButton.BorderColor3=Color3.fromRGB(255,215,0)
speedButton.BorderSizePixel=2
speedButton.Parent=home
local speedEnabled=false
local normalSpeed=16
local boostSpeed=24
speedButton.MouseButton1Click:Connect(function()
    speedEnabled=not speedEnabled
    speedButton.Text=speedEnabled and lang("Speed Boost: ON","زيادة السرعة: تشغيل") or lang("Speed Boost: OFF","زيادة السرعة: إيقاف")
    speedButton.BackgroundColor3=speedEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,0)
    playSound(speedEnabled)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed=speedEnabled and boostSpeed or normalSpeed
    end
end)
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if speedEnabled then char.Humanoid.WalkSpeed=boostSpeed end
end)

-- Laser Click
local autoClickButton=Instance.new("TextButton")
autoClickButton.Size=UDim2.new(0,150,0,40)
autoClickButton.Position=UDim2.new(0,10,0,110)
autoClickButton.Text=lang("Laser Click: OFF","ضغط الليزر: إيقاف")
autoClickButton.BackgroundColor3=Color3.fromRGB(0,0,0)
autoClickButton.TextColor3=Color3.fromRGB(255,215,0)
autoClickButton.BorderColor3=Color3.fromRGB(255,215,0)
autoClickButton.BorderSizePixel=2
autoClickButton.Parent=home
local autoClickEnabled=false
local equippedTool=nil
autoClickButton.MouseButton1Click:Connect(function()
    autoClickEnabled=not autoClickEnabled
    autoClickButton.Text=autoClickEnabled and lang("Laser Click: ON","ضغط الليزر: تشغيل") or lang("Laser Click: OFF","ضغط الليزر: إيقاف")
    autoClickButton.BackgroundColor3=autoClickEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,0)
    playSound(autoClickEnabled)
    if not autoClickEnabled and equippedTool then
        equippedTool.Parent=player.Backpack
        equippedTool=nil
    end
end)

-- Invisible Man
local invisibleButton=Instance.new("TextButton")
invisibleButton.Size=UDim2.new(0,150,0,40)
invisibleButton.Position=UDim2.new(0,10,0,160)
invisibleButton.Text=lang("Invisible Man: OFF","الاختفاء: إيقاف")
invisibleButton.BackgroundColor3=Color3.fromRGB(0,0,0)
invisibleButton.TextColor3=Color3.fromRGB(255,215,0)
invisibleButton.BorderColor3=Color3.fromRGB(255,215,0)
invisibleButton.BorderSizePixel=2
invisibleButton.Parent=home
local invisibleEnabled=false

local function setInvisible(state)
    for _, p in pairs(Players:GetPlayers()) do
        if p==player then
            local char=p.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency=state and 1 or 0
                        part.CanCollide=not state
                    end
                end
            end
        else
            local char=p.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier=state and 1 or 0
                    end
                end
            end
        end
    end
end

invisibleButton.MouseButton1Click:Connect(function()
    invisibleEnabled=not invisibleEnabled
    invisibleButton.Text=invisibleEnabled and lang("Invisible Man: ON","الاختفاء: تشغيل") or lang("Invisible Man: OFF","الاختفاء: إيقاف")
    invisibleButton.BackgroundColor3=invisibleEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,0)
    playSound(invisibleEnabled)
    setInvisible(invisibleEnabled)
end)

-- ======== ESP TAB ========
local esp=tabs[lang("ESP","ESP")].Frame
local espEnabled=false
local bestEspEnabled=false
local redDotEnabled=false
local highlights={}
local redDots={}

-- Rainbow Highlight ESP
local espButton=Instance.new("TextButton")
espButton.Size=UDim2.new(0,150,0,40)
espButton.Position=UDim2.new(0,10,0,10)
espButton.Text=lang("ESP Players: OFF","ESP اللاعبين: إيقاف")
espButton.BackgroundColor3=Color3.fromRGB(0,0,0)
espButton.TextColor3=Color3.fromRGB(255,215,0)
espButton.BorderColor3=Color3.fromRGB(255,215,0)
espButton.BorderSizePixel=2
espButton.Parent=esp

local function createHighlight(plr,color)
    if plr.Character and not highlights[plr] then
        local hl=Instance.new("Highlight")
        hl.Adornee=plr.Character
        hl.FillTransparency=0.6
        hl.OutlineTransparency=0.5
        hl.FillColor=color or Color3.fromRGB(255,0,0)
        hl.OutlineColor=color or Color3.fromRGB(255,0,0)
        hl.Parent=Workspace
        highlights[plr]=hl
    end
end

local function removeHighlights()
    for _, hl in pairs(highlights) do if hl then hl:Destroy() end end
    highlights={}
end

espButton.MouseButton1Click:Connect(function()
    espEnabled=not espEnabled
    espButton.Text=espEnabled and lang("ESP Players: ON","ESP اللاعبين: تشغيل") or lang("ESP Players: OFF","ESP اللاعبين: إيقاف")
    espButton.BackgroundColor3=espEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,0)
    playSound(espEnabled)
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p~=player then createHighlight(p) end
        end
    else
        removeHighlights()
    end
end)

-- RedDot ESP
local redDotButton=Instance.new("TextButton")
redDotButton.Size=UDim2.new(0,150,0,40)
redDotButton.Position=UDim2.new(0,10,0,60)
redDotButton.Text=lang("RedDot ESP: OFF","نقطة اللاعبين: إيقاف")
redDotButton.BackgroundColor3=Color3.fromRGB(0,0,0)
redDotButton.TextColor3=Color3.fromRGB(255,215,0)
redDotButton.BorderColor3=Color3.fromRGB(255,215,0)
redDotButton.BorderSizePixel=2
redDotButton.Parent=esp

redDotButton.MouseButton1Click:Connect(function()
    redDotEnabled=not redDotEnabled
    redDotButton.Text=redDotEnabled and lang("RedDot ESP: ON","نقطة اللاعبين: تشغيل") or lang("RedDot ESP: OFF","نقطة اللاعبين: إيقاف")
    redDotButton.BackgroundColor3=redDotEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,0)
    playSound(redDotEnabled)
end)

-- Best Brainrot ESP
local bestBrainrotButton=Instance.new("TextButton")
bestBrainrotButton.Size=UDim2.new(0,150,0,40)
bestBrainrotButton.Position=UDim2.new(0,10,0,110)
bestBrainrotButton.Text=lang("Best Brainrot ESP: OFF","أفضل ESP: إيقاف")
bestBrainrotButton.BackgroundColor3=Color3.fromRGB(0,0,0)
bestBrainrotButton.TextColor3=Color3.fromRGB(255,215,0)
bestBrainrotButton.BorderColor3=Color3.fromRGB(255,215,0)
bestBrainrotButton.BorderSizePixel=2
bestBrainrotButton.Parent=esp

local brainrotValues={
    ["Brainrot God"]=1000000,
    ["La Vacca Staturno Saturnita"]=500000,
    ["Nuclearo Dinossauro"]=250000,
}

local function highlightBestBrainrot()
    local bestValue=0
    local bestPlayer=nil
    for _, p in pairs(Players:GetPlayers()) do
        if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local val=brainrotValues[p.Name] or 0
            if val>bestValue then bestValue=val bestPlayer=p end
        end
    end
    if bestPlayer then createHighlight(bestPlayer,Color3.fromRGB(255,255,255)) end
end

bestBrainrotButton.MouseButton1Click:Connect(function()
    bestEspEnabled=not bestEspEnabled
    bestBrainrotButton.Text=bestEspEnabled and lang("Best Brainrot ESP: ON","أفضل ESP: تشغيل") or lang("Best Brainrot ESP: OFF","أفضل ESP: إيقاف")
    bestBrainrotButton.BackgroundColor3=bestEspEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,0)
    playSound(bestEspEnabled)
    if bestEspEnabled then highlightBestBrainrot() else removeHighlights() end
end)

-- تحديث رينبو ESP و RedDot
RunService.RenderStepped:Connect(function()
    local hue=tick()%1
    local rainbowColor=Color3.fromHSV(hue,1,1)
    for _, hl in pairs(highlights) do
        if hl then hl.FillColor=rainbowColor; hl.OutlineColor=rainbowColor end
    end
    if redDotEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dot=redDots[p]
                if not dot then
                    dot=Instance.new("BillboardGui")
                    dot.Size=UDim2.new(0,10,0,10)
                    dot.Adornee=p.Character.HumanoidRootPart
                    dot.AlwaysOnTop=true
                    local frame=Instance.new("Frame")
                    frame.Size=UDim2.new(1,0,1,0)
                    frame.BackgroundColor3=rainbowColor
                    frame.BorderSizePixel=0
                    frame.Parent=dot
                    dot.Parent=Workspace
                    redDots[p]=dot
                else
                    if dot:FindFirstChildOfClass("Frame") then
                        dot:FindFirstChildOfClass("Frame").BackgroundColor3=rainbowColor
                    end
                end
            end
        end
    else
        for _, d in pairs(redDots) do if d then d:Destroy() end end
        redDots={}
    end
end)

Players.PlayerAdded:Connect(function(p)
    if espEnabled and p~=player then createHighlight(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then highlights[p]:Destroy(); highlights[p]=nil end
    if redDots[p] then redDots[p]:Destroy(); redDots[p]=nil end
end)

-- ======== SERVER TAB ========
local server=tabs[lang("Server","السيرفر")].Frame

local rejoinButton=Instance.new("TextButton")
rejoinButton.Size=UDim2.new(0,150,0,40)
rejoinButton.Position=UDim2.new(0,10,0,10)
rejoinButton.Text=lang("Rejoin","إعادة الدخول")
rejoinButton.BackgroundColor3=Color3.fromRGB(0,0,0)
rejoinButton.TextColor3=Color3.fromRGB(255,215,0)
rejoinButton.BorderColor3=Color3.fromRGB(255,215,0)
rejoinButton.BorderSizePixel=2
rejoinButton.Parent=server
rejoinButton.MouseButton1Click:Connect(function()
    playSound(true)
    TeleportService:Teleport(game.PlaceId,player)
end)

local teleportButton=Instance.new("TextButton")
teleportButton.Size=UDim2.new(0,150,0,40)
teleportButton.Position=UDim2.new(0,10,0,60)
teleportButton.Text=lang("Teleport to New Server","الانتقال لسيرفر جديد")
teleportButton.BackgroundColor3=Color3.fromRGB(0,0,0)
teleportButton.TextColor3=Color3.fromRGB(255,215,0)
teleportButton.BorderColor3=Color3.fromRGB(255,215,0)
teleportButton.BorderSizePixel=2
teleportButton.Parent=server
teleportButton.MouseButton1Click:Connect(function()
    playSound(true)
    local servers={}
    local success,data=pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and data and data.data then
        for _,v in pairs(data.data) do
            if v.id~=game.JobId and v.playing<v.maxPlayers then
                table.insert(servers,v.id)
            end
        end
    end
    if #servers>0 then
        local newServer=servers[math.random(1,#servers)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId,newServer,player)
    end
end)

-- ======== SETTINGS TAB ========
local settings=tabs[lang("Settings","الإعدادات")].Frame
local langButton=Instance.new("TextButton")
langButton.Size=UDim2.new(0,150,0,40)
langButton.Position=UDim2.new(0,10,0,10)
langButton.Text=lang("Language: EN","اللغة: الإنجليزية")
langButton.BackgroundColor3=Color3.fromRGB(0,0,0)
langButton.TextColor3=Color3.fromRGB(255,215,0)
langButton.BorderColor3=Color3.fromRGB(255,215,0)
langButton.BorderSizePixel=2
langButton.Parent=settings
langButton.MouseButton1Click:Connect(function()
    if language=="EN" then language="AR" else language="EN" end
    langButton.Text=language=="EN" and "Language: EN" or "اللغة: العربية"
    -- تحديث كل التبويبات والنصوص
    toggleButton.Text=language=="EN" and "سكربت ابو الصوف" or "سكربت ابو الصوف"
    tabs[lang("Home","الرئيسية")].Button.Text=lang("Home","الرئيسية")
    tabs[lang("ESP","ESP")].Button.Text=lang("ESP","ESP")
    tabs[lang("Server","السيرفر")].Button.Text=lang("Server","السيرفر")
    tabs[lang("Settings","الإعدادات")].Button.Text=lang("Settings","الإعدادات")
    flyButton.Text=flyEnabled and lang("Fly (Jump Power): ON","طيران: تشغيل") or lang("Fly (Jump Power): OFF","طيران: إيقاف")
    speedButton.Text=speedEnabled and lang("Speed Boost: ON","زيادة السرعة: تشغيل") or lang("Speed Boost: OFF","زيادة السرعة: إيقاف")
    autoClickButton.Text=autoClickEnabled and lang("Laser Click: ON","ضغط الليزر: تشغيل") or lang("Laser Click: OFF","ضغط الليزر: إيقاف")
    invisibleButton.Text=invisibleEnabled and lang("Invisible Man: ON","الاختفاء: تشغيل") or lang("Invisible Man: OFF","الاختفاء: إيقاف")
    espButton.Text=espEnabled and lang("ESP Players: ON","ESP اللاعبين: تشغيل") or lang("ESP Players: OFF","ESP اللاعبين: إيقاف")
    redDotButton.Text=redDotEnabled and lang("RedDot ESP: ON","نقطة اللاعبين: تشغيل") or lang("RedDot ESP: OFF","نقطة اللاعبين: إيقاف")
    bestBrainrotButton.Text=bestEspEnabled and lang("Best Brainrot ESP: ON","أفضل ESP: تشغيل") or lang("Best Brainrot ESP: OFF","أفضل ESP: إيقاف")
    rejoinButton.Text=lang("Rejoin","إعادة الدخول")
    teleportButton.Text=lang("Teleport to New Server","الانتقال لسيرفر جديد")
end)

-- فتح تبويب Home افتراضياً
tabs[lang("Home","الرئيسية")].Frame.Visible=true
