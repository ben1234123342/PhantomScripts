-- [[ PHANTOM SCRIPTS - RESILIENT CORE ]] --
local _main_ok, _main_err = pcall(function()
-- [[ PHANTOM SCRIPTS - THROW FOOD FOR ANIMALS ]] --
-- Premium Tabbed ImGui Remake (Fortnite External 0x0E0E12 / 0xF962FA Theme)
-- Auto Throw, Auto Workout & x2 Tap Collector, Auto Sell Bad Animals, Auto Tycoon & Teleports

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character and Character:FindFirstChild("Humanoid")

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Phantom Scripts",
        Text = "Booting Phantom UI...",
        Duration = 4
    })
end)

task.spawn(function()
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    RootPart = Character:WaitForChild("HumanoidRootPart", 5) or Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid", 5) or Character:FindFirstChild("Humanoid")
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid", 5) or char:FindFirstChild("Humanoid")
end)

-- Safe GUI Parent Resolution (Direct PlayerGui / gethui)
local function GetSafeGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then
            return h
        end
    end
    local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        return pgui
    end
    local okP, res = pcall(function()
        return LocalPlayer:WaitForChild("PlayerGui", 5)
    end)
    if okP and res then
        return res
    end
    return game:GetService("CoreGui")
end

local guiParent = GetSafeGuiParent()
local oldGui = guiParent:FindFirstChild("PhantomScripts_UI")
if not oldGui and LocalPlayer:FindFirstChild("PlayerGui") then
    oldGui = LocalPlayer.PlayerGui:FindFirstChild("PhantomScripts_UI")
end
if oldGui then
    oldGui:Destroy()
end

-- Game Remotes (Non-blocking Resolution)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 8)
local function getRemote(name)
    if not Remotes then return nil end
    return Remotes:FindFirstChild(name) or Remotes:WaitForChild(name, 3)
end

local R_Throw_Start = getRemote("Throw_Start")
local R_Throw_Resolve = getRemote("Throw_Resolve")
local R_Throw_Complete = getRemote("Throw_Complete")

local R_Training_Start = getRemote("Training_Start")
local R_Training_Stop = getRemote("Training_Stop")
local R_Training_TapBonus = getRemote("Training_TapBonus")
local R_Stand_Upgrade = getRemote("Stand_Upgrade")

local R_Shop_Buy = getRemote("Shop_Buy")
local R_Shop_Equip = getRemote("Shop_Equip")
local R_Shop_ClaimFree = getRemote("Shop_ClaimFree")
local R_Offline_Claim = getRemote("Offline_Claim")

local R_Plot_EquipBest = getRemote("Plot_EquipBest")
local R_Plot_SellAll = getRemote("Plot_SellAll")
local R_Plot_UpgradeFence = getRemote("Plot_UpgradeFence")
local R_Sell_Protected = getRemote("Sell_Protected")
local R_Plot_SellAnimal = getRemote("Plot_SellAnimal")

-- Safe Module Requester
local safeRequire = function(moduleInstance)
    if not moduleInstance then
        return nil
    end
    local ok, res = pcall(require, moduleInstance)
    if ok then
        return res
    end
    return nil
end

-- Controllers (Dynamic Runtime Resolution)
local ControllersFolder = nil
local ThrowController = nil
local TrainingController = nil
local PlotController = nil
local DataController = nil
local ProtectedSell = nil
local SellShop = nil
local AnimalsPanel = nil
local HUDController = nil
local TapBlockers = nil
local ScreenFX = nil

pcall(function()
    local pScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if pScripts then
        local clientFolder = pScripts:FindFirstChild("Client")
        if clientFolder then
            ControllersFolder = clientFolder:FindFirstChild("Controllers")
            if ControllersFolder then
                ThrowController = safeRequire(ControllersFolder:FindFirstChild("ThrowController"))
                TrainingController = safeRequire(ControllersFolder:FindFirstChild("TrainingController"))
                PlotController = safeRequire(ControllersFolder:FindFirstChild("PlotController"))
                DataController = safeRequire(ControllersFolder:FindFirstChild("DataController"))
                ProtectedSell = safeRequire(ControllersFolder:FindFirstChild("ProtectedSell"))
                SellShop = safeRequire(ControllersFolder:FindFirstChild("SellShop"))
                AnimalsPanel = safeRequire(ControllersFolder:FindFirstChild("AnimalsPanel"))
                HUDController = safeRequire(ControllersFolder:FindFirstChild("HUDController"))
                TapBlockers = safeRequire(ControllersFolder:FindFirstChild("TapBlockers"))
                ScreenFX = safeRequire(ControllersFolder:FindFirstChild("ScreenFX"))

                -- Safely neutralize strobe flash without crashing on readonly table
                if ScreenFX then
                    pcall(function()
                        if setreadonly then
                            setreadonly(ScreenFX, false)
                        end
                        ScreenFX.Flash = function() end
                        ScreenFX.PulseVignette = function() end
                        if setreadonly then
                            setreadonly(ScreenFX, true)
                        end
                    end)
                end
            end
        end
    end
end)

-- Anti-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
    end)
end)

-- State
local State = {
    AutoWorkout = false,
    TrainDelay = 0.08,
    AutoTapBonus = true,
    DisableFlash = true,
    AutoThrow = false,
    ThrowDelay = 0.25,
    AutoBuyFood = false,
    AutoSellBad = false,
    SellInterval = 5,
    AutoUpgradeStand = false,
    AutoUpgradeFence = false,
    AutoEquipBest = false,
    AutoClaimFree = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    InfJump = false,
    AnimalESP = false,
    MenuVisible = true
}

-- Logger
local Logs = {}
local LogCallback = nil
local function Log(msg)
    local line = string.format("[%s] %s", os.date("%X"), tostring(msg))
    table.insert(Logs, line)
    if #Logs > 35 then
        table.remove(Logs, 1)
    end
    print("[Phantom] " .. tostring(msg))
    if LogCallback then
        LogCallback(line)
    end
end

-- Teleport to Stand (Colon method call)
local function TeleportToStand()
    local called = false
    if PlotController then
        pcall(function()
            if type(PlotController.TeleportToStand) == "function" then
                PlotController:TeleportToStand()
                called = true
            end
        end)
    end
    if not called and RootPart then
        RootPart.CFrame = CFrame.new(-66, 4, -16.5)
    end
end

-- Clean Workout Release
local function StopTraining()
    State.AutoWorkout = false

    pcall(function()
        if TrainingController then
            if type(TrainingController.Stop) == "function" then
                TrainingController:Stop()
            end
            if type(TrainingController.RestoreCamera) == "function" then
                TrainingController:RestoreCamera()
            end
        end
    end)

    pcall(function()
        R_Training_Stop:InvokeServer()
    end)

    -- Step back slightly so proximity prompt doesn't re-latch
    pcall(function()
        if RootPart then
            RootPart.CFrame = RootPart.CFrame + Vector3.new(0, 0, 5)
        end
    end)

    pcall(function()
        if ScreenFX and type(ScreenFX.Reset) == "function" then
            ScreenFX:Reset()
        end
    end)

    Log("Workout cleanly stopped & camera restored.")
end

-- Multiplier & x2 Tap Bonus Collector (Controlled rate)
local lastBonusTime = 0
local function TriggerTapBonuses()
    local now = tick()
    if now - lastBonusTime < 0.35 then
        return
    end
    lastBonusTime = now

    pcall(function()
        R_Training_TapBonus:InvokeServer()
    end)

    if TapBlockers and type(TapBlockers.Hit) == "function" then
        pcall(function()
            TapBlockers:Hit()
        end)
    end

    pcall(function()
        local charPos = RootPart and RootPart.Position
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ClickDetector") then
                local p = desc.Parent
                if p and p:IsA("BasePart") and charPos and (p.Position - charPos).Magnitude < 30 then
                    local name = p.Name:lower()
                    if name:find("stand") or name:find("bar") or name:find("tap") or name:find("bonus") or name:find("pillar") then
                        if fireclickdetector then
                            fireclickdetector(desc)
                        end
                    end
                end
            elseif desc:IsA("ProximityPrompt") and desc.Enabled then
                local act = desc.ActionText:lower()
                local obj = desc.ObjectText:lower()
                if act:find("tap") or act:find("bonus") or act:find("claim") or act:find("x2") or obj:find("tap") or obj:find("bonus") or obj:find("x2") then
                    if fireproximityprompt then
                        fireproximityprompt(desc)
                    end
                end
            elseif desc:IsA("BillboardGui") and desc.Enabled then
                local bName = desc.Name:lower()
                if bName:find("tap") or bName:find("bonus") or bName:find("x2") or bName:find("multiplier") then
                    for _, btn in ipairs(desc:GetDescendants()) do
                        if (btn:IsA("ImageButton") or btn:IsA("TextButton")) and firesignal then
                            firesignal(btn.Activated)
                            firesignal(btn.MouseButton1Click)
                        end
                    end
                end
            end
        end
    end)
end

-- 1. WORKOUT ENGINE
task.spawn(function()
    while true do
        if State.AutoWorkout then
            TeleportToStand()
            task.wait(0.04)

            if TrainingController and type(TrainingController.Start) == "function" then
                pcall(function()
                    local isRun = false
                    if type(TrainingController.IsRunning) == "function" then
                        isRun = TrainingController:IsRunning()
                    end
                    if not isRun then
                        TrainingController:Start()
                    end
                end)
            end
            pcall(function()
                R_Training_Start:InvokeServer()
            end)

            for _ = 1, 3 do
                pcall(function()
                    R_Training_TapBonus:InvokeServer()
                end)
                if State.AutoTapBonus then
                    TriggerTapBonuses()
                end
                task.wait(State.TrainDelay)
            end
        else
            task.wait(0.2)
        end
    end
end)

-- 2. THROW ENGINE
local function DoThrow()
    local tool = Character:FindFirstChildWhichIsA("Tool")
    if not tool and LocalPlayer:FindFirstChild("Backpack") then
        tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
        if tool and Humanoid then
            Humanoid:EquipTool(tool)
        end
    end
    if tool then
        tool:Activate()
    end

    if ThrowController and type(ThrowController.Start) == "function" then
        pcall(function()
            ThrowController:Start()
        end)
    end

    pcall(function()
        local sess = R_Throw_Start:InvokeServer()
        task.wait(0.02)
        if sess then
            R_Throw_Resolve:InvokeServer(sess, 1.0)
            R_Throw_Complete:InvokeServer(sess)
        else
            R_Throw_Resolve:InvokeServer(1.0)
            R_Throw_Complete:InvokeServer()
        end
    end)
end

task.spawn(function()
    while true do
        if State.AutoThrow then
            DoThrow()
        end
        task.wait(State.ThrowDelay)
    end
end)

-- 3. AUTO BUY BEST FOOD (High-Tier Priority & Owned Food Protection)
local function BuyAndEquipBestFood()
    local bestId = nil

    -- Step 1: Attempt purchase from Tier 50 down to 1
    for id = 50, 1, -1 do
        local purchased = false
        for _, payload in ipairs({id, tostring(id), {"Food", id}, {"Food", tostring(id)}}) do
            local ok, res = pcall(function()
                if type(payload) == "table" then
                    return R_Shop_Buy:InvokeServer(payload[1], payload[2])
                else
                    return R_Shop_Buy:InvokeServer(payload)
                end
            end)
            if ok and res ~= nil and res ~= false then
                purchased = true
                bestId = id
                Log(string.format("Purchased Food Tier %d!", id))
                break
            end
        end
        if purchased then
            break -- STOP immediately on first successful purchase
        end
    end

    -- Step 2: If no purchase made, identify highest already-owned food from DataController
    if not bestId and DataController and DataController.GetData then
        pcall(function()
            local data = DataController:GetData()
            if data and type(data) == "table" then
                local owned = data.OwnedFoods or data.Foods or data.Food or data.UnlockedFoods or data.Inventory
                if owned and type(owned) == "table" then
                    local maxOwned = 1
                    for k, v in pairs(owned) do
                        local num = tonumber(k)
                        if not num and type(v) == "table" then
                            num = tonumber(v.Id) or tonumber(v.Tier) or tonumber(v.Level)
                        elseif not num then
                            num = tonumber(v)
                        end
                        if num and num > maxOwned and num <= 50 then
                            maxOwned = num
                        end
                    end
                    bestId = maxOwned
                end
            end
        end)
    end

    -- Step 3: Equip the best food (or highest owned tier) without cascading to Tier 1
    if bestId then
        for _, payload in ipairs({bestId, tostring(bestId), {"Food", bestId}, {"Food", tostring(bestId)}}) do
            pcall(function()
                if type(payload) == "table" then
                    R_Shop_Equip:InvokeServer(payload[1], payload[2])
                else
                    R_Shop_Equip:InvokeServer(payload)
                end
            end)
        end
        Log(string.format("Best food equipped: Tier %d", bestId))
    else
        -- Fallback: probe equip from 50 down, STOP on first success
        for id = 50, 1, -1 do
            local equipped = false
            for _, payload in ipairs({id, tostring(id), {"Food", id}, {"Food", tostring(id)}}) do
                local ok, res = pcall(function()
                    if type(payload) == "table" then
                        return R_Shop_Equip:InvokeServer(payload[1], payload[2])
                    else
                        return R_Shop_Equip:InvokeServer(payload)
                    end
                end)
                if ok and res ~= nil and res ~= false then
                    equipped = true
                    Log(string.format("Best food equipped: Tier %d", id))
                    break
                end
            end
            if equipped then
                break -- STOP! Do not cascade down to lower tiers!
            end
        end
    end
end

-- 4. AUTO SELL BAD ANIMALS (Guaranteed Enclosure & Equipped Protection)
local function SellBadAnimals()
    -- 1. Ensure best animals are equipped to the enclosure first
    pcall(function()
        R_Plot_EquipBest:InvokeServer()
    end)
    task.wait(0.15)

    -- 2. Build whitelist of all animals currently active in enclosure or equipped
    local protectedIds = {}

    -- Whitelist physical enclosure animals walking on plot
    pcall(function()
        local plotModel = nil
        if PlotController and PlotController.GetPlotPart then
            local part = PlotController:GetPlotPart()
            if part then
                plotModel = part.Parent
            end
        end
        if not plotModel and workspace:FindFirstChild("Plots") then
            for _, plot in ipairs(workspace.Plots:GetChildren()) do
                if plot.Name == LocalPlayer.Name or plot:FindFirstChild(LocalPlayer.Name) then
                    plotModel = plot
                    break
                end
            end
        end
        if plotModel then
            for _, desc in ipairs(plotModel:GetDescendants()) do
                if desc:IsA("Model") and desc ~= Character then
                    protectedIds[tostring(desc.Name)] = true
                    for _, attrName in ipairs({"AnimalId", "Id", "UUID", "Uid", "EntryId"}) do
                        local val = desc:GetAttribute(attrName)
                        if val then
                            protectedIds[tostring(val)] = true
                        end
                    end
                end
            end
        end
    end)

    -- Whitelist equipped animals from DataController
    if DataController and DataController.GetData then
        pcall(function()
            local data = DataController:GetData()
            if data and type(data) == "table" then
                for _, fName in ipairs({"Equipped", "PlotAnimals", "EquippedAnimals", "ActiveAnimals"}) do
                    if data[fName] and type(data[fName]) == "table" then
                        for k, v in pairs(data[fName]) do
                            protectedIds[tostring(k)] = true
                            if type(v) == "string" or type(v) == "number" then
                                protectedIds[tostring(v)] = true
                            elseif type(v) == "table" then
                                local id = v.Id or v.UUID or v.Uid or k
                                protectedIds[tostring(id)] = true
                            end
                        end
                    end
                end
            end
        end)
    end

    local soldCount = 0
    local success = false

    -- Strategy 1: Safe Protected Sell Remote (server protects equipped animals)
    local okProt, resProt = pcall(function()
        return R_Sell_Protected:InvokeServer()
    end)
    if okProt and resProt ~= nil and resProt ~= false then
        success = true
    end

    -- Strategy 2: Inventory scan with strict enclosure protection
    if DataController and DataController.GetData then
        pcall(function()
            local data = DataController:GetData()
            if data and type(data) == "table" then
                local animalList = data.Animals or data.Inventory or data.OwnedAnimals
                if animalList and type(animalList) == "table" then
                    for animalId, animalInfo in pairs(animalList) do
                        local isEquipped = false
                        local isLocked = false
                        local animalKey = animalId

                        if type(animalInfo) == "table" then
                            isEquipped = animalInfo.Equipped or animalInfo.IsEquipped or animalInfo.equipped or false
                            isLocked = animalInfo.Locked or animalInfo.IsLocked or animalInfo.locked or animalInfo.Protected or false
                            animalKey = animalInfo.Id or animalInfo.UUID or animalInfo.Uid or animalId
                        end

                        local sKey = tostring(animalKey)
                        local sId = tostring(animalId)

                        -- STRICT CHECK: NEVER sell animals currently in the enclosure or equipped
                        if not isEquipped and not isLocked and not protectedIds[sKey] and not protectedIds[sId] then
                            local okSell, sRes = pcall(function()
                                return R_Plot_SellAnimal:InvokeServer(animalKey)
                            end)
                            if okSell and sRes ~= false then
                                soldCount = soldCount + 1
                                success = true
                            end
                        end
                    end
                end
            end
        end)
    end

    if success then
        if soldCount > 0 then
            Log(string.format("Auto Sell: %d bad animals sold (enclosure safe).", soldCount))
        else
            Log("Auto Sell: Clean inventory sold (enclosure safe).")
        end
    end
end

-- 5. TYCOON & REWARDS ENGINE
task.spawn(function()
    while true do
        if State.AutoBuyFood then
            BuyAndEquipBestFood()
        end
        if State.AutoEquipBest then
            pcall(function()
                R_Plot_EquipBest:InvokeServer()
            end)
        end
        if State.AutoSellBad then
            SellBadAnimals()
        end
        if State.AutoUpgradeStand then
            pcall(function()
                R_Stand_Upgrade:InvokeServer()
            end)
        end
        if State.AutoUpgradeFence then
            pcall(function()
                R_Plot_UpgradeFence:InvokeServer()
            end)
        end
        if State.AutoClaimFree then
            pcall(function()
                R_Shop_ClaimFree:InvokeServer()
                R_Offline_Claim:InvokeServer()
            end)
        end
        task.wait(State.SellInterval)
    end
end)

-- 6. MOVEMENT
RunService.Stepped:Connect(function()
    if State.Noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    if Humanoid then
        if Humanoid.WalkSpeed ~= State.WalkSpeed and State.WalkSpeed ~= 16 then
            Humanoid.WalkSpeed = State.WalkSpeed
        end
        if Humanoid.JumpPower ~= State.JumpPower and State.JumpPower ~= 50 then
            Humanoid.JumpPower = State.JumpPower
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 7. ANIMAL ESP
local EspFolder = Instance.new("Folder")
EspFolder.Name = "Phantom_ESP"
EspFolder.Parent = guiParent

local function UpdateESP()
    EspFolder:ClearAllChildren()
    if not State.AnimalESP then
        return
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Character and obj:FindFirstChild("HumanoidRootPart") then
            local isAnimal = obj.Name:find("Animal") or (obj.Parent and obj.Parent.Name:find("Animal"))
            if not isAnimal and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                isAnimal = true
            end
            if isAnimal then
                local bbg = Instance.new("BillboardGui")
                bbg.Name = "AnimalTag"
                bbg.Adornee = obj:FindFirstChild("HumanoidRootPart")
                bbg.Size = UDim2.new(0, 100, 0, 30)
                bbg.AlwaysOnTop = true

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = obj.Name
                lbl.TextColor3 = Color3.fromRGB(249, 98, 250)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 11
                lbl.Parent = bbg
                bbg.Parent = EspFolder
            end
        end
    end
end

task.spawn(function()
    while true do
        if State.AnimalESP then
            UpdateESP()
        end
        task.wait(3)
    end
end)

-- 8. TELEPORT WAYPOINTS
local Waypoints = {
    ["Spawn / Lobby"] = CFrame.new(-38, 4, 30),
    ["Jungle Area"] = CFrame.new(200, 4, 30),
    ["Ocean Area"] = CFrame.new(500, 4, 30),
    ["Desert Area"] = CFrame.new(900, 4, 30),
    ["Winter Area"] = CFrame.new(1400, 4, 30),
    ["Hell Area"] = CFrame.new(2000, 4, 30),
    ["Harvest Fields"] = CFrame.new(2700, 4, 30),
    ["Deep Waters"] = CFrame.new(3500, 4, 30),
    ["Mythical Paradise"] = CFrame.new(4400, 4, 30),
    ["My Pull-Up Bar"] = CFrame.new(-66, 4, -16.5),
    ["Stand Upgrade Spot"] = CFrame.new(-66, 4, -22),
    ["Sell Shop NPC"] = CFrame.new(-20, 4, -40)
}

local function TeleportTo(cf)
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = cf + Vector3.new(0, 3, 0)
    end
end

-- =========================================================================
-- IMGUI UI FRAMEWORK (Dear ImGui Dark + Fortnite Violet Theme)
-- =========================================================================

local C = {
    Bg = Color3.fromRGB(14, 14, 18),
    Card = Color3.fromRGB(19, 18, 24),
    Header = Color3.fromRGB(24, 22, 30),
    Accent = Color3.fromRGB(249, 98, 250),
    AccentDark = Color3.fromRGB(204, 54, 250),
    Border = Color3.fromRGB(42, 41, 48),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(138, 136, 149),
    Active = Color3.fromRGB(34, 31, 44),
    Green = Color3.fromRGB(50, 215, 75),
    Red = Color3.fromRGB(255, 69, 58)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomScripts_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = true
ScreenGui.Parent = guiParent

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Phantom Scripts",
        Text = "UI Loaded! Press INSERT to toggle.",
        Duration = 5
    })
end)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 680, 0, 460)
Main.Position = UDim2.new(0.5, -340, 0.5, -230)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = C.Border
MainStroke.Thickness = 1.2
MainStroke.Parent = Main

-- Dragging
local isDragging = false
local dragStart = nil
local startPos = nil

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Top Header Bar
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = C.Header
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderStroke = Instance.new("Frame")
HeaderStroke.Size = UDim2.new(1, 0, 0, 1)
HeaderStroke.Position = UDim2.new(0, 0, 1, -1)
HeaderStroke.BackgroundColor3 = C.Border
HeaderStroke.BorderSizePixel = 0
HeaderStroke.Parent = Header

local BrandIcon = Instance.new("Frame")
BrandIcon.Size = UDim2.new(0, 24, 0, 24)
BrandIcon.Position = UDim2.new(0, 16, 0, 12)
BrandIcon.BackgroundColor3 = C.Accent
BrandIcon.BorderSizePixel = 0
BrandIcon.Parent = Header

local BrandCorner = Instance.new("UICorner")
BrandCorner.CornerRadius = UDim.new(0, 6)
BrandCorner.Parent = BrandIcon

local BrandLabel = Instance.new("TextLabel")
BrandLabel.Size = UDim2.new(1, 0, 1, 0)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Text = "P"
BrandLabel.TextColor3 = Color3.fromRGB(14, 14, 18)
BrandLabel.Font = Enum.Font.GothamBold
BrandLabel.TextSize = 14
BrandLabel.Parent = BrandIcon

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 140, 0, 20)
Title.Position = UDim2.new(0, 48, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "PHANTOM SCRIPTS"
Title.TextColor3 = C.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 200, 0, 14)
SubTitle.Position = UDim2.new(0, 48, 0, 26)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Throw Food For Animals | External Engine"
SubTitle.TextColor3 = C.TextDim
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

-- Tab Navigation
local TabsList = {"FARM", "WORKOUT", "TYCOON", "TELEPORT", "MISC"}
local TabButtons = {}
local PageFrames = {}

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 360, 0, 32)
TabContainer.Position = UDim2.new(1, -376, 0, 8)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Header

local TabUIList = Instance.new("UIListLayout")
TabUIList.FillDirection = Enum.FillDirection.Horizontal
TabUIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
TabUIList.SortOrder = Enum.SortOrder.LayoutOrder
TabUIList.Padding = UDim.new(0, 6)
TabUIList.Parent = TabContainer

-- Content Body
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -32, 1, -64)
Content.Position = UDim2.new(0, 16, 0, 56)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function SwitchTab(tabName)
    for name, page in pairs(PageFrames) do
        page.Visible = (name == tabName)
    end
    for name, btn in pairs(TabButtons) do
        local active = (name == tabName)
        TweenService:Create(btn, TweenInfo.new(0.18), {
            BackgroundColor3 = active and C.Active or Color3.fromRGB(20, 19, 26),
            TextColor3 = active and C.Accent or C.TextDim
        }):Play()
        local stroke = btn:FindFirstChild("UIStroke")
        if stroke then
            stroke.Color = active and C.AccentDark or C.Border
        end
    end
end

for i, tabName in ipairs(TabsList) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName
    tabBtn.Size = UDim2.new(0, 66, 0, 28)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 19, 26)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = tabName
    tabBtn.TextColor3 = C.TextDim
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 11
    tabBtn.Parent = TabContainer

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 5)
    tCorner.Parent = tabBtn

    local tStroke = Instance.new("UIStroke")
    tStroke.Color = C.Border
    tStroke.Thickness = 1
    tStroke.Parent = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        SwitchTab(tabName)
    end)
    TabButtons[tabName] = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "_Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.Border
    page.Visible = false
    page.Parent = Content

    local pList = Instance.new("UIListLayout")
    pList.FillDirection = Enum.FillDirection.Horizontal
    pList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    pList.SortOrder = Enum.SortOrder.LayoutOrder
    pList.Padding = UDim.new(0, 12)
    pList.Parent = page

    PageFrames[tabName] = page
end

-- Component Helpers
local function CreateCard(parent, titleText)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 318, 0, 388)
    card.BackgroundColor3 = C.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = card

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = C.Border
    cStroke.Thickness = 1
    cStroke.Parent = card

    local cHeader = Instance.new("TextLabel")
    cHeader.Size = UDim2.new(1, -24, 0, 30)
    cHeader.Position = UDim2.new(0, 12, 0, 6)
    cHeader.BackgroundTransparency = 1
    cHeader.Text = titleText:upper()
    cHeader.TextColor3 = C.Accent
    cHeader.Font = Enum.Font.GothamBold
    cHeader.TextSize = 11
    cHeader.TextXAlignment = Enum.TextXAlignment.Left
    cHeader.Parent = card

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -24, 0, 1)
    divider.Position = UDim2.new(0, 12, 0, 36)
    divider.BackgroundColor3 = C.Border
    divider.BorderSizePixel = 0
    divider.Parent = card

    local body = Instance.new("ScrollingFrame")
    body.Size = UDim2.new(1, -24, 1, -48)
    body.Position = UDim2.new(0, 12, 0, 42)
    body.BackgroundTransparency = 1
    body.BorderSizePixel = 0
    body.ScrollBarThickness = 2
    body.ScrollBarImageColor3 = C.Border
    body.Parent = card

    local bList = Instance.new("UIListLayout")
    bList.SortOrder = Enum.SortOrder.LayoutOrder
    bList.Padding = UDim.new(0, 8)
    bList.Parent = body

    return body
end

local function AddToggle(parent, labelText, defaultVal, callback)
    local val = defaultVal or false

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(24, 23, 30)
    row.BorderSizePixel = 0
    row.Parent = parent

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 4)
    rCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 34, 0, 18)
    toggleBtn.Position = UDim2.new(1, -42, 0.5, -9)
    toggleBtn.BackgroundColor3 = val and C.Accent or Color3.fromRGB(36, 35, 44)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = row

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBtn

    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(1, 0)
    kCorner.Parent = knob

    toggleBtn.MouseButton1Click:Connect(function()
        val = not val
        TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = val and C.Accent or Color3.fromRGB(36, 35, 44)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if callback then
            callback(val)
        end
    end)

    return row
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(28, 26, 35)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = C.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = parent

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = C.Border
    bStroke.Thickness = 1
    bStroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(38, 35, 48),
            TextColor3 = C.Accent
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(28, 26, 35),
            TextColor3 = C.Text
        }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return btn
end

local function AddSlider(parent, labelText, minVal, maxVal, defaultVal, suffix, callback)
    local val = defaultVal or minVal
    suffix = suffix or ""

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 46)
    container.BackgroundColor3 = Color3.fromRGB(24, 23, 30)
    container.BorderSizePixel = 0
    container.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 4)
    cCorner.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 20)
    valLbl.Position = UDim2.new(1, -68, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(val) .. suffix
    valLbl.TextColor3 = C.Accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(36, 35, 44)
    track.BorderSizePixel = 0
    track.Parent = container

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = track

    local fill = Instance.new("Frame")
    local pct = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(1, 0)
    fCorner.Parent = fill

    local draggingSlider = false
    local function UpdateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(minVal + (maxVal - minVal) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLbl.Text = tostring(val) .. suffix
        if callback then
            callback(val)
        end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            UpdateFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)

    return container
end

-- ==================== TAB 1: FARM ====================
do
    local cLeft = CreateCard(PageFrames["FARM"], "Throw Automation")
    AddToggle(cLeft, "Auto Throw Loop", false, function(v)
        State.AutoThrow = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Auto Throw: " .. status)
    end)
    AddSlider(cLeft, "Throw Delay", 1, 30, 25, "0ms", function(v)
        State.ThrowDelay = v / 100
    end)
    AddButton(cLeft, "Test Throw (1x)", function()
        DoThrow()
    end)

    local cRight = CreateCard(PageFrames["FARM"], "Food & Free Rewards")
    AddToggle(cRight, "Auto Buy & Equip Best Food", false, function(v)
        State.AutoBuyFood = v
        if v then
            BuyAndEquipBestFood()
        end
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Auto Buy Food: " .. status)
    end)
    AddButton(cRight, "Buy Best Food Now", function()
        BuyAndEquipBestFood()
    end)
    AddToggle(cRight, "Auto Claim Free Gifts / Offline", false, function(v)
        State.AutoClaimFree = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Auto Claim Gifts: " .. status)
    end)
end

-- ==================== TAB 2: WORKOUT ====================
do
    local cLeft = CreateCard(PageFrames["WORKOUT"], "Pull-Up Stand Training")
    AddToggle(cLeft, "Auto Workout (Stand Lock)", false, function(v)
        State.AutoWorkout = v
        if not v then
            StopTraining()
        else
            Log("Auto Workout: ENABLED")
        end
    end)
    AddToggle(cLeft, "Auto Collect x2 Tap Bonus", true, function(v)
        State.AutoTapBonus = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Auto Tap Bonus Collector: " .. status)
    end)
    AddToggle(cLeft, "Anti-Screen Flash / Strobe", true, function(v)
        State.DisableFlash = v
        if ScreenFX then
            pcall(function()
                if setreadonly then
                    setreadonly(ScreenFX, false)
                end
                if v then
                    ScreenFX.Flash = function() end
                    ScreenFX.PulseVignette = function() end
                end
                if setreadonly then
                    setreadonly(ScreenFX, true)
                end
            end)
        end
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Anti-Screen Flash: " .. status)
    end)
    AddSlider(cLeft, "Training Speed", 1, 20, 8, "0ms", function(v)
        State.TrainDelay = v / 100
    end)
    AddToggle(cLeft, "Auto Upgrade Stand", false, function(v)
        State.AutoUpgradeStand = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Auto Upgrade Stand: " .. status)
    end)
    AddButton(cLeft, "Stop Workout & Release", function()
        StopTraining()
    end)

    local cRight = CreateCard(PageFrames["WORKOUT"], "Workout Status")
    local statusInfo = Instance.new("TextLabel")
    statusInfo.Size = UDim2.new(1, 0, 0, 120)
    statusInfo.BackgroundTransparency = 1
    statusInfo.TextColor3 = C.TextDim
    statusInfo.Font = Enum.Font.Gotham
    statusInfo.TextSize = 11
    statusInfo.TextXAlignment = Enum.TextXAlignment.Left
    statusInfo.TextYAlignment = Enum.TextYAlignment.Top
    statusInfo.TextWrapped = true
    statusInfo.Text = "Status: Ready\n\nWhen active: Locks your character to your pull-up stand, runs the workout cycle, and automatically claims the floating x2 tap bonus bubbles without screen strobing."
    statusInfo.Parent = cRight
end

-- ==================== TAB 3: TYCOON ====================
do
    local cLeft = CreateCard(PageFrames["TYCOON"], "Auto Sell (Bad Animals)")
    AddToggle(cLeft, "Auto Sell Bad Animals", false, function(v)
        State.AutoSellBad = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Auto Sell: " .. status)
        if v then
            SellBadAnimals()
        end
    end)
    AddSlider(cLeft, "Sell Interval", 2, 20, 5, "s", function(v)
        State.SellInterval = v
    end)
    AddButton(cLeft, "Sell Bad Animals Now", function()
        SellBadAnimals()
    end)
    AddButton(cLeft, "Clear Plot (Sell All Animals)", function()
        pcall(function()
            R_Plot_SellAll:InvokeServer()
        end)
        Log("All plot animals sold!")
    end)

    local cRight = CreateCard(PageFrames["TYCOON"], "Plot & Enclosure")
    AddToggle(cRight, "Auto Equip Best Animals", false, function(v)
        State.AutoEquipBest = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Auto Equip Best: " .. status)
    end)
    AddButton(cRight, "Equip Best Animals Now", function()
        pcall(function()
            R_Plot_EquipBest:InvokeServer()
        end)
        Log("Best animals equipped to plot.")
    end)
    AddToggle(cRight, "Auto Upgrade Fence / Plot", false, function(v)
        State.AutoUpgradeFence = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Auto Upgrade Fence: " .. status)
    end)
    AddButton(cRight, "Upgrade Fence Now", function()
        pcall(function()
            R_Plot_UpgradeFence:InvokeServer()
        end)
        Log("Fence upgraded.")
    end)
end

-- ==================== TAB 4: TELEPORT ====================
do
    local cLeft = CreateCard(PageFrames["TELEPORT"], "Biome Teleports")
    for name, cf in pairs(Waypoints) do
        if not name:find("My Pull-Up") and not name:find("Stand Upgrade") and not name:find("Sell Shop") then
            AddButton(cLeft, "TP: " .. name, function()
                TeleportTo(cf)
                Log("Teleported to " .. name)
            end)
        end
    end

    local cRight = CreateCard(PageFrames["TELEPORT"], "Key Locations")
    AddButton(cRight, "TP: My Pull-Up Bar", function()
        TeleportTo(Waypoints["My Pull-Up Bar"])
        Log("Teleported to Pull-Up Bar.")
    end)
    AddButton(cRight, "TP: Stand Upgrade Spot", function()
        TeleportTo(Waypoints["Stand Upgrade Spot"])
        Log("Teleported to Stand Upgrade.")
    end)
    AddButton(cRight, "TP: Sell Shop NPC", function()
        TeleportTo(Waypoints["Sell Shop NPC"])
        Log("Teleported to Sell Shop.")
    end)
end

-- ==================== TAB 5: MISC ====================
do
    local cLeft = CreateCard(PageFrames["MISC"], "Character Physics")
    AddSlider(cLeft, "WalkSpeed", 16, 250, 16, "", function(v)
        State.WalkSpeed = v
        if Humanoid then
            Humanoid.WalkSpeed = v
        end
    end)
    AddSlider(cLeft, "JumpPower", 50, 350, 50, "", function(v)
        State.JumpPower = v
        if Humanoid then
            Humanoid.JumpPower = v
        end
    end)
    AddToggle(cLeft, "Noclip", false, function(v)
        State.Noclip = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Noclip: " .. status)
    end)
    AddToggle(cLeft, "Infinite Jump", false, function(v)
        State.InfJump = v
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Infinite Jump: " .. status)
    end)
    AddToggle(cLeft, "Animal ESP", false, function(v)
        State.AnimalESP = v
        if not v then
            EspFolder:ClearAllChildren()
        else
            UpdateESP()
        end
        local status = "DISABLED"
        if v then
            status = "ENABLED"
        end
        Log("Animal ESP: " .. status)
    end)

    local cRight = CreateCard(PageFrames["MISC"], "Live Console Logs")
    local logBox = Instance.new("TextLabel")
    logBox.Size = UDim2.new(1, 0, 0, 240)
    logBox.BackgroundColor3 = Color3.fromRGB(16, 15, 20)
    logBox.TextColor3 = C.TextDim
    logBox.Font = Enum.Font.Code
    logBox.TextSize = 10
    logBox.TextXAlignment = Enum.TextXAlignment.Left
    logBox.TextYAlignment = Enum.TextYAlignment.Top
    logBox.TextWrapped = true
    logBox.Text = table.concat(Logs, "\n")
    logBox.Parent = cRight

    LogCallback = function()
        logBox.Text = table.concat(Logs, "\n")
    end

    AddButton(cRight, "Close Menu (Insert / RCtrl)", function()
        ScreenGui:Destroy()
    end)
end

-- Toggle Hotkey
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl) then
        State.MenuVisible = not State.MenuVisible
        Main.Visible = State.MenuVisible
    end
end)

SwitchTab("FARM")
Log("Phantom Scripts loaded. Anti-Flash active & Clean Workout Release ready.")

end)

if not _main_ok then
    pcall(function()
        local pgui = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pgui then
            local errGui = Instance.new("ScreenGui")
            errGui.Name = "Phantom_FatalCrash"
            errGui.DisplayOrder = 999999
            errGui.ResetOnSpawn = false
            errGui.Parent = pgui

            local errFrame = Instance.new("Frame")
            errFrame.Size = UDim2.new(0, 620, 0, 140)
            errFrame.Position = UDim2.new(0.5, -310, 0, 40)
            errFrame.BackgroundColor3 = Color3.fromRGB(180, 20, 30)
            errFrame.BorderSizePixel = 2
            errFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
            errFrame.Parent = errGui

            local errCorner = Instance.new("UICorner")
            errCorner.CornerRadius = UDim.new(0, 8)
            errCorner.Parent = errFrame

            local errTitle = Instance.new("TextLabel")
            errTitle.Size = UDim2.new(1, 0, 0, 30)
            errTitle.BackgroundTransparency = 1
            errTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            errTitle.TextSize = 16
            errTitle.Font = Enum.Font.GothamBold
            errTitle.Text = "[ PHANTOM SCRIPTS RUNTIME ERROR ]"
            errTitle.Parent = errFrame

            local errDesc = Instance.new("TextLabel")
            errDesc.Size = UDim2.new(1, -20, 1, -40)
            errDesc.Position = UDim2.new(0, 10, 0, 35)
            errDesc.BackgroundTransparency = 1
            errDesc.TextColor3 = Color3.fromRGB(240, 240, 240)
            errDesc.TextSize = 14
            errDesc.Font = Enum.Font.Gotham
            errDesc.TextWrapped = true
            errDesc.TextXAlignment = Enum.TextXAlignment.Left
            errDesc.TextYAlignment = Enum.TextYAlignment.Top
            errDesc.Text = tostring(_main_err)
            errDesc.Parent = errFrame
        end
    end)
    warn("[PHANTOM SCRIPTS CRASH]: " .. tostring(_main_err))
end
