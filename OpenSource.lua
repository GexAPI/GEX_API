
--[[
Welcome to GEX API! This is a closed source API which has a large variety of features.

To use these features, you paste in the loadstring, and call one of these with this prefix; API:insertcommand()

Current list of features:

API:GetGun(GunName)
API:AllGuns()
API:Speed(speed)
API:JumpPower(power)
API:Gravity(gravity)
API:Time()
API:SaveGame()
API:Bypasser()
API:Teleport(PlrName)
API:bring(playerInstance,Cframe)
]]

local API = {}

local CurrentVersion = "0.0.2"
local Old_Version = game:GetService("HttpService"):JSONDecode((game:HttpGet("https://raw.githubusercontent.com/TheXbots/GEX_API/main/Version.lua"))).Version

if not CurrentVersion == Old_Version then
    print("API is outdated! Please get latest version.")
end

local PremiumActivated = false

local plr = game.Players.LocalPlayer
local Player = game.Players.LocalPlayer

function Clipboard(value)
    print("going through")
    local clipBoard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
	if clipBoard then
		clipBoard(value)
        print("Works")
	else
        print("Incompatible")
	end
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

--API:bring(game.Players.DrDoomsDemise, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)

API:MakeAllCrim()
