repeat task.wait() until game:IsLoaded()

if Plutyexecuted then 
    print("script already executed")
    return 
end
Plutyexecuted = true

local UIS = game:GetService("UserInputService")
local Touchscreen = UIS.TouchEnabled

getgenv().Device = Touchscreen and "Mobile" or "PC"

if getgenv().Device == "Mobile" then
    loadstring(game:HttpGet(""))()
else
    warn("PC SUPPORT")
    loadstring(game:HttpGet(""))()
end
