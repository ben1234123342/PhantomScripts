-- [[ PHANTOM SCRIPTS - WAR TYCOON ELITE V5 ]] --
-- Universal Reversal: Separate Aimbot & Silent Aim, Wallbang (Shoot Through Walls), Visibles-Only Auto Buy with Cooldown
-- PlaceId: 4639625707 | Targeted Remotes: BulletFireSystem & ACS_Engine | 100% English UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Character Resolution
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 5) or Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid", 5) or Character:FindFirstChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid", 5) or char:FindFirstChild("Humanoid")
end)

-- Safe UI Cleanup & Resolution
local function GetSafeGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    return LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

local guiParent = GetSafeGuiParent()
for _, oldName in ipairs({"PhantomWarTycoon_UI", "PhantomWarTycoon_FOV", "PhantomWarTycoon_ESP", "PhantomWarTycoon_Crates"}) do
    local old = guiParent:FindFirstChild(oldName)
    if not old and LocalPlayer:FindFirstChild("PlayerGui") then
        old = LocalPlayer.PlayerGui:FindFirstChild(oldName)
    end
    if old then pcall(function() old:Destroy() end) end
end

-- ==================== TARGETED WEAPON & GAME REMOTES ====================
local BFS = ReplicatedStorage:FindFirstChild("BulletFireSystem")
local ACS = ReplicatedStorage:FindFirstChild("ACS_Engine")
local ACSEvents = ACS and ACS:FindFirstChild("Events")
local RS = ReplicatedStorage:FindFirstChild("RocketSystem")
local RSEvents = RS and RS:FindFirstChild("Events")
local KnitBase = nil
local KnitMunition = nil
local KnitCrate = nil

pcall(function()
    local sPath = ReplicatedStorage.Packages.Knit.Services
    KnitBase = sPath.BaseService
    KnitMunition = sPath.MunitionService
    KnitCrate = sPath.CrateService
end)

local RocketEvents = {
    FireRocket = RSEvents and RSEvents:FindFirstChild("FireRocket"),
    ReloadRocket = RSEvents and RSEvents:FindFirstChild("ReloadRocket"),
    FireRocketFX = RSEvents and RSEvents:FindFirstChild("FireRocketFX"),
    FireRocketReplicated = RSEvents and RSEvents:FindFirstChild("FireRocketReplicated"),
    RocketBulletHit = RSEvents and RSEvents:FindFirstChild("RocketBulletHit"),
    RocketHit = RSEvents and RSEvents:FindFirstChild("RocketHit"),
    RocketReloadedFX = RSEvents and RSEvents:FindFirstChild("RocketReloadedFX"),
    ExplosionShake = RSEvents and RSEvents:FindFirstChild("ExplosionShake"),
    JamRocket = RSEvents and RSEvents:FindFirstChild("JamRocket"),
    LockOnWarn = RSEvents and RSEvents:FindFirstChild("LockOnWarn"),
    WirePos = RSEvents and RSEvents:FindFirstChild("WirePos")
}

local WeaponEvents = {
    -- BulletFireSystem Remotes
    FireGun = BFS and BFS:FindFirstChild("FireGun"),
    BulletFired = BFS and BFS:FindFirstChild("BulletFired"),
    GunReload = BFS and BFS:FindFirstChild("GunReload"),
    BulletHit = BFS and BFS:FindFirstChild("BulletHit"),
    ObjectShot = BFS and BFS:FindFirstChild("ObjectShot"),
    RegisterTurretHit = BFS and BFS:FindFirstChild("RegisterTurretHit"),
    FireBeam = BFS and BFS:FindFirstChild("FireBeam"),

    -- ACS Engine Remotes
    AcsHit = ACSEvents and ACSEvents:FindFirstChild("Hit"),
    AcsDamage = ACSEvents and ACSEvents:FindFirstChild("Damage"),
    AcsReload = ACSEvents and ACSEvents:FindFirstChild("Reload"),
    AcsServerBullet = ACSEvents and ACSEvents:FindFirstChild("ServerBullet"),

    -- Tycoon & Crate Remotes
    ButtonTouched = KnitBase and KnitBase:FindFirstChild("RE") and KnitBase.RE:FindFirstChild("ButtonTouched"),
    DefaultExtractor = KnitBase and KnitBase:FindFirstChild("RE") and KnitBase.RE:FindFirstChild("DefaultExtractorTrigger"),
    RequestButtonList = KnitBase and KnitBase:FindFirstChild("RF") and KnitBase.RF:FindFirstChild("RequestBaseButtonList"),
    RequestSteal = KnitMunition and KnitMunition:FindFirstChild("RF") and KnitMunition.RF:FindFirstChild("RequestSteal"),
    OpenCrate = KnitCrate and KnitCrate:FindFirstChild("RF") and KnitCrate.RF:FindFirstChild("OpenCrate"),
    UnweldCrate = ReplicatedStorage:FindFirstChild("TankCrates") and ReplicatedStorage.TankCrates:FindFirstChild("UnweldCrate")
}

local HeavyEvents = {
    MissileStrike = nil,
    AirstrikeCall = nil,
    AirstrikeWarn = nil,
    TurretFire = nil,
    FireTurret = nil,
    FireTurretEnd = nil,
    ClaimBase = nil
}

for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
        if d.Name == "ButtonTouched" and not WeaponEvents.ButtonTouched then WeaponEvents.ButtonTouched = d end
        if d.Name == "DefaultExtractorTrigger" and not WeaponEvents.DefaultExtractor then WeaponEvents.DefaultExtractor = d end
        if d.Name == "RequestBaseButtonList" and not WeaponEvents.RequestButtonList then WeaponEvents.RequestButtonList = d end
        if d.Name == "RequestSteal" and not WeaponEvents.RequestSteal then WeaponEvents.RequestSteal = d end
        if d.Name == "OpenCrate" and not WeaponEvents.OpenCrate then WeaponEvents.OpenCrate = d end
        if d.Name == "FireGun" and not WeaponEvents.FireGun then WeaponEvents.FireGun = d end
        if d.Name == "BulletHit" and not WeaponEvents.BulletHit then WeaponEvents.BulletHit = d end
        if d.Name == "GunReload" and not WeaponEvents.GunReload then WeaponEvents.GunReload = d end
        if d.Name == "FireRocket" and not RocketEvents.FireRocket then RocketEvents.FireRocket = d end
        if d.Name == "RocketHit" and not RocketEvents.RocketHit then RocketEvents.RocketHit = d end
        if d.Name == "RocketBulletHit" and not RocketEvents.RocketBulletHit then RocketEvents.RocketBulletHit = d end
        if d.Name == "FireRocketFX" and not RocketEvents.FireRocketFX then RocketEvents.FireRocketFX = d end
        if d.Name == "MissileStrike" and not HeavyEvents.MissileStrike then HeavyEvents.MissileStrike = d end
        if d.Name == "AirstrikeCall" and not HeavyEvents.AirstrikeCall then HeavyEvents.AirstrikeCall = d end
        if d.Name == "AirstrikeWarn" and not HeavyEvents.AirstrikeWarn then HeavyEvents.AirstrikeWarn = d end
        if d.Name == "TurretFire" and not HeavyEvents.TurretFire then HeavyEvents.TurretFire = d end
        if d.Name == "FireTurret" and not HeavyEvents.FireTurret then HeavyEvents.FireTurret = d end
        if d.Name == "FireTurretEnd" and not HeavyEvents.FireTurretEnd then HeavyEvents.FireTurretEnd = d end
        if d.Name == "ObjectShot" and not WeaponEvents.ObjectShot then WeaponEvents.ObjectShot = d end
        if d.Name == "BulletFired" and not WeaponEvents.BulletFired then WeaponEvents.BulletFired = d end
        if d.Name == "ClaimBase" and not HeavyEvents.ClaimBase then HeavyEvents.ClaimBase = d end
    end
end

-- ==================== STATE CONFIGURATION ====================
local State = {
    -- Aim & Combat (Separate Aimbot & Silent Aim)
    CameraAimbot = false,
    SilentAim = true,
    Wallbang = true,
    AimKey = Enum.UserInputType.MouseButton2,
    AimTargetPart = "Head", -- "Head" or "HumanoidRootPart"
    AimFov = 150,
    AimSmooth = 3,
    DrawFov = true,
    TeamCheck = true,
    AimMaxDist = 1500,

    -- Visuals & ESP (Second Priority)
    Chams = true,
    PlayerESP = true,
    ShowDistance = true,
    ShowHealth = true,
    CrateESP = true,
    ESPDistance = 1500,

    -- Weapon Modifications
    InfiniteAmmo = true,
    RapidFire = false,
    NoRecoil = false,
    NoSpread = false,

    -- Tycoon Automation (Visibles only + Cooldown)
    AutoBuyProximity = false,
    AutoBuyStepTP = false,
    AutoBuyVisibleOnly = true,
    AutoExtractor = true,
    BuyCooldown = 0.4,
    BuyRadius = 250,

    -- Crates & Munitions
    AutoStealCrates = false,
    AutoInstantPrompts = true,
    StealRadius = 120,

    -- Movement & Flight
    Fly = false,
    FlySpeed = 150,
    Noclip = false,
    NoclipSpeed = 52,
    SpeedHack = false,
    WalkSpeed = 26,
    InfJump = false,
    NoFallDamage = true
}

local LastRocketFireTick = 0
local LastMissileStrikeTick = 0
local LastAirstrikeTick = 0

local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3.5
        })
    end)
end

-- ==================== THEME CONFIGURATION (0x0E0E12 / 0xF962FA) ====================
local C = {
    Bg = Color3.fromRGB(14, 14, 18),
    Card = Color3.fromRGB(20, 20, 26),
    CardBorder = Color3.fromRGB(32, 32, 42),
    Accent = Color3.fromRGB(249, 98, 250),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(140, 140, 155),
    Border = Color3.fromRGB(249, 98, 250),
    Active = Color3.fromRGB(34, 31, 44),
    Green = Color3.fromRGB(50, 215, 75),
    Red = Color3.fromRGB(255, 69, 58),
    Gold = Color3.fromRGB(255, 215, 0)
}

-- ==================== SCREEN GUI & FOV CIRCLE ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomWarTycoon_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = true
ScreenGui.Parent = guiParent

local FovGui = Instance.new("ScreenGui")
FovGui.Name = "PhantomWarTycoon_FOV"
FovGui.ResetOnSpawn = false
FovGui.DisplayOrder = 9998
FovGui.Parent = guiParent

local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircle"
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.Size = UDim2.new(0, State.AimFov * 2, 0, State.AimFov * 2)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = State.DrawFov and (State.CameraAimbot or State.SilentAim)
FovCircle.Parent = FovGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovCircle

local FovStroke = Instance.new("UIStroke")
FovStroke.Color = C.Accent
FovStroke.Thickness = 1.2
FovStroke.Transparency = 0.3
FovStroke.Parent = FovCircle

RunService.RenderStepped:Connect(function()
    FovCircle.Visible = State.DrawFov and (State.CameraAimbot or State.SilentAim)
    if FovCircle.Visible then
        local mousePos = UserInputService:GetMouseLocation()
        FovCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
        FovCircle.Size = UDim2.new(0, State.AimFov * 2, 0, State.AimFov * 2)
    end
end)

-- Main Menu Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 720, 0, 485)
Main.Position = UDim2.new(0.5, -360, 0.5, -242)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = C.Border
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.25
MainStroke.Parent = Main

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundColor3 = C.Card
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarFill = Instance.new("Frame")
TopBarFill.Name = "TopBarFill"
TopBarFill.Size = UDim2.new(1, 0, 0, 12)
TopBarFill.Position = UDim2.new(0, 0, 1, -12)
TopBarFill.BackgroundColor3 = C.Card
TopBarFill.BorderSizePixel = 0
TopBarFill.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 230, 0, 22)
Title.Position = UDim2.new(0, 16, 0, 5)
Title.BackgroundTransparency = 1
Title.TextColor3 = C.Accent
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13.5
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "PHANTOM · WAR TYCOON"
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Size = UDim2.new(0, 240, 0, 16)
Subtitle.Position = UDim2.new(0, 16, 0, 25)
Subtitle.BackgroundTransparency = 1
Subtitle.TextColor3 = C.TextDim
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 9.5
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Text = "Wallbang · Silent Aim · Clean Auto Buy"
Subtitle.Parent = TopBar

-- Navigation Tabs Container (AIM and ESP First!)
local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(0, 440, 0, 30)
NavContainer.Position = UDim2.new(1, -450, 0, 8)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = TopBar

local NavLayout = Instance.new("UIListLayout")
NavLayout.FillDirection = Enum.FillDirection.Horizontal
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 4)
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NavLayout.Parent = NavContainer

local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -24, 1, -60)
PageContainer.Position = UDim2.new(0, 12, 0, 52)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = Main

local Tabs = {"AIMBOT", "VISUALS", "WEAPONS", "TYCOON", "CRATES", "MOVEMENT", "MISC"}
local TabButtons = {}
local PageFrames = {}

for i, tabName in ipairs(Tabs) do
    local tb = Instance.new("TextButton")
    tb.Name = tabName
    tb.Size = UDim2.new(0, 57, 1, 0)
    tb.BackgroundColor3 = (i == 1) and C.Active or C.Card
    tb.TextColor3 = (i == 1) and C.Accent or C.TextDim
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 9.5
    tb.Text = tabName
    tb.BorderSizePixel = 0
    tb.Parent = NavContainer

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 6)
    tc.Parent = tb

    local ts = Instance.new("UIStroke")
    ts.Color = (i == 1) and C.Accent or C.CardBorder
    ts.Thickness = 1
    ts.Parent = tb

    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "_Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.Accent
    page.Visible = (i == 1)
    page.AutomaticCanvasSize = Enum.AutomaticSize.X
    page.CanvasSize = UDim2.new(0, 0, 0, 480)
    page.Parent = PageContainer

    local pLayout = Instance.new("UIListLayout")
    pLayout.FillDirection = Enum.FillDirection.Horizontal
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 10)
    pLayout.Parent = page

    TabButtons[tabName] = { Button = tb, Stroke = ts }
    PageFrames[tabName] = page

    tb.MouseButton1Click:Connect(function()
        for tKey, tObj in pairs(TabButtons) do
            local sel = (tKey == tabName)
            tObj.Button.BackgroundColor3 = sel and C.Active or C.Card
            tObj.Button.TextColor3 = sel and C.Accent or C.TextDim
            tObj.Stroke.Color = sel and C.Accent or C.CardBorder
            PageFrames[tKey].Visible = sel
        end
    end)
end

-- UI Builder Components
local function CreateCard(parent, titleText)
    local card = Instance.new("Frame")
    card.Name = titleText .. "_Card"
    card.Size = UDim2.new(0, 340, 0, 465)
    card.BackgroundColor3 = C.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 8)
    cc.Parent = card

    local cs = Instance.new("UIStroke")
    cs.Color = C.CardBorder
    cs.Thickness = 1
    cs.Parent = card

    local cTitle = Instance.new("TextLabel")
    cTitle.Name = "CardTitle"
    cTitle.Size = UDim2.new(1, -20, 0, 24)
    cTitle.Position = UDim2.new(0, 12, 0, 8)
    cTitle.BackgroundTransparency = 1
    cTitle.TextColor3 = C.Text
    cTitle.Font = Enum.Font.GothamBold
    cTitle.TextSize = 11
    cTitle.TextXAlignment = Enum.TextXAlignment.Left
    cTitle.Text = titleText:upper()
    cTitle.Parent = card

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -40)
    content.Position = UDim2.new(0, 10, 0, 34)
    content.BackgroundTransparency = 1
    content.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content

    return content
end

local function AddToggle(parent, labelText, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = C.Bg
    row.BorderSizePixel = 0
    row.Parent = parent

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -55, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10.5
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = labelText
    lbl.Parent = row

    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(0, 38, 0, 18)
    tBtn.Position = UDim2.new(1, -44, 0.5, -9)
    tBtn.BackgroundColor3 = defaultVal and C.Accent or C.Card
    tBtn.Text = ""
    tBtn.BorderSizePixel = 0
    tBtn.Parent = row

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = tBtn

    local tBall = Instance.new("Frame")
    tBall.Size = UDim2.new(0, 14, 0, 14)
    tBall.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    tBall.BackgroundColor3 = C.Text
    tBall.BorderSizePixel = 0
    tBall.Parent = tBtn

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = tBall

    local val = defaultVal
    tBtn.MouseButton1Click:Connect(function()
        val = not val
        TweenService:Create(tBtn, TweenInfo.new(0.18), {BackgroundColor3 = val and C.Accent or C.Card}):Play()
        TweenService:Create(tBall, TweenInfo.new(0.18), {Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        callback(val)
    end)
    return row
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = C.Card
    btn.TextColor3 = C.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10.5
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = C.CardBorder
    bs.Thickness = 1
    bs.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.Accent, TextColor3 = C.Bg}):Play()
        task.delay(0.15, function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.Card, TextColor3 = C.Text}):Play()
        end)
        callback()
    end)
    return btn
end

local function AddSlider(parent, labelText, minVal, maxVal, defaultVal, suffix, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = C.Bg
    row.BorderSizePixel = 0
    row.Parent = parent

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = labelText
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 18)
    valLbl.Position = UDim2.new(1, -68, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = C.Accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 10
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = tostring(defaultVal) .. (suffix or "")
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 26)
    track.BackgroundColor3 = C.Card
    track.BorderSizePixel = 0
    track.Parent = row

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = track

    local fill = Instance.new("Frame")
    local pct = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local sliding = false
    local function UpdateSlide(xPos)
        local rel = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLbl.Text = tostring(value) .. (suffix or "")
        callback(value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateSlide(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlide(input.Position.X)
        end
    end)
    return row
end

-- ==================== TAB 1: AIMBOT (SEPARATE AIMBOT & SILENT AIM + WALLBANG) ====================
local function GetClosestEnemy(ignoreWalls)
    local mousePos = UserInputService:GetMouseLocation()
    local bestTarget = nil
    local bestDist = State.AimFov
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position or Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local sameTeam = (LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team)
            if not (State.TeamCheck and sameTeam) then
                local part = plr.Character:FindFirstChild(State.AimTargetPart) or plr.Character:FindFirstChild("Head")
                if part then
                    local worldDist = (part.Position - myPos).Magnitude
                    if worldDist <= State.AimMaxDist then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen and screenPos.Z > 0 then
                            local canHit = true
                            if not ignoreWalls then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = {myChar, plr.Character, Camera}
                                local res = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
                                if res then canHit = false end
                            end

                            if canHit then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist < bestDist then
                                    bestDist = dist
                                    bestTarget = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

do
    local cLeft = CreateCard(PageFrames["AIMBOT"], "Aim Modes & Wallbang")
    AddToggle(cLeft, "Camera Aimbot (RMB Lock-On)", State.CameraAimbot, function(v)
        State.CameraAimbot = v
        if v then notify("Aimbot", "Camera tracking active on RMB.") end
    end)
    AddToggle(cLeft, "Silent Aim (Hit Redirection)", State.SilentAim, function(v)
        State.SilentAim = v
        if v then notify("Silent Aim", "Silent Hit Redirection ENABLED.") end
    end)
    AddToggle(cLeft, "Wallbang (Shoot Through Walls)", State.Wallbang, function(v)
        State.Wallbang = v
        if v then notify("Wallbang", "Wallbang ENABLED! Hits penetrate all walls.") end
    end)
    AddToggle(cLeft, "Draw FOV Circle", State.DrawFov, function(v) State.DrawFov = v end)
    AddSlider(cLeft, "FOV Radius", 40, 450, State.AimFov, "px", function(v) State.AimFov = v end)
    AddSlider(cLeft, "Camera Smoothness", 1, 20, State.AimSmooth, "", function(v) State.AimSmooth = v end)

    local cRight = CreateCard(PageFrames["AIMBOT"], "Targeting & Configuration")
    AddButton(cRight, "Target Bone: HEAD", function()
        State.AimTargetPart = "Head"
        notify("Combat", "Aim target set to HEAD.")
    end)
    AddButton(cRight, "Target Bone: TORSO", function()
        State.AimTargetPart = "HumanoidRootPart"
        notify("Combat", "Aim target set to TORSO.")
    end)
    AddToggle(cRight, "Team Check (Ignore Allies)", State.TeamCheck, function(v) State.TeamCheck = v end)
    AddSlider(cRight, "Max Target Distance", 100, 3000, State.AimMaxDist, " studs", function(v) State.AimMaxDist = v end)

    local infoRow = Instance.new("Frame")
    infoRow.Size = UDim2.new(1, 0, 0, 110)
    infoRow.BackgroundColor3 = C.Bg
    infoRow.BorderSizePixel = 0
    infoRow.Parent = cRight

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 6)
    infoCorner.Parent = infoRow

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -16, 1, -10)
    infoText.Position = UDim2.new(0, 10, 0, 5)
    infoText.BackgroundTransparency = 1
    infoText.TextColor3 = C.Text
    infoText.Font = Enum.Font.Code
    infoText.TextSize = 10
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Text = [[STATUS:
- Camera Aimbot: Separate (Smooth RMB)
- Silent Aim: Separate (Fires on shot)
- Wallbang: ACTIVE (Penetrates bases & walls)
- Target: BulletFireSystem & ACS_Engine]]
    infoText.Parent = infoRow
end

-- Camera Aimbot Lerp Loop (Only if CameraAimbot is enabled)
RunService.RenderStepped:Connect(function()
    if State.CameraAimbot and UserInputService:IsMouseButtonPressed(State.AimKey) then
        local target = GetClosestEnemy(State.Wallbang)
        if target then
            local targetPos = target.Position
            local camPos = Camera.CFrame.Position
            local targetLook = CFrame.new(camPos, targetPos)
            local smooth = math.clamp(1 / State.AimSmooth, 0.05, 1)
            Camera.CFrame = Camera.CFrame:Lerp(targetLook, smooth)
        end
    end
end)

-- ==================== TAB 2: VISUALS (SECOND TAB) ====================
local EspFolder = Instance.new("Folder")
EspFolder.Name = "PhantomWarTycoon_ESP"
EspFolder.Parent = guiParent

local VisualCache = {}
local function CleanupVisual(obj)
    if VisualCache[obj] then
        if VisualCache[obj].Billboard then VisualCache[obj].Billboard:Destroy() end
        if VisualCache[obj].Highlight then VisualCache[obj].Highlight:Destroy() end
        VisualCache[obj] = nil
    end
end
Players.PlayerRemoving:Connect(CleanupVisual)

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position or Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local pRoot = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if char and pRoot and hum and hum.Health > 0 then
                local dist = math.floor((pRoot.Position - myPos).Magnitude)
                local inRange = (dist <= State.ESPDistance)
                local isEnemy = not (LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team)
                local eColor = isEnemy and C.Red or C.Green

                if not VisualCache[plr] then VisualCache[plr] = {} end
                local cache = VisualCache[plr]

                -- Chams
                if State.Chams and inRange then
                    if not cache.Highlight or cache.Highlight.Parent ~= char then
                        if cache.Highlight then cache.Highlight:Destroy() end
                        local hl = Instance.new("Highlight")
                        hl.Name = "Phantom_Highlight"
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                        cache.Highlight = hl
                    end
                    cache.Highlight.Enabled = true
                    cache.Highlight.FillColor = eColor
                    cache.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    cache.Highlight.FillTransparency = 0.45
                elseif cache.Highlight then
                    cache.Highlight.Enabled = false
                end

                -- Billboard ESP
                if State.PlayerESP and inRange then
                    if not cache.Billboard or cache.Billboard.Parent ~= EspFolder then
                        if cache.Billboard then cache.Billboard:Destroy() end
                        local bbg = Instance.new("BillboardGui")
                        bbg.Adornee = pRoot
                        bbg.Size = UDim2.new(0, 160, 0, 45)
                        bbg.StudsOffset = Vector3.new(0, 3.5, 0)
                        bbg.AlwaysOnTop = true
                        bbg.Parent = EspFolder

                        local nLbl = Instance.new("TextLabel")
                        nLbl.Name = "Name"
                        nLbl.Size = UDim2.new(1, 0, 0, 16)
                        nLbl.BackgroundTransparency = 1
                        nLbl.TextSize = 11
                        nLbl.Font = Enum.Font.GothamBold
                        nLbl.Parent = bbg

                        local dLbl = Instance.new("TextLabel")
                        dLbl.Name = "Dist"
                        dLbl.Size = UDim2.new(1, 0, 0, 14)
                        dLbl.Position = UDim2.new(0, 0, 0, 16)
                        dLbl.BackgroundTransparency = 1
                        dLbl.TextSize = 10
                        dLbl.Font = Enum.Font.GothamBold
                        dLbl.Parent = bbg

                        cache.Billboard = bbg
                    end

                    cache.Billboard.Enabled = true
                    local nLbl = cache.Billboard:FindFirstChild("Name")
                    local dLbl = cache.Billboard:FindFirstChild("Dist")
                    if nLbl then
                        nLbl.TextColor3 = eColor
                        nLbl.Text = string.format("[%s] %s", isEnemy and "ENEMY" or "ALLY", plr.DisplayName)
                    end
                    if dLbl then
                        dLbl.TextColor3 = C.TextDim
                        dLbl.Text = string.format("%d studs · HP: %d", dist, math.floor(hum.Health))
                    end
                elseif cache.Billboard then
                    cache.Billboard.Enabled = false
                end
            else
                CleanupVisual(plr)
            end
        end
    end
end)

-- Fast Crate ESP
local CrateEspFolder = Instance.new("Folder")
CrateEspFolder.Name = "PhantomWarTycoon_Crates"
CrateEspFolder.Parent = guiParent

local function UpdateCrateESP()
    CrateEspFolder:ClearAllChildren()
    if not State.CrateESP then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = root and root.Position or Camera.CFrame.Position

    local parts = {}
    if workspace.GetPartBoundsInRadius then
        parts = workspace:GetPartBoundsInRadius(myPos, math.min(State.ESPDistance, 600), nil)
    end

    local drawn = {}
    for _, p in ipairs(parts) do
        local parent = p.Parent
        local n = (parent and parent.Name or p.Name):lower()
        if (n:match("crate") or n:match("barrel") or n:match("airdrop") or n:match("munition")) and not drawn[parent or p] then
            drawn[parent or p] = true
            local dist = math.floor((p.Position - myPos).Magnitude)
            local bbg = Instance.new("BillboardGui")
            bbg.Adornee = p
            bbg.Size = UDim2.new(0, 140, 0, 30)
            bbg.StudsOffset = Vector3.new(0, 2.5, 0)
            bbg.AlwaysOnTop = true
            bbg.Parent = CrateEspFolder

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.TextColor3 = C.Gold
            l.TextSize = 11
            l.Font = Enum.Font.GothamBold
            l.Text = string.format("[CRATE / DROP]\n%d studs", dist)
            l.Parent = bbg
        end
    end
end

task.spawn(function()
    while true do
        pcall(UpdateCrateESP)
        task.wait(1.5)
    end
end)

do
    local cLeft = CreateCard(PageFrames["VISUALS"], "Visual Overlays")
    AddToggle(cLeft, "Chams (Wallhack Silhouette)", State.Chams, function(v) State.Chams = v end)
    AddToggle(cLeft, "Player Billboard ESP", State.PlayerESP, function(v) State.PlayerESP = v end)
    AddToggle(cLeft, "Supply Crate & Airdrop ESP", State.CrateESP, function(v) State.CrateESP = v end)
    AddSlider(cLeft, "ESP Max Distance", 200, 3000, State.ESPDistance, " studs", function(v) State.ESPDistance = v end)
end

-- ==================== TAB 3: WEAPONS (TARGETED EVENTS & WALLBANG HOOK) ====================
local function IsSafeWeaponConfig(mod)
    if not mod or not mod:IsA("ModuleScript") then return false end
    local name = mod.Name:lower()
    -- NEVER touch core engine, raycasting or network modules
    if name:match("client") or name:match("server") or name:match("signal") or name:match("fastcast") or name:match("framework") or name:match("spring") or name:match("caster") or name:match("network") or name:match("sound") or name:match("ui") or name:match("camera") then
        return false
    end
    -- Must be inside a Tool or explicitly named Config/Setting
    if mod:FindFirstAncestorOfClass("Tool") then
        return true
    end
    if name:match("setting") or name:match("config") then
        return true
    end
    return false
end

local function DeepPatchWeaponTable(t)
    if type(t) ~= "table" then return false end
    -- Guard: If this is an engine class (FastCast / FireModule / Caster), DO NOT TOUCH!
    if rawget(t, "Fire") or rawget(t, "Caster") or rawget(t, "OnRayHit") or rawget(t, "RayHit") or rawget(t, "Signal") or rawget(t, "Handlers") then
        return false
    end
    local patched = false
    if State.RapidFire then
        if type(t.RPM) == "number" then t.RPM = 999999; patched = true end
        if type(t.FireRate) == "number" then t.FireRate = 999999; patched = true end
        if type(t.ShootRate) == "number" then t.ShootRate = 0; patched = true end
        if type(t.ShootDelay) == "number" then t.ShootDelay = 0; patched = true end
        if type(t.Cooldown) == "number" then t.Cooldown = 0; patched = true end
        if type(t.Debounce) == "boolean" then t.Debounce = false; patched = true end
        if type(t.Auto) == "boolean" then t.Auto = true; patched = true end
        if type(t.FullAuto) == "boolean" then t.FullAuto = true; patched = true end
        if type(t.CanShoot) == "boolean" then t.CanShoot = true; patched = true end
    end
    if State.NoRecoil then
        if type(t.VrecOil) == "table" then t.VrecOil = {0, 0}; patched = true end
        if type(t.HrecOil) == "table" then t.HrecOil = {0, 0}; patched = true end
        if type(t.Recoil) == "table" then
            for k in pairs(t.Recoil) do t.Recoil[k] = 0 end
            patched = true
        elseif type(t.Recoil) == "number" then
            t.Recoil = 0
            patched = true
        end
        if type(t.CameraRecoil) == "number" then t.CameraRecoil = 0; patched = true end
        if type(t.AimRecoilReduction) == "number" then t.AimRecoilReduction = 0; patched = true end
    end
    if State.NoSpread then
        if type(t.MinSpread) == "number" then t.MinSpread = 0; patched = true end
        if type(t.MaxSpread) == "number" then t.MaxSpread = 0; patched = true end
        if type(t.Spread) == "number" then t.Spread = 0; patched = true end
        if type(t.AimInaccuracy) == "number" then t.AimInaccuracy = 0; patched = true end
    end
    if State.InfiniteAmmo then
        for _, k in ipairs({"Ammo", "StoredAmmo", "MagCapacity", "Clip", "CurrentAmmo", "MaxAmmo", "AmmoInMag", "TotalAmmo", "Bullets", "Mag"}) do
            if type(t[k]) == "number" then
                t[k] = 9999
                patched = true
            end
        end
    end
    return patched
end

local function ForcePatchAllWeapons()
    local count = 0
    -- 1. Patch weapon modules inside character tools
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                for _, desc in ipairs(item:GetDescendants()) do
                    if IsSafeWeaponConfig(desc) then
                        pcall(function()
                            local t = require(desc)
                            if DeepPatchWeaponTable(t) then count = count + 1 end
                        end)
                    end
                end
            end
        end
    end

    -- 2. Patch weapon configs in backpack
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                for _, desc in ipairs(item:GetDescendants()) do
                    if IsSafeWeaponConfig(desc) then
                        pcall(function()
                            local t = require(desc)
                            if DeepPatchWeaponTable(t) then count = count + 1 end
                        end)
                    end
                end
            end
        end
    end

    -- 3. Targeted loaded modules (only safe config names, never engine modules)
    if getloadedmodules then
        for _, mod in ipairs(getloadedmodules()) do
            if IsSafeWeaponConfig(mod) then
                pcall(function()
                    local t = require(mod)
                    if DeepPatchWeaponTable(t) then count = count + 1 end
                end)
            end
        end
    end

    return count
end

local LastShotRemote = nil
local LastShotArgs = nil
local LastRocketCall = nil

-- __namecall Hook for Silent Aim, Wallbang, Infinite Ammo & Rocket/Gun Sniffing
local raw_namecall
if hookmetamethod then
    raw_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- Ultra-fast check: ONLY inspect FireServer remotes, never touch internal Roblox method calls (:IsA, etc.)
        if not checkcaller() and method == "FireServer" then
            local sName = self.Name

            -- Cache active shooting remote & arguments when fired normally
            if sName == "FireGun" or sName == "BulletFired" or sName == "ServerBullet" then
                LastShotRemote = self
                LastShotArgs = args
            end

            -- 1. Infinite Ammo: Block reload events
            if State.InfiniteAmmo then
                if (WeaponEvents.GunReload and self == WeaponEvents.GunReload) or (WeaponEvents.AcsReload and self == WeaponEvents.AcsReload) then
                    return nil
                end
            end

            -- 2. Silent Aim & Wallbang: Redirect hits directly to target safely
            if State.SilentAim then
                local isHit = (WeaponEvents.BulletHit and self == WeaponEvents.BulletHit)
                    or (WeaponEvents.AcsHit and self == WeaponEvents.AcsHit)
                    or (WeaponEvents.AcsDamage and self == WeaponEvents.AcsDamage)
                    or (WeaponEvents.ObjectShot and self == WeaponEvents.ObjectShot)

                if isHit then
                    pcall(function()
                        local target = GetClosestEnemy(State.Wallbang)
                        if target then
                            if typeof(args[1]) == "Instance" then
                                args[1] = target
                            end
                            if typeof(args[2]) == "Vector3" then
                                args[2] = target.Position
                            end
                        end
                    end)
                    return raw_namecall(self, unpack(args))
                end
            end
        end

        return raw_namecall(self, ...)
    end))
end

local function IsMouseOverGui()
    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then return false end
    if not ScreenGui.Enabled then return false end
    local mPos = UserInputService:GetMouseLocation()
    local gPos = Main.AbsolutePosition
    local gSize = Main.AbsoluteSize
    return (mPos.X >= gPos.X and mPos.X <= gPos.X + gSize.X and mPos.Y >= gPos.Y and mPos.Y <= gPos.Y + gSize.Y)
end

-- Force patch any equipped weapon tool
local function ForcePatchTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    for _, desc in ipairs(tool:GetDescendants()) do
        if desc:IsA("ModuleScript") then
            pcall(function()
                local t = require(desc)
                DeepPatchWeaponTable(t)
            end)
        elseif desc:IsA("LocalScript") and getsenv then
            pcall(function()
                local env = getsenv(desc)
                if env then
                    if env.RPM then env.RPM = 2500 end
                    if env.FireRate then env.FireRate = 2500 end
                    if env.Mode then env.Mode = "Auto" end
                    if env.FireMode then env.FireMode = "Auto" end
                    if env.ShootRate then env.ShootRate = 0 end
                    if env.ShootDelay then env.ShootDelay = 0 end
                    if env.Cooldown then env.Cooldown = 0 end
                    if env.Debounce ~= nil then env.Debounce = false end
                    if env.Auto ~= nil then env.Auto = true end
                    if env.CanShoot ~= nil then env.CanShoot = true end
                end
            end)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") and State.RapidFire then
            task.wait(0.1)
            ForcePatchTool(c)
        end
    end)
end)
if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function(c)
        if c:IsA("Tool") and State.RapidFire then
            task.wait(0.1)
            ForcePatchTool(c)
        end
    end)
end

-- Safe & Lag-Free Shooting Loop
local LastWeaponShotTick = 0

RunService.RenderStepped:Connect(function()
    if State.RapidFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not IsMouseOverGui() then
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            local tName = tool.Name:lower()
            -- RPG / Rocket / Heavy weapon protection: debounce to prevent engine particle/physics freeze
            local isHeavy = tName:match("rpg") or tName:match("rocket") or tName:match("missile") or tName:match("grenade") or tName:match("launcher")
            local cooldown = isHeavy and 0.22 or 0.03

            if (tick() - LastWeaponShotTick) >= cooldown then
                LastWeaponShotTick = tick()

                if mouse1click then
                    pcall(mouse1click)
                end
                tool:Activate()
                if firesignal then
                    pcall(function() firesignal(tool.Activated) end)
                end
                if LastShotRemote and LastShotArgs then
                    pcall(function() LastShotRemote:FireServer(unpack(LastShotArgs)) end)
                end
                if WeaponEvents.FireGun then
                    pcall(function() WeaponEvents.FireGun:FireServer() end)
                end
                if WeaponEvents.BulletFired then
                    pcall(function() WeaponEvents.BulletFired:FireServer() end)
                end
                if WeaponEvents.AcsServerBullet then
                    pcall(function() WeaponEvents.AcsServerBullet:FireServer() end)
                end
                tool:Deactivate()
            end
        end
    end
end)

-- Continuous Weapon Memory Refill & Infinite Ammo Enforcer
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.InfiniteAmmo or State.RapidFire or State.NoRecoil or State.NoSpread then
            pcall(ForcePatchAllWeapons)
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() ForcePatchTool(tool) end)
            end
        end
    end
end)


do
            local cLeft = CreateCard(PageFrames["WEAPONS"], "ACS & Gun Mods")
    AddToggle(cLeft, "Infinite Ammo (Block Reload Remote)", State.InfiniteAmmo, function(v)
        State.InfiniteAmmo = v
        if v then
            ForcePatchAllWeapons()
            notify("Weapons", "Infinite Ammo ENABLED!")
        end
    end)
    AddToggle(cLeft, "Rapid Fire (Infinite Stream)", State.RapidFire, function(v)
        State.RapidFire = v
        if v then
            ForcePatchAllWeapons()
            notify("Weapons", "Rapid Fire (Continuous Stream) ENABLED!")
        end
    end)
    AddToggle(cLeft, "Zero Recoil (Camera & Gun)", State.NoRecoil, function(v) State.NoRecoil = v end)
    AddToggle(cLeft, "Zero Spread / Max Accuracy", State.NoSpread, function(v) State.NoSpread = v end)
    AddButton(cLeft, "Force Memory Patch (All Guns)", function()
        local count = ForcePatchAllWeapons()
        notify("Weapons", string.format("Patched %d weapon tables in memory.", count))
    end)
    AddButton(cLeft, "Refill Ammo Tables to 9999 Now", function()
        local count = ForcePatchAllWeapons()
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then ForcePatchTool(tool) end
        notify("Weapons", "Refilled ammo on all weapons.")
    end)

    local cRight = CreateCard(PageFrames["WEAPONS"], "Targeted Engine Remotes")
    local dRow = Instance.new("Frame")
    dRow.Size = UDim2.new(1, 0, 0, 140)
    dRow.BackgroundColor3 = C.Bg
    dRow.BorderSizePixel = 0
    dRow.Parent = cRight

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 6)
    dCorner.Parent = dRow

    local dText = Instance.new("TextLabel")
    dText.Size = UDim2.new(1, -16, 1, -10)
    dText.Position = UDim2.new(0, 10, 0, 5)
    dText.BackgroundTransparency = 1
    dText.TextColor3 = C.Text
    dText.Font = Enum.Font.Code
    dText.TextSize = 10
    dText.TextXAlignment = Enum.TextXAlignment.Left
    dText.TextYAlignment = Enum.TextYAlignment.Top
    dText.Text = string.format([[REVERSED GUN REMOTES:
BulletFireSystem:
  - BulletHit: %s
  - FireGun: %s
  - GunReload: %s
  - BulletFired: %s
ACS_Engine:
  - Hit: %s
  - Reload: %s
  - ServerBullet: %s]],
        WeaponEvents.BulletHit and "[FOUND]" or "[MISSING]",
        WeaponEvents.FireGun and "[FOUND]" or "[MISSING]",
        WeaponEvents.GunReload and "[FOUND]" or "[MISSING]",
        WeaponEvents.BulletFired and "[FOUND]" or "[MISSING]",
        WeaponEvents.AcsHit and "[FOUND]" or "[MISSING]",
        WeaponEvents.AcsReload and "[FOUND]" or "[MISSING]",
        WeaponEvents.AcsServerBullet and "[FOUND]" or "[MISSING]")
    dText.Parent = dRow

    AddButton(cRight, "Trigger Instant Hit on Nearest Enemy", function()
        local target = GetClosestEnemy(State.Wallbang)
        if target then
            if WeaponEvents.BulletHit then
                pcall(function() WeaponEvents.BulletHit:FireServer(target, target.Position) end)
            end
            if WeaponEvents.AcsHit then
                pcall(function() WeaponEvents.AcsHit:FireServer(target, target.Position) end)
            end
            notify("Weapons", "Sent instant hit event to: " .. target.Parent.Name)
        else
            notify("Weapons", "No enemy target in FOV.")
        end
    end)
    AddButton(cRight, "Fast Re-Scan Remotes", function()
        local rCount = 0
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                rCount = rCount + 1
            end
        end
        notify("Engine", string.format("Scan complete: %d remotes verified in ReplicatedStorage.", rCount))
    end)
end

-- ==================== TAB 4: TYCOON (VISIBLES ONLY + CONFIGURABLE COOLDOWN) ====================
local function IsButtonVisibleAndActive(part, btnObj)
    if not part or not part:IsDescendantOf(Workspace) then return false end
    if part.Transparency > 0.85 then return false end

    local bbg = part:FindFirstChildWhichIsA("BillboardGui") or (btnObj and btnObj:FindFirstChildWhichIsA("BillboardGui"))
    if bbg and not bbg.Enabled then return false end

    if bbg then
        local label = bbg:FindFirstChildWhichIsA("TextLabel", true)
        if label and not label.Visible then return false end
    end

    return true
end

local function GetNearbyTycoonButtons()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end

    local list = {}
    local parts = {}
    if workspace.GetPartBoundsInRadius then
        parts = workspace:GetPartBoundsInRadius(root.Position, State.BuyRadius, nil)
    else
        parts = workspace:FindPartsInRegion3(Region3.new(root.Position - Vector3.new(State.BuyRadius, 50, State.BuyRadius), root.Position + Vector3.new(State.BuyRadius, 50, State.BuyRadius)), nil, 250)
    end

    for _, p in ipairs(parts) do
        local parent = p.Parent
        local isBtn = false
        local btnObj = parent

        if p:FindFirstChildWhichIsA("BillboardGui") or (parent and parent:FindFirstChildWhichIsA("BillboardGui")) then
            isBtn = true
        elseif p.Name:lower():match("button") or (parent and parent.Name:lower():match("button")) then
            isBtn = true
        elseif p:FindFirstChild("TouchInterest") then
            isBtn = true
        end

        if isBtn then
            table.insert(list, {
                Part = p,
                Button = btnObj or p
            })
        end
    end
    return list
end

-- Auto Buy Loop (Proximity Touch with Visibles-Only Check and Cooldown)
task.spawn(function()
    while true do
        task.wait(State.BuyCooldown)
        if State.AutoBuyProximity then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local btns = GetNearbyTycoonButtons()
                for _, b in ipairs(btns) do
                    if not State.AutoBuyProximity then break end
                    if not State.AutoBuyVisibleOnly or IsButtonVisibleAndActive(b.Part, b.Button) then
                        if WeaponEvents.ButtonTouched then
                            pcall(function() WeaponEvents.ButtonTouched:FireServer(b.Button) end)
                            pcall(function() WeaponEvents.ButtonTouched:FireServer(b.Button.Name) end)
                        end
                        if firetouchinterest then
                            pcall(function()
                                firetouchinterest(root, b.Part, 0)
                                task.wait(0.02)
                                firetouchinterest(root, b.Part, 1)
                            end)
                        end
                        task.wait(State.BuyCooldown)
                    end
                end

                if State.AutoExtractor and WeaponEvents.DefaultExtractor then
                    WeaponEvents.DefaultExtractor:FireServer()
                end
            end)
        end
    end
end)

-- Step-TP Auto Buy Loop (Visibles-Only + Cooldown)
task.spawn(function()
    while true do
        task.wait(0.2)
        if State.AutoBuyStepTP then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local btns = GetNearbyTycoonButtons()
                for _, b in ipairs(btns) do
                    if not State.AutoBuyStepTP then break end
                    if not State.AutoBuyVisibleOnly or IsButtonVisibleAndActive(b.Part, b.Button) then
                        local targetCFrame = b.Part.CFrame + Vector3.new(0, 2.5, 0)
                        root.CFrame = targetCFrame
                        if firetouchinterest then
                            firetouchinterest(root, b.Part, 0)
                            task.wait(0.04)
                            firetouchinterest(root, b.Part, 1)
                        end
                        if WeaponEvents.ButtonTouched then
                            WeaponEvents.ButtonTouched:FireServer(b.Button)
                        end
                        task.wait(State.BuyCooldown)
                    end
                end
            end)
        end
    end
end)

do
    local cLeft = CreateCard(PageFrames["TYCOON"], "Tycoon Auto Completion")
    AddToggle(cLeft, "Auto Buy (Proximity Touch)", State.AutoBuyProximity, function(v) State.AutoBuyProximity = v end)
    AddToggle(cLeft, "Auto Buy (Step-TP Walk Through)", State.AutoBuyStepTP, function(v) State.AutoBuyStepTP = v end)
    AddToggle(cLeft, "Only Visible / Displayed Buttons", State.AutoBuyVisibleOnly, function(v)
        State.AutoBuyVisibleOnly = v
        if v then notify("Tycoon", "Now only purchasing unlocked and visible buttons.") end
    end)
    AddToggle(cLeft, "Auto Pump Oil Extractors", State.AutoExtractor, function(v) State.AutoExtractor = v end)
    AddSlider(cLeft, "Purchase Cooldown Delay", 1, 20, 4, "00ms", function(v)
        State.BuyCooldown = v / 10
    end)
    AddSlider(cLeft, "Purchase Scan Radius", 50, 400, State.BuyRadius, " studs", function(v) State.BuyRadius = v end)

    local cRight = CreateCard(PageFrames["TYCOON"], "Tycoon Fast Actions")
    AddButton(cRight, "Claim Nearest Free Base", function()
        pcall(function()
            local claimRemote = KnitBase and KnitBase:FindFirstChild("RF") and KnitBase.RF:FindFirstChild("RequestAutoClaimBase")
                or ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ClaimBase")
            if claimRemote then
                if claimRemote:IsA("RemoteFunction") then claimRemote:InvokeServer() else claimRemote:FireServer() end
                notify("Tycoon", "Claim Base executed.")
            end
        end)
    end)
    AddButton(cRight, "Collect Oil Extractor Cash", function()
        pcall(function()
            if WeaponEvents.DefaultExtractor then
                WeaponEvents.DefaultExtractor:FireServer()
                notify("Tycoon", "Oil extractor collected.")
            end
        end)
    end)
end

-- ==================== TAB 5: CRATES ====================
ProximityPromptService.PromptShown:Connect(function(prompt)
    if State.AutoInstantPrompts then
        prompt.HoldDuration = 0
        if State.AutoStealCrates and fireproximityprompt then
            fireproximityprompt(prompt)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AutoStealCrates then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local parts = {}
                if workspace.GetPartBoundsInRadius then
                    parts = workspace:GetPartBoundsInRadius(root.Position, State.StealRadius, nil)
                end

                for _, p in ipairs(parts) do
                    local parent = p.Parent
                    local n = (parent and parent.Name or p.Name):lower()
                    if n:match("crate") or n:match("barrel") or n:match("airdrop") or n:match("munition") or n:match("tank") then
                        if WeaponEvents.RequestSteal then
                            pcall(function() WeaponEvents.RequestSteal:InvokeServer(parent) end)
                            pcall(function() WeaponEvents.RequestSteal:InvokeServer(p) end)
                        end
                        if WeaponEvents.OpenCrate then
                            pcall(function() WeaponEvents.OpenCrate:InvokeServer(parent) end)
                            pcall(function() WeaponEvents.OpenCrate:InvokeServer(p) end)
                        end
                        if WeaponEvents.UnweldCrate then
                            pcall(function() WeaponEvents.UnweldCrate:FireServer(parent) end)
                        end
                        local prompt = p:FindFirstChildWhichIsA("ProximityPrompt", true) or (parent and parent:FindFirstChildWhichIsA("ProximityPrompt", true))
                        if prompt and fireproximityprompt then
                            prompt.HoldDuration = 0
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
        end
    end
end)

do
    local cLeft = CreateCard(PageFrames["CRATES"], "Auto Steal Crates")
    AddToggle(cLeft, "Auto Steal & Open Crates", State.AutoStealCrates, function(v) State.AutoStealCrates = v end)
    AddToggle(cLeft, "Instant Proximity Prompts (0s)", State.AutoInstantPrompts, function(v) State.AutoInstantPrompts = v end)
    AddSlider(cLeft, "Steal Scan Radius", 20, 300, State.StealRadius, " studs", function(v) State.StealRadius = v end)

    local cRight = CreateCard(PageFrames["CRATES"], "Quick Crate Actions")
    AddButton(cRight, "Steal & Loot All Nearby Crates", function()
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local count = 0
            local parts = {}
            if workspace.GetPartBoundsInRadius then parts = workspace:GetPartBoundsInRadius(root.Position, State.StealRadius, nil) end

            for _, p in ipairs(parts) do
                local parent = p.Parent
                local n = (parent and parent.Name or p.Name):lower()
                if n:match("crate") or n:match("barrel") or n:match("airdrop") or n:match("munition") or n:match("tank") then
                    if WeaponEvents.RequestSteal then pcall(function() WeaponEvents.RequestSteal:InvokeServer(parent) end) end
                    if WeaponEvents.OpenCrate then pcall(function() WeaponEvents.OpenCrate:InvokeServer(parent) end) end
                    local prompt = p:FindFirstChildWhichIsA("ProximityPrompt", true) or (parent and parent:FindFirstChildWhichIsA("ProximityPrompt", true))
                    if prompt and fireproximityprompt then
                        prompt.HoldDuration = 0
                        fireproximityprompt(prompt)
                    end
                    count = count + 1
                end
            end
            notify("Crates", string.format("Triggered %d crates/barrels.", count))
        end)
    end)
    AddButton(cRight, "Teleport to Nearest Crate / Drop", function()
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local nearestPart = nil
            local nearestDist = math.huge

            for _, folder in ipairs({Workspace:FindFirstChild("Crates"), Workspace:FindFirstChild("Airdrops"), Workspace:FindFirstChild("Munitions"), Workspace}) do
                if folder then
                    for _, inst in ipairs(folder:GetChildren()) do
                        local n = inst.Name:lower()
                        if n:match("crate") or n:match("barrel") or n:match("airdrop") or n:match("munition") then
                            local part = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local d = (part.Position - root.Position).Magnitude
                                if d < nearestDist and d > 4 then
                                    nearestDist = d
                                    nearestPart = part
                                end
                            end
                        end
                    end
                end
            end

            if nearestPart then
                root.CFrame = nearestPart.CFrame + Vector3.new(0, 3, 0)
                notify("Crates", string.format("Teleported to crate (%d studs away)!", math.floor(nearestDist)))
            else
                notify("Crates", "No crates or airdrops currently spawned.")
            end
        end)
    end)
end

-- ==================== TAB 6: MOVEMENT ====================
-- Dedicated Noclip Stepped Hook (Physics-safe + High Velocity Phasing)
RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end

        -- Fast Wall Phasing Velocity Injection
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            local nSpeed = State.NoclipSpeed or 52
            root.AssemblyLinearVelocity = Vector3.new(
                hum.MoveDirection.X * nSpeed,
                root.AssemblyLinearVelocity.Y,
                hum.MoveDirection.Z * nSpeed
            )
        end
    end
end)

local flyBodyVel = nil
local flyBodyGyro = nil

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if State.Fly and root and hum and hum.Health > 0 then
        if not flyBodyVel or flyBodyVel.Parent ~= root then
            if flyBodyVel then flyBodyVel:Destroy() end
            if flyBodyGyro then flyBodyGyro:Destroy() end

            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.Name = "Phantom_FlyVel"
            flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBodyVel.Parent = root

            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.Name = "Phantom_FlyGyro"
            flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBodyGyro.P = 15000
            flyBodyGyro.Parent = root
        end

        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            local targetVel = moveDir * State.FlySpeed
            flyBodyVel.Velocity = targetVel
            root.AssemblyLinearVelocity = targetVel
        else
            flyBodyVel.Velocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
        end

        flyBodyGyro.CFrame = Camera.CFrame
        hum.PlatformStand = true
    else
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if hum and not State.Noclip then hum.PlatformStand = false end
    end

    if State.SpeedHack and hum and hum.WalkSpeed > 0 then
        hum.WalkSpeed = State.WalkSpeed
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJump and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

if State.NoFallDamage then
    RunService.Heartbeat:Connect(function()
        if RootPart and RootPart.AssemblyLinearVelocity.Y < -65 then
            RootPart.AssemblyLinearVelocity = Vector3.new(RootPart.AssemblyLinearVelocity.X, 0, RootPart.AssemblyLinearVelocity.Z)
        end
    end)
end

do
    local cLeft = CreateCard(PageFrames["MOVEMENT"], "Flight & Noclip Engine")
    AddToggle(cLeft, "Noclip (Walk Through Walls)", State.Noclip, function(v)
        State.Noclip = v
        if v then notify("Movement", "Fast Noclip ENABLED (" .. tostring(State.NoclipSpeed) .. " spd)!") end
    end)
    AddSlider(cLeft, "Noclip Phase Speed", 20, 150, State.NoclipSpeed, " spd", function(v)
        State.NoclipSpeed = v
    end)
    AddToggle(cLeft, "Smooth Flight Mode", State.Fly, function(v) State.Fly = v end)
    AddSlider(cLeft, "Flight Speed", 50, 500, State.FlySpeed, " spd", function(v) State.FlySpeed = v end)

    local cRight = CreateCard(PageFrames["MOVEMENT"], "Speed & Jump")
    AddToggle(cRight, "Speed Boost", State.SpeedHack, function(v) State.SpeedHack = v end)
    AddSlider(cRight, "WalkSpeed", 16, 80, State.WalkSpeed, " ws", function(v) State.WalkSpeed = v end)
    AddToggle(cRight, "Infinite Jump / Bunnyhop", State.InfJump, function(v) State.InfJump = v end)
    AddToggle(cRight, "No Fall Damage", State.NoFallDamage, function(v) State.NoFallDamage = v end)
end

-- ==================== TAB 7: MISC ====================
do
    local cLeft = CreateCard(PageFrames["MISC"], "Client Utilities")
    AddButton(cLeft, "Rejoin Same Server", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    AddButton(cLeft, "Server Hop", function()
        pcall(function()
            local HttpService = game:GetService("HttpService")
            local req = (syn and syn.request) or (http and http.request) or request
            if req then
                local res = req({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"})
                local data = HttpService:JSONDecode(res.Body)
                for _, s in ipairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        break
                    end
                end
            end
        end)
    end)
    AddButton(cLeft, "Unload / Close Menu", function()
        ScreenGui:Destroy()
        FovGui:Destroy()
        EspFolder:Destroy()
        CrateEspFolder:Destroy()
        notify("Phantom Scripts", "Menu successfully unloaded.")
    end)
end

-- Hotkey Toggle (INSERT or RIGHT CONTROL)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl) then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

notify("Phantom Scripts", "War Tycoon Elite v5 Loaded! Wallbang & Clean Auto Buy ready.")
