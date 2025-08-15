-- Pluty Hub — WindUI version (clean, fixed)
-- If this script errors, make sure the WindUI URL is reachable and you're in a Roblox executor environment.

if getgenv().r3thexecuted then 
    print("Pluty Hub (WindUI) already executed")
    return 
end
getgenv().r3thexecuted = true

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer

-- (Optional) Theme
WindUI:SetTheme("Dark")
WindUI.TransparencyValue = 0.1

-- Window
local Window = WindUI:CreateWindow({
    Title = "Pluty Hub"
})

-- Sections & Tabs
local Root = Window:Section({ Title = "Pluty Hub", Opened = true })

local Tabs = {
    Visual    = Root:Tab({ Title = "Visual",    Icon = "eye" }),
    Character = Root:Tab({ Title = "Character", Icon = "user" }),
    Teleport  = Root:Tab({ Title = "Teleport",  Icon = "arrow-right" }),
    Combat    = Root:Tab({ Title = "Combat",    Icon = "sword" }),
    Trolling  = Root:Tab({ Title = "Trolling",  Icon = "smile-plus" }),
    AutoFarm  = Root:Tab({ Title = "AutoFarm",  Icon = "calculator" }),
    Spectator = Root:Tab({ Title = "Spectator", Icon = "camera" }),
    Other     = Root:Tab({ Title = "Other",     Icon = "file-cog" }),
    Server    = Root:Tab({ Title = "Server",    Icon = "aperture" }),
    Main      = Root:Tab({ Title = "Main",      Icon = "house" }),
    Settings  = Root:Tab({ Title = "Settings",  Icon = "settings" }),
}

------------------------------------------------------------------
-- VISUAL
------------------------------------------------------------------
do
    local VisualTab = Tabs.Visual

    -- ESP config
    local ESPConfig = {
        Murderer = false,
        Sheriff  = false,
        Innocent = false,
    }

    local MurderName, SheriffName, HeroName

    -- Utility: get/set highlight on a player
    local function getCharacter(player)
        return player.Character
    end

    local function getHighlight(player)
        if not player then return nil end
        local char = getCharacter(player)
        if not char then return nil end
        return char:FindFirstChild("PlutyHighlight")
    end

    local function createHighlight(player, color)
        local char = getCharacter(player)
        if not char then return end
        local h = Instance.new("Highlight")
        h.Name = "PlutyHighlight"
        h.FillColor = color or Color3.new(1,1,1)
        h.OutlineColor = Color3.new(0,0,0)
        h.FillTransparency = 0.75
        h.OutlineTransparency = 0
        h.Adornee = char
        h.Parent = char
        return h
    end

    local function ensureHighlight(player, color)
        local h = getHighlight(player)
        if not h then
            h = createHighlight(player, color)
        end
        return h
    end

    -- Try to fetch roles (fallback to leaderstats Role if exists)
    local function updateRoles()
        MurderName, SheriffName, HeroName = nil, nil, nil
        for _, pl in ipairs(Players:GetPlayers()) do
            local leaderstats = pl:FindFirstChild("leaderstats")
            if leaderstats then
                local roleVal = leaderstats:FindFirstChild("Role")
                if roleVal and roleVal:IsA("StringValue") then
                    local role = roleVal.Value
                    if role == "Murderer" then
                        MurderName = pl.Name
                    elseif role == "Sheriff" then
                        SheriffName = pl.Name
                    elseif role == "Hero" then
                        HeroName = pl.Name
                    end
                end
            end
        end
    end

    local function updateHighlights()
        updateRoles()

        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local h = getHighlight(pl)
                local shouldShow = false
                local color = Color3.fromRGB(255, 255, 255)

                if ESPConfig.Murderer and (pl.Name == MurderName) then
                    shouldShow = true
                    color = Color3.fromRGB(255, 0, 0)
                elseif ESPConfig.Sheriff and (pl.Name == SheriffName or pl.Name == HeroName) then
                    shouldShow = true
                    color = Color3.fromRGB(0, 0, 255)
                elseif ESPConfig.Innocent then
                    shouldShow = true
                    color = Color3.fromRGB(0, 255, 0)
                end

                if shouldShow then
                    h = ensureHighlight(pl, color)
                    if h then
                        h.Enabled = true
                        h.FillColor = color
                    end
                else
                    if h then
                        h.Enabled = false
                    end
                end
            end
        end
    end

    -- ESP toggles
    VisualTab:Toggle({
        Title = "ESP Murderer",
        Value = false,
        Callback = function(state)
            ESPConfig.Murderer = state
            updateHighlights()
        end
    })

    VisualTab:Toggle({
        Title = "ESP Sheriff/Hero",
        Value = false,
        Callback = function(state)
            ESPConfig.Sheriff = state
            updateHighlights()
        end
    })

    VisualTab:Toggle({
        Title = "ESP Innocent (All)",
        Value = false,
        Callback = function(state)
            ESPConfig.Innocent = state
            updateHighlights()
        end
    })

    -- NameTags (simple BillboardGui tags)
    local nameTagsEnabled = false
    local nameTags = {}

    local function createNameTag(player)
        if nameTags[player] then return end
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if not head then return end

        local gui = Instance.new("BillboardGui")
        gui.Name = "PlutyNameTag"
        gui.Size = UDim2.new(0, 200, 0, 30)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true
        gui.Adornee = head

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1,1,1)
        label.TextStrokeTransparency = 0.7
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = player.Name
        label.Parent = gui

        gui.Parent = char
        nameTags[player] = gui
    end

    local function removeNameTag(player)
        local gui = nameTags[player]
        if gui then
            gui:Destroy()
            nameTags[player] = nil
        end
    end

    VisualTab:Toggle({
        Title = "NameTags",
        Value = false,
        Callback = function(state)
            nameTagsEnabled = state
            if not state then
                for pl, _ in pairs(nameTags) do
                    removeNameTag(pl)
                end
            else
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LP then
                        createNameTag(pl)
                    end
                end
            end
        end
    })

    -- Keep updating names/roles/highlights periodically
    task.spawn(function()
        while true do
            if nameTagsEnabled then
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LP then
                        if not nameTags[pl] then
                            createNameTag(pl)
                        end
                    end
                end
            end
            updateHighlights()
            task.wait(1.0)
        end
    end)

    -- GunDrop ESP (simple)
    local gunDropESP = false

    local function highlightGunDrop(obj)
        if not obj then return end
        if obj:FindFirstChild("GunDropHighlight") then return end
        local h = Instance.new("Highlight")
        h.Name = "GunDropHighlight"
        h.FillColor = Color3.fromRGB(0, 255, 255)
        h.OutlineColor = Color3.fromRGB(0, 128, 128)
        h.Adornee = obj
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = obj
    end

    local function scanGunDrops()
        if not gunDropESP then return end
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") and desc.Name == "GunDrop" then
                highlightGunDrop(desc)
            end
        end
    end

    VisualTab:Toggle({
        Title = "ESP GunDrop",
        Value = false,
        Callback = function(state)
            gunDropESP = state
            scanGunDrops()
        end
    })

    task.spawn(function()
        while true do
            scanGunDrops()
            task.wait(2.0)
        end
    end)
end

------------------------------------------------------------------
-- CHARACTER
------------------------------------------------------------------
do
    local CharacterTab = Tabs.Character

    local wsEnabled = false
    local wsValue = 16

    CharacterTab:Toggle({
        Title = "WalkSpeed (Loop)",
        Value = false,
        Callback = function(state)
            wsEnabled = state
        end
    })

    CharacterTab:Slider({
        Title = "WalkSpeed",
        Value = { Min = 0, Max = 100, Default = 16 },
        Step = 1,
        Callback = function(value)
            wsValue = tonumber(value) or 16
        end
    })

    RunService.Heartbeat:Connect(function()
        if wsEnabled then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = wsValue end
        end
    end)

    local jpEnabled = false
    local jpValue = 50

    CharacterTab:Toggle({
        Title = "JumpPower (Loop)",
        Value = false,
        Callback = function(state)
            jpEnabled = state
        end
    })

    CharacterTab:Slider({
        Title = "JumpPower",
        Value = { Min = 0, Max = 200, Default = 50 },
        Step = 1,
        Callback = function(value)
            jpValue = tonumber(value) or 50
        end
    })

    RunService.Heartbeat:Connect(function()
        if jpEnabled then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = jpValue end
        end
    end)

    -- Noclip
    local noclipEnabled = false

    CharacterTab:Toggle({
        Title = "Noclip",
        Value = false,
        Callback = function(state)
            noclipEnabled = state
        end
    })

    RunService.Stepped:Connect(function()
        if noclipEnabled then
            local char = LP.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)
end

------------------------------------------------------------------
-- TELEPORT
------------------------------------------------------------------
do
    local TeleportTab = Tabs.Teleport

    local function playerNames()
        local arr = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then table.insert(arr, p.Name) end
        end
        if #arr == 0 then
            table.insert(arr, "No players")
        end
        return arr
    end

    local selectedName = nil

    local playersDropdown = TeleportTab:Dropdown({
        Title = "Players",
        Values = playerNames(),
        Value = playerNames()[1],
        Callback = function(choice)
            if choice ~= "No players" then
                selectedName = choice
            else
                selectedName = nil
            end
        end
    })

    TeleportTab:Button({
        Title = "Teleport to Player",
        Icon = "navigation",
        Variant = "Primary",
        Callback = function()
            if not selectedName then
                WindUI:Notify({ Title = "Teleport", Content = "No player selected", Duration = 2 })
                return
            end
            local target = Players:FindFirstChild(selectedName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") 
               and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                WindUI:Notify({ Title = "Teleport", Content = "Teleported to "..selectedName, Duration = 2 })
            else
                WindUI:Notify({ Title = "Teleport", Content = "Target not available", Duration = 2 })
            end
        end
    })

    -- simple refresh button to repopulate the dropdown
    TeleportTab:Button({
        Title = "Refresh Players",
        Icon = "refresh-ccw",
        Callback = function()
            local values = playerNames()
            if playersDropdown and playersDropdown.SetValues then
                playersDropdown:SetValues(values)
            end
        end
    })
end

------------------------------------------------------------------
-- Placeholders for other tabs (port later if needed)
------------------------------------------------------------------
local function addComingSoon(tab, name)
    tab:Paragraph({
        Title = name.." — Coming Soon",
        Desc = "Core features are ported. If you need specific tools from Fluent version, tell me which ones to add next."
    })
end

addComingSoon(Tabs.Combat, "Combat")
addComingSoon(Tabs.Trolling, "Trolling")
addComingSoon(Tabs.AutoFarm, "AutoFarm")
addComingSoon(Tabs.Spectator, "Spectator")
addComingSoon(Tabs.Other, "Other")
addComingSoon(Tabs.Server, "Server")
addComingSoon(Tabs.Main, "Main")
addComingSoon(Tabs.Settings, "Settings")

Window:OnClose(function()
    print("Pluty Hub window closed")
end)

Window:OnDestroy(function()
    print("Pluty Hub window destroyed")
end)
