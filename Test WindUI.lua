do
	local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))();
	local Players = game:GetService("Players");
	local Workspace = game:GetService("Workspace");
	local LocalPlayer = Players.LocalPlayer;

	-- Функция градиента (для заголовков/уведомлений)
	local function gradient(text, startColor, endColor)
		local result, length = "", #text
		for i = 1, length do
			local t = (i - 1) / math.max(length - 1, 1)
			local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
			local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
			local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
			local char = text:sub(i, i)
			result ..= string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, char)
		end
		return result
	end

	-- Уведомление при запуске
	WindUI:Notify({
		Title = gradient("PlutyHub", Color3.fromHex("#ff00cc"), Color3.fromHex("#3333ff")),
		Content = gradient("Script successfully loaded!", Color3.fromHex("#00ffcc"), Color3.fromHex("#00ff66")),
		Icon = "check-circle",
		Duration = 3
	});

	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local userId = LocalPlayer.UserId

	-- Получаем аватар игрока
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

	local Window = WindUI:CreateWindow({
		Title = gradient("PlutyHub", Color3.fromHex("#ff0080"), Color3.fromHex("#00bfff")),
		Icon = "infinity",
		Author = gradient("Murder Mystery 2", Color3.fromHex("#00ffcc"), Color3.fromHex("#33ccff")),
		Folder = "WindUI",
		Size = UDim2.fromOffset(300, 270),
		Transparent = true,
		Theme = "Dark",
		SideBarWidth = 220,
		UserEnabled = true,
		HasOutline = true,
		User = {
			Enabled = true,
			Anonymous = false, -- можно убрать анонимность
			Username = LocalPlayer.Name, -- Ник игрока
			Tag = "@anonymous", -- Подпись под ником
			Image = content, -- Вот тут будет аватарка
			Callback = function()
				print("Открыл профиль:", LocalPlayer.Name)
			end
		},
		ScrollBarEnabled = true
	})


	-- Кнопка открытия
	Window:EditOpenButton({
		Title = "Open UI",
		Icon = "monitor",
		CornerRadius = UDim.new(2, 6),
		StrokeThickness = 2,
		Color = ColorSequence.new(Color3.fromHex("6600ff"), Color3.fromHex("00ccff")),
		Draggable = true
	});

	
	local Tabs = {
		MainTab = Window:Tab({Title = "MAIN", Icon = "terminal"}),
		Divider = Window:Divider(),
		VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" }),
        CharacterTab = Window:Tab({ Title = "Character", Icon = "user" }),
        TeleportTab = Window:Tab({ Title = "Teleport", Icon = "arrow-right" }),
        CombatTab = Window:Tab({ Title = "Combat", Icon = "sword" }),
        TrollingTab = Window:Tab({ Title = "Trolling", Icon = "smile-plus" }),
        AutoFarmTab = Window:Tab({ Title = "AutoFarm", Icon = "calculator" }),
        SpectatorTab = Window:Tab({ Title = "Spectator", Icon = "camera" }),
        OtherTab = Window:Tab({ Title = "Other", Icon = "file-cog" }),
        ServerTab = Window:Tab({ Title = "Server", Icon = "aperture" }),
		Divider2 = Window:Divider(),
        SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" }),
	};
	




	do
				-- // Services
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local LP = Players.LocalPlayer

		-- // Configs
		local ESPConfig = {
			HighlightMurderer = false,
			HighlightInnocent = false,
			HighlightSheriff = false
		}

		local NameTagsConfig = {
			Enabled = false,
			TextSize = 14,
			ShowDistance = true
		}

		local Murder, Sheriff, Hero
		local roles = {}
		local gunDropESPEnabled = false
		local nameTags = {}

		-- // Utility Functions
		local function GetHighlight(player)
			if player == LP then return nil end
			if not player.Character then return nil end

			local highlight = player.Character:FindFirstChild("Highlight")
			if not highlight then
				highlight = Instance.new("Highlight")
				highlight.Name = "Highlight"
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Adornee = player.Character
				highlight.Parent = player.Character
			end
			return highlight
		end

		local function IsAlive(player)
			for name, data in pairs(roles) do
				if player.Name == name then
					return not data.Killed and not data.Dead
				end
			end
			return false
		end

		local function UpdateRoles()
			local success, data = pcall(function()
				return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
			end)
			if success and type(data) == "table" then
				roles = data
				Murder, Sheriff, Hero = nil, nil, nil
				for name, info in pairs(roles) do
					if info.Role == "Murderer" then
						Murder = name
					elseif info.Role == "Sheriff" then
						Sheriff = name
					elseif info.Role == "Hero" then
						Hero = name
					end
				end
			end
		end

		local function UpdateHighlights()
			for _, player in ipairs(Players:GetPlayers()) do
				if player == LP then continue end
				local highlight = GetHighlight(player)
				if not highlight then continue end

				local show = false
				local color = Color3.new(1, 1, 1)

				if ESPConfig.HighlightMurderer and player.Name == Murder and IsAlive(player) then
					color = Color3.fromRGB(255, 0, 0) -- Murderer
					show = true
				elseif ESPConfig.HighlightSheriff and player.Name == Sheriff and IsAlive(player) then
					color = Color3.fromRGB(0, 0, 255) -- Sheriff
					show = true
				elseif ESPConfig.HighlightSheriff and player.Name == Hero and IsAlive(player) and (not Sheriff or not IsAlive(Players[Sheriff])) then
					color = Color3.fromRGB(255, 255, 0) -- Hero
					show = true
				elseif ESPConfig.HighlightInnocent and IsAlive(player) and player.Name ~= Murder and player.Name ~= Sheriff and player.Name ~= Hero then
					color = Color3.fromRGB(0, 255, 0) -- Innocent
					show = true
				end

				highlight.Enabled = show
				highlight.FillColor = color
				highlight.OutlineColor = color
			end
		end

		RunService.Heartbeat:Connect(function()
			UpdateRoles()
			UpdateHighlights()
		end)

		-- // Gun ESP
		local mapPaths = {
			"ResearchFacility", "Hospital3", "MilBase", "House2",
			"Workplace", "Mansion2", "BioLab", "Hotel", "Factory",
			"Bank2", "PoliceStation","BeachResort", "Office3"
		}

		local function createGunDropHighlight(gunDrop)
			if gunDrop and not gunDrop:FindFirstChild("GunDropHighlight") then
				local highlight = Instance.new("Highlight")
				highlight.Name = "GunDropHighlight"
				highlight.FillColor = Color3.fromRGB(0, 255, 255)
				highlight.OutlineColor = Color3.fromRGB(0, 128, 128)
				highlight.Adornee = gunDrop
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Parent = gunDrop
			end
		end

		local function removeGunDropHighlight(gunDrop)
			if gunDrop and gunDrop:FindFirstChild("GunDropHighlight") then
				gunDrop.GunDropHighlight:Destroy()
			end
		end

		local function scanGunDrops()
			for _, mapName in ipairs(mapPaths) do
				local map = workspace:FindFirstChild(mapName)
				if map then
					local gunDrop = map:FindFirstChild("GunDrop")
					if gunDrop then
						if gunDropESPEnabled then
							createGunDropHighlight(gunDrop)
						else
							removeGunDropHighlight(gunDrop)
						end
					end
				end
			end
		end

		task.spawn(function()
			while true do
				scanGunDrops()
				task.wait(2)
			end
		end)

		-- // Nicknames
		local function CreateNameTag(player)
			if player == LP then return end
			if nameTags[player] then
				nameTags[player].gui:Destroy()
				nameTags[player] = nil
			end

			local character = player.Character
			if not character then return end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then return end

			local billboard = Instance.new("BillboardGui")
			local textLabel = Instance.new("TextLabel")

			billboard.Name = "NameTag"
			billboard.Adornee = humanoidRootPart
			billboard.Size = UDim2.new(0, 200, 0, 50)
			billboard.StudsOffset = Vector3.new(0, 2.5, 0)
			billboard.AlwaysOnTop = true
			billboard.MaxDistance = 1000
			billboard.Parent = character

			textLabel.Name = "Label"
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.TextStrokeTransparency = 0.5
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.TextSize = NameTagsConfig.TextSize
			textLabel.Font = Enum.Font.GothamBold
			textLabel.Parent = billboard

			nameTags[player] = { gui = billboard }
		end

		local function RemoveNameTag(player)
			if nameTags[player] then
				if nameTags[player].gui then
					nameTags[player].gui:Destroy()
				end
				nameTags[player] = nil
			end
		end

		local function UpdateNameTagText(player)
			local tagData = nameTags[player]
			if not tagData or not tagData.gui then return end

			local character = player.Character
			if not character then return end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local lpHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart or not lpHRP then
				tagData.gui.Label.Text = player.Name
				return
			end

			local distance = (humanoidRootPart.Position - lpHRP.Position).Magnitude
			if NameTagsConfig.ShowDistance then
				tagData.gui.Label.Text = string.format("%s [%d]", player.Name, math.floor(distance))
			else
				tagData.gui.Label.Text = player.Name
			end
		end

		task.spawn(function()
			while true do
				task.wait(0.5)
				if NameTagsConfig.Enabled then
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= LP then
							local char = player.Character
							local hrp = char and char:FindFirstChild("HumanoidRootPart")
							if hrp then
								if not nameTags[player] or not nameTags[player].gui or nameTags[player].gui.Adornee ~= hrp then
									CreateNameTag(player)
								end
								UpdateNameTagText(player)
							else
								RemoveNameTag(player)
							end
						end
					end
					for p in pairs(nameTags) do
						if not Players:FindFirstChild(p.Name) then
							RemoveNameTag(p)
						end
					end
				else
					for p in pairs(nameTags) do
						RemoveNameTag(p)
					end
				end
			end
		end)

		-- // UI Integration
		Tabs.VisualTab:Section({
			Title = gradient("ESP", Color3.fromHex("#ff0000"), Color3.fromHex("#660000"))
		})

		Tabs.VisualTab:Toggle({
			Title = "ESP Murderer",
			Default = ESPConfig.HighlightMurderer,
			Callback = function(state)
				ESPConfig.HighlightMurderer = state
			end
		})

		Tabs.VisualTab:Toggle({
			Title = "ESP Sheriff",
			Default = ESPConfig.HighlightSheriff,
			Callback = function(state)
				ESPConfig.HighlightSheriff = state
			end
		})

		Tabs.VisualTab:Toggle({
			Title = "ESP Innocent",
			Default = ESPConfig.HighlightInnocent,
			Callback = function(state)
				ESPConfig.HighlightInnocent = state
			end
		})

		Tabs.VisualTab:Toggle({
			Title = "ESP Gun Drop",
			Default = false,
			Callback = function(value)
				gunDropESPEnabled = value
				scanGunDrops()
			end
		})

		Tabs.VisualTab:Button({
			Title = "Force Update ESP",
			Callback = function()
				for _, player in ipairs(Players:GetPlayers()) do
					local h = player.Character and player.Character:FindFirstChild("Highlight")
					if h then h:Destroy() end
				end
			end
		})

		Tabs.VisualTab:Section({
			Title = gradient("Nicknames", Color3.fromHex("#00ffcc"), Color3.fromHex("#0066ff"))
		})

		Tabs.VisualTab:Toggle({
			Title = "Show Nicknames",
			Default = NameTagsConfig.Enabled,
			Callback = function(value)
				NameTagsConfig.Enabled = value
			end
		})

		Tabs.VisualTab:Slider({
			Title = "Nickname size",
			Value = {
				Min = 8,
				Max = 32,
				Default = NameTagsConfig.TextSize
			},
			Callback = function(value)
				NameTagsConfig.TextSize = value
				for _, tagData in pairs(nameTags) do
					if tagData.gui and tagData.gui.Label then
						tagData.gui.Label.TextSize = value
					end
				end
			end
		})

	end

			------CharacterTab-----
	do
				local CharacterTab = Tabs.CharacterTab
			local Players = game:GetService("Players")
			local RunService = game:GetService("RunService")
			local UserInputService = game:GetService("UserInputService")

			local LP = Players.LocalPlayer
			local humanoid, rootPart

			-- ===== WalkSpeed =====
			local defWalk = 16
			local walkSpeed = defWalk
			local walkToggle = false

			CharacterTab:Section({Title = "WalkSpeed"})

			CharacterTab:Slider({
				Title = "WalkSpeed",
				Value = {Min = 16, Max = 100, Default = defWalk},
				Callback = function(value)
					walkSpeed = value
				end
			})

			CharacterTab:Toggle({
				Title = "Toggle WalkSpeed",
				Default = false,
				Callback = function(state)
					walkToggle = state
				end
			})

			-- ===== JumpPower =====
			local defJump = 50
			local jumpPower = defJump
			local jumpToggle = false

			CharacterTab:Section({Title = "JumpPower"})

			CharacterTab:Slider({
				Title = "JumpPower",
				Value = {Min = 20, Max = 100, Default = defJump},
				Callback = function(value)
					jumpPower = value
				end
			})

			CharacterTab:Toggle({
				Title = "Toggle JumpPower",
				Default = false,
				Callback = function(state)
					jumpToggle = state
				end
			})

			-- ===== Fly =====
			local flyEnabled = false
			local flySpeed = 50
			local flyConnections = {}
			local flyBodyVelocity, flyBodyGyro

			CharacterTab:Section({Title = "Movement"})

			CharacterTab:Toggle({
				Title = "Fly",
				Default = false,
				Callback = function(state)
					flyEnabled = state
					if state then startFly() else stopFly() end
				end
			})

			CharacterTab:Slider({
				Title = "Fly Speed",
				Value = {Min = 10, Max = 200, Default = 50},
				Callback = function(value)
					flySpeed = value
				end
			})

			-- ===== Noclip =====
			local noclipEnabled = false
			local noclipConnection

			CharacterTab:Toggle({
				Title = "Noclip",
				Default = false,
				Callback = function(state)
					if state then startNoclip() else stopNoclip() end
				end
			})

			-- ===== Respawn =====
			CharacterTab:Section({Title = "Respawn"})

			CharacterTab:Button({
				Title = "Character Respawn",
				Callback = function()
					local player = LP
					local wasFlying = flyEnabled
					local wasNoclip = noclipEnabled

					if flyEnabled then flyEnabled = false; stopFly() end
					if noclipEnabled then stopNoclip() end

					if player.Character then
						player.Character:BreakJoints()
					end

					task.wait(0.5)

					if wasFlying then flyEnabled = true; startFly() end
					if wasNoclip then startNoclip() end
				end
			})

			-- ===== Helper Functions =====
			local function UpdateHumanoid()
				if LP.Character then
					humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
					rootPart = LP.Character:FindFirstChild("HumanoidRootPart")
				end
			end

			LP.CharacterAdded:Connect(function(char)
				char:WaitForChild("Humanoid")
				char:WaitForChild("HumanoidRootPart")
				UpdateHumanoid()
				if flyEnabled then startFly() end
				if noclipEnabled then startNoclip() end
			end)

			UpdateHumanoid()

			RunService.Heartbeat:Connect(function()
				if humanoid then
					humanoid.WalkSpeed = walkToggle and walkSpeed or defWalk
					humanoid.JumpPower = jumpToggle and jumpPower or defJump
				end
			end)

			-- Fly Functions
			function startFly()
				if not (humanoid and rootPart) then return end
				flyBodyVelocity = Instance.new("BodyVelocity")
				flyBodyGyro = Instance.new("BodyGyro")

				flyBodyVelocity.Velocity = Vector3.zero
				flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
				flyBodyGyro.P = 10000
				flyBodyGyro.D = 500

				flyBodyVelocity.Parent = rootPart
				flyBodyGyro.Parent = rootPart

				humanoid.PlatformStand = true

				local camera = workspace.CurrentCamera
				local activeKeys = {}

				flyConnections.InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
					if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
						activeKeys[input.KeyCode] = true
					end
				end)

				flyConnections.InputEnded = UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						activeKeys[input.KeyCode] = nil
					end
				end)

				flyConnections.Heartbeat = RunService.Heartbeat:Connect(function()
					if not (flyBodyVelocity and flyBodyGyro) then return end

					local moveVector = Vector3.zero
					local cam = camera.CFrame
					local forward = cam.LookVector
					local right = cam.RightVector
					local up = Vector3.new(0,1,0)

					if activeKeys[Enum.KeyCode.W] then moveVector += forward end
					if activeKeys[Enum.KeyCode.S] then moveVector -= forward end
					if activeKeys[Enum.KeyCode.A] then moveVector -= right end
					if activeKeys[Enum.KeyCode.D] then moveVector += right end
					if activeKeys[Enum.KeyCode.Space] then moveVector += up end
					if activeKeys[Enum.KeyCode.LeftShift] then moveVector -= up end

					flyBodyGyro.CFrame = cam
					flyBodyVelocity.Velocity = (moveVector.Magnitude > 0 and moveVector.Unit * flySpeed) or Vector3.zero
				end)
			end

			function stopFly()
				if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
				if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
				for _, conn in pairs(flyConnections) do conn:Disconnect() end
				flyConnections = {}
				if humanoid then humanoid.PlatformStand = false end
			end

			-- Noclip Functions
			function startNoclip()
				noclipEnabled = true
				noclipConnection = RunService.Stepped:Connect(function()
					if LP.Character then
						for _, part in ipairs(LP.Character:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = false
							end
						end
					end
				end)
			end

			function stopNoclip()
				noclipEnabled = false
				if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
			end


	end

			------TeleportTab---

do
	
	local Section = Tabs.TeleportTab:Section({ 
		Title = "Teleport to a person",
		TextXAlignment = "Left",
		TextSize = 17,
	})

	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local teleportTarget = nil

	-- Функция обновления списка игроков
	local function updateTeleportPlayers()
		local playersList = {"Select Player"}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(playersList, player.Name)
			end
		end
		return playersList
	end

	-- Создание выпадающего списка
	local Dropdown = Tabs.TeleportTab:Dropdown({
		Title = "Players",
		Values = updateTeleportPlayers(),
		Value = "Select Player",
		Multi = false,
		Callback = function(selected)
			if selected ~= "Select Player" then
				teleportTarget = Players:FindFirstChild(selected)
			else
				teleportTarget = nil
			end
		end
	})

	-- Автообновление списка игроков
	Players.PlayerAdded:Connect(function()
		task.wait(1)
		Dropdown:SetValues(updateTeleportPlayers())
	end)

	Players.PlayerRemoving:Connect(function()
		Dropdown:SetValues(updateTeleportPlayers())
	end)

	-- Логика телепорта
	local function teleportToPlayer()
		if teleportTarget and teleportTarget.Character then
			local targetRoot = teleportTarget.Character:FindFirstChild("HumanoidRootPart")
			local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			
			if targetRoot and localRoot then
				localRoot.CFrame = targetRoot.CFrame
				WindUI:Notify({
					Title = "Teleport",
					Content = "Successfully teleported to "..teleportTarget.Name,
					Duration = 3
				})
			end
		else
			WindUI:Notify({
				Title = "Error",
				Content = "Target not found or unavailable",
				Duration = 3
			})
		end
	end

	-- Кнопка для телепорта
	Tabs.TeleportTab:Button({
		Title = "Teleport to Selected",
		Locked = false,
		Callback = teleportToPlayer
	})

	-- Кнопка обновления списка игроков
	Tabs.TeleportTab:Button({
		Title = "Update players list",
		Locked = false,
		Callback = function()
			Dropdown:SetValues(updateTeleportPlayers())
		end
	})

	-- Быстрые телепорты
	Tabs.TeleportTab:Section({ Title = "Teleport to", TextXAlignment = "Left", TextSize = 17 })

	Tabs.TeleportTab:Button({
		Title = "Teleport to Lobby",
		Description = "Teleport to the main lobby area",
		Callback = function()
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(112.961197, 140.252960, 46.383835)
		end
	})

	Tabs.TeleportTab:Button({
		Title = "Teleport to Sheriff",
		Callback = function()
			for _, v in pairs(Players:GetPlayers()) do
				if v.Character and (v.Character:FindFirstChild("Gun") or (v.Backpack and v.Backpack:FindFirstChild("Gun"))) then
					LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
					break
				end
			end
		end
	})

	Tabs.TeleportTab:Button({
		Title = "Teleport to Murderer",
		Callback = function()
			for _, v in pairs(Players:GetPlayers()) do
				if v.Character and (v.Character:FindFirstChild("Knife") or (v.Backpack and v.Backpack:FindFirstChild("Knife"))) then
					LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
					break
				end
			end
		end
	})

	-- ================== GrabGun ==================
	Tabs.TeleportTab:Section({ Title = "GrabGun", TextXAlignment = "Left", TextSize = 17 })

	local gunDropESPEnabled = true
	local autoGrabEnabled = false
	local notifiedGunDrops = {}
	local autoGrabLocked = false
	local lastGrabTime = 0
	local grabAttempts = 0

	local mapGunDrops = {
		"ResearchFacility", "Hospital3", "MilBase", "House2", "Workplace",
		"Mansion2", "BioLab", "Hotel", "Factory", "Bank2", "PoliceStation",
		"Yacht", "Office3", "BeachResort"
	}

	local function grabGunFast(gunDrop)
		if not gunDrop or not LocalPlayer.Character then return false end
		if LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Gun") then 
			return true
		end
		local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not root then return false end

		local originalCFrame = root.CFrame
		root.CFrame = gunDrop.CFrame + Vector3.new(0, 2.5, 0)

		task.delay(0.15, function()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
			end
		end)

		task.wait(0.2)
		return LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Gun")
	end

	local function checkForGunDrops()
		if autoGrabLocked then return end
		if autoGrabEnabled and (tick() - lastGrabTime) < 2 then return end

		for _, mapName in ipairs(mapGunDrops) do
			local map = workspace:FindFirstChild(mapName)
			if map then
				local gunDrop = map:FindFirstChild("GunDrop")
				if gunDrop then
					if not notifiedGunDrops[gunDrop] then
						notifiedGunDrops = {}
						notifiedGunDrops[gunDrop] = true

						if gunDropESPEnabled then
							WindUI:Notify({
								Title = "Gun Drop Spawned",
								Content = "A gun has appeared on the map: " .. mapName,
								Icon = "alert-circle",
								Duration = 5
							})
						end

						if autoGrabEnabled then
							lastGrabTime = tick()
							grabAttempts += 1
							local success = grabGunFast(gunDrop)
							if success or grabAttempts >= 2 then
								autoGrabLocked = true
							end
						end
					elseif autoGrabEnabled then
						lastGrabTime = tick()
						grabAttempts += 1
						local success = grabGunFast(gunDrop)
						if success or grabAttempts >= 2 then
							autoGrabLocked = true
						end
					end
				end
			end
		end
	end

	local function manualGrabGun()
		for _, mapName in ipairs(mapGunDrops) do
			local map = workspace:FindFirstChild(mapName)
			if map then
				local gunDrop = map:FindFirstChild("GunDrop")
				if gunDrop then
					grabGunFast(gunDrop)
					return
				end
			end
		end
		WindUI:Notify({
			Title = "Gun System",
			Content = "No GunDrop found on map",
			Icon = "x",
			Duration = 3
		})
	end

	LocalPlayer.CharacterAdded:Connect(function()
		autoGrabLocked = false
		grabAttempts = 0
	end)

	-- UI Toggles
	Tabs.TeleportTab:Toggle({
		Title = "Notify GunDrop",
		Default = true,
		Callback = function(state)
			gunDropESPEnabled = state
		end
	})

	Tabs.TeleportTab:Toggle({
		Title = "Auto Grab Gun",
		Default = false,
		Callback = function(state)
			autoGrabEnabled = state
			WindUI:Notify({
				Title = "Gun System",
				Content = autoGrabEnabled and "Auto Grab Gun enabled" or "Auto Grab Gun disabled",
				Icon = autoGrabEnabled and "check-circle" or "x",
				Duration = 3
			})
		end
	})

	Tabs.TeleportTab:Button({
		Title = "Grab Gun",
		Callback = manualGrabGun
	})

	-- Проверка каждые 0.3 сек
	task.spawn(function()
		if not LocalPlayer.Character then
			LocalPlayer.CharacterAdded:Wait()
		end
		while task.wait(0.3) do
			checkForGunDrops()
		end
	end)




end

			---------CombatTab--------

	do
		
					-- Combat Tab setup
			local CombatSection = Tabs.CombatTab:Section({
				Title = "Sheriff"
			})

			-- Local state
			local Players = game:GetService("Players")
			local Workspace = game:GetService("Workspace")
			local RunService = game:GetService("RunService")
			local UserInputService = game:GetService("UserInputService")
			local LocalPlayer = Players.LocalPlayer
			local Camera = Workspace.CurrentCamera

			-- Config
			local PRIORITY_PARTS = {
				"HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso", "Head",
				"RightUpperLeg", "LeftUpperLeg", "RightUpperArm", "LeftUpperArm",
				"RightLowerLeg", "LeftLowerLeg", "RightLowerArm", "LeftLowerArm"
			}
			local CHECK_GUN_INTERVAL = 4
			local FIND_TARGET_INTERVAL = 0.4
			local AIM_SMOOTHNESS = 1
			local NOTIFY_DURATION = 4

			-- State
			local previousMouseBehavior = nil
			local notifiedNoGun = false
			local uiToggle, uiKeybind = nil, nil
			local fallbackToggle = false
			local fallbackKeyToggled = false
			local fallbackKeyEnum = Enum.KeyCode.E

			-- Helpers
			local function GetCamera()
				Camera = Camera or Workspace.CurrentCamera
				return Camera
			end

			local function HasGun()
				local char = LocalPlayer.Character
				if char then
					for _, v in ipairs(char:GetChildren()) do
						if v:IsA("Tool") and (v.Name:lower():find("gun")) then return true end
					end
				end
				local backpack = LocalPlayer:FindFirstChild("Backpack")
				if backpack then
					for _, v in ipairs(backpack:GetChildren()) do
						if v:IsA("Tool") and (v.Name:lower():find("gun")) then return true end
					end
				end
				return false
			end

			local function IsMurderer(player)
				if not player or player == LocalPlayer then return false end
				if player.Character and player.Character:FindFirstChild("Knife") then return true end
				if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife") then return true end
				return false
			end

			local function IsInViewport(part)
				local cam = GetCamera()
				if not cam or not part then return false end
				local sp, onScreen = cam:WorldToViewportPoint(part.Position)
				local vs = cam.ViewportSize
				return onScreen and sp.X >= 0 and sp.Y >= 0 and sp.X <= vs.X and sp.Y <= vs.Y
			end

			local function IsPartVisible(part)
				if not part then return false end
				if not IsInViewport(part) then return false end
				local camPos = GetCamera().CFrame.Position
				local dir = part.Position - camPos
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Blacklist
				params.FilterDescendantsInstances = { LocalPlayer.Character }
				local res = Workspace:Raycast(camPos, dir, params)
				return not res or res.Instance:IsDescendantOf(part.Parent)
			end

			local function FindVisibleMurdererPart()
				local camPos = GetCamera().CFrame.Position
				local bestDist, bestPart, bestPlayer = math.huge, nil, nil
				for _, plr in ipairs(Players:GetPlayers()) do
					if IsMurderer(plr) and plr.Character then
						local char = plr.Character
						local found = false
						for _, name in ipairs(PRIORITY_PARTS) do
							local part = char:FindFirstChild(name)
							if part and part:IsA("BasePart") and IsPartVisible(part) then
								local dist = (camPos - part.Position).Magnitude
								if dist < bestDist then
									bestDist, bestPart, bestPlayer = dist, part, plr
								end
								found = true
								break
							end
						end
						if not found then
							for _, desc in ipairs(char:GetDescendants()) do
								if desc:IsA("BasePart") and IsPartVisible(desc) then
									local dist = (camPos - desc.Position).Magnitude
									if dist < bestDist then
										bestDist, bestPart, bestPlayer = dist, desc, plr
									end
									break
								end
							end
						end
					end
				end
				return bestPart, bestPlayer
			end

			local function AimCameraAtPart(part)
				if not part then return end
				local cam = GetCamera()
				local desired = CFrame.new(cam.CFrame.Position, part.Position)
				if AIM_SMOOTHNESS >= 0.999 then
					cam.CFrame = desired
				else
					cam.CFrame = cam.CFrame:Lerp(desired, math.clamp(AIM_SMOOTHNESS, 0, 1))
				end
			end

			local function SetShiftLockOn()
				if previousMouseBehavior == nil then previousMouseBehavior = UserInputService.MouseBehavior end
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			end

			local function RestoreMouseBehavior()
				if previousMouseBehavior then
					UserInputService.MouseBehavior = previousMouseBehavior
					previousMouseBehavior = nil
				else
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end
			end

			local function NotifyNoGunOnce()
				if notifiedNoGun then return end
				notifiedNoGun = true
				print("[AimBot] No gun equipped!")
			end
			local function ResetNoGunNotification() notifiedNoGun = false end

			local function GetToggleState()
				if uiToggle and uiToggle.GetState then return uiToggle:GetState() end
				return fallbackToggle
			end

			local function GetKeybindState()
				if uiKeybind and uiKeybind.GetState then return uiKeybind:GetState() end
				return fallbackKeyToggled
			end

			-- UI

			Tabs.CombatTab:Toggle({
				Title = "AimBot",
				Callback = function(val)
					fallbackToggle = val
					print("[AimBot] Toggle:", val)
					if not val then RestoreMouseBehavior() end
				end
			})

			local KeyBind = Tabs.CombatTab:Keybind({
				Title = "Keybind AimBot",
				Desc = "",
				Value = "E",
				Callback = function(val)
					fallbackKeyEnum = Enum.KeyCode[val:upper()] or Enum.KeyCode.E
					print("[AimBot] Keybind set to", val)
				end
			})

			-- Main loop
			task.spawn(function()
				while true do
					task.wait(0.05)
					if not GetToggleState() or not GetKeybindState() then
						RestoreMouseBehavior()
						task.wait(0.15)
						continue
					end
					if not HasGun() then
						NotifyNoGunOnce()
						while GetToggleState() and GetKeybindState() and not HasGun() do
							task.wait(CHECK_GUN_INTERVAL)
						end
					end
					if not GetToggleState() or not GetKeybindState() then
						RestoreMouseBehavior()
						task.wait(0.1)
						continue
					end
					ResetNoGunNotification()
					while GetToggleState() and GetKeybindState() and HasGun() do
						local part, plr = FindVisibleMurdererPart()
						if part and plr then
							SetShiftLockOn()
							while GetToggleState() and GetKeybindState() and HasGun() and plr and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 and IsPartVisible(part) do
								RunService.RenderStepped:Wait()
								AimCameraAtPart(part)
								if plr and plr.Character then
									local newPart = plr.Character:FindFirstChild(part.Name)
									if newPart then part = newPart end
								end
							end
							RestoreMouseBehavior()
						else
							task.wait(FIND_TARGET_INTERVAL)
						end
						if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
							RestoreMouseBehavior()
							break
						end
					end
					RestoreMouseBehavior()
					task.wait(0.1)
				end
			end)

			-- Respawn handling
			LocalPlayer.CharacterAdded:Connect(function(char)
				RestoreMouseBehavior()
				notifiedNoGun = false
				local ok, hum = pcall(function() return char:WaitForChild("Humanoid", 30) end)
				if ok and hum then
					hum.Died:Connect(function() RestoreMouseBehavior() end)
				else
					RestoreMouseBehavior()
				end
			end)
			LocalPlayer.CharacterRemoving:Connect(RestoreMouseBehavior)

				

		 -------------------------- Silent Aim --------------------------

			-- Services
			local Players = game:GetService("Players")
			local Workspace = game:GetService("Workspace")
			local UserInputService = game:GetService("UserInputService")

			local LocalPlayer = Players.LocalPlayer
			local Camera = Workspace and Workspace.CurrentCamera

			-- ===== Config =====
			local BULLET_SPEED = 1200
			local PREDICT_ITERATIONS = 1
			local SHOT_COOLDOWN = 0.03
			local REMOTE_ARG1 = 1
			local REMOTE_ARG3 = "AH2"

			-- ===== State & caches =====
			local lastShot = 0
			local cachedGunName, cachedRemote = nil, nil

			-- Наши переменные для Toggle и Keybind
			local SilentAimEnabled = false
			local SilentAimKey = Enum.KeyCode.R

			-- ===== Helpers =====
			local function GetCamera()
				Camera = Camera or (Workspace and Workspace.CurrentCamera)
				return Camera
			end

			local function LocalAlive()
				local ch = LocalPlayer and LocalPlayer.Character
				if not ch then return false end
				local hum = ch:FindFirstChildOfClass("Humanoid")
				return hum and hum.Health > 0
			end

			local function FindMurdererPlayerFast()
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl ~= LocalPlayer then
						local char = pl.Character
						if char then
							local hum = char:FindFirstChildOfClass("Humanoid")
							if hum and hum.Health > 0 then
								if char:FindFirstChild("Knife") then
									return pl
								end
								local bp = pl:FindFirstChild("Backpack")
								if bp and bp:FindFirstChild("Knife") then
									return pl
								end
							end
						end
					end
				end
				return nil
			end

			local function GetPreferredPart(plr)
				if not plr or not plr.Character then return nil end
				local char = plr.Character
				local prefer = { "HumanoidRootPart", "UpperTorso", "Torso", "Head", "LowerTorso" }
				for _, name in ipairs(prefer) do
					local p = char:FindFirstChild(name)
					if p and p:IsA("BasePart") then return p end
				end
				for _, d in ipairs(char:GetDescendants()) do
					if d:IsA("BasePart") then return d end
				end
				return nil
			end

			local function IsPartVisibleFast(part)
				if not part then return false end
				local cam = GetCamera()
				if not cam then return false end
				local sp, onScreen = cam:WorldToViewportPoint(part.Position)
				if not onScreen then return false end
				local vx, vy = sp.X, sp.Y
				local vs = cam.ViewportSize
				if vx < 0 or vy < 0 or vx > vs.X or vy > vs.Y then return false end

				local origin = cam.CFrame.Position
				local dir = (part.Position - origin)
				if dir.Magnitude <= 0.01 then return true end

				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Blacklist
				params.FilterDescendantsInstances = { LocalPlayer.Character }
				local res = Workspace:Raycast(origin, dir, params)
				if not res then return true end
				return res.Instance and res.Instance:IsDescendantOf(part.Parent)
			end

			local function PredictPositionFast(part)
				if not part then return nil end
				local cam = GetCamera()
				if not cam then return part.Position end

				local origin = cam.CFrame.Position
				local targetPos = part.Position

				local vel = Vector3.new(0,0,0)
				pcall(function() vel = part.AssemblyLinearVelocity end)
				if (vel == Vector3.new(0,0,0) or vel == nil) and part.Velocity then vel = part.Velocity end

				local predicted = targetPos
				for i = 1, PREDICT_ITERATIONS do
					local dist = (predicted - origin).Magnitude
					local t = (BULLET_SPEED > 0) and (dist / BULLET_SPEED) or 0.0001
					predicted = targetPos + vel * t
				end
				return predicted
			end

			local function GetLocalGunObjectFast()
				local char = LocalPlayer and LocalPlayer.Character
				if char then
					local g = char:FindFirstChild("Gun")
					if g and g:IsA("Tool") then return g end
					for _, o in ipairs(char:GetChildren()) do
						if o:IsA("Tool") and o:FindFirstChild("IsGun") then return o end
					end
				end
				local bp = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
				if bp then
					local g = bp:FindFirstChild("Gun")
					if g and g:IsA("Tool") then return g end
					for _, o in ipairs(bp:GetChildren()) do
						if o:IsA("Tool") and o:FindFirstChild("IsGun") then return o end
					end
				end
				return nil
			end

			local function EnsureGunEquippedFast()
				local gun = GetLocalGunObjectFast()
				if not gun then return nil end
				if LocalPlayer.Character and gun.Parent ~= LocalPlayer.Character then
					pcall(function() gun.Parent = LocalPlayer.Character end)
					task.wait(0.01)
				end
				if LocalPlayer.Character then
					local g = LocalPlayer.Character:FindFirstChild(gun.Name)
					if g and g:IsA("Tool") then return g end
				end
				return gun
			end

			local function GetCachedRemoteForGun(gun)
				if not gun then
					cachedGunName = nil
					cachedRemote = nil
					return nil
				end

				if cachedGunName == gun.Name and cachedRemote and cachedRemote.Parent and cachedRemote:IsDescendantOf(gun) then
					return cachedRemote
				end

				cachedGunName = nil
				cachedRemote = nil

				local ok, knifeLocal = pcall(function() return gun:FindFirstChild("KnifeLocal") end)
				if ok and knifeLocal then
					local cb = knifeLocal:FindFirstChild("CreateBeam")
					if cb then
						local rf = cb:FindFirstChildWhichIsA("RemoteFunction")
						if rf then
							cachedGunName = gun.Name
							cachedRemote = rf
							return rf
						end
					end
				end

				for _, desc in ipairs(gun:GetDescendants()) do
					if desc:IsA("RemoteFunction") then
						local pname = desc.Parent and tostring(desc.Parent.Name):lower() or ""
						if pname:find("create") or pname:find("beam") or pname:find("knife") then
							cachedGunName = gun.Name
							cachedRemote = desc
							return desc
						end
					end
				end

				for _, desc in ipairs(gun:GetDescendants()) do
					if desc:IsA("RemoteFunction") then
						cachedGunName = gun.Name
						cachedRemote = desc
						return desc
					end
				end

				cachedGunName = nil
				cachedRemote = nil
				return nil
			end

			local function ResetCaches()
				cachedGunName = nil
				cachedRemote = nil
			end

			-- Main silent aim shoot
			local function SilentShootOnceFast()
				local now = tick()
				if now - lastShot < SHOT_COOLDOWN then return false end
				lastShot = now

				if not LocalAlive() then return false end

				local murderer = FindMurdererPlayerFast()
				if not murderer then return false end

				local part = GetPreferredPart(murderer)
				if not part then return false end
				if not IsPartVisibleFast(part) then return false end

				local aimPos = PredictPositionFast(part) or part.Position

				local gun = EnsureGunEquippedFast()
				if not gun then return false end

				local rf = GetCachedRemoteForGun(gun)
				if not rf then return false end

				local ok, res = pcall(function() return rf:InvokeServer(REMOTE_ARG1, aimPos, REMOTE_ARG3) end)
				if ok then
					return true
				else
					warn("[SilentAimFast] Invoke error:", res)
					ResetCaches()
					return false
				end
			end

			-- ===== UI (твои Toggle и Keybind) =====
			local Toggle = Tabs.CombatTab:Toggle({ 
				Title = "SilentAim Toggle", 
				Default = false,
				Callback = function(state) 
					SilentAimEnabled = state
					print("[SilentAim] Enabled:", state)
				end
			})

			local Keybind = Tabs.CombatTab:Keybind({ 
				Title = "Bind SilentAim", 
				Desc = "",
				Value = "R", 
				Callback = function(v)
					if Enum.KeyCode[v] then
						SilentAimKey = Enum.KeyCode[v]
						print("[SilentAim] Keybind changed to:", v)
					end
				end
			})

			-- ===== Input =====
			UserInputService.InputBegan:Connect(function(input, processed)
				if processed then return end
				if not SilentAimEnabled then return end

				if input.KeyCode == SilentAimKey then
					pcall(function()
						local ok = SilentShootOnceFast()
						if ok then
							print("[SilentAim] Shot fired")
						end
					end)
				end
			end)

			-- ===== Reset caches on respawn =====
			if LocalPlayer then
				LocalPlayer.CharacterAdded:Connect(function(char)
					ResetCaches()
					task.spawn(function()
						local hum = char:WaitForChild("Humanoid", 10)
						if hum then
							hum.Died:Connect(function()
								ResetCaches()
							end)
						end
					end)
				end)
				LocalPlayer.CharacterRemoving:Connect(function()
					ResetCaches()
				end)
			end

					------killAll-----

			
				
				local Section = Tabs.CombatTab:Section({ 
					Title = "Murder",
					TextXAlignment = "Left",
					TextSize = 17,
				})

				--// Services
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local RunService = game:GetService("RunService")

				--// Locals
				local LP = Players.LocalPlayer
				local KnifeRemoteCache = {}
				local KillAllEnabled = false
				local ROLES = {}

				-- ===== Utils =====
				local function GetRoot(char)
					if not char then return nil end
					return char:FindFirstChild("HumanoidRootPart")
						or char:FindFirstChild("UpperTorso")
						or char:FindFirstChild("Torso")
				end

				local function IsAlive(plr)
					if not plr or not plr.Character then return false end
					local hum = plr.Character:FindFirstChildOfClass("Humanoid")
					return hum and hum.Health > 0
				end

				local function Message(title, text, time)
					pcall(function()
						game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = title,
							Text = text,
							Duration = time or 3
						})
					end)
				end

				-- Таблица ролей (если есть в игре)
				local function UpdateRoles()
					local rf = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
					if not rf then return end
					local ok, data = pcall(function()
						return rf:InvokeServer()
					end)
					if ok and type(data) == "table" then
						ROLES = data
					end
				end

				local function RoleIsTarget(plr)
					local info = ROLES[plr.Name]
					if not info then
						-- Фоллбек: если не смогли получить роли — считаем целью всех, кроме нас и мёртвых
						return true
					end
					local role = info.Role or info.role
					return role == "Innocent" or role == "Sheriff" or role == "Hero"
				end

				-- Экип ножа (если ты убийца)
				local function EquipKnife()
					local char = LP.Character or LP.CharacterAdded:Wait()
					local hum = char:FindFirstChildOfClass("Humanoid")
					if not hum then return nil end

					local knife = char:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
					if not knife then return nil end

					if knife.Parent == LP.Backpack then
						hum:EquipTool(knife)
						task.wait(0.05)
					end
					return knife
				end

				-- Собираем все Remote’ы ножа (и кэшируем)
				local function CollectKnifeRemotes(knife)
					if not knife then return {} end
					if KnifeRemoteCache[knife] then
						return KnifeRemoteCache[knife]
					end
					local rems = {}
					for _, d in ipairs(knife:GetDescendants()) do
						if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
							rems[#rems+1] = d
						end
					end
					KnifeRemoteCache[knife] = rems
					return rems
				end

				-- Пробуем «удалённое убийство» через все найденные remote’ы (всё в pcall)
				local function TryRemoteKill(knife, targetPart)
					local anyFired = false
					if not knife or not targetPart then return false end
					local rems = CollectKnifeRemotes(knife)

					for _, r in ipairs(rems) do
						local ok = pcall(function()
							if r:IsA("RemoteFunction") then
								-- популярные сигнатуры (всё безопасно в pcall)
								r:InvokeServer(1, targetPart.Position, "AH2")
							else
								r:FireServer(1, targetPart.Position, "AH2")
							end
						end)
						anyFired = anyFired or ok
						task.wait()
						local hum = targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health <= 0 then
							return true
						end
					end

					-- альтернативные сигнатуры
					for _, r in ipairs(rems) do
						local ok = pcall(function()
							if r:IsA("RemoteFunction") then
								r:InvokeServer(targetPart, targetPart.Position)
							else
								r:FireServer(targetPart, targetPart.Position)
							end
						end)
						anyFired = anyFired or ok
						task.wait()
						local hum = targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health <= 0 then
							return true
						end
					end

					return false
				end

				-- Безопасный быстрый микротп + спам удара и возврат назад
				local function MeleeRush(knife, targetPart, maxTime)
					local char = LP.Character
					local root = GetRoot(char)
					if not (char and root and knife and targetPart) then return false end
					maxTime = maxTime or 0.25

					local startCF = root.CFrame

					-- локальный no-clip на время рывка
					local noclip = true
					local conn = RunService.Stepped:Connect(function()
						if not noclip then return end
						for _, p in ipairs(char:GetDescendants()) do
							if p:IsA("BasePart") then
								p.CanCollide = false
							end
						end
					end)

					-- прыжок к цели (чуть сбоку/сверху, чтобы не застревать)
					local tpos = targetPart.Position
					root.CFrame = CFrame.new(tpos + Vector3.new(0, 1.2, 0))

					-- спам ударов
					local t0 = tick()
					local dead = false
					while tick() - t0 < maxTime do
						pcall(function() knife:Activate() end)
						local hum = targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health <= 0 then
							dead = true
							break
						end
						task.wait(0.05)
					end

					-- возврат + полный сброс инерции
					root.CFrame = startCF
					for _, p in ipairs(char:GetDescendants()) do
						if p:IsA("BasePart") then
							p.AssemblyLinearVelocity = Vector3.new()
							p.AssemblyAngularVelocity = Vector3.new()
						end
					end

					noclip = false
					if conn then conn:Disconnect() end

					return dead
				end

				-- Убить одного игрока (все способы)
				local function KillOne(plr)
					if not IsAlive(plr) then return end
					if not RoleIsTarget(plr) then return end

					local knife = EquipKnife()
					if not knife then return end

					local part = GetRoot(plr.Character) or plr.Character:FindFirstChild("Head")
					if not part then return end

					-- 1) пробуем remote-kill
					if TryRemoteKill(knife, part) then
						return
					end

					-- 2) если не сработало — делаем короткий рывок и спамим Activate()
					MeleeRush(knife, part, 0.35)
				end

				-- Основной цикл
				task.spawn(function()
					-- ждём персонажа
					if not LP.Character then LP.CharacterAdded:Wait() end
					while task.wait(0.2) do
						if KillAllEnabled then
							UpdateRoles()
							for _, pl in ipairs(Players:GetPlayers()) do
								if pl ~= LP and IsAlive(pl) then
									-- игнорируем шерифа/инно/героя только если включены роли
									if RoleIsTarget(pl) then
										KillOne(pl)
										task.wait(0.05)
									end
								end
							end
						end
					end
				end)

				-- UI Toggle
				local Toggle = Tabs.CombatTab:Toggle({
					Title = "KillAll",
					Desc = "",
					Default = false,
					Callback = function(state)
						KillAllEnabled = state
						if state then
							WindUI:Notify("KillAll", "On", 3)
						else
							WindUI:Notify("KillAll", "Off", 2)
						end
					end
				})

				

				------ Knife Aura ------
	

	--// Services
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")

	--// Locals
	local LP = Players.LocalPlayer
	local KnifeAuraEnabled = false
	local KnifeAuraRadius = 15 -- стартовый радиус

	-- ===== Utils =====
	local function GetRoot(char)
		if not char then return nil end
		return char:FindFirstChild("HumanoidRootPart")
			or char:FindFirstChild("UpperTorso")
			or char:FindFirstChild("Torso")
	end

	local function IsAlive(plr)
		if not plr or not plr.Character then return false end
		local hum = plr.Character:FindFirstChildOfClass("Humanoid")
		return hum and hum.Health > 0
	end

	local function EquipKnife()
		local char = LP.Character
		if not char then return nil end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return nil end

		local knife = char:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
		if not knife then return nil end

		if knife.Parent == LP.Backpack then
			hum:EquipTool(knife)
			task.wait(0.05)
		end
		return knife
	end

	-- Атака цели (локально Knife:Activate() + Remote fallback)
	local function AttackTarget(knife, targetPart)
		if not knife or not targetPart then return end
		pcall(function() knife:Activate() end)
		for _, d in ipairs(knife:GetDescendants()) do
			if d:IsA("RemoteEvent") then
				pcall(function() d:FireServer(1, targetPart.Position, "AH2") end)
			elseif d:IsA("RemoteFunction") then
				pcall(function() d:InvokeServer(1, targetPart.Position, "AH2") end)
			end
		end
	end

	-- ===== Основной цикл ауры =====
	task.spawn(function()
		while task.wait(0.2) do
			if KnifeAuraEnabled then
				local knife = EquipKnife()
				if knife then
					local root = GetRoot(LP.Character)
					if root then
						for _, pl in ipairs(Players:GetPlayers()) do
							if pl ~= LP and IsAlive(pl) then
								local targetRoot = GetRoot(pl.Character)
								if targetRoot and (targetRoot.Position - root.Position).Magnitude <= KnifeAuraRadius then
									AttackTarget(knife, targetRoot)
								end
							end
						end
					end
				end
			end
		end
	end)

	-- UI Toggle
	local Toggle = Tabs.CombatTab:Toggle({
		Title = "Knife Aura",
		Desc = "",
		Default = false,
		Callback = function(state)
			KnifeAuraEnabled = state
		end
	})

	-- UI Slider (радиус)
	local Slider = Tabs.CombatTab:Slider({
		Title = "Aura Radius",
		Step = 1,
		Desc = "",
		Value = {
			Min = 10,
			Max = 100,
			Default = 15,
		},
		Callback = function(val)
			KnifeAuraRadius = val
		end
	})

	


					

			
	end



					---------------------------TrollingTab----------


	do
		local Section = Tabs.TrollingTab:Section({ 
			Title = "Fling",
			TextXAlignment = "Left",
			TextSize = 17,
		})

		-- === Переменные ===
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local trollTarget = nil
		local FlingActive = false
		getgenv().OldPos = nil
		getgenv().FPDH = workspace.FallenPartsDestroyHeight

		-- утилита для корня
		local function getRoot(char)
			if not char then return nil end
			return char:FindFirstChild("HumanoidRootPart")
				or char:FindFirstChild("Torso")
				or char:FindFirstChild("UpperTorso")
		end

		-- === Обновление списка игроков ===
		local function updateTrollingPlayers()
			local playersList = {"Select Player"}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(playersList, player.Name)
				end
			end
			return playersList
		end

		-- === Dropdown ===
		local Dropdown = Tabs.TrollingTab:Dropdown({
			Title = "Players",
			Values = updateTrollingPlayers(),
			Multi = false,
			Callback = function(selected)
				if selected ~= "Select Player" then
					trollTarget = Players:FindFirstChild(selected)
				else
					trollTarget = nil
				end
			end
		})

		-- Автообновление игроков
		Players.PlayerAdded:Connect(function()
			task.wait(1)
			Dropdown:SetValues(updateTrollingPlayers())
		end)

		Players.PlayerRemoving:Connect(function()
			Dropdown:SetValues(updateTrollingPlayers())
		end)

		-- === Notification ===
		local function Message(Title, Text, Time)
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = Title,
				Text = Text,
				Duration = Time or 5
			})
		end

		-- === Логика Fling ===
		local function SkidFling(TargetPlayer)
			local Character = LocalPlayer.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			local RootPart = getRoot(Character)
			local TCharacter = TargetPlayer and TargetPlayer.Character
			if not TCharacter then return end

			local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
			local TRootPart = getRoot(TCharacter)
			local THead = TCharacter:FindFirstChild("Head")
			local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
			local Handle = Accessory and Accessory:FindFirstChild("Handle")

			if Character and Humanoid and RootPart then
				if RootPart.AssemblyLinearVelocity.Magnitude < 50 then
					getgenv().OldPos = RootPart.CFrame
				end

				if THumanoid and THumanoid.Sit then
					return Message("Error", TargetPlayer.Name .. " is sitting", 2)
				end

				-- камера на цель
				if THead then
					workspace.CurrentCamera.CameraSubject = THead
				elseif Handle then
					workspace.CurrentCamera.CameraSubject = Handle
				elseif THumanoid and TRootPart then
					workspace.CurrentCamera.CameraSubject = THumanoid
				end

				if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

				-- телепорт + импульс (обновлено: используем Assembly*Velocity)
				local FPos = function(BasePart, Pos, Ang)
					local cf = CFrame.new(BasePart.Position) * Pos * Ang
					RootPart.CFrame = cf
					-- гарантируем что PrimaryPart есть
					if not Character.PrimaryPart then
						pcall(function() Character.PrimaryPart = RootPart end)
					end
					Character:SetPrimaryPartCFrame(cf)
					RootPart.AssemblyLinearVelocity = Vector3.new(9e7, 9e7 * 10, 9e7)
					RootPart.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
				end

				-- === ТВОЯ ОСНОВНАЯ ЛОГИКА — БЕЗ ИЗМЕНЕНИЙ ===
				local SFBasePart = function(BasePart)
					local TimeToWait = 2
					local Time = tick()
					local Angle = 0
					repeat
						if RootPart and THumanoid then
							if BasePart.Velocity.Magnitude < 50 then
								Angle = Angle + 100
								FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
								task.wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
								task.wait()
								FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
								task.wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
								task.wait()
								FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
								task.wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
								task.wait()
							else
								FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
								task.wait()
								FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
								task.wait()
								FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
								task.wait()
								
								FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
								task.wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
								task.wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
								task.wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
								task.wait()
							end
						end
					until Time + TimeToWait < tick() or not FlingActive
				end

				-- подготовка
				workspace.FallenPartsDestroyHeight = 0/0 -- NaN, «антикилл»
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
				local oldAutoRotate = Humanoid.AutoRotate
				Humanoid.AutoRotate = false

				-- выбираем часть цели
				if TRootPart then
					SFBasePart(TRootPart)
				elseif THead then
					SFBasePart(THead)
				elseif Handle then
					SFBasePart(Handle)
				else
					-- фэйл-сейф: вернуть настройки
					Humanoid.AutoRotate = oldAutoRotate
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
					workspace.CurrentCamera.CameraSubject = Humanoid
					workspace.FallenPartsDestroyHeight = getgenv().FPDH
					return Message("Error", TargetPlayer.Name .. " has no valid parts", 2)
				end

				-- завершение
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
				Humanoid.AutoRotate = oldAutoRotate
				workspace.CurrentCamera.CameraSubject = Humanoid

				-- возврат на старую позицию и полный сброс инерции
				if getgenv().OldPos then
					local targetCF = getgenv().OldPos * CFrame.new(0, .5, 0)
					RootPart.CFrame = targetCF
					Character:SetPrimaryPartCFrame(targetCF)
					Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

					for _, part in ipairs(Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.AssemblyLinearVelocity = Vector3.new()
							part.AssemblyAngularVelocity = Vector3.new()
						end
					end
				end

				workspace.FallenPartsDestroyHeight = getgenv().FPDH
			else
				return Message("Error", "Your character is not ready", 2)
			end
		end

		-- === Кнопки Fling ===
		Tabs.TrollingTab:Button({
			Title = "Fling Target",
			Desc = "",
			Locked = false,
			Callback = function()
				if not trollTarget or not trollTarget:IsA("Player") then
					return Message("Error", "No player selected", 2)
				end

				FlingActive = true
				task.spawn(function()
					SkidFling(trollTarget)
					FlingActive = false
				end)
			end
		})

		local Section2 = Tabs.TrollingTab:Section({ 
			Title = "Fling roles",
			TextXAlignment = "Left",
			TextSize = 17,
		})

		Tabs.TrollingTab:Button({
			Title = "Fling Sheriff",
			Desc = "",
			Locked = false,
			Callback = function()
				local sheriff = nil
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						local hasGun = player.Character:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun"))
						if hasGun then
							sheriff = player
							break
						end
					end
				end

				if sheriff then
					FlingActive = true
					task.spawn(function()
						SkidFling(sheriff)
						FlingActive = false
					end)
				else
					Message("Info", "Sheriff not found", 3)
				end
			end
		})

		Tabs.TrollingTab:Button({
			Title = "Fling Murderer",
			Desc = "",
			Locked = false,
			Callback = function()
				local murderer = nil
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						local hasKnife = player.Character:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife"))
						if hasKnife then
							murderer = player
							break
						end
					end
				end

				if murderer then
					FlingActive = true
					task.spawn(function()
						SkidFling(murderer)
						FlingActive = false
					end)
				else
					Message("Info", "Murderer not found", 3)
				end
			end
		})









	end




			--------------AutoFarmTab---------------

	do
			--// AutoFarm System with new UI assets
		local Section = Tabs.AutoFarmTab:Section({ 
			Title = "AutoFarm",
			TextXAlignment = "Left",
			TextSize = 17, -- Default Size
		})

			local Players = game:GetService("Players")
			local Workspace = game:GetService("Workspace")
			local LP = Players.LocalPlayer

			-- Переменные
			local AutoFarmRunning = false
			local SmoothSaveMode = false
			local Mode = "Smooth"
			local TeleportDelay = 3
			local SmoothSpeed = 25
			local SpawnCFrame = CFrame.new(112.961197, 140.252960, 46.383835)

			-- Карты
			local Maps = {
				"Factory","Hospital3","MilBase","House2","Workplace","Mansion2",
				"BioLab","Hotel","Bank2","PoliceStation","ResearchFacility",
				"Lobby","BeachResort", "Yacht", "Office3"
			}

			-- Проверка: монета доступна
			local function IsCollectableCoin(part)
				return part:FindFirstChild("TouchInterest") ~= nil
			end

			-- Поиск ближайшей монеты
			local function GetClosestCoin()
				if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
				local hrp = LP.Character.HumanoidRootPart
				local closest, bestDist = nil, math.huge

				for _, mapName in ipairs(Maps) do
					local map = Workspace:FindFirstChild(mapName)
					if map and map:FindFirstChild("CoinContainer") then
						for _, coin in ipairs(map.CoinContainer:GetChildren()) do
							if IsCollectableCoin(coin) then
								local pos = coin.Position
								local dist = (hrp.Position - pos).Magnitude
								if dist < bestDist then
									bestDist = dist
									closest = coin
								end
							end
						end
					end
				end
				return closest
			end

			-- Проверка: виден ли мешок (разрешено ли фармить)
			local function IsCoinBagVisible()
				local gui = LP:FindFirstChild("PlayerGui")
				if not gui then return false end

				local beachBall = gui:FindFirstChild("MainGUI", true)
					and gui.MainGUI:FindFirstChild("Game", true)
					and gui.MainGUI.Game:FindFirstChild("CoinBags", true)
					and gui.MainGUI.Game.CoinBags:FindFirstChild("Container", true)
					and gui.MainGUI.Game.CoinBags.Container:FindFirstChild("BeachBall")

				return beachBall and beachBall.Visible
			end

			-- Проверка: мешок заполнен
			local function IsBagFull()
				local gui = LP:FindFirstChild("PlayerGui")
				if not gui then return false end

				local fullLabel = gui:FindFirstChild("MainGUI", true)
					and gui.MainGUI:FindFirstChild("Game", true)
					and gui.MainGUI.Game:FindFirstChild("CoinBags", true)
					and gui.MainGUI.Game.CoinBags:FindFirstChild("Container", true)
					and gui.MainGUI.Game.CoinBags.Container:FindFirstChild("BeachBall", true)
					and gui.MainGUI.Game.CoinBags.Container.BeachBall:FindFirstChild("Full")

				return fullLabel and fullLabel.Visible
			end

			-- Суицид
			local function KillPlayer()
				local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.Health = 0 end
			end

			-- Teleport режим
			local function TeleportFarm()
				local coin = GetClosestCoin()
				if coin and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
					local pos = coin.Position
					LP.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
					task.wait(0.3)
					LP.Character.HumanoidRootPart.CFrame = SpawnCFrame
				end
			end

			-- Smooth режим
			local function SmoothFarm()
				local coin = GetClosestCoin()
				if coin and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
					local pos = coin.Position
					local hrp = LP.Character.HumanoidRootPart
					local dist = (pos - hrp.Position).Magnitude
					if dist > 0 then
						local totalTime = dist / SmoothSpeed
						local start = tick()
						local startPos = hrp.Position
						while tick() - start < totalTime do
							if not AutoFarmRunning or not IsCoinBagVisible() then return end
							local alpha = (tick() - start) / totalTime
							local interpolated = startPos:Lerp(pos, alpha)

							if SmoothSaveMode then
								interpolated = interpolated - Vector3.new(0, 2.5, 0)
								hrp.CFrame = CFrame.new(interpolated) * CFrame.Angles(math.rad(90), 0, 0)
							else
								hrp.CFrame = CFrame.new(interpolated)
							end
							task.wait(0.015)
						end
					end
				end
			end

			-- Главный цикл
			task.spawn(function()
				while true do
					task.wait(0.8)

					if AutoFarmRunning then
						if not IsCoinBagVisible() then continue end
						if IsBagFull() then
							KillPlayer()
							continue
						end
						if Mode == "Teleport" then
							task.wait(TeleportDelay)
							TeleportFarm()
						else
							SmoothFarm()
						end
					end
				end
			end)

			-- === UI через новые ассеты ===

			-- Dropdown: выбор режима
			local DropdownMode = Tabs.AutoFarmTab:Dropdown({
				Title = "AutoFarm Mode",
				Values = { "Smooth", "Teleport" },
				Value = "Smooth",
				Callback = function(option)
					Mode = option
					print("Mode:", option)
				end
			})

			-- Slider: TeleportDelay
			local SliderTeleport = Tabs.AutoFarmTab:Slider({
				Title = "Teleport Delay",
				Step = 0.1,
				Value = { Min = 0.5, Max = 5, Default = TeleportDelay },
				Callback = function(value)
					TeleportDelay = value
				end
			})

			-- Slider: SmoothSpeed
			local SliderSmooth = Tabs.AutoFarmTab:Slider({
				Title = "Smooth Speed",
				Step = 1,
				Value = { Min = 20, Max = 100, Default = SmoothSpeed },
				Callback = function(value)
					SmoothSpeed = value
				end
			})

			-- Toggle: включение фарма
			local ToggleAutoFarm = Tabs.AutoFarmTab:Toggle({
				Title = "Enable AutoFarm",
				Default = false,
				Callback = function(state)
					AutoFarmRunning = state
					print("AutoFarm:", state)
				end
			})

			-- Toggle: Safe Mode
			local ToggleSmoothSave = Tabs.AutoFarmTab:Toggle({
				Title = "Smooth Save Mode",
				Default = false,
				Callback = function(state)
					SmoothSaveMode = state
				end
			})

			-- Coin ESP (отображение монет)
			local function getAllCoins()
				local coins = {}
				for _, mapName in ipairs(Maps) do
					local map = Workspace:FindFirstChild(mapName)
					if map and map:FindFirstChild("CoinContainer") then
						for _, child in ipairs(map.CoinContainer:GetChildren()) do
							if child:IsA("BasePart") and child:FindFirstChildWhichIsA("TouchTransmitter") then
								table.insert(coins, child)
							end
						end
					end
				end
				return coins
			end

			local function clearBoxes()
				for _, adorn in pairs(game:GetService("CoreGui"):GetChildren()) do
					if adorn:IsA("BoxHandleAdornment") and adorn.Name == "CoinESP" then
						adorn:Destroy()
					end
				end
			end

			local function showBoxes()
				clearBoxes()
				for _, coin in pairs(getAllCoins()) do
					local box = Instance.new("BoxHandleAdornment")
					box.Name = "CoinESP"
					box.Adornee = coin
					box.AlwaysOnTop = true
					box.ZIndex = 10
					box.Size = coin.Size
					box.Color3 = Color3.fromRGB(255, 215, 0)
					box.Transparency = 0.3
					box.Parent = game:GetService("CoreGui")
				end
			end

			local isESP = false
			local function startCoinESP()
				if isESP then return end
				isESP = true
				task.spawn(function()
					while isESP do
						showBoxes()
						task.wait(1.2)
					end
				end)
			end

			local function stopCoinESP()
				isESP = false
				clearBoxes()
			end

			-- Toggle: ESP
			local ToggleESP = Tabs.AutoFarmTab:Toggle({
				Title = "Show Coins ESP",
				Default = false,
				Callback = function(state)
					if state then startCoinESP() else stopCoinESP() end
				end
			})


	end
	


			-----SpectatorTab------



	do
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local Camera = workspace.CurrentCamera
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		-- Функция получения роли игрока
		local function getPlayerRole(player)
			local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
			if roles then
				local data = roles:InvokeServer()
				if data and data[player.Name] then
					return data[player.Name].Role
				end
			end
			return nil
		end

		-- Следим за игроком
		local function trackPlayer(player)
			if player and player.Character and player.Character:FindFirstChild("Humanoid") then
				Camera.CameraSubject = player.Character.Humanoid
				WindUI:Notify({
					Title = "Spectator",
					Content = "Now spectating: " .. player.Name,
					Duration = 2
				})
			end
		end

		-- Возврат камеры на себя
		local function returnToSelf()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				Camera.CameraSubject = LocalPlayer.Character.Humanoid
				WindUI:Notify({
					Title = "Spectator",
					Content = "Returned to yourself",
					Duration = 2
				})
			end
		end

		-- Получаем список игроков для дропдауна
		local function getPlayerList()
			local list = {}
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					table.insert(list, p.Name)
				end
			end
			return list
		end

		-- Создание секции Tracker
		local Section = Tabs.SpectatorTab:Section({ 
			Title = "Tracker",
			TextXAlignment = "Left",
			TextSize = 17
		})

		-- Создание Dropdown для выбора игрока
		local selectedPlayerName = nil
		local Dropdown = Tabs.SpectatorTab:Dropdown({
			Title = "Select Player",
			Values = getPlayerList(),
			Multi = false,
			Default = 1,
			Callback = function(Value)
				selectedPlayerName = Value
				WindUI:Notify({
					Title = "Spectator",
					Content = "Selected player: " .. Value,
					Duration = 2
				})
			end
		})

		-- Кнопка: Следить за выбранным игроком
		Tabs.SpectatorTab:Button({
			Title = "Spectate the selected player",
			Description = "",
			Callback = function()
				local player = Players:FindFirstChild(selectedPlayerName)
				if player then
					trackPlayer(player)
				else
					WindUI:Notify({
						Title = "Spectator",
						Content = "Player not found",
						Duration = 2
					})
				end
			end
		})

		-- Секция для ролей
		local SectionRoles = Tabs.SpectatorTab:Section({ 
			Title = "Spectate to roles",
			TextXAlignment = "Left",
			TextSize = 17
		})

		-- Кнопка: Следить за шерифом
		Tabs.SpectatorTab:Button({
			Title = "Spectate the Sheriff",
			Description = "",
			Callback = function()
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and getPlayerRole(player) == "Sheriff" then
						trackPlayer(player)
						return
					end
				end
				WindUI:Notify({
					Title = "Spectator",
					Content = "Sheriff not found",
					Duration = 2
				})
			end
		})

		-- Кнопка: Следить за мардером
		Tabs.SpectatorTab:Button({
			Title = "Spectate the Murder",
			Description = "",
			Callback = function()
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and getPlayerRole(player) == "Murderer" then
						trackPlayer(player)
						return
					end
				end
				WindUI:Notify({
					Title = "Spectator",
					Content = "Murderer not found",
					Duration = 2
				})
			end
		})

		-- Секция для возврата к себе
		local SectionSelf = Tabs.SpectatorTab:Section({ 
			Title = "Spectate to yourself",
			TextXAlignment = "Left",
			TextSize = 17
		})

		-- Кнопка: Вернуться к себе
		Tabs.SpectatorTab:Button({
			Title = "Return to yourself",
			Description = "Stop spectating and return",
			Callback = function()
				returnToSelf()
			end
		})

		-- Автообновление списка игроков в Dropdown
		Players.PlayerAdded:Connect(function()
			Dropdown:SetValues(getPlayerList())
		end)
		Players.PlayerRemoving:Connect(function()
			Dropdown:SetValues(getPlayerList())
		end)




	end



			-------------OtherTab--------------------

	do
		
		local Section = Tabs.OtherTab:Section({ 
			Title = "Other",
			TextXAlignment = "Left",
			TextSize = 17, -- Default Size
		})

		-- == Anti-AFK ==
		local VirtualUser = game:GetService("VirtualUser")
		local antiAFKEnabled = false
		local antiAFKThread
		local delayMinutes = 5 -- каждые 5 минут

		local AntiAFKToggle = Tabs.OtherTab:Toggle({
			Title = "Anti-AFK",
			Default = false,
			Callback = function(state)
				antiAFKEnabled = state

				if state then
					antiAFKThread = task.spawn(function()
						while antiAFKEnabled do
							task.wait(delayMinutes * 60)
							VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
							task.wait(0.1)
							VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
							WindUI:Notify({
								Title = "Anti-AFK",
								Content = "Activity simulated after " .. delayMinutes .. " min",
								Duration = 2
							})
						end
					end)

					WindUI:Notify({
						Title = "Anti-AFK",
						Content = "Anti-AFK activated (every " .. delayMinutes .. " min)",
						Duration = 2
					})
				else
					antiAFKEnabled = false
					WindUI:Notify({
						Title = "Anti-AFK",
						Content = "Anti-AFK deactivated",
						Duration = 2
					})
				end
			end
		})

		-- == Anti-Fling ==
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer

		local AntiFlingToggle = Tabs.OtherTab:Toggle({
			Title = "Anti-Fling",
			Default = false,
			Callback = function(state)
			if state then
				getgenv().AntiFlingActive = true
				task.spawn(function()
					while getgenv().AntiFlingActive do
						AntiFling()
						task.wait(0.1)
					end
				end)
			else
				getgenv().AntiFlingActive = false
			end
		end
		})

		
		

		-- == X-ray ==
		local Section = Tabs.OtherTab:Section({ 
			Title = "X-ray",
			TextXAlignment = "Left",
			TextSize = 17, -- Default Size
		})

		local Workspace = game:GetService("Workspace")
		local LP = Players.LocalPlayer
		local XrayEnabled = false
		local XrayTransparency = 0.4
		local XrayLoop

		local function SetXrayTransparency(transparency)
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("BasePart") and not v:IsDescendantOf(LP.Character or Instance.new("Model")) then
					pcall(function()
						v.LocalTransparencyModifier = transparency
					end)
				end
			end
		end

		local function ResetXray()
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("BasePart") and not v:IsDescendantOf(LP.Character or Instance.new("Model")) then
					pcall(function()
						v.LocalTransparencyModifier = 0
					end)
				end
			end
		end

		local function ToggleXrayLoop(state)
			if state then
				XrayLoop = task.spawn(function()
					while XrayEnabled do
						SetXrayTransparency(XrayTransparency)
						task.wait(1.5)
					end
				end)
			else
				if XrayLoop then
					task.cancel(XrayLoop)
					XrayLoop = nil
				end
				ResetXray()
			end
		end

		local XrayToggle = Tabs.OtherTab:Toggle({
			Title = "X-ray Mode",
			Default = false,
			Callback = function(Value)
				XrayEnabled = Value
				ToggleXrayLoop(Value)
				WindUI:Notify("X-ray mode:", Value and "On" or "Off")
			end
		})

		

		local Slider = Tabs.OtherTab:Slider({
			Title = "X-ray Intensity",
			Step = 1,
			
			Value = {
				Min = 20,
				Max = 80,
				Default = 40,
			},
			Callback = function(value)
				XrayTransparency = Value / 100
				WindUI:Notify("X-ray Transparency set to:", XrayTransparency)
				if XrayEnabled then
					SetXrayTransparency(XrayTransparency)
				end
			end
		})


	end






			---------ServerTab-------------

	do	
						-- Создаём секцию
			local Section = Tabs.ServerTab:Section({ 
				Title = "Actions with the server",
				TextXAlignment = "Left",
				TextSize = 17,
			})


			-- == Rejoin ==
			local function RejoinGame()
				local TeleportService = game:GetService("TeleportService")
				local placeId = game.PlaceId
				local serverId = game.JobId
				TeleportService:TeleportToPlaceInstance(placeId, serverId, game.Players.LocalPlayer)
			end

			-- == Server Hop ==
			local visitedServers = {}

			local HttpService = game:GetService("HttpService")
			local TeleportService = game:GetService("TeleportService")
			local Players = game:GetService("Players")
			local LocalPlayer = Players.LocalPlayer
			local placeId = game.PlaceId

			local function ServerHop()
				local success, response = pcall(function()
					return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
				end)

				if success then
					local data = HttpService:JSONDecode(response)
					if data and data.data then
						local targetServer
						for _, server in ipairs(data.data) do
							if server.playing < server.maxPlayers and not visitedServers[server.id] then
								targetServer = server
								break
							end
						end

						if targetServer then
							visitedServers[targetServer.id] = true
							TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, LocalPlayer)
						else
							warn("No available servers to hop to.")
						end
					end
				else
					warn("Failed to fetch server list.")
				end
			end

			local Button = Tabs.ServerTab:Button({
				Title = "Rejoin Game",
				Description = "",
				Callback = function()
					RejoinGame()
				end
			})

			

			local Button = Tabs.ServerTab:Button({
				Title = "Server Hop",
				Description = "",
				Callback = function()
					ServerHop()
				end
			})


	end



	






		-------------------SettingsTab-=---=--=
	do
			local HttpService = game:GetService("HttpService");
		local folderPath = "WindUI";
		makefolder(folderPath);
		local function SaveFile(fileName, data)
			local filePath = folderPath   .. "/"   .. fileName   .. ".json" ;
			local jsonData = HttpService:JSONEncode(data);
			writefile(filePath, jsonData);
		end
		local function LoadFile(fileName)
			local filePath = folderPath   .. "/"   .. fileName   .. ".json" ;
			if isfile(filePath) then
				local jsonData = readfile(filePath);
				return HttpService:JSONDecode(jsonData);
			end
		end
		local function ListFiles()
			local files = {};
			for _, file in ipairs(listfiles(folderPath)) do
				local fileName = file:match("([^/]+)%.json$");
				if fileName then
					table.insert(files, fileName);
				end
			end
			return files;
		end
		Tabs.SettingsTab:Section({
			Title = "Window"
		});
		local themeValues = {};
		for name, _ in pairs(WindUI:GetThemes()) do
			table.insert(themeValues, name);
		end
		local themeDropdown = Tabs.SettingsTab:Dropdown({
			Title = "Select Theme",
			Multi = false,
			AllowNone = false,
			Value = nil,
			Values = themeValues,
			Callback = function(theme)
				WindUI:SetTheme(theme);
			end
		});
		themeDropdown:Select(WindUI:GetCurrentTheme());
		local ToggleTransparency = Tabs.SettingsTab:Toggle({
			Title = "Toggle Window Transparency",
			Callback = function(e)
				Window:ToggleTransparency(e);
			end,
			Value = WindUI:GetTransparency()
		});
		Tabs.SettingsTab:Section({
			Title = "Save"
		});
		local fileNameInput = "";
		Tabs.SettingsTab:Input({
			Title = "Write File Name",
			PlaceholderText = "Enter file name",
			Callback = function(text)
				fileNameInput = text;
			end
		});
		Tabs.SettingsTab:Button({
			Title = "Save File",
			Callback = function()
				if (fileNameInput ~= "") then
					SaveFile(fileNameInput, {
						Transparent = WindUI:GetTransparency(),
						Theme = WindUI:GetCurrentTheme()
					});
				end
			end
		});
		Tabs.SettingsTab:Section({
			Title = "Load"
		});
		local filesDropdown;
		local files = ListFiles();
		filesDropdown = Tabs.SettingsTab:Dropdown({
			Title = "Select File",
			Multi = false,
			AllowNone = true,
			Values = files,
			Callback = function(selectedFile)
				fileNameInput = selectedFile;
			end
		});
		Tabs.SettingsTab:Button({
			Title = "Load File",
			Callback = function()
				if (fileNameInput ~= "") then
					local data = LoadFile(fileNameInput);
					if data then
						WindUI:Notify({
							Title = "File Loaded",
							Content = "Loaded data: "   .. HttpService:JSONEncode(data) ,
							Duration = 5
						});
						if data.Transparent then
							Window:ToggleTransparency(data.Transparent);
							ToggleTransparency:SetValue(data.Transparent);
						end
						if data.Theme then
							WindUI:SetTheme(data.Theme);
						end
					end
				end
			end
		});
		Tabs.SettingsTab:Button({
			Title = "Overwrite File",
			Callback = function()
				if (fileNameInput ~= "") then
					SaveFile(fileNameInput, {
						Transparent = WindUI:GetTransparency(),
						Theme = WindUI:GetCurrentTheme()
					});
				end
			end
		});
		Tabs.SettingsTab:Button({
			Title = "Refresh List",
			Callback = function()
				filesDropdown:Refresh(ListFiles());
			end
		});



	end



end
