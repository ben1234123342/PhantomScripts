-- [[ C4 ROBLOX UNIVERSAL GAME DUMPER & REVERSER ]] --
-- Dumps: Remotes (Events/Functions), Client Controllers/Modules, APIs, and Data structures
-- Outputs: Formatted Luau boilerplate -> writefile() + setclipboard()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local PlaceName = game:GetService("MarketplaceService"):GetProductInfo(PlaceId).Name or ("Place_" .. tostring(PlaceId))

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 6
        })
    end)
    print(string.format("[%s]: %s", title, text))
end

notify("C4 Dumper", "Scanning game tree & network remotes...")

-- Helper: Get full hierarchy path as Luau access string
local function GetPath(inst)
    local path = {}
    local curr = inst
    while curr and curr ~= game do
        local name = curr.Name
        if name:match("^[%a_][%w_]*$") then
            table.insert(path, 1, "." .. name)
        else
            table.insert(path, 1, string.format('["%s"]', name:gsub('"', '\\"')))
        end
        curr = curr.Parent
    end
    
    if curr == game and #path > 0 then
        local root = path[1]:gsub("^%.", ""):gsub('^%["', ''):gsub('"%]$', '')
        local rest = table.concat(path, "", 2, #path)
        return string.format('game:GetService("%s")%s', root, rest)
    end
    return table.concat(path, "")
end

-- 1. Scan Remotes
local RemoteEvents = {}
local RemoteFunctions = {}
local BindableEvents = {}
local BindableFunctions = {}

local scanRoots = {
    ReplicatedStorage,
    workspace,
    LocalPlayer:WaitForChild("PlayerScripts", 3) or LocalPlayer:FindFirstChild("PlayerScripts"),
    LocalPlayer:WaitForChild("PlayerGui", 3) or LocalPlayer:FindFirstChild("PlayerGui")
}

for _, root in ipairs(scanRoots) do
    if root then
        for _, inst in ipairs(root:GetDescendants()) do
            if inst:IsA("RemoteEvent") then
                table.insert(RemoteEvents, { Name = inst.Name, Path = GetPath(inst), Instance = inst })
            elseif inst:IsA("RemoteFunction") then
                table.insert(RemoteFunctions, { Name = inst.Name, Path = GetPath(inst), Instance = inst })
            elseif inst:IsA("BindableEvent") then
                table.insert(BindableEvents, { Name = inst.Name, Path = GetPath(inst), Instance = inst })
            elseif inst:IsA("BindableFunction") then
                table.insert(BindableFunctions, { Name = inst.Name, Path = GetPath(inst), Instance = inst })
            end
        end
    end
end

-- 2. Scan Client Controllers & ModuleScripts
local Controllers = {}
local pScripts = LocalPlayer:FindFirstChild("PlayerScripts")

local function InspectModule(mod)
    local ok, res = pcall(require, mod)
    local members = {}
    if ok and type(res) == "table" then
        for k, v in pairs(res) do
            local t = type(v)
            if t == "function" then
                table.insert(members, { Name = tostring(k), Type = "function" })
            elseif t == "table" then
                table.insert(members, { Name = tostring(k), Type = "table" })
            else
                table.insert(members, { Name = tostring(k), Type = t, Value = tostring(v) })
            end
        end
        table.sort(members, function(a, b) return a.Name < b.Name end)
    end
    return ok, members
end

if pScripts then
    for _, inst in ipairs(pScripts:GetDescendants()) do
        if inst:IsA("ModuleScript") then
            local ok, members = InspectModule(inst)
            table.insert(Controllers, {
                Name = inst.Name,
                Path = GetPath(inst),
                Loaded = ok,
                Members = members
            })
        end
    end
end

-- Also check ReplicatedStorage for shared controllers/modules
for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
    if inst:IsA("ModuleScript") and (inst.Name:match("Controller") or inst.Name:match("Service") or inst.Name:match("Manager") or inst.Name:match("Data")) then
        local ok, members = InspectModule(inst)
        table.insert(Controllers, {
            Name = inst.Name,
            Path = GetPath(inst),
            Loaded = ok,
            Members = members
        })
    end
end

-- 3. Scan Player Data / Stats
local PlayerDataDump = {}
local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
if leaderstats then
    for _, v in ipairs(leaderstats:GetChildren()) do
        table.insert(PlayerDataDump, string.format("leaderstats.%s = %s (%s)", v.Name, tostring(v.Value), v.ClassName))
    end
end

-- 4. Construct Output Code Document
local out = {}
local function w(line) table.insert(out, line or "") end

w("-- ================================================================")
w("-- [[ C4 DUMPER REVERSAL EXPORT ]]")
w("-- Game: " .. PlaceName)
w("-- PlaceId: " .. tostring(PlaceId))
w("-- Generated: " .. os.date("!%Y-%m-%d %H:%M:%SZ"))
w("-- ================================================================\n")

w("-- ==================== 1. REMOTE EVENTS (" .. #RemoteEvents .. ") ====================")
w("local RemoteEvents = {")
for _, r in ipairs(RemoteEvents) do
    w(string.format('    ["%s"] = %s,', r.Name, r.Path))
end
w("}\n")

w("-- ==================== 2. REMOTE FUNCTIONS (" .. #RemoteFunctions .. ") ====================")
w("local RemoteFunctions = {")
for _, r in ipairs(RemoteFunctions) do
    w(string.format('    ["%s"] = %s,', r.Name, r.Path))
end
w("}\n")

if #BindableEvents > 0 then
    w("-- ==================== 3. BINDABLE EVENTS (" .. #BindableEvents .. ") ====================")
    w("local BindableEvents = {")
    for _, r in ipairs(BindableEvents) do
        w(string.format('    ["%s"] = %s,', r.Name, r.Path))
    end
    w("}\n")
end

w("-- ==================== 4. CLIENT CONTROLLERS & MODULES (" .. #Controllers .. ") ====================")
w("local Controllers = {}")
for _, c in ipairs(Controllers) do
    w(string.format('\n-- Module: %s', c.Name))
    w(string.format('Controllers["%s"] = require(%s)', c.Name, c.Path))
    if #c.Members > 0 then
        w("-- Methods & Fields:")
        for _, m in ipairs(c.Members) do
            if m.Type == "function" then
                w(string.format('--   :%s()', m.Name))
            else
                w(string.format('--   .%s [%s]', m.Name, m.Type))
            end
        end
    end
end

if #PlayerDataDump > 0 then
    w("\n-- ==================== 5. LOCAL PLAYER VALUES ====================")
    for _, d in ipairs(PlayerDataDump) do
        w("-- " .. d)
    end
end

w("\n-- ==================== BOILERPLATE SETUP ====================")
w([[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function SafeRequire(inst)
    local ok, res = pcall(require, inst)
    if ok then return res end
    return nil
end
]])

local finalSource = table.concat(out, "\n")

-- 5. Export to Workspace File and Clipboard
local fileName = string.format("Dump_%d.lua", PlaceId)
local wroteFile = false

if writefile then
    pcall(function()
        writefile(fileName, finalSource)
        wroteFile = true
    end)
end

if setclipboard then
    pcall(function()
        setclipboard(finalSource)
    end)
end

local msg = string.format("Dumped %d Remotes, %d Functions, %d Modules.", #RemoteEvents, #RemoteFunctions, #Controllers)
if wroteFile then
    msg = msg .. string.format(" Saved to '%s'.", fileName)
end
if setclipboard then
    msg = msg .. " Copied to Clipboard!"
end

notify("C4 Dumper Complete", msg)
print("\n" .. finalSource)
