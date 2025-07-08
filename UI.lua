local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Создание UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Enabled = false -- Изначально меню скрыто

local Frame = Instance.new("Frame")
Frame.Name = "MenuFrame"
Frame.Size = UDim2.new(0, 650, 0, 450) -- Увеличенный размер
Frame.Position = UDim2.new(0.3, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
Frame.BorderSizePixel = 1
Frame.BorderColor3 = Color3.new(0, 0, 0.5)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local CheatName = Instance.new("TextLabel")
CheatName.Name = "CheatName"
CheatName.Size = UDim2.new(0, 150, 0, 25)
CheatName.Position = UDim2.new(0, 10, 0, 0)
CheatName.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) -- Темно-серый фон
CheatName.BackgroundTransparency = 0
CheatName.TextColor3 = Color3.new(1, 1, 1)
CheatName.Text = "Pluty v0.0.1"
CheatName.Font = Enum.Font.SourceSansBold
CheatName.TextSize = 16
CheatName.TextXAlignment = Enum.TextXAlignment.Left
CheatName.Parent = Frame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -25, 0, 0)
CloseButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) -- Темно-серый фон
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Frame
-- Функция закрытия меню - Прощай, жестокий мир!
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy() -- Уничтожаем меню

end)

local FunctionsPanel = Instance.new("Frame")
FunctionsPanel.Name = "FunctionsPanel"
FunctionsPanel.Size = UDim2.new(0, 150, 0, 430) -- Скорректированная высота
FunctionsPanel.Position = UDim2.new(0.01, 0, 0.04, 0)
FunctionsPanel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
FunctionsPanel.BorderSizePixel = 0
FunctionsPanel.Parent = Frame

local VisualSection = Instance.new("TextButton")
VisualSection.Name = "VisualSection"
VisualSection.Size = UDim2.new(0, 140, 0, 40)
VisualSection.Position = UDim2.new(0, 0, 0.05, 0)
VisualSection.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
VisualSection.TextColor3 = Color3.new(1, 1, 1)
VisualSection.Text = "Visual"
VisualSection.Font = Enum.Font.SourceSansBold
VisualSection.TextSize = 18
VisualSection.BorderSizePixel = 0
VisualSection.Parent = FunctionsPanel

local PlayerSection = Instance.new("TextButton")
PlayerSection.Name = "PlayerSection"
PlayerSection.Size = UDim2.new(0, 140, 0, 40)
PlayerSection.Position = UDim2.new(0, 0, 0.2, 0) -- Ниже кнопки Visual
PlayerSection.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
PlayerSection.TextColor3 = Color3.new(1, 1, 1)
PlayerSection.Text = "Player"
PlayerSection.Font = Enum.Font.SourceSansBold
PlayerSection.TextSize = 18
PlayerSection.BorderSizePixel = 0
PlayerSection.Parent = FunctionsPanel

-- Панели
local VisualPanel = Instance.new("Frame")
VisualPanel.Name = "VisualPanel"
VisualPanel.Size = UDim2.new(0, 360, 0, 320) -- Скорректированная ширина и высота
VisualPanel.Position = UDim2.new(0.25, 0, 0.04, 0)
VisualPanel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
VisualPanel.BorderSizePixel = 0
VisualPanel.Visible = false
VisualPanel.Parent = Frame

local PlayerPanel = Instance.new("Frame")
PlayerPanel.Name = "PlayerPanel"
PlayerPanel.Size = UDim2.new(0, 360, 0, 320) -- Скорректированная ширина и высота
PlayerPanel.Position = UDim2.new(0.25, 0, 0.04, 0)
PlayerPanel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
PlayerPanel.BorderSizePixel = 0
PlayerPanel.Visible = false
PlayerPanel.Parent = Frame

local PlayerChamsButton = Instance.new("TextButton")
PlayerChamsButton.Name = "PlayerChamsButton"
PlayerChamsButton.Size = UDim2.new(0, 220, 0, 30)
PlayerChamsButton.Position = UDim2.new(0, 10, 0, 10)
PlayerChamsButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
PlayerChamsButton.TextColor3 = Color3.new(1, 1, 1)
PlayerChamsButton.Text = "Player Chams"
PlayerChamsButton.Font = Enum.Font.SourceSansBold
PlayerChamsButton.TextSize = 14
PlayerChamsButton.BorderSizePixel = 0
PlayerChamsButton.Parent = VisualPanel

local PocketsButton = Instance.new("TextButton")
PocketsButton.Name = "PocketsButton"
PocketsButton.Size = UDim2.new(0, 220, 0, 30)
PocketsButton.Position = UDim2.new(0, 10, 0, 50)
PocketsButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
PocketsButton.TextColor3 = Color3.new(1, 1, 1)
PocketsButton.Text = "Pockets"
PocketsButton.Font = Enum.Font.SourceSansBold
PocketsButton.TextSize = 14
PocketsButton.BorderSizePixel = 0
PocketsButton.Parent = VisualPanel

local HitBoxPlayerButton = Instance.new("TextButton")
HitBoxPlayerButton.Name = "HitBoxPlayerButton"
HitBoxPlayerButton.Size = UDim2.new(0, 220, 0, 30)
HitBoxPlayerButton.Position = UDim2.new(0, 10, 0, 90)
HitBoxPlayerButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
HitBoxPlayerButton.TextColor3 = Color3.new(1, 1, 1)
HitBoxPlayerButton.Text = "HitBox Player"
HitBoxPlayerButton.Font = Enum.Font.SourceSansBold
HitBoxPlayerButton.TextSize = 14
HitBoxPlayerButton.BorderSizePixel = 0
HitBoxPlayerButton.Parent = VisualPanel

-- Включение/выключение меню
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.Insert then
        if ScreenGui.Enabled then
            ScreenGui.Enabled = false -- Скрываем меню
        else
            ScreenGui.Enabled = true -- Показываем меню
        end
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/LenivayZopaKota/Pluty-v0.0.1/refs/heads/main/Visual.lua"))()
loadstring(game:HttpGet(""))()
loadstring(game:HttpGet(""))()
loadstring(game:HttpGet(""))()
