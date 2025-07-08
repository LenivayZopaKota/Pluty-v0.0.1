-- Chams.lua
local Shared = require(game.ReplicatedStorage.Shared) -- Предполагается, что ModuleScript находится в ReplicatedStorage

game:GetService("RunService").Stepped:Connect(function()
    if Shared.PlayerChamsEnabled then
        -- Код для включения Player Chams
    else
        -- Код для выключения Player Chams
    end
end)
