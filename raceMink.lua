--[Function Uesless]
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService('Workspace'):FindFirstChild('Map')
spawn(function() 
	while true do wait(.3)
		   pcall(function ()
          local Race = game:GetService("Players").LocalPlayer.Data.Race.Value
		if (Race == "Mink") == false then 
			game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
		end
      end)
	end
end)
local vu = game:GetService("VirtualUser")
	game:GetService("Players").LocalPlayer.Idled:connect(function()
		vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		wait(1)
		vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)
function randomString(length)
    local result = ""; 
    local character = {
      [1] = "A",
      [2] = "B",
      [3] = "C",
      [4] = "D",
      [5] = "E",
      [6] = "F",
      [7] = "G",
      [8] = "H",
      [9] = "I",
      [10] = "J",
      [11] = "K",
      [12] = "L",
      [13] = "M",
      [14] = "N",
      [15] = "O",
      [16] = "P",
      [17] = "Q",
      [18] = "R",
      [19] = "S",
      [20] = "T",
      [21] = "U",
      [22] = "V",
      [23] = "W",
      [24] = "X",
      [25] = "Y",
      [26] = "Z",
      [27] = "a",
      [28] = "b",
      [29] = "c",
      [30] = "d",
      [31] = "e",
      [32] = "f",
      [33] = "g",
      [34] = "h",
      [35] = "i",
      [36] = "j",
      [37] = "k",
      [38] = "l",
      [39] = "m",
      [40] = "n",
      [41] = "o",
      [42] = "p",
      [43] = "q",
      [44] = "r",
      [45] = "s",
      [46] = "t",
      [47] = "u",
      [48] = "v",
      [49] = "w",
      [50] = "x",
      [51] = "y",
      [52] = "z",
      [53] = "0",
      [54] = "1",
      [55] = "2",
      [56] = "3",
      [57] = "4",
      [58] = "5",
      [59] = "6",
      [60] = "7",
      [61] = "8",
      [62] = "9",
    }
  local characterLength = #character
  for i= 1, length do 
      math.randomseed(math.random(1, characterLength * length / 0.5 * math.random(characterLength + length) + tick()))
        result = result .. character[math.random(1, characterLength)]
    end 
  return result
end

local Constant = {
	ESC_MAP = {
		["\\"] = [[\]],
		["\""] = [[\"]],
		["/"] = [[\/]],
		["\b"] = [[\b]],
		["\f"] = [[\f]],
		["\n"] = [[\n]],
		["\r"] = [[\r]],
		["\t"] = [[\t]],
		["\a"] = [[\u0007]],
		["\v"] = [[\u000b]]
	},

	UN_ESC_MAP = {
		b = "\b",
		f = "\f",
		n = "\n",
		r = "\r",
		t = "\t",
		u0007 = "\a",
		u000b = "\v"
	},

	NULL = setmetatable({}, {
		__tostring = function() return "null" end
	})
}

function split(pString, pPattern)
	local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)
	while s do
	   if s ~= 1 or cap ~= "" then
	  table.insert(Table,cap)
	   end
	   last_end = e+1
	   s, e, cap = pString:find(fpat, last_end)
	end
	if last_end <= #pString then
	   cap = pString:sub(last_end)
	   table.insert(Table, cap)
	end
	return Table
 end
local NULL = Constant.NULL
local UN_ESC_MAP = Constant.UN_ESC_MAP

local function next_char(str, pos)
	pos = pos + #str:match("^%s*", pos)
	return str:sub(pos, pos), pos
end

local function syntax_error(str, pos)
	return error("Invalid json syntax starting at position " .. pos .. ": " .. str:sub(pos, pos + 10))
end

local Parser = {}

setmetatable(Parser, {
	__call = function(self, opts)
		local parser = {
			without_null = opts.without_null
		}

		setmetatable(parser, { __index = Parser })

		return parser
	end
})

function Parser:number(str, pos)
	local num = str:match("^-?%d+%.?%d*[eE]?[+-]?%d*", pos)
	local val = tonumber(num)

	if not val then
		syntax_error(str, pos)
	else
		return val, pos + #num
	end
end

function Parser:string(str, pos)
	pos = pos + 1

	local i = 1
	local chars = table.new(#str - pos - 1, 0)
	while(pos <= #str) do
		local c = str:sub(pos, pos)

		if c == "\"" then
			return table.concat(chars, ""), pos + 1
		elseif c == "\\" then
			local j = pos + 1

			local next_c = str:sub(j, j)
			for k, v in pairs(UN_ESC_MAP) do
				if str:sub(j, j + #k - 1) == k then
					next_c = v
					j = j + #k - 1
				end
			end

			c = next_c
			pos = j
		end

		chars[i] = c
		i = i + 1
		pos = pos + 1
	end

	syntax_error(str, pos)
end

function Parser:array(str, pos)
	local arr = table.new(10, 0)
	local val
	local i = 1
	local c

	pos = pos + 1
	while true do
		val, pos = self:json(str, pos)
		arr[i] = val
		i = i + 1

		c, pos = next_char(str, pos)
		if (c == ",") then
			pos = pos + 1
		elseif (c == "]") then
			return arr, pos + 1
		else
			syntax_error(str, pos)
		end
	end

	return arr
end

function Parser:table(str, pos)
	local obj = table.new(0, 10)
	local key
	local val
	local c

	pos = pos + 1
	while true do
		c, pos = next_char(str, pos)

		if c == "}" then return obj, pos + 1
		elseif c == "\"" then key, pos = self:string(str, pos)
		else syntax_error(str, pos) end

		c, pos = next_char(str, pos)
		if c ~= ":" then syntax_error(str, pos) end

		val, pos = self:json(str, pos + 1)
		obj[key] = val

		c, pos = next_char(str, pos)
		if c == "}" then
			return obj, pos + 1
		elseif c == "," then
			pos = pos + 1
		else
			syntax_error(str, pos)
		end
	end
end

function Parser:json(str, pos)
	local first = false
	local val
	local c

	if not pos or pos == 1 then first = true end
	pos = pos or 1

	if type(str) ~= "string" then error("str should be a string")
	elseif pos > #str then error("Reached unexpected end of input") end

	c, pos = next_char(str, pos)
	if c == "{" then
		val, pos =  self:table(str, pos)
	elseif c == "[" then
		val, pos = self:array(str, pos)
	elseif c == "\"" then
		val, pos = self:string(str, pos)
	elseif c == "-" or c:match("%d") then
		val, pos = self:number(str, pos)
	else
		for k, v in pairs({ ["true"] = true, ["false"] = false, ["null"] = NULL }) do
			if (str:sub(pos, pos + #k - 1) == k) then 
				val, pos = v, pos + #k
				break
			end
		end

		if val == nil then syntax_error(str, pos) end
	end

	if first and pos <= #str then syntax_error(str, pos) end
	if self.without_null and val == NULL then val = nil end

	return val, pos
end
local NULL = Constant.NULL
local ESC_MAP = Constant.ESC_MAP

local function kind_of(obj)
	if type(obj) ~= "table" then return type(obj) end
	if obj == NULL then return "nil" end

	local i = 1
	for _ in pairs(obj) do
		if obj[i] ~= nil then i = i + 1 else return "table" end
	end

	if i == 1 then
		return "table"
	else
		return "array"
	end
end

local function escape_str(s)
	for k, v in pairs(ESC_MAP) do
		s = s:gsub(k, v)
	end

	return s
end

local Serializer = {
	print_address = false,
	max_depth = 100
}

setmetatable(Serializer, {
	__call = function(self, opts)
		local serializer = {
			depth = 0,
			max_depth = opts.max_depth,
			print_address = opts.print_address,
			stream = opts.stream
		}

		setmetatable(serializer, { __index = Serializer })

		return serializer
	end
})

function Serializer:space(n)
	local stream = self.stream
	for i = 1, n or 0 do
		stream:write(" ")
	end

	return self
end

function Serializer:key(key)
	local stream = self.stream
	local kind = kind_of(key)

	if kind == "array" then
		error("Can't encode array as key.")
	elseif kind == "table" then
		error("Can't encode table as key.")
	elseif kind == "string" then
		stream:write("\"", escape_str(key), "\"")
	elseif kind == "number" then
		stream:write("\"", tostring(key), "\"")
	elseif self.print_address then
		stream:write(tostring(key))
	else
		error("Unjsonifiable type: " .. kind .. ".")
	end

	return self
end

function Serializer:array(arr, replacer, indent, space)
	local stream = self.stream

	stream:write("[")
	for i, v in ipairs(arr) do
		if replacer then v = replacer(k, v) end

		stream:write(i == 1 and "" or ",")
		stream:write(space > 0 and "\n" or "")
		self:space(indent)
		self:json(v, replacer, indent + space, space)
	end
	if #arr > 0 then
		stream:write(space > 0 and "\n" or "")
		self:space(indent - space)
	end
	stream:write("]")

	return self
end

function Serializer:table(obj, replacer, indent, space)
	local stream = self.stream

	stream:write("{")
	local len = 0
	for k, v in pairs(obj) do
		if replacer then v = replacer(k, v) end

		if v ~= nil then
			stream:write(len == 0 and "" or ",")
			stream:write(space > 0 and "\n" or "")
			self:space(indent)
			self:key(k)
			stream:write(space > 0 and ": " or ":")
			self:json(v, replacer, indent + space, space)
			len = len + 1
		end
	end
	if len > 0 then
		stream:write(space > 0 and "\n" or "")
		self:space(indent - space)
	end
	stream:write("}")

	return self
end

function Serializer:json(obj, replacer, indent, space)
	local stream = self.stream
	local kind = kind_of(obj)

	self.depth = self.depth + 1
	if self.depth > self.max_depth then error("Reach max depth: " .. tostring(self.max_depth)) end

	if kind == "array" then
		self:array(obj, replacer, indent, space)
	elseif kind == "table" then
		self:table(obj, replacer, indent, space)
	elseif kind == "string" then
		stream:write("\"", escape_str(obj), "\"")
	elseif kind == "number" then
		stream:write(tostring(obj))
	elseif kind == "boolean" then
		stream:write(tostring(obj))
	elseif kind == "nil" then
		stream:write("null")
	elseif self.print_address then
		stream:write(tostring(obj))
	else
		error("Unjsonifiable type: " .. kind)
	end

	return self
end

function Serializer:toString()
	return self.stream:toString()
end

local json = {
	_VERSION = "0.1",
	null = Constant.NULL
}
function EquipWeapon(ToolSe)
        local x, p = pcall(function()    
			if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) then
				local tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
				game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
			end
		end)
        if not x then 
            for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do 
                if v.ToolTip == "Melee" then 
                    local x, p = pcall(function()    
                        if game.Players.LocalPlayer.Backpack:FindFirstChild(v.Name) then
                            local tool = game.Players.LocalPlayer.Backpack:FindFirstChild(v.Name)
                            game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                        end
                    end)
                end
            end
        end
end

function json.stringify(obj, replacer, space, print_address)
	if type(space) ~= "number" then space = 0 end

	return Serializer({
		print_address = print_address,
		stream = {
			fragments = {},
			write = function(self, ...)
				for i = 1, #{...} do
					self.fragments[#self.fragments + 1] = ({...})[i]
				end
			end,
			toString = function(self)
				return table.concat(self.fragments)
			end
		}
	}):json(obj, replacer, space, space):toString()
end

function json.parse(str, without_null)
	return Parser({ without_null = without_null }):json(str, 1)
end

function CreatePart(Name, PostionC, Vector)
		local TeleportList = game:GetService('Workspace'):WaitForChild('TeleportList')
		local Part = Instance.new('Part')
		Part.Parent = TeleportList
		Part.Name = Name
		Part.CanCollide = false
		Part.Anchored = true
		Part.CFrame = PostionC
		Part.Transparency = 1
		local Partx = Instance.new('Part')
		Partx.Parent = Part
		Partx.Name = "Part"
		Partx.CanCollide = false
		Partx.Anchored = true
		Partx.Position = Vector
		Partx.Transparency = 1
end

function CreateTeleport()
	if game.PlaceId == 2753915549 then 
		CreatePart('Underwater', CFrame.new(61163.8515625, 5.307314872741699, 1819.7841796875), Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
		CreatePart('WhirlPool', CFrame.new(3864.6884765625, 5.373158931732178, -1926.214111328125), Vector3.new(3864.6884765625, 6.736950397491455, -1926.214111328125))
		CreatePart('Sky upper', CFrame.new(-7898.87451171875, 5545.49169921875, -379.93194580078125), Vector3.new(-7894.61767578125, 5547.1416015625, -380.29119873046875))
		CreatePart('Sky lower', CFrame.new(-4607.82275390625, 872.5422973632812, -1667.556884765625), Vector3.new(-4607.82275390625, 874.3905029296875, -1667.556884765625))
	end
	if game.PlaceId == 7449423635 then 
		CreatePart('Hydra Upper', CFrame.new(5739.33447265625, 610.4498291015625, -265.63494873046875), Vector3.new(5742.9599609375, 613.9691772460938, -283.685546875))
		CreatePart('Mansion', CFrame.new(-12464.9599609375, 374.94024658203125, -7548.9443359375), Vector3.new(-12463.6025390625, 378.3270568847656, -7566.0830078125))
		CreatePart('Castle', CFrame.new(-5071.39013671875, 314.5412902832031, -3161.394287109375), Vector3.new(-5089.66455078125, 318.5023193359375, -3146.126708984375))
		CreatePart('Domain', CFrame.new(5313.10693359375, 22.56223487854004, -7.038661956787109), Vector3.new(5314.58203125, 25.419387817382812, -125.94227600097656))
	end
	if game.PlaceId == 4442272183 then 
		CreatePart('Flamingo Entrance', CFrame.new(-286.8727111816406, 306.19329833984375, 607.1571044921875), game:GetService("Workspace").Map.Dressrosa.FlamingoEntrance.Position)
		CreatePart('Flamingo Exit', CFrame.new(2285.48779296875, 15.214705467224121, 899.39306640625), game:GetService("Workspace").Map.Dressrosa.FlamingoExit.Position)
		CreatePart('Ship Entrance', CFrame.new(-6506.07470703125, 83.24968719482422, -129.59954833984375),game:GetService("Workspace").Map.GhostShip.TeleportSpawn.Position)
		CreatePart('Ship Exit', CFrame.new(923.2125244140625, 125.1197738647461, 32852.83203125), game:GetService("Workspace").Map.GhostShipInterior.TeleportSpawn.Position)
	end
end
local function findClosestPart(group, position)
	local closestPart, closestPartMagnitude

	local tmpMagnitude -- to store our calculation 
	for i, v in pairs(group:GetChildren()) do
		if closestPart then -- we have a part
			tmpMagnitude = (position - v.Position).magnitude

			-- check the next part
			if tmpMagnitude < closestPartMagnitude then
				closestPart = v
				closestPartMagnitude = tmpMagnitude 
			end
		else
			-- our first part
			closestPart = v
			closestPartMagnitude = (position - v.Position).magnitude
		end
	end
	return closestPart, closestPartMagnitude
end
function FindItem(item)
    local RequestInventory = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")
    for i, v in pairs(RequestInventory) do
        if string.lower(v.Name) == string.lower(item) then
            return true
        end
    end
    return false
end
function Redeem(value)
    game:GetService("ReplicatedStorage").Remotes.Redeem:InvokeServer(value)
end
--Vars etc
if game:GetService('Workspace'):FindFirstChild('TeleportList') then
	game:GetService('Workspace'):FindFirstChild('TeleportList'):Destroy()
end

local TeleportList = Instance.new('Folder')
TeleportList.Parent = game:GetService('Workspace')
TeleportList.Name = "TeleportList"
local triedPlayer = nil

CreateTeleport()

getgenv().CraftHub = {}

local virtualUser = game:GetService('VirtualUser')
virtualUser:CaptureController()

math.randomseed(math.random(1, tick()))
local byteToSet = randomString(14)

if game.PlaceId == 2753915549 then
    FirstSea = true
elseif game.PlaceId == 4442272183 then
    SecondSea = true
elseif game.PlaceId == 7449423635 then
    ThridSea = true
end

local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
local CombatFrameworkR = debug.getupvalues(CombatFramework)[2]
local RigController = require(game:GetService("Players")["LocalPlayer"].PlayerScripts.CombatFramework.RigController)
local RigControllerR = debug.getupvalues(RigController)[2]
local realbhit = require(game.ReplicatedStorage.CombatFramework.RigLib)
local cooldownfastattack = tick()

local posrandom = 0

--[Function Manager]
PlayerQuest = false

--[Function Tween]
local function Tween(...)
	local RealtargetPos = {...}
	local targetPos = RealtargetPos[1]
	local RealTarget
	if type(targetPos) == "vector" then
		RealTarget = CFrame.new(targetPos)
	elseif type(targetPos) == "userdata" then
		RealTarget = targetPos
	elseif type(targetPos) == "number" then
		RealTarget = CFrame.new(unpack(RealtargetPos))
	end
	
	if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health == 0 then if tween then tween:Cancel() end repeat wait() until game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health > 0; wait(0.2) end
	
	if TeleportList:FindFirstChild('HumanoidRootPart') then 
		TeleportList:FindFirstChild('HumanoidRootPart'):Destroy()
	end
	
	if not TeleportList:FindFirstChild('HumanoidRootPart') then 
		local Part = Instance.new('Part')
		Part.Parent = TeleportList
		Part.Name = "HumanoidRootPart"
		Part.CanCollide = false
		Part.Anchored = true
		Part.CFrame = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
		Part.Transparency = 1
	end
	
	local Position = TeleportList:FindFirstChild('HumanoidRootPart').Position
	local Closest = findClosestPart(TeleportList, RealTarget.Position);
	local Hitbox = nil;
	
	if Closest:FindFirstChild('Part') then 
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Closest:FindFirstChild("Part").Position)
		game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame * CFrame.new(1,-30,0)
	end
		
	local Distance = (RealTarget.Position - game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).Magnitude
	if Distance < 400 then
		Speed = 300
	elseif Distance >= 1000 then
		Speed = 300
	end
	
	local tweenfunc = {}
	local TweenService = game:GetService("TweenService")
	local tween, err = pcall(function()
	    local info = TweenInfo.new((RealTarget.Position - game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).Magnitude/Speed, Enum.EasingStyle.Linear)
		tween = TweenService:Create(game.Players.LocalPlayer.Character["HumanoidRootPart"], info, {CFrame = RealTarget})
		tween:Play()
		return tween
	end)
	function tweenfunc:Stop()
		tween:Cancel()
	end 

	function tweenfunc:Wait()
		tween.Completed:Wait()
		return;
	end 

	return tweenfunc
end


--[Function Config]
function Save() 
	if not isfolder('Kaiwa Scripts') then 
		makefolder('Kaiwa Scripts')
	end
	writefile('Kaiwa Scripts/' .. tostring(game.PlaceId) .. "-" .. game.Players.LocalPlayer.Name .. ".json", json.stringify(getgenv().CraftHub, nil, 4))
end

function Load() 
	if isfile('Kaiwa Scripts/' .. tostring(game.PlaceId) .. "-" .. game.Players.LocalPlayer.Name .. ".json") then
		local s = game:GetService("HttpService"):JSONDecode(readfile('Kaiwa Scripts/' .. tostring(game.PlaceId) .. "-" .. game.Players.LocalPlayer.Name .. ".json"))
		for e, j in pairs(s) do 
			getgenv().CraftHub[e] = j
		end
	else 
		Save()
	end
end
task.spawn(function() 
	game.Players.LocalPlayer.OnTeleport:Connect(function() 
		Save()
	end)
end)
task.spawn(function() 
	while true do task.wait(4) do 
			Save()
		end
	end
end)
Load()


function getValue(index)
	
	local err , value = pcall(function()
		return getgenv().CraftHub[index]; 
	end)
	if err then return value else return nil end;
end

function setValue(index, v)
	local err , value = pcall(function()
		 getgenv().CraftHub[index] = v;
	end)
	if err then return true else return nil end;
end

-- [Function Select Side]

local join = game.Players.localPlayer.Neutral == false

if getValue("Team") == nil then
    setValue("Team", "Pirates") 
end
if (getValue("Team") == "Pirates" or getValue("Team") == "Marines") and not join then
    repeat
        wait()
        pcall(
            function()
                join = game.Players.localPlayer.Neutral == false
                if getValue("Team") == "Pirates" then
                    for i, v in pairs({"MouseButton1Click", "MouseButton1Down", "Activated"}) do
                        for i, v in pairs(
                            getconnections(
                                game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Pirates.Frame.ViewportFrame.TextButton[
                                    v
                                ]
                            )
                        ) do
                            v.Function()
                        end
                    end
                elseif getValue("Team") == "Marines" then
                    for i, v in pairs({"MouseButton1Click", "MouseButton1Down", "Activated"}) do
                        for i, v in pairs(
                            getconnections(
                                game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Marines.Frame.ViewportFrame.TextButton[
                                    v
                                ]
                            )
                        ) do
                            v.Function()
                        end
                    end
                else
                    for i, v in pairs({"MouseButton1Click", "MouseButton1Down", "Activated"}) do
                        for i, v in pairs(
                            getconnections(
                                game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Marines.Frame.ViewportFrame.TextButton[
                                    v
                                ]
                            )
                        ) do
                            v.Function()
                        end
                    end
                end
            end
        )
    until (game.Players.localPlayer.Neutral == false) == true
end
repeat
        wait()
until (game.Players.localPlayer.Neutral == false) == true
repeat
        wait()
until (game.Players.localPlayer.Neutral == false) == true

--[Function AttackNoCooldown]



function CurrentWeapon()
	local ac = CombatFrameworkR.activeController
	local ret = ac.blades[1]
	if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
	pcall(function()
		while ret.Parent~=game.Players.LocalPlayer.Character do ret=ret.Parent end
	end)
	if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
	return ret
end

function getAllBladeHitsPlayers(Sizes)
	local Hits = {}
	local Client = game.Players.LocalPlayer
	local Characters = game:GetService("Workspace").Characters:GetChildren()
	for i=1,#Characters do local v = Characters[i]
		local Human = v:FindFirstChildOfClass("Humanoid")
		if v.Name ~= game.Players.LocalPlayer.Name and Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 then
			table.insert(Hits,Human.RootPart)
		end
	end
	for i=1,#Characters do local v = Characters[i]
		local Human = v:FindFirstChildOfClass("Humanoid")
		if v.Name ~= game.Players.LocalPlayer.Name and Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 then
			table.insert(Hits,Human.RootPart)
		end
	end
	return Hits
end

function getAllBladeHits(Sizes)
	local Hits = {}
	local Client = game.Players.LocalPlayer
	local Enemies = game:GetService("Workspace").Enemies:GetChildren()
    if getValue("Fast Attack") or getValue("Ultra Fast Attack") then 
        pcall(function() 
             for i=1,2 do 
                for i=1,#Enemies do local v = Enemies[i]
            		local Human = v:FindFirstChildOfClass("Humanoid")
            		if Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 and (Human.RootPart.Position - Client.Character.HumanoidRootPart.Position).Magnitude <= 300  then
            			table.insert(Hits,Human.RootPart)
            		end
            	end
        	end        
        end)
    end
    for i=1,#Enemies do local v = Enemies[i]
        		local Human = v:FindFirstChildOfClass("Humanoid")
        		if Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 and (Human.RootPart.Position - Client.Character.HumanoidRootPart.Position).Magnitude <= 300  then
        			table.insert(Hits,Human.RootPart)
        		end
        	end
	return Hits
end

function AttackFunction()
	local ac = CombatFrameworkR.activeController
	if ac and ac.equipped then
		for indexincrement = 1, 1 do
			local bladehit = getAllBladeHits(60)
			if #bladehit > 0 then
				local AcAttack8 = debug.getupvalue(ac.attack, 5)
				local AcAttack9 = debug.getupvalue(ac.attack, 6)
				local AcAttack7 = debug.getupvalue(ac.attack, 4)
				local AcAttack10 = debug.getupvalue(ac.attack, 7)
				local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
				local NumberAc13 = AcAttack7 * 798405
				(function()
					NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
					AcAttack8 = math.floor(NumberAc12 / AcAttack9)
					AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
				end)()
				AcAttack10 = AcAttack10 + 1
				debug.setupvalue(ac.attack, 5, AcAttack8)
				debug.setupvalue(ac.attack, 6, AcAttack9)
				debug.setupvalue(ac.attack, 4, AcAttack7)
				debug.setupvalue(ac.attack, 7, AcAttack10)
				for k, v in pairs(ac.animator.anims.basic) do
					v:Play(0.01,0.01,0.01)
				end                 
				if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(CurrentWeapon()))
					game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 2, "") 
				end
			end
		end
	end
end

function AttackPlayers()
	local ac = CombatFrameworkR.activeController
	if ac and ac.equipped then
		for indexincrement = 1, 1 do
			local bladehit = getAllBladeHitsPlayers(60)
			if #bladehit > 0 then
				local AcAttack8 = debug.getupvalue(ac.attack, 5)
				local AcAttack9 = debug.getupvalue(ac.attack, 6)
				local AcAttack7 = debug.getupvalue(ac.attack, 4)
				local AcAttack10 = debug.getupvalue(ac.attack, 7)
				local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
				local NumberAc13 = AcAttack7 * 798405
				(function()
					NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
					AcAttack8 = math.floor(NumberAc12 / AcAttack9)
					AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
				end)()
				AcAttack10 = AcAttack10 + 1
				debug.setupvalue(ac.attack, 5, AcAttack8)
				debug.setupvalue(ac.attack, 6, AcAttack9)
				debug.setupvalue(ac.attack, 4, AcAttack7)
				debug.setupvalue(ac.attack, 7, AcAttack10)
				for k, v in pairs(ac.animator.anims.basic) do
					v:Play(0.01,0.01,0.01)
				end                 
				if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(CurrentWeapon()))
					game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 2, "") 
				end
			end
		end
	end
end
--[Function Attack] 

local CameraShakerR = require(game.ReplicatedStorage.Util.CameraShaker)
spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        pcall(function()
            CombatFrameworkR.activeController.hitboxMagnitude = 180
            CameraShakerR:Stop()
                if __Attack then
                    CombatFrameworkR.activeController.timeToNextAttack = -math.huge
                    CombatFrameworkR.activeController.attacking = false
                    CombatFrameworkR.activeController.increment = 3
                    CombatFrameworkR.activeController.blocking = false
                    CombatFrameworkR.activeController.timeToNextBlock = -math.huge
                end
        end)
        pcall(function()
                if __Attack then
                    CombatFrameworkR.activeController:attack()
                end
        end)
    end)
end)

-- Function NoClip
spawn(function()
	game:GetService("RunService").Stepped:Connect(function()
		if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
			if syn then 
				if  getValue("Auto Farm Level") or getValue("Mob Aura") then
					setfflag("HumanoidParallelRemoveNoPhysics", "False")
					setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
				end
			end
			for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide == true then
					if getValue("Auto Farm Level") or getValue('Mob Aura') or getValue("Teleport Island") or getValue("Auto Evo Race") then
						v.CanCollide = false
					else
						v.CanCollide = true
					end
				end;
			end;
		end

	end)
end)

spawn(function() 
	while wait () do
		local x, e = pcall(function () 
			local UpperTorso = game.Players.LocalPlayer.Character.UpperTorso
			if getValue("Auto Farm Level") or getValue('Mob Aura') or getValue("Teleport Island") or getValue("Auto Evo Race") then
				if not UpperTorso:FindFirstChild('BodyVelocity_Volkthan') then
					local BodyVelocity = Instance.new("BodyVelocity", UpperTorso)
					BodyVelocity.Name = 'BodyVelocity_Volkthan'
					BodyVelocity.Velocity, BodyVelocity.MaxForce, BodyVelocity.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000

				end
				if not UpperTorso:FindFirstChild('BodyGyro_Volkthan') then
					local BodyGyro = Instance.new("BodyAngularVelocity", UpperTorso)
					BodyGyro.Name = 'BodyGyro_Volkthan'
					BodyGyro.AngularVelocity, BodyGyro.MaxTorque, BodyGyro.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
				end
			else
				if  UpperTorso:FindFirstChild('BodyVelocity_Volkthan') then
					UpperTorso:FindFirstChild('BodyVelocity_Volkthan'):Destroy()
				end
				if  UpperTorso:FindFirstChild('BodyGyro_Volkthan') then
					UpperTorso:FindFirstChild('BodyGyro_Volkthan'):Destroy()
				end
			end    
		end)
	end
end)


--[Function getLevelData]
local QuestLib = require(game:GetService("ReplicatedStorage").Quests)
local lastIndex = 0;
function getNextIndex(NameQuest) 
    lastIndex = 0
    for i, v in pairs(NameQuest) do 
        lastIndex = lastIndex + 1;
        if i == NameQuest then 
            return lastIndex + 1;
        end
    end
end
function getSpawnNear(name)
        for i, v in pairs(game:GetService("Workspace")["_WorldOrigin"].EnemySpawns:GetChildren()) do 
            if string.find(v.Name, name)     then 
                return true         
            end
        end
        return false
end
function getDoubleQuest()
        if not Enemies and QuestName  then return game.Players.LocalPlayer.Data.Level.Value end 
        if Enemies then 
            getLevelData(false)
            if game:GetService("Workspace")["_WorldOrigin"].EnemySpawns:FindFirstChild(Enemies) then 
                return QuestLib[QuestName][QuestData]["LevelReq"] - 1
            end
            if not game:GetService("Workspace")["_WorldOrigin"].EnemySpawns:FindFirstChild(Enemies)  then 
                if QuestData > 1 then 
                    if QuestData == 2 then 
                        print(getSpawnNear(QuestLib[QuestName][3]["Name"]))
                        if getSpawnNear(QuestLib[QuestName][3]["Name"]) then 
                            return QuestLib[QuestName][3]["LevelReq"] - 1       
                        end
                    end
                    if QuestData == 3 then 
                        print(getSpawnNear(QuestLib[QuestName][2]["Name"]))
                        if getSpawnNear(QuestLib[QuestName][2]["Name"]) then 
                            return QuestLib[QuestName][2]["LevelReq"]  - 1      
                        end
                    end
                    return game.Players.LocalPlayer.Data.Level.Value
                else 
                    return  QuestLib[QuestName][QuestData]["LevelReq"]  
                end
            end
        end
        return game.Players.LocalPlayer.Data.Level.Value
end
function getLevelData(FakeLevel)
    local Level = (FakeLevel and game.Players.LocalPlayer.Data.Level.Value  or game.Players.LocalPlayer.Data.Level.Value ) 
    if FirstSea then
         BringDistance = 350
         if Level == 1 or Level <= 9 then
         BringDistance = 275
         Enemies = "Bandit [Lv. 5]"
         QuestName = "BanditQuest1"
         QuestData = 1
         QuestNameMenu = "Bandit"
         QuestPos = CFrame.new(1060.61548, 16.5166187, 1546.06348, -0.966731012, 9.64880797e-08, 0.255795151, 8.52720916e-08, 1, -5.49381056e-08, -0.255795151, -3.12981818e-08, -0.966731012)
         EnemiesCFrame = CFrame.new(1094.74158, 68.1195679, 1617.98132, -0.805238843, 2.58748241e-06, -0.592950821, 6.83637325e-07, 1, 3.43534839e-06, 0.592950821, 2.36091159e-06, -0.805238843)
     elseif Level == 10 or Level <= 14 then
         BringDistance = 250
         Enemies = "Monkey [Lv. 14]"
         QuestName = "JungleQuest"
         QuestData = 1
         QuestNameMenu = "Monkey"
         QuestPos = CFrame.new(-1600.24353, 36.8521347, 153.224792, 0.0664860159, 1.09421023e-07, -0.997787356, 9.55680779e-09, 1, 1.10300476e-07, 0.997787356, -1.68691017e-08, 0.0664860159)
         EnemiesCFrame = CFrame.new(-1609.71216, 39.8521576, 123.384674, 0.708323717, 6.74341152e-08, 0.705887735, -1.86098941e-08, 1, -7.68568071e-08, -0.705887735, 4.13030072e-08, 0.708323717)
         elseif Level == 15 or Level <= 24 then
         BringDistance = 240
         Enemies = "Gorilla [Lv. 20]"
         QuestName = "JungleQuest"
         QuestData = 2
         QuestNameMenu = "Gorilla"
         QuestPos = CFrame.new(-1600.24353, 36.8521347, 153.224792, 0.0664860159, 1.09421023e-07, -0.997787356, 9.55680779e-09, 1, 1.10300476e-07, 0.997787356, -1.68691017e-08, 0.0664860159)
         EnemiesCFrame = CFrame.new(-1260.29321, 18.6214619, -398.3508, 0.816335142, 5.76316722e-07, -0.577578545, 8.32609999e-08, 1, 1.11549434e-06, 0.577578545, -9.58707005e-07, 0.816335142)
         elseif Level == 25 or Level <= 119 then
         Enemies = "Royal Squad [Lv. 525]"
         QuestName = "JungleQuest"
         QuestData = 1
         QuestNameMenu = "Monkey"
         QuestPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
         EnemiesCFrame = CFrame.new(-7579.42285, 5628.39111, -1540.75073, -0.0374937952, 1.17099557e-08, 0.999296963, -3.30279164e-08, 1, -1.29574085e-08, -0.999296963, -3.34905081e-08, -0.0374937952)
         elseif Level == 120 or Level <= 149 then
         Enemies = "Chief Petty Officer [Lv. 120]"
         QuestName = "MarineQuest2"
         QuestData = 1
         QuestNameMenu = "Chief Petty Officer"
         QuestPos = CFrame.new(-5034.64893, 28.6520348, 4324.53369, -0.0616381466, 5.83357576e-08, 0.998098552, -1.59750098e-08, 1, -5.9433436e-08, -0.998098552, -1.96080023e-08, -0.0616381466)
         EnemiesCFrame = CFrame.new(-4863.61328, 22.6520348, 4306.39307, 0.536051273, 7.00434066e-09, -0.844185412, -5.8011751e-10, 1, 7.92878918e-09, 0.844185412, -3.76051057e-09, 0.536051273)
         elseif Level == 150 or Level <= 174 then
         Enemies = "Sky Bandit [Lv. 150]"
         QuestName = "SkyQuest"
         QuestData = 1
         QuestNameMenu = "Sky Bandit"
         QuestPos = CFrame.new(-4843.2041, 717.669617, -2623.13159, -0.775086224, -1.6359829e-08, -0.631855488, -4.10942462e-08, 1, 2.45178793e-08, 0.631855488, 4.49690951e-08, -0.775086224)
         EnemiesCFrame = CFrame.new(-4970.74219, 294.544342, -2890.11353, -0.994874597, -8.61311165e-08, -0.101116329, -9.10836278e-08, 1, 4.43614923e-08, 0.101116329, 5.33441664e-08, -0.994874597)
         elseif Level == 175 or Level <= 189 then
         Enemies = "Dark Master [Lv. 175]"
         QuestName = "SkyQuest"
         QuestData = 2
         QuestNameMenu = "Dark Master"
         QuestPos = CFrame.new(-4843.2041, 717.669617, -2623.13159, -0.775086224, -1.6359829e-08, -0.631855488, -4.10942462e-08, 1, 2.45178793e-08, 0.631855488, 4.49690951e-08, -0.775086224)
         EnemiesCFrame = CFrame.new(-5239.94629, 392.217102, -2208.18335, 0.969297886, -5.95604988e-09, -0.245889395, 3.87897714e-09, 1, -8.93151775e-09, 0.245889395, 7.70350184e-09, 0.969297886)
         elseif Level == 190 or Level <= 209 then
         Enemies = "Prisoner [Lv. 190]"
         QuestName = "PrisonerQuest"
         QuestData = 1
         QuestNameMenu = "Prisoner"
         QuestPos = CFrame.new(5307.95166015625, 1.6809712648391724, 475.1698913574219)
         EnemiesCFrame = CFrame.new(5029.708984375, 68.67806243896484, 445.857177734375)
         elseif Level == 210 or Level <= 249 then
         Enemies = "Dangerous Prisoner [Lv. 210]"
         QuestName = "PrisonerQuest"
         QuestData = 2
         QuestNameMenu = "Dangerous Prisoner"
         QuestPos = CFrame.new(5307.95166015625, 1.6809712648391724, 475.1698913574219)
         EnemiesCFrame = CFrame.new(5673.51758, 68.6786652, 783.757629, -0.0514698699, 7.78369369e-08, 0.998674572, 8.35602094e-08, 1, -7.36337e-08, -0.998674572, 7.96595359e-08, -0.0514698699)
         elseif Level == 250 or Level <= 274 then
         Enemies = "Toga Warrior [Lv. 250]"
         QuestName = "ColosseumQuest"
         QuestData = 1
         QuestNameMenu = "Toga Warrior"
         QuestPos = CFrame.new(-1575.72961, 7.38933659, -2983.39453, 0.52762109, -1.48187587e-06, 0.849479854, 2.69328297e-07, 1, 1.57716818e-06, -0.849479854, -6.0335816e-07, 0.52762109)
         EnemiesCFrame = CFrame.new(-1819.12415, 7.28907108, -2744.02539, 0.547199547, 2.10840998e-08, -0.837002158, -1.27399286e-10, 1, 2.51067309e-08, 0.837002158, -1.36317579e-08, 0.547199547)
         elseif Level == 275 or Level <= 299 then
         Enemies = "Gladiator [Lv. 275]"
         QuestName = "ColosseumQuest"
         QuestData = 2
         QuestNameMenu = "Gladiator"
         QuestPos = CFrame.new(-1575.72961, 7.38933659, -2983.39453, 0.52762109, -1.48187587e-06, 0.849479854, 2.69328297e-07, 1, 1.57716818e-06, -0.849479854, -6.0335816e-07, 0.52762109)
         EnemiesCFrame = CFrame.new(-1334.76514, 7.44254398, -3228.90552, -0.340173125, 2.8230156e-08, 0.940362811, 2.60959143e-09, 1, -2.90764834e-08, -0.940362811, -7.4370754e-09, -0.340173125)
         BringDistance = 500
         elseif Level == 300 or Level <= 324 then
         Enemies = "Military Soldier [Lv. 300]"
         QuestName = "MagmaQuest"
         QuestData = 1
         QuestNameMenu = "Military Soldier"
         QuestPos = CFrame.new(-5316.33887, 12.236989, 8517.67285, 0.499506682, -5.08374072e-08, -0.86631006, -1.30872131e-08, 1, -6.62286652e-08, 0.86631006, 4.44192452e-08, 0.499506682)
         EnemiesCFrame = CFrame.new(-5419.0752, 10.9255161, 8464.50488, -0.637788415, -4.55103836e-05, 0.770211577, 7.05542743e-06, 1, 6.49305366e-05, -0.770211577, 4.68461185e-05, -0.637788415)
         elseif Level == 325 or Level <= 374 then
         Enemies = "Military Spy [Lv. 325]"
         QuestName = "MagmaQuest"
         QuestData = 2
         QuestNameMenu = "Military Spy"
         QuestPos = CFrame.new(-5316.33887, 12.236989, 8517.67285, 0.499506682, -5.08374072e-08, -0.86631006, -1.30872131e-08, 1, -6.62286652e-08, 0.86631006, 4.44192452e-08, 0.499506682)
         EnemiesCFrame = CFrame.new(-5805.42041, 99.5276108, 8782.36719, -0.316935152, -6.4923519e-08, 0.948447227, 4.12987404e-08, 1, 8.2252896e-08, -0.948447227, 6.52385026e-08, -0.316935152)
         elseif Level == 375 or Level <= 399 then
         BringDistance = 350
         
         Enemies = "Fishman Warrior [Lv. 375]"
         QuestName = "FishmanQuest"
         QuestData = 1
         QuestNameMenu = "Fishman Warrior"
         QuestPos = CFrame.new(61122.2422, 18.4716377, 1568.84778, 0.971045971, -1.77007031e-08, 0.238892734, 4.80190776e-09, 1, 5.45760841e-08, -0.238892734, -5.18487475e-08, 0.971045971)
         EnemiesCFrame = CFrame.new(60898.043, 18.4828224, 1550.9906, -0.0750192106, -4.46996573e-09, 0.997182071, 3.6461556e-10, 1, 4.51002746e-09, -0.997182071, 7.0192685e-10, -0.0750192106)
         if getgenv().AutoFarm and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 3000 then
             game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
         end
         elseif Level == 400 or Level <= 449 then
         BringDistance = 0
         Enemies = "Fishman Commando [Lv. 400]"
         QuestName = "FishmanQuest"
         QuestData = 2
         QuestNameMenu = "Fishman Commando"
         QuestPos = CFrame.new(61122.2422, 18.4716377, 1568.84778, 0.971045971, -1.77007031e-08, 0.238892734, 4.80190776e-09, 1, 5.45760841e-08, -0.238892734, -5.18487475e-08, 0.971045971)
         EnemiesCFrame = CFrame.new(61885.4063, 18.4828224, 1500.37195, 0.722261012, 4.84021889e-08, -0.691620588, 1.27929427e-08, 1, 8.33434299e-08, 0.691620588, -6.90435726e-08, 0.722261012)
         if getValue("Auto Farm Level") and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 3000 then
             game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
         end
         elseif Level == 450 or Level <= 474 then
         Enemies = "God's Guard [Lv. 450]"
         QuestName = "SkyExp1Quest"
         QuestData = 1
         QuestNameMenu = "God's Guard"
         QuestPos = CFrame.new(-4721.28369, 845.277161, -1954.95154, -0.979754269, -1.72096932e-08, 0.200205252, -2.52417198e-09, 1, 7.36076018e-08, -0.200205252, 7.16119786e-08, -0.979754269)
         EnemiesCFrame = CFrame.new(-4630.00635, 866.902954, -1936.76331, -0.656243384, 9.12737941e-12, 0.754549265, 3.58402819e-09, 1, 3.10498938e-09, -0.754549265, 4.74195483e-09, -0.656243384)
         if getValue("Auto Farm Level") and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 3000 then
             game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
         end
         elseif Level == 475 or Level <= 524 then
         Enemies = "Shanda [Lv. 475]"
         QuestName = "SkyExp1Quest"
         QuestData = 2
         QuestNameMenu = "Shanda"
         QuestPos = CFrame.new(-7861.79736, 5545.49316, -379.920776, 0.504107952, -1.41941534e-08, -0.863640666, -1.31181936e-08, 1, -2.40923566e-08, 0.863640666, 2.34745521e-08, 0.504107952)
         EnemiesCFrame = CFrame.new(-7682.69775, 5607.36279, -445.691833, 0.786274791, -4.48163426e-08, -0.617877364, -4.81674345e-09, 1, -7.86622607e-08, 0.617877364, 6.48263239e-08, 0.786274791)
         if getgenv().AutoFarm and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 3000 then
             game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
         end
         elseif Level == 525 or Level <= 549 then
         Enemies = "Royal Squad [Lv. 525]"
         QuestName = "SkyExp2Quest"
         QuestData = 1
         QuestNameMenu = "Royal Squad"
         QuestPos = CFrame.new(-7902.23242, 5635.96387, -1411.96741, -0.0435957126, -2.13718043e-09, 0.999049246, 4.23562352e-10, 1, 2.15769735e-09, -0.999049246, 5.1722604e-10, -0.0435957126)
         EnemiesCFrame = CFrame.new(-7579.42285, 5628.39111, -1540.75073, -0.0374937952, 1.17099557e-08, 0.999296963, -3.30279164e-08, 1, -1.29574085e-08, -0.999296963, -3.34905081e-08, -0.0374937952)
         elseif Level == 550 or Level <= 624 then
         Enemies = "Royal Soldier [Lv. 550]"
         QuestName = "SkyExp2Quest"
         QuestData = 2
         QuestNameMenu = "Royal Soldier"
         QuestPos = CFrame.new(-7902.23242, 5635.96387, -1411.96741, -0.0435957126, -2.13718043e-09, 0.999049246, 4.23562352e-10, 1, 2.15769735e-09, -0.999049246, 5.1722604e-10, -0.0435957126)
         EnemiesCFrame = CFrame.new(-7834.84717, 5681.36182, -1790.76782, -0.102890432, 3.28112684e-08, 0.994692683, -6.45397762e-08, 1, -3.96622966e-08, -0.994692683, -6.82781121e-08, -0.102890432)
         elseif Level == 625 or Level <= 649 then
         BringDistance = 300
         Enemies = "Galley Pirate [Lv. 625]"
         QuestName = "FountainQuest"
         QuestData = 1
         QuestNameMenu = "Galley Pirate"
         QuestPos = CFrame.new(5254.52734, 38.5011368, 4049.80127, -0.0732342899, 2.23174847e-08, -0.997314751, 1.2052287e-07, 1, 1.35274023e-08, 0.997314751, -1.19208565e-07, -0.0732342899)
         EnemiesCFrame = CFrame.new(5597.58936, 41.5013657, 3960.55371, -0.584786832, 4.98908861e-08, 0.811187029, 4.10757259e-08, 1, -3.18919575e-08, -0.811187029, 1.4670098e-08, -0.584786832)
         BringDistance = 450
         elseif Level >= 650 then
         BringDistance = 350
         Enemies = "Galley Captain [Lv. 650]"
         QuestName = "FountainQuest"
         QuestData = 2
         QuestNameMenu = "Galley Captain"
         QuestPos = CFrame.new(5254.52734, 38.5011368, 4049.80127, -0.0732342899, 2.23174847e-08, -0.997314751, 1.2052287e-07, 1, 1.35274023e-08, 0.997314751, -1.19208565e-07, -0.0732342899)
         EnemiesCFrame = CFrame.new(5705.8252, 52.241478, 4890.11035, -0.969319642, 4.40228476e-09, 0.245803744, -7.88622412e-09, 1, -4.90088397e-08, -0.245803744, -4.94436954e-08, -0.969319642)    
         end
         end
         if SecondSea then
             BringDistance = 350
             if Level == 700 or Level <= 724 then
             Enemies = "Raider [Lv. 700]"
             QuestName = "Area1Quest"
             QuestData = 1
             QuestNameMenu = "Raider"
             QuestPos = CFrame.new(-424.080078, 73.0055847, 1836.91589, 0.253544956, -1.42165932e-08, 0.967323601, -6.00147771e-08, 1, 3.04272909e-08, -0.967323601, -6.5768397e-08, 0.253544956)
             EnemiesCFrame = CFrame.new(-141.872437, 96.6845093, 2491.01538, 0.13152431, 0, -0.991312981, -0, 1.00000012, -0, 0.991312981, 0, 0.13152431)
             elseif Level == 725 or Level <= 774 then
             Enemies = "Mercenary [Lv. 725]"
             QuestName = "Area1Quest"
             QuestData = 2
             QuestNameMenu = "Mercenary"
             QuestPos = CFrame.new(-424.080078, 73.0055847, 1836.91589, 0.253544956, -1.42165932e-08, 0.967323601, -6.00147771e-08, 1, 3.04272909e-08, -0.967323601, -6.5768397e-08, 0.253544956)
             EnemiesCFrame = CFrame.new(-938.497314, 80.9546738, 1443.98608, 0.231955677, 0, 0.972726345, -0, 1, -0, -0.972726345, 0, 0.231955677)
             elseif Level == 775 or Level <= 874 then
             Enemies = "Swan Pirate [Lv. 775]"
             QuestName = "Area2Quest"
             QuestData = 1
             QuestNameMenu = "Swan Pirate"
             QuestPos = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-10, -0.999488771, 1.36326533e-10, 1, 8.92172336e-10, 0.999488771, -1.07732087e-10, -0.0319722369)
             EnemiesCFrame = CFrame.new(967.233276, 141.309494, 1210.06384, 0.999673784, 5.40161649e-09, -0.0255404469, -7.62258967e-09, 1, -8.68617107e-08, 0.0255404469, 8.7028063e-08, 0.999673784)
             elseif Level == 875 or Level <= 899 then
             Enemies = "Marine Lieutenant [Lv. 875]"
             QuestName = "MarineQuest3"
             QuestData = 1
             QuestNameMenu = "Marine Lieutenant."
             QuestPos = CFrame.new(-2443.04639, 73.0161057, -3220.30225, -0.854058921, -6.13997599e-08, -0.520176232, -1.30658604e-08, 1, -9.65840883e-08, 0.520176232, -7.56919505e-08, -0.854058921)
             EnemiesCFrame = CFrame.new(-2967.00757, 72.9661407, -2972.7478, 0.977851391, 8.27619218e-08, -0.209300488, -6.95268412e-08, 1, 7.05923142e-08, 0.209300488, -5.44767893e-08, 0.977851391)
             elseif Level == 900 or Level <= 949 then
             Enemies = "Marine Captain [Lv. 900]"
             QuestName = "MarineQuest3"
             QuestData = 2
             QuestNameMenu = "Marine Captain"
             QuestPos = CFrame.new(-2443.04639, 73.0161057, -3220.30225, -0.854058921, -6.13997599e-08, -0.520176232, -1.30658604e-08, 1, -9.65840883e-08, 0.520176232, -7.56919505e-08, -0.854058921)
             EnemiesCFrame = CFrame.new(-1818.36401, 93.3760834, -3203.57788, 0.315930545, 4.84752114e-08, 0.948782325, 1.37578589e-08, 1, -5.56731905e-08, -0.948782325, 3.06420738e-08, 0.315930545)
             elseif Level == 950 or Level <= 974 then
             Enemies = "Zombie [Lv. 950]"
             QuestName = "ZombieQuest"
             QuestData = 1
             QuestNameMenu = "Zombie"
             QuestPos = CFrame.new(-5492.79395, 48.5151672, -793.710571, 0.321800292, -6.24695815e-08, 0.946807742, 4.05616092e-08, 1, 5.21931227e-08, -0.946807742, 2.16082796e-08, 0.321800292)
             EnemiesCFrame = CFrame.new(-5736.03516, 126.031998, -728.026184, 0.0818082988, -5.90035434e-08, 0.996648133, 3.5947787e-09, 1, 5.89069167e-08, -0.996648133, -1.23634614e-09, 0.0818082988)
             elseif Level == 975 or Level <= 999 then
             Enemies = "Vampire [Lv. 975]"
             QuestName = "ZombieQuest"
             QuestData = 2
             QuestNameMenu = "Vampire"
             QuestPos = CFrame.new(-5492.79395, 48.5151672, -793.710571, 0.321800292, -6.24695815e-08, 0.946807742, 4.05616092e-08, 1, 5.21931227e-08, -0.946807742, 2.16082796e-08, 0.321800292)
             EnemiesCFrame = CFrame.new(-6028.23584, 6.40270138, -1295.4563, 0.667547405, 0, 0.744567394, -0, 1.00000012, -0, -0.744567394, 0, 0.667547405)
             elseif Level == 1000 or Level <= 1049 then
             Enemies = "Snow Trooper [Lv. 1000]"
             QuestName = "SnowMountainQuest"
             QuestData = 1
             QuestNameMenu = "Snow Trooper"
             QuestPos = CFrame.new(605.670532, 401.422028, -5370.10107, 0.459257662, -9.56824509e-10, -0.888303101, 5.98925964e-10, 1, -7.67489405e-10, 0.888303101, -1.79552401e-10, 0.459257662)
             EnemiesCFrame = CFrame.new(544.207947, 401.422028, -5309.08887, 0.503866196, -2.06684501e-08, 0.86378175, 1.27917943e-09, 1, 2.31816841e-08, -0.86378175, -1.05755351e-08, 0.503866196)
             elseif Level == 1050 or Level <= 1099 then
             Enemies = "Winter Warrior [Lv. 1050]"
             QuestName = "SnowMountainQuest"
             QuestData = 2
             QuestNameMenu = "Winter Warrior"
             QuestPos = CFrame.new(605.670532, 401.422028, -5370.10107, 0.459257662, -9.56824509e-10, -0.888303101, 5.98925964e-10, 1, -7.67489405e-10, 0.888303101, -1.79552401e-10, 0.459257662)
             EnemiesCFrame = CFrame.new(1240.86279, 461.108154, -5191.104, 0.528719008, -7.18234645e-08, 0.848796904, 2.89169716e-10, 1, 8.44378363e-08, -0.848796904, -4.4398444e-08, 0.528719008)
             elseif Level == 1100 or Level <= 1124 then
             Enemies = "Lab Subordinate [Lv. 1100]"
             QuestName = "IceSideQuest"
             QuestData = 1
             QuestNameMenu = "Lab Subordinate"
             QuestPos = CFrame.new(-6060.10693, 15.9868021, -4904.7876, -0.411000341, -5.06538868e-07, 0.91163528, 1.26306062e-07, 1, 6.12581289e-07, -0.91163528, 3.66916197e-07, -0.411000341)
             EnemiesCFrame = CFrame.new(-5833.63379, 48.4371948, -4510.4458, 0.0372838341, 5.56001822e-09, -0.999304712, -6.95599089e-09, 1, 5.30436006e-09, 0.999304712, 6.75338763e-09, 0.0372838341)
             elseif Level == 1125 or Level <= 1174 then
             Enemies = "Horned Warrior [Lv. 1125]"
             QuestName = "IceSideQuest"
             QuestData = 2
             QuestNameMenu = "Horned Warrior"
             QuestPos = CFrame.new(-6060.10693, 15.9868021, -4904.7876, -0.411000341, -5.06538868e-07, 0.91163528, 1.26306062e-07, 1, 6.12581289e-07, -0.91163528, 3.66916197e-07, -0.411000341)
             EnemiesCFrame = CFrame.new(-6168.15918, 42.7079964, -6020.96826, -0.744210601, 2.41774178e-09, -0.667945027, -2.3336304e-09, 1, 6.21975493e-09, 0.667945027, 6.18754425e-09, -0.744210601)
             elseif Level == 1175 or Level <= 1199 then
             Enemies = "Magma Ninja [Lv. 1175]"
             QuestName = "FireSideQuest"
             QuestData = 1
             QuestNameMenu = "Magma Ninja"
             QuestPos = CFrame.new(-5429.68359, 15.9517593, -5296.70215, 0.919959962, -6.00166317e-08, -0.392012328, 2.29238974e-08, 1, -9.93018858e-08, 0.392012328, 8.23673076e-08, 0.919959962)
             EnemiesCFrame = CFrame.new(-5404.85449, 22.8623676, -5896.09033, -0.519595861, 4.74720929e-09, 0.854412138, 1.52255595e-08, 1, 3.70304742e-09, -0.854412138, 1.49329917e-08, -0.519595861)
             if getValue("Auto Farm Level") and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 500 then
                 game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-5466.8896484375, 15.951756477356, -5212.197265625))
             end
             elseif Level == 1200 or Level <= 1249 then
             Enemies = "Lava Pirate [Lv. 1200]"
             QuestName = "FireSideQuest"
             QuestData = 2
             QuestNameMenu = "Lava Pirate"
             QuestPos = CFrame.new(-5429.68359, 15.9517593, -5296.70215, 0.919959962, -6.00166317e-08, -0.392012328, 2.29238974e-08, 1, -9.93018858e-08, 0.392012328, 8.23673076e-08, 0.919959962)
             EnemiesCFrame = CFrame.new(-5075.1958, 16.1485081, -4814.36133, -0.800640523, -1.06090866e-07, 0.599145055, -6.59776447e-08, 1, 8.89041587e-08, -0.599145055, 3.16500923e-08, -0.800640523)
             elseif Level == 1250 or Level <= 1274 then
             Enemies = "Ship Deckhand [Lv. 1250]"
             QuestName = "ShipQuest1" 
             QuestData = 1
             QuestNameMenu = "Ship Deckhand"
             QuestPos = CFrame.new(1038.67456, 125.057098, 32911.3477, 0.120709591, 5.22710089e-08, -0.992687881, 7.9174507e-09, 1, 5.36187876e-08, 0.992687881, -1.43318593e-08, 0.120709591)
             EnemiesCFrame = CFrame.new(1215.14063, 125.057114, 33050.7188, 0.527230442, 2.61814961e-08, 0.849722326, -5.66963045e-08, 1, 4.36674741e-09, -0.849722326, -5.04783984e-08, 0.527230442)
             if getgenv().AutoFarm and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
                 game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
             end
             elseif Level == 1275 or Level <= 1299 then
             Enemies = "Ship Engineer [Lv. 1275]"
             QuestName = "ShipQuest1" 
             QuestData = 2
             QuestNameMenu = "Ship Engineer"
             QuestPos = CFrame.new(1038.67456, 125.057098, 32911.3477, 0.120709591, 5.22710089e-08, -0.992687881, 7.9174507e-09, 1, 5.36187876e-08, 0.992687881, -1.43318593e-08, 0.120709591)
             EnemiesCFrame = CFrame.new(862.985413, 40.4428635, 32867.9492, -0.847809434, 8.49998827e-08, -0.530301034, 2.99658929e-08, 1, 1.1237865e-07, 0.530301034, 7.93847335e-08, -0.847809434)
             if getgenv().AutoFarm and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
                 game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
             end
             elseif Level == 1300 or Level <= 1324 then
             Enemies = "Ship Steward [Lv. 1300]"
             QuestName = "ShipQuest2" 
             QuestData = 1
             QuestNameMenu = "Ship Steward"
             QuestPos = CFrame.new(969.268311, 125.057121, 33245.2695, -0.85863924, -4.77058464e-08, -0.512580395, -1.49134394e-08, 1, -6.80880134e-08, 0.512580395, -5.08187057e-08, -0.85863924)
             EnemiesCFrame = CFrame.new(923.611511, 129.555984, 33442.3125, 0.997516274, 9.71936913e-08, 0.0704362914, -9.52239958e-08, 1, -3.13219992e-08, -0.0704362914, 2.45369804e-08, 0.997516274)
             if getgenv().AutoFarm and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
                 game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
             end
             elseif Level == 1325 or Level <= 1349 then
             Enemies = "Ship Officer [Lv. 1325]"
             QuestName = "ShipQuest2" 
             QuestData = 2
             QuestNameMenu = "Ship Officer"
             QuestPos = CFrame.new(969.268311, 125.057121, 33245.2695, -0.85863924, -4.77058464e-08, -0.512580395, -1.49134394e-08, 1, -6.80880134e-08, 0.512580395, -5.08187057e-08, -0.85863924)
             EnemiesCFrame = CFrame.new(882.275574, 181.057739, 33354.1797, 0.845816016, -3.71928088e-08, -0.533474684, 1.28583932e-09, 1, -6.7679359e-08, 0.533474684, 5.65583242e-08, 0.845816016)
             if getgenv().AutoFarm and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
                 game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
             end
             elseif Level == 1350 or Level <= 1374 then
             Enemies = "Arctic Warrior [Lv. 1350]"
             QuestName = "FrostQuest" 
             QuestData = 1
             QuestNameMenu = "Arctic Warrior"
             QuestPos = CFrame.new(5669.43506, 28.2117786, -6482.60107, 0.888092756, 1.02705066e-07, 0.459664226, -6.20391774e-08, 1, -1.03572376e-07, -0.459664226, 6.34646895e-08, 0.888092756)
             EnemiesCFrame = CFrame.new(5995.9292, 57.0727844, -6184.98926, 0.706337512, 5.23128296e-09, -0.707875192, -2.2285974e-08, 1, -1.48474424e-08, 0.707875192, 2.62629936e-08, 0.706337512)
             if getgenv().AutoFarm and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
                 game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422))
             end
             elseif Level == 1375 or Level <= 1424 then
             Enemies = "Snow Lurker [Lv. 1375]"
             QuestName = "FrostQuest" 
             QuestData = 2
             QuestNameMenu = "Snow Lurker"
             QuestPos = CFrame.new(5669.43506, 28.2117786, -6482.60107, 0.888092756, 1.02705066e-07, 0.459664226, -6.20391774e-08, 1, -1.03572376e-07, -0.459664226, 6.34646895e-08, 0.888092756)
             EnemiesCFrame = CFrame.new(5516.27539, 60.5209846, -6830.82764, 0.219563305, -7.8544824e-09, 0.975598276, 4.69439376e-09, 1, 6.99444236e-09, -0.975598276, 3.04411962e-09, 0.219563305)
             elseif Level == 1425 or Level <= 1449 then
             Enemies = "Sea Soldier [Lv. 1425]"
             QuestName = "ForgottenQuest" 
             QuestData = 1
             QuestNameMenu = "Sea Soldier"
             QuestPos = CFrame.new(-3053.97339, 236.846283, -10146.1484, -0.999963522, -2.10707256e-08, -0.00854360498, -2.09657198e-08, 1, -1.23802275e-08, 0.00854360498, -1.22006529e-08, -0.999963522)
             EnemiesCFrame = CFrame.new(-3026.54834, 29.5403671, -9758.74316, -0.999909937, 1.71713896e-08, -0.0134194754, 1.68009748e-08, 1, 2.7715517e-08, 0.0134194754, 2.74875607e-08, -0.999909937)
             if getgenv().AutoFarm and (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
                 game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422))
             end
             elseif Level >= 1450  then
             Enemies = "Water Fighter [Lv. 1450]"
             QuestName = "ForgottenQuest" 
             QuestData = 2
             QuestNameMenu = "Water Fighter"
             QuestPos = CFrame.new(-3053.97339, 236.846283, -10146.1484, -0.999963522, -2.10707256e-08, -0.00854360498, -2.09657198e-08, 1, -1.23802275e-08, 0.00854360498, -1.22006529e-08, -0.999963522)
             EnemiesCFrame = CFrame.new(-3262.00098, 298.699615, -10553.6943, -0.233570755, -4.57538185e-08, 0.972339869, -5.80986068e-08, 1, 3.30992194e-08, -0.972339869, -4.87605725e-08, -0.233570755)
             end 
         end
         if ThridSea then
             BringDistance = 350
             if Level == 1500 or Level <= 1524 then
                 Enemies = "Pirate Millionaire [Lv. 1500]"
                 QuestName = "PiratePortQuest" 
                 QuestData = 1
                 QuestNameMenu = "Pirate Millionaire"
                 QuestPos = CFrame.new(-288.688629, 43.7932091, 5578.0918, -0.980135322, 4.04644034e-08, 0.198329896, 5.16003063e-08, 1, 5.0980109e-08, -0.198329896, 6.02012875e-08, -0.980135322)
                 EnemiesCFrame = CFrame.new(-362.372589, 116.311394, 5690.42188, 0.982939184, -1.16153336e-08, -0.183930904, 1.35050096e-08, 1, 9.02115538e-09, 0.183930904, -1.13512355e-08, 0.982939184)
             elseif Level == 1525 or Level <= 1574 then
                 Enemies = "Pistol Billionaire [Lv. 1525]"
                 QuestName = "PiratePortQuest" 
                 QuestData = 2
                 QuestNameMenu = "Pistol Billionaire"
                 QuestPos = CFrame.new(-288.688629, 43.7932091, 5578.0918, -0.980135322, 4.04644034e-08, 0.198329896, 5.16003063e-08, 1, 5.0980109e-08, -0.198329896, 6.02012875e-08, -0.980135322)
                 EnemiesCFrame = CFrame.new(-238.026596, 219.645935, 6007.1748, 0.902000248, -1.08513618e-07, -0.431735516, 9.17130407e-08, 1, -5.97320096e-08, 0.431735516, 1.42825076e-08, 0.902000248)
             elseif Level == 1575 or Level <= 1624 then
                 Enemies = "Dragon Crew Warrior [Lv. 1575]"
                 QuestName = "AmazonQuest" 
                 QuestData = 1
                 QuestNameMenu = "Dragon Crew Warrior"
                 QuestPos = CFrame.new(5833.72559, 51.3513527, -1104.3147, -0.958539188, -3.53234562e-08, 0.284960806, -3.93179853e-08, 1, -8.29718783e-09, -0.284960806, -1.91572642e-08, -0.958539188)
                 EnemiesCFrame = CFrame.new(6210.00977, 51.4822731, -1187.48975, 0.208473638, 2.79291683e-08, -0.978027999, -6.3442954e-08, 1, 1.50332973e-08, 0.978027999, 5.89149387e-08, 0.208473638)
             
             elseif Level == 1625 or Level <= 1649 then
                 Enemies = "Female Islander [Lv. 1625]"
                 QuestName = "AmazonQuest2" 
                 QuestData = 1
                 QuestNameMenu = "Female Islander"
                 QuestPos = CFrame.new(5445.99756, 601.603638, 750.611145, -0.0389447734, 1.17245778e-08, -0.999241352, 1.19459349e-08, 1, 1.12678942e-08, 0.999241352, -1.1498047e-08, -0.0389447734)
                 EnemiesCFrame = CFrame.new(4660.0293, 793.07666, 771.150757, -0.300044596, 6.91594604e-09, -0.953925192, -9.75659518e-08, 1, 3.79380722e-08, 0.953925192, 1.04453733e-07, -0.300044596)
             elseif Level == 1650 or Level <= 1699 then
                 Enemies = "Giant Islander [Lv. 1650]"
                 QuestName = "AmazonQuest2" 
                 QuestData = 2
                 QuestNameMenu = "Giant Islander"
                 QuestPos = CFrame.new(5445.99756, 601.603638, 750.611145, -0.0389447734, 1.17245778e-08, -0.999241352, 1.19459349e-08, 1, 1.12678942e-08, 0.999241352, -1.1498047e-08, -0.0389447734)
                 EnemiesCFrame = CFrame.new(5013.77881, 664.0849, -42.7317543, 0.793121755, 2.98509946e-08, 0.609063148, -3.13217008e-08, 1, -8.22422486e-09, -0.609063148, -1.25540822e-08, 0.793121755)
             elseif Level == 1700 or Level <= 1724 then
                 Enemies = "Marine Commodore [Lv. 1700]"
                 QuestName = "MarineTreeIsland" 
                 QuestData = 1
                 QuestNameMenu = "Marine Commodore"
                 QuestPos = CFrame.new(2179.58447, 28.7054367, -6738.48682, 0.97564882, -2.54533923e-08, -0.219338506, 1.31742075e-08, 1, -5.74454191e-08, 0.219338506, 5.31569455e-08, 0.97564882)
                 EnemiesCFrame = CFrame.new(2548.86279, 124.071259, -7774.8999, -0.790427029, -1.174846e-08, -0.612556159, -2.99833545e-08, 1, 1.95103667e-08, 0.612556159, 3.37880124e-08, -0.790427029)
             elseif Level == 1725 or Level <= 1774 then
                 Enemies = "Marine Rear Admiral [Lv. 1725]"
                 QuestName = "MarineTreeIsland" 
                 QuestData = 2
                 QuestNameMenu = "Marine Rear Admiral"
                 QuestPos = CFrame.new(2179.58447, 28.7054367, -6738.48682, 0.97564882, -2.54533923e-08, -0.219338506, 1.31742075e-08, 1, -5.74454191e-08, 0.219338506, 5.31569455e-08, 0.97564882)
                 EnemiesCFrame = CFrame.new(3582.24365, 160.524048, -7055.01416, -0.182099551, 6.68982807e-08, -0.983280122, 8.52377937e-08, 1, 5.22501367e-08, 0.983280122, -7.42978941e-08, -0.182099551)
             elseif Level == 1775 or Level <= 1799 then
                 Enemies = "Fishman Raider [Lv. 1775]"
                 QuestName = "DeepForestIsland3" 
                 QuestData = 1
                 QuestNameMenu = "Fishman Raider"
                 QuestPos = CFrame.new(-10582.666, 331.762634, -8758.61035, 0.919332206, 1.69593086e-08, -0.393482327, -3.42409479e-08, 1, -3.68999942e-08, 0.393482327, 4.73965578e-08, 0.919332206)
                 EnemiesCFrame = CFrame.new(-10449.9258, 331.762634, -8475.85742, -0.739984214, -8.96819241e-09, 0.67262423, -5.59647688e-08, 1, -4.82362239e-08, -0.67262423, -7.33373042e-08, -0.739984214)
             elseif Level == 1800 or Level <= 1824 then
                 Enemies = "Fishman Captain [Lv. 1800]"
                 QuestName = "DeepForestIsland3" 
                 QuestData = 2
                 QuestNameMenu = "Fishman Captain"
                 QuestPos = CFrame.new(-10582.666, 331.762634, -8758.61035, 0.919332206, 1.69593086e-08, -0.393482327, -3.42409479e-08, 1, -3.68999942e-08, 0.393482327, 4.73965578e-08, 0.919332206)
                 EnemiesCFrame = CFrame.new(-11035.9189, 331.762634, -8966.12012, -0.199661195, 8.05780545e-08, -0.979865015, -2.36975328e-08, 1, 8.70625314e-08, 0.979865015, 4.06033926e-08, -0.199661195)
             elseif Level == 1825 or Level <= 1849 then
                 Enemies = "Forest Pirate [Lv. 1825]"
                 QuestName = "DeepForestIsland" 
                 QuestData = 1
                 QuestNameMenu = "Forest Pirate"
                 QuestPos = CFrame.new(-13232.082, 332.378143, -7627.49121, -0.717027605, -4.07509866e-08, 0.69704479, 3.86317822e-08, 1, 9.8201788e-08, -0.69704479, 9.734147e-08, -0.717027605)
                 EnemiesCFrame = CFrame.new(-13438.9268, 417.009583, -7767.28467, -0.301585436, -7.02043721e-08, -0.953439176, -4.40521433e-08, 1, -5.96985004e-08, 0.953439176, 2.39968401e-08, -0.301585436)
             elseif Level == 1850 or Level <= 1899 then
                 Enemies = "Mythological Pirate [Lv. 1850]"
                 QuestName = "DeepForestIsland" 
                 QuestData = 2
                 QuestNameMenu = "Mythological Pirate"
                 QuestPos = CFrame.new(-13232.082, 332.378143, -7627.49121, -0.717027605, -4.07509866e-08, 0.69704479, 3.86317822e-08, 1, 9.8201788e-08, -0.69704479, 9.734147e-08, -0.717027605)
                 EnemiesCFrame = CFrame.new(-13560.6543, 522.013672, -6733.91113, 0.996960402, -1.61884088e-08, 0.0779099241, 1.91753653e-08, 1, -3.75904605e-08, -0.0779099241, 3.89701533e-08, 0.996960402)
             elseif Level == 1900 or Level <= 1924 then
                 Enemies = "Jungle Pirate [Lv. 1900]"
                 QuestName = "DeepForestIsland2" 
                 QuestData = 1
                 QuestNameMenu = "Jungle Pirate"
                 QuestPos = CFrame.new(-12683.9668, 390.860687, -9901.30176, 0.152271122, 4.28084199e-08, -0.988338768, -4.4882615e-08, 1, 3.63985464e-08, 0.988338768, 3.88167827e-08, 0.152271122)
                 EnemiesCFrame = CFrame.new(-11983.4141, 375.940613, -10459.2383, 0.999999106, 1.88226306e-08, 0.00133047614, -1.87607263e-08, 1, -4.65408618e-08, -0.00133047614, 4.65158578e-08, 0.999999106)
             elseif Level == 1925 or Level <= 1974 then
                 Enemies = "Musketeer Pirate [Lv. 1925]"
                 QuestName = "DeepForestIsland2" 
                 QuestData = 2
                 QuestNameMenu = "Musketeer Pirate"
                 QuestPos = CFrame.new(-12683.9668, 390.860687, -9901.30176, 0.152271122, 4.28084199e-08, -0.988338768, -4.4882615e-08, 1, 3.63985464e-08, 0.988338768, 3.88167827e-08, 0.152271122)
                 EnemiesCFrame = CFrame.new(13282.3046875, 496.23684692383, -9565.150390625)
             elseif Level == 1975 or Level <= 1999 then
                 Enemies = "Reborn Skeleton [Lv. 1975]"
                 QuestName = "HauntedQuest1" 
                 QuestData = 1
                 QuestNameMenu = "Reborn Skeleton"
                 QuestPos = CFrame.new(-9481.97754, 142.104843, 5566.03662, 0.00151404156, -4.14115426e-08, -0.999998868, -3.46592838e-10, 1, -4.14121146e-08, 0.999998868, 4.092921e-10, 0.00151404156)
                 EnemiesCFrame = CFrame.new(-8762.2832, 185.188904, 6169.08057, 0.964605391, 2.60655728e-08, 0.263697594, -2.23583552e-08, 1, -1.70596284e-08, -0.263697594, 1.05599645e-08, 0.964605391)
             elseif Level == 2000 or Level <= 2024 then
                 Enemies = "Living Zombie [Lv. 2000]"
                 QuestName = "HauntedQuest1" 
                 QuestData = 2
                 QuestNameMenu = "Living Zombie"
                 QuestPos = CFrame.new(-9481.97754, 142.104843, 5566.03662, 0.00151404156, -4.14115426e-08, -0.999998868, -3.46592838e-10, 1, -4.14121146e-08, 0.999998868, 4.092921e-10, 0.00151404156)
                 EnemiesCFrame = CFrame.new(-10081.085, 237.834961, 5913.92871, 0.0515871011, 9.59092787e-08, 0.998668492, 4.31864713e-08, 1, -9.82679822e-08, -0.998668492, 4.81983271e-08, 0.0515871011)
             elseif Level == 2025 or Level <= 2049 then
                 Enemies = "Demonic Soul [Lv. 2025]"
                 QuestName = "HauntedQuest2" 
                 QuestData = 1
                 QuestNameMenu = "Demonic Soul"
                 QuestPos = CFrame.new(-9513.68945, 172.104813, 6078.30811, 0.06916935, 2.37454696e-08, 0.997604907, 1.21678923e-07, 1, -3.22391358e-08, -0.997604907, 1.23617454e-07, 0.06916935)
                 EnemiesCFrame = CFrame.new(-9661.06152, 234.989151, 6208.34473, 0.839007735, 1.00638069e-07, -0.544119537, -9.42643013e-08, 1, 3.9604533e-08, 0.544119537, 1.80625381e-08, 0.839007735)
             elseif Level == 2050 or Level <= 2074 then
                 Enemies = "Posessed Mummy [Lv. 2050]"
                 QuestName = "HauntedQuest2" 
                 QuestData = 2
                 QuestNameMenu = "Posessed Mummy"
                 QuestPos = CFrame.new(-9513.68945, 172.104813, 6078.30811, 0.06916935, 2.37454696e-08, 0.997604907, 1.21678923e-07, 1, -3.22391358e-08, -0.997604907, 1.23617454e-07, 0.06916935)
                 EnemiesCFrame = CFrame.new(-9555.10254, 66.3880768, 6371.47021, 0.993915081, -2.2833456e-08, 0.110149056, 2.02630606e-08, 1, 2.44549945e-08, -0.110149056, -2.20742304e-08, 0.993915081)
             elseif Level == 2075 or Level <= 2099 then
                 Enemies = "Peanut Scout [Lv. 2075]"
                 QuestName = "NutsIslandQuest" 
                 QuestData = 1
                 QuestNameMenu = "Peanut Scout"
                 QuestPos = CFrame.new(-2103.03442, 38.103981, -10192.5801, 0.779485822, -2.70350977e-08, 0.626419842, -3.08562882e-08, 1, 8.15541483e-08, -0.626419842, -8.2899291e-08, 0.779485822)
                 EnemiesCFrame = CFrame.new(-2149.84937, 122.471855, -10359.0498, -0.0922852308, -3.50682292e-08, -0.995732605, 3.04092396e-09, 1, -3.55003564e-08, 0.995732605, -6.30410568e-09, -0.0922852308)
             elseif Level == 2100 or Level <= 2124 then
                 Enemies = "Peanut President [Lv. 2100]"
                 QuestName = "NutsIslandQuest" 
                 QuestData = 2
                 QuestNameMenu = "Peanut President"
                 QuestPos = CFrame.new(-2103.03442, 38.103981, -10192.5801, 0.779485822, -2.70350977e-08, 0.626419842, -3.08562882e-08, 1, 8.15541483e-08, -0.626419842, -8.2899291e-08, 0.779485822)
                 EnemiesCFrame = CFrame.new(-2149.84937, 122.471855, -10359.0498, -0.0922852308, -3.50682292e-08, -0.995732605, 3.04092396e-09, 1, -3.55003564e-08, 0.995732605, -6.30410568e-09, -0.0922852308)
             elseif Level == 2125 or Level <= 2149 then
                 Enemies = "Ice Cream Chef [Lv. 2125]"
                 QuestName = "IceCreamIslandQuest" 
                 QuestData = 1
                 QuestNameMenu = "Ice Cream Chef"
                 QuestPos = CFrame.new(-823.195129, 65.8453369, -10963.583, 0.367210746, -2.2831804e-08, -0.930137753, 2.00119876e-09, 1, -2.37566322e-08, 0.930137753, 6.86230051e-09, 0.367210746)
                 EnemiesCFrame = CFrame.new(-846.166931, 205.853973, -11006.5137, -0.153710946, 3.34348504e-09, 0.988115847, -4.13023145e-08, 1, -9.80867032e-09, -0.988115847, -4.23191722e-08, -0.153710946)
             elseif Level == 2150 or Level <= 2199 then
                 Enemies = "Ice Cream Commander [Lv. 2150]"
                 QuestName = "IceCreamIslandQuest" 
                 QuestData = 2
                 QuestNameMenu = "Ice Cream Commander"
                 QuestPos = CFrame.new(-823.195129, 65.8453369, -10963.583, 0.367210746, -2.2831804e-08, -0.930137753, 2.00119876e-09, 1, -2.37566322e-08, 0.930137753, 6.86230051e-09, 0.367210746)
                 EnemiesCFrame = CFrame.new(-846.166931, 205.853973, -11006.5137, -0.153710946, 3.34348504e-09, 0.988115847, -4.13023145e-08, 1, -9.80867032e-09, -0.988115847, -4.23191722e-08, -0.153710946)
             elseif Level == 2200 or Level <= 2224 then
                 Enemies = "Cookie Crafter [Lv. 2200]"
                 QuestName = "CakeQuest1" 
                 QuestData = 1
                 QuestNameMenu = "Cookie Crafter"
                 QuestPos = CFrame.new(-2021.3193359375, 37.82402038574219, -12027.6845703125)
                 EnemiesCFrame = CFrame.new(-2288.84717, 93.943161, -12046.7285, 0.0389619507, -8.05070766e-09, 0.999240696, 1.44159458e-08, 1, 7.49472484e-09, -0.999240696, 1.41129908e-08, 0.0389619507)
             elseif Level == 2225 or Level <= 2249 then
                 Enemies = "Cake Guard [Lv. 2225]"
                 QuestName = "CakeQuest1" 
                 QuestData = 2
                 QuestNameMenu = "Cake Guard"
                 QuestPos = CFrame.new(-2021.3193359375, 37.82402038574219, -12027.6845703125)
                 EnemiesCFrame = CFrame.new(-1600.24854, 195.694992, -12346.0342, -0.9457618, -7.09395209e-08, -0.32486099, -9.57561568e-08, 1, 6.04042683e-08, 0.32486099, 8.82354882e-08, -0.9457618)
             elseif Level == 2250 or Level <= 2274 then
                 Enemies = "Baking Staff [Lv. 2250]"
                 QuestName = "CakeQuest2" 
                 QuestData = 1
                 QuestNameMenu = "Baking Staff"
                 QuestPos = CFrame.new(-1928.67395, 37.8331604, -12842.3936, -0.235107109, -7.40617239e-08, -0.971969485, -7.00571334e-08, 1, -5.92516507e-08, 0.971969485, 5.41629106e-08, -0.235107109)
                 EnemiesCFrame = CFrame.new(-1848.26746, 186.937271, -13007.0479, 0.460077673, 6.23081897e-09, -0.887878656, -9.55947232e-09, 1, 2.06415507e-09, 0.887878656, 7.53797913e-09, 0.460077673)
             elseif Level == 2275 or Level <= 2299 then
                 Enemies = "Head Baker [Lv. 2275]"
                 QuestName = "CakeQuest2" 
                 QuestData = 2
                 QuestNameMenu = "Head Baker"
                 QuestPos = CFrame.new(-1928.67395, 37.8331604, -12842.3936, -0.235107109, -7.40617239e-08, -0.971969485, -7.00571334e-08, 1, -5.92516507e-08, 0.971969485, 5.41629106e-08, -0.235107109)
                 EnemiesCFrame = CFrame.new(-2012.3689, 177.257675, -12839.6357, 0.759093106, 4.20168478e-09, -0.650982082, 1.84710747e-10, 1, 6.66976474e-09, 0.650982082, -5.18321563e-09, 0.759093106)  
             elseif Level == 2275 or Level <= 2299 then
                 Enemies = "Head Baker [Lv. 2275]"
                 QuestName = "CakeQuest2" 
                 QuestData = 2
                 QuestNameMenu = "Head Baker"
                 QuestPos = CFrame.new(-1928.67395, 37.8331604, -12842.3936, -0.235107109, -7.40617239e-08, -0.971969485, -7.00571334e-08, 1, -5.92516507e-08, 0.971969485, 5.41629106e-08, -0.235107109)
                 EnemiesCFrame = CFrame.new(-2012.3689, 177.257675, -12839.6357, 0.759093106, 4.20168478e-09, -0.650982082, 1.84710747e-10, 1, 6.66976474e-09, 0.650982082, -5.18321563e-09, 0.759093106)  
             elseif Level == 2300 or Level <= 2324 then 
                 Enemies = "Cocoa Warrior [Lv. 2300]"
                 QuestName = "ChocQuest1"
                 QuestData = 1
                 QuestNameMenu = "Cocoa Warrior"
                 QuestPos = CFrame.new(232.75099182128906, 24.760034561157227, -12198.2216796875)
                 EnemiesCFrame = CFrame.new(85.33313751220703, 73.5171127319336, -12317.169921875)
             elseif Level == 2325 or Level <= 2349 then
                 Enemies = "Chocolate Bar Battler [Lv. 2325]"
                 QuestName = "ChocQuest1"
                 QuestData = 2 
                 QuestNameMenu = "Chocolate Bar Battler"
                 QuestPos = CFrame.new(232.75099182128906, 24.760034561157227, -12198.2216796875)
                 EnemiesCFrame = CFrame.new(722.2747802734375, 141.80760192871094, -12716.5302734375)
             elseif Level == 2350 or Level <= 2374 then
                 Enemies = "Sweet Thief [Lv. 2350]"
                 QuestName = "ChocQuest2"
                 QuestData = 1 
                 QuestNameMenu = "Sweet Thief"
                 QuestPos = CFrame.new(149.86026000976562, 24.819625854492188, -12775.3720703125)
                 EnemiesCFrame = CFrame.new(-114.19597625732422, 105.17113494873047, -12673.9541015625)
             elseif Level >= 2375 then 
                 Enemies = "Candy Rebel [Lv. 2375]"
                 QuestName = "ChocQuest2"
                 QuestData = 2
                 QuestNameMenu = "Candy Rebel"
                 QuestPos = CFrame.new(152.71707153320312, 24.819623947143555, -12774.052734375)
                 EnemiesCFrame = CFrame.new(420.3561096191406, 109.24739837646484, -12989.76171875)
             end
         end
        end
 
local TeleportListReqiurement = {
    ['Island'] = {
        [7449423635] = {
            ['Chocolate Island'] = CFrame.new(93.06615447998047, 24.760082244873047, -12079.8544921875),
            ['Cookie Island'] = CFrame.new(-2007.2210693359375, 37.82394790649414, -11922.1650390625),
            ['Ice cream Island'] = CFrame.new(-887.1438598632812, 65.84530639648438, -10901.7314453125),
            ['Peanut Island'] = CFrame.new(-2051.560791015625, 4.701087474822998, -9904.705078125),
            ['Haunted Castle'] = CFrame.new(-9514.884765625, 164.0062255859375, 5786.513671875),
            ['Floating Turtle'] = CFrame.new(-11990.1728515625, 331.7489929199219, -9149.810546875),
            ['Mansion'] = CFrame.new(-12548.7802734375, 337.1940612792969, -7466.06005859375),
            ['Castle on the sea'] = CFrame.new(-5077.16357421875, 314.5412902832031, -2982.691650390625),
            ['Hydra Island (Top)'] = CFrame.new(5224.20263671875, 603.9165649414062, 348.0016174316406),
            ['Freindly Arena'] = CFrame.new(5241.35888671875, 68.15036010742188, -1456.508056640625),
            ['Secret Temple'] = CFrame.new(5226.72998046875, 8.112529754638672, 1100.6185302734375),
            ['Hydra Island (Bottom)'] = CFrame.new(6592.29443359375, 378.42431640625, 198.75831604003906),
            ['Beautiful Pirate Domain'] = CFrame.new(5317.4150390625, 22.562240600585938, -86.25806427001953),
            ['Port Town'] = CFrame.new(-277.5933532714844, 29.43861198425293, 5397.7939453125),
            ['Great Tree'] = CFrame.new(2317.06494140625, 40.68013000488281, -6644.35595703125),
            ['List'] = function () 
                return {
                    "Mansion",
                    "Chocolate Island",
                    "Cookie Island",
                    "Peanut Island",
                    "Haunted Castle",
                    "Floating Turtle",
                    "Castle on the sea",
                    "Hydra Island (Top)",
                    "Freindly Area",
                    "Secret Temple",
                    "Hydra Island (Bottom)",
                    "Beautiful Pirate Domain",
                    "Port Town",
                    "Great Tree"
                }
            end
        },
        [4442272183] = {
            ['Kingdom of Rose (First)'] = CFrame.new(-311.698273, 76.5936203, 353.891449),
            ["Colosseum"] = CFrame.new(-1815.9678955078125, 45.82050323486328, 1361.7818603515625),
            ["Arowe"] = CFrame.new(-1991.29871, 125.493317, -70.4986115),
            ['Cafe'] = CFrame.new(-311.698273, 76.5936203, 353.891449),
            ['Factory'] = CFrame.new(321.70513916015625, 74.4476547241211, -322.9969177246094),
            ['Green Zone'] = CFrame.new(-2281.22412109375, 72.9919204711914, -2739.0517578125),
            ['Snow Mountain'] = CFrame.new(728.682373046875, 406.376220703125, -5290.54931640625),
            ['Dark Area'] = CFrame.new(3779.173828125, 22.677961349487305, -3499.56884765625),
            ["Ice Castle"] = CFrame.new(5599.55859375, 28.21732521057129, -6258.75341796875),
            ["Graveyard Island"]  = CFrame.new(-5619.25537109375, 492.22174072265625, -779.9219970703125),
            ['Cursed Ship'] = CFrame.new(-6520.28759765625, 116.21282958984375, -66.84648132324219),
            ['Cold Island'] = CFrame.new(-5928.41259765625, 15.97756290435791, -5074.2919921875),
            ['Hot Island'] = CFrame.new(-5565.30762, 329.040497, -5955.07617),
            ['Lab (Raid)'] = CFrame.new(-6506.06005859375, 249.5574188232422, -4478.32470703125),
            ['List'] = function ()
                return {
                    "Kingdom of Rose (First)",
                    "Colosseum",
                    "Arowe",
                    "Cafe",
                    "Factory",
                    "Green Zone",
                    "Snow Mountain",
                    "Dark Area",
                    "Ice Castle",
                    "Graveyard Island",
                    "Cursed Ship",
                    "Cold Island",
                    "Hot Island", 
                    "Lab (Raid)",
                }    
            end,
        },
        [2753915549] = {
            ["Pirate Starter (Wind Mill)"] = CFrame.new(1023.6799926757812, 16.299358367919922, 1423.7130126953125),
            ['Middle Town'] = CFrame.new(-793.1625366210938, 74.08917236328125, 1609.5194091796875),
            ['Jungle (First)'] = CFrame.new(-1611.679443359375, 36.87788772583008, 150.90872192382812),
            ['Jungle (Second)']  = CFrame.new(-1197.575927734375, 7.706204891204834, -445.1310729980469),
            ['Pirate Village'] = CFrame.new(-1175.1016845703125, 44.77783203125, 3838.5625),
            ['Desert'] = CFrame.new(913.9247436523438, 6.482755661010742, 4348.37255859375),
            ['Forzen Village'] = CFrame.new(1393.5726318359375, 87.29856872558594, -1358.452392578125),
            ['Leader Island'] = CFrame.new(-2865.027587890625, 51.078887939453125, 5415.31298828125),
            ["Marine Fortess"] = CFrame.new(-4930.88525390625, 195.8453369140625, 4319.03857421875),
            ["Marine Starter (Marine Base)"] = CFrame.new(-2537.419189453125, 6.881472110748291, 2041.1346435546875),
            ["Skylands (Floor 0)"] = CFrame.new(-4976.720703125, 3.9034066200256348, -2443.78173828125),
            ["Skylands (Floor 1)"] = CFrame.new(-5001.01220703125, 278.0926513671875, -2816.78271484375),
            ['Skylands (Floor 2)'] = CFrame.new(-5276.6171875, 388.677734375, -2310.68798828125),
            ['Skylands (Floor 3)'] = CFrame.new(-4845.89453125, 717.7422485351562, -2629.07666015625),
            ["Skylands (Floor 4)"] = CFrame.new(-4657.05517578125, 845.3027954101562, -1820.4195556640625),
            ["Skylands (Floor Highest)"] = CFrame.new(-7809.8525390625, 5559.29833984375, -427.9993896484375),
            ['Colosseum'] = CFrame.new(-1671.0989990234375, 39.3856201171875, -3127.36962890625),
            ['Prison'] = CFrame.new(4866.326171875, 64.67761993408203, 739.7095336914062),
            ['Underwater (Gateway)'] = CFrame.new(3853.03564453125, 16.73044204711914, -1950.12353515625),
            ['Fountain City'] = CFrame.new(5184.32373046875, 38.52693176269531, 4134.9306640625),
            ['Magma Village'] = CFrame.new(-5252.62353515625, 8.616477012634277, 8455.3974609375),
            ['List'] = function() 
                return {
                    "Pirate Starter (Wind Mill)",
                    "Marine Starter (Marine Base)",
                    'Middle Town',
                    'Jungle (Main)',
                    'Jungle (Second)',
                    "Pirate Village",
                    'Desert',
                    "Leader Island",
                    "Skylands (Floor 0)",
                    "Skylands (Floor 1)",
                    'Skylands (Floor 2)',
                    'Skylands (Floor 3)' ,
                    "Skylands (Floor 4)",
                    "Skylands (Floor Highest)",
                    "Colosseum",
                    "Prison",
                    "Magma Village",
                    "Underwater (Gateway)",
                    "Fountain City"
                }    
            end
        }
    },
};

--Function Bring

spawn(function() -- Bring Mob Function
    game:GetService("RunService").Stepped:Connect(function()
        if getValue("Auto Farm Level") and __BringMob then 
            getLevelData(true)
            pcall(function() 
                for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                    if v.Name == Enemies then 
                            if (v.HumanoidRootPart.Position - PosMon.Position).Magnitude <= 350 and isnetworkowner(v.HumanoidRootPart) then
                                v.Head.CanCollide = false
                                v.Humanoid.Sit = false
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.CFrame = PosMon
                                for i , v in pairs(v:GetChildren()) do 
                                    if v:IsA("BasePart") and v.CanCollide == true then
                                        v.CanCollide = false
                                    end
                                end
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                            end
                    end
                end    
            end)
        end
    end)
end)



--[Function Auto Farm]

spawn(function() --Auto Farm Function
    while  wait() do 
        if getValue("Auto Farm Level") then 
            __BringMob = false
            __Attack = false
            PosMon = nil
            getLevelData(true)
            if not game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible then
            	Tween(QuestPos)
            	if (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5  then
						getLevelData(true)
						wait(1)
						if (QuestPos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5  then
							game.ReplicatedStorage.Remotes.CommF_:InvokeServer('StartQuest', QuestName, QuestData)
						else
							Tween(QuestPos)
						end
					end
            else 
            -- End get quest
            EnemiesWorkspace = game.Workspace.Enemies
            ReplicatedStorage = game.ReplicatedStorage
            if not EnemiesWorkspace:FindFirstChild(Enemies) and ReplicatedStorage:FindFirstChild(Enemies) then
                pcall(function() 
					Tween(ReplicatedStorage:FindFirstChild(Enemies).HumanoidRootPart.CFrame * CFrame.new(20, 0, 0))
				end)
            end
            if not EnemiesWorkspace:FindFirstChild(Enemies) and not  ReplicatedStorage:FindFirstChild(Enemies) then
                PosMon = nil
				Tween(EnemiesCFrame)
            end
            if EnemiesWorkspace:FindFirstChild(Enemies) and game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible then 
                for i , v in pairs(EnemiesWorkspace:GetChildren()) do 
                    if v.Name == Enemies and v:FindFirstChild('Humanoid') then 
                        if v.Humanoid.Health > 0 then
                                repeat task.wait() 
									if not string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,QuestNameMenu) then
										game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible = false
									end
									pcall(function() 
									     if PosMon == nil then 
									     	PosMon = v.HumanoidRootPart.CFrame
										 end
                                         pcall(function()
                                             EquipWeapon(getValue("Weapon"))
                                         end)
										 Tween(PosMon* CFrame.new(0,30,15))
                                         v.Humanoid.JumpPower = 0
                                         v.Humanoid.WalkSpeed = 0
                                         v.Humanoid.Sit = true
                                         v.HumanoidRootPart.CanCollide = false
										 if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 50 then
											__Attack = true
										else
											__Attack = false
										end
										getLevelData(true)
										if not game.Players.LocalPlayer.Character:FindFirstChild('HasBuso')then
											game.ReplicatedStorage.Remotes.CommF_:InvokeServer('Buso')
										end
										if not string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,QuestNameMenu) then
												game.ReplicatedStorage.Remotes.CommF_:InvokeServer('StartQuest', QuestName, QuestData)
										end
										__BringMob = true
                                         sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)    
									end)
                                until  not game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible or  not v.Parent or v.Humanoid.Health <= 0 or not getValue("Auto Farm Level")
                                PosMon = nil
                        end
                    end
                end
            end
            --
            end
        end
    end
end)
if game.CoreGui:FindFirstChild("PepsiUi") then
    game.CoreGui:FindFirstChild("PepsiUi"):Destroy()
end

local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Wait = library.subs.Wait 


local PepsiUi = library:CreateWindow({
    Name = "KAI HUB",
    Theme = {
        Image = "rbxassetid://7483871523",
        Info = "Info",
        Background = {
            Asset = "rbxassetid://5553946656"
        }
    }
})

local Page = PepsiUi:CreateTab({
    Name = "Main"
})


local TeleportList = PepsiUi:CreateTab({
    Name = "Teleport"
})






local GrindTab = Page:CreateSection({
    Name = "Auto Grind & etc", -- ชื่อ
    Side = "Left" -- ตำแหน่ง Left/Right
})

local MiscTab = Page:CreateSection({
    Name = "Settings ", -- ชื่อ
    Side = "Right" -- ตำแหน่ง Left/Right
})
local EvoRaceTab = Page:CreateSection({
    Name = "Evo Race ", -- ชื่อ
    Side = "Left" -- ตำแหน่ง Left/Right
})
local TeleportTab = TeleportList:CreateSection({
    Name = "Teleport Island", -- ชื่อ
    Side = "Left" -- ตำแหน่ง Left/Right
})
TeleportTab:AddDropdown({
    Name = "Select Island",
    Value = TeleportListReqiurement['Island'][game.PlaceId]['List']()[1],
    List = TeleportListReqiurement['Island'][game.PlaceId]['List'](),
    Callback = function(v)
        setValue("Select Island", v)    
    end
})
TeleportTab:AddToggle({
    Name = "Teleport Island",
    Value = getValue("Teleport Island"),
    Callback = function(v)
        setValue("Teleport Island", v)    
    end
})
if getValue("Distance Bring Mob") == nil then
	setValue("Distance Bring Mob", 350)
end
spawn(function() 
    while true do task.wait() 
        if getValue("Teleport Island") then 
            pcall(function() 
                Tween(TeleportListReqiurement['Island'][game.PlaceId][getValue("Select Island")])
            end)    
        end
    end
end)
GrindTab:AddToggle({
    Name = "Auto Grind Level",
	Value = getValue("Auto Farm Level"), -- ปรับค่าToggle true/false or Config
    Callback = function(value)
        setValue("Auto Farm Level", value)
    end
})

GrindTab:AddToggle({
    Name = "Mob Aura",
	Value = getValue("Mob Aura"), -- ปรับค่าToggle true/false or Config
    Callback = function(value)
        setValue("Mob Aura", value)
    end
})
local MobPosLabel = GrindTab:AddLabel({
    Name = "Position : null"
})
GrindTab:AddButton({
    Name = "Set Position Mob Aura",
    Callback = function()
        MobPosLabel:Set("Position : " .. tostring(game.Players.LocalPlayer.Character.HumanoidRootPart.Position))
        MobAuraPos = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
    end
})
local RaceInfo = EvoRaceTab:AddLabel({
    Name = "Race : Unknow"
})
local RaceV2 = EvoRaceTab:AddLabel({
    Name = "Race V (2) : ❌"
})
local RaceV3 = EvoRaceTab:AddLabel({
    Name = "Race V (3) : ❌"
})
EvoRaceTab:AddLabel({
    Name = "Race Support"
})
EvoRaceTab:AddLabel({
    Name = "Human ✅"
})
EvoRaceTab:AddLabel({
    Name = "Mink ✅"
})
local function HttpRequest(...) 
    local args = {...}
    local status, result = pcall(function() 
        if syn then 
            if syn.request then 
                return syn.request
            end
        end
        if http then 
            if http.request then 
                return http.request
            end
        end
        if request then  
            return request
        end
    end) 
    if status then 
        return result(args[1])
    end
    if not status then
        return request(args[1])
    end
end

local ChestCount = 0;
local RaceCheck = (function() 
    local err, result = pcall(function() 
        return game:GetService("Players").LocalPlayer.Data.Race.Value
    end)
    return result
end)()
_G.Send = false
spawn(function() 
	while true do wait() 
		if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "1") == -2 then 
			RaceV2:Set("Race V (2) : ✅")
		end
		if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1") == -2 then 
			RaceV3:Set("Race V (3) : ✅")
			wait(10) 
			game:Shutdown()
			if _G.Send == false then 
				local embed = 
                                        string.gsub( 
                                            string.gsub([=[
                                                {
                                                    "color": 16776181,
                                                    "title": "Race V3 Notify",
                                                    "fields": [{
                                                        "name": "Username",
                                                        "inline": true,
                                                        "value": "```\n{username}```"
                                                    }, {
                                                        "name": "Race",
                                                        "inline": true,
                                                        "value": "```\n {race} ```"
                                                    }],
                                                    "image": {
                                                        "url": "https://media.discordapp.net/attachments/1071121457352028233/1071123192107773999/ezgif-2-cf057197f6.gif"
                                                    }
                                                }
                                            ]=], "{username}", tostring(game.Players.LocalPlayers.Name)
                                            ), "{race}",tostring(game:GetService("Players").LocalPlayer.Data.Race.Value)
                )
                local Payload = {
                    ["embeds"] = {
                        game:GetService("HttpService"):JSONDecode(embed)
                    }
                }
                local url = getgenv().Webhook
                local respone = HttpRequest({
                    Url = url,
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Method = "POST",
                    Body = game:GetService("HttpService"):JSONEncode(Payload)
                })
                _G.Send = true
                if not respone then return nil end 
                if respone then 
                    return respone
                end
			end
		end
	end
end)
if RaceCheck then 
    RaceInfo:Set("Race : " .. RaceCheck)
    if RaceCheck == "Mink" then 
        local ChestCountLabel = EvoRaceTab:AddLabel({
            Name = "Chest : " .. tostring(ChestCount)
        })
        spawn(function() 
            while true do wait()
                ChestCountLabel:Set("Chest : " .. tostring(ChestCount))
            end            
        end)
    end
end
setValue("Auto Evo Race", true)
EvoRaceTab:AddToggle({
    Name = "Auto Evo Race (3)",
	Value = getValue("Auto Evo Race"), -- ปรับค่าToggle true/false or Config
    Callback = function(value)
        setValue("Auto Evo Race", value)
    end
})
function touchInterest(Part)
    pcall(function() 
        firetouchinterest(Part, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
        firetouchinterest(Part, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
    end)
end
function findSkypiea()
    for i, v in pairs(game.Players:GetPlayers()) do 
        if v ~= game.Players.LocalPlayer then 
            if v:FindFirstChild("Data") then 
                local Data = v:FindFirstChild("Data")
                local Race = Data:FindFirstChild("Race")
                if Race then 
                    if Race == "Skypiea" then 
                        return v     
                    end
                end
            end
        end
    end
    return nil
end

spawn(function() 
    while true do task.wait() 
        if getValue("Auto Evo Race") then 
            if not SecondSea then 
                repeat wait()
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
                until SecondSea
            end
            local CheckIsEvo = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "1");
            if CheckIsEvo == -2 then 
                local Check = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
                if Check == 0 then 
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "2")
                    Check = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
                end
                if Check == 2 then 
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
                end
                if Check == 1 then 
                    local Race = (function() 
                        local err, result = pcall(function() 
                            return game:GetService("Players").LocalPlayer.Data.Race.Value
                        end)
                        return result
                    end)()
                    print('Race')
                    if Race then 
                        Check = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
                        if Race == "Mink" then 
                            for i, v in pairs(game:GetService("Workspace"):GetChildren()) do 
                                if v:IsA("Part") then 
                                    if v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3" then 
                                        repeat wait()
                                            Tween(v.CFrame)
                                            Check = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
                                            if Check == 2 then 
                                                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
                                            end
                                        until not v.Parent or not getValue("Auto Evo Race")
                                        ChestCount = ChestCount + 1
                                    end
                                end
                            end
                            for i, v in pairs(game:GetService("Workspace").Map:GetDescendants()) do 
                                if v:IsA("Part") then 
                                    if v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3"  then 
                                        repeat wait()
                                            Tween(v.CFrame)
                                            ChestCount = ChestCount + 1
                                            Check = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
                                            if Check == 2 then 
                                                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
                                            end
                                        until not v.Parent or not getValue("Auto Evo Race")
                                        ChestCount = ChestCount + 1
                                    end
                                end
                            end
                            if Check == 2 then 
                                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
                            end
                        end
                        if Race == "Skypiea" then 
                            local founded = findSkypiea()
                            if founded then 
                                local v = founded.Character
                                repeat task.wait() 
                                     pcall(function() 
                                        if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                                        end
                                        pcall(function()
                                            EquipWeapon(getValue("Weapon"))
                                        end)  
                                        Tween(v.HumanoidRootPart.CFrame * CFrame.new(1,1,0))
                                        AttackPlayers()
                                    end)
                                    sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                until not getValue("Auto Evo Race") or not v.Parent or v.Humanoid.Health <= 0
                            else 
                            end
                        end
                        if Race == "Human" then 
                            Check = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
                            if Check == 2 then 
                                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
                            end
                            if game:GetService("ReplicatedStorage"):FindFirstChild("Fajita [Lv. 925] [Boss]") then 
                                repeat task.wait() 
                                    pcall(function() 
                                        Tween(game:GetService("ReplicatedStorage"):FindFirstChild("Fajita [Lv. 925] [Boss]").HumanoidRootPart.CFrame * CFrame.new(0,30,15))
                                    end)
                                until not game:GetService("ReplicatedStorage"):FindFirstChild("Fajita [Lv. 925] [Boss]")
                            end
                            if game:GetService("Workspace").Enemies:FindFirstChild("Fajita [Lv. 925] [Boss]") then 
                                local v = game:GetService("Workspace").Enemies:FindFirstChild("Fajita [Lv. 925] [Boss]")
                                repeat task.wait() 
                                    if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                                    end
                                    pcall(function()
                                        EquipWeapon(getValue("Weapon"))
                                    end)
                                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 50 then
                                        __Attack = true
                                    else
                                        __Attack = false
                                    end
                                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                    v.Head.CanCollide = false
                                    v.Humanoid.Sit = false
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.JumpPower = 0
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid:ChangeState(11)
                                    sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                until not getValue("Auto Evo Race") or not v.Parent or v.Humanoid.Health <= 0
                            end
                            if game:GetService("ReplicatedStorage"):FindFirstChild("Jeremy [Lv. 850] [Boss]") then 
                                repeat task.wait() 
                                    pcall(function() 
                                        Tween(game:GetService("ReplicatedStorage"):FindFirstChild("Jeremy [Lv. 850] [Boss]").HumanoidRootPart.CFrame * CFrame.new(0,30,15))
                                    end)
                                until not game:GetService("ReplicatedStorage"):FindFirstChild("Jeremy [Lv. 850] [Boss]")
                            end
                            if game:GetService("Workspace").Enemies:FindFirstChild("Jeremy [Lv. 850] [Boss]") then 
                                local v = game:GetService("Workspace").Enemies:FindFirstChild("Jeremy [Lv. 850] [Boss]")
                                repeat task.wait() 
                                    if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                                    end
                                    pcall(function()
                                        EquipWeapon(getValue("Weapon"))
                                    end)
                                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 50 then
                                        __Attack = true
                                    else
                                        __Attack = false
                                    end
                                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                    v.Head.CanCollide = false
                                    v.Humanoid.Sit = false
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.JumpPower = 0
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid:ChangeState(11)
                                    sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                until not getValue("Auto Evo Race") or not v.Parent or v.Humanoid.Health <= 0
                            end
                            if game:GetService("ReplicatedStorage"):FindFirstChild("Diamond [Lv. 750] [Boss]") then 
                                repeat task.wait() 
                                    pcall(function() 
                                        Tween(game:GetService("ReplicatedStorage"):FindFirstChild("Diamond [Lv. 750] [Boss]").HumanoidRootPart.CFrame * CFrame.new(0,30,15))
                                    end)
                                until not game:GetService("ReplicatedStorage"):FindFirstChild("Diamond [Lv. 750] [Boss]")
                            end
                            if game:GetService("Workspace").Enemies:FindFirstChild("Diamond [Lv. 750] [Boss]") then 
                                local v = game:GetService("Workspace").Enemies:FindFirstChild("Diamond [Lv. 750] [Boss]")
                                repeat task.wait() 
                                    if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                                    end
                                    pcall(function()
                                        EquipWeapon(getValue("Weapon"))
                                    end)
                                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 50 then
                                        __Attack = true
                                    else
                                        __Attack = false
                                    end
                                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                    v.Head.CanCollide = false
                                    v.Humanoid.Sit = false
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.JumpPower = 0
                                    v.Humanoid.WalkSpeed = 0
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid:ChangeState(11)
                                    sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                until not getValue("Auto Evo Race") or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                end
            else 
                if CheckIsEvo == 0 then 
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "2")
                    CheckIsEvo = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "1")
                end
                if CheckIsEvo == 1 then 
                    pcall(function() 
                        touchInterest(game:GetService("Workspace").Flower1)
                        touchInterest(game:GetService("Workspace").Flower2)    
                    end)
                    --
                    if not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 3") or not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Flower 3") then
                        repeat wait() 
                             if (#game:GetService("Workspace").Enemies:GetChildren() == 0) then 
                                pcall(function() 
                                    Tween(CFrame.new(921.51416015625, 126.08345794677734, 33142.796875))  
                                end)  
                            end
                            for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                                if  v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 2000 then
                                    repeat wait()
                                        pcall(function()
                                            if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                                            end
                                            pcall(function()
                                                EquipWeapon(getValue("Weapon"))
                                            end)
                                            v.Humanoid.JumpPower = 0
                                            v.Humanoid.WalkSpeed = 0
                                            v.HumanoidRootPart.CanCollide = false
                                            v.Humanoid:ChangeState(11)
                                            if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 50 then
                                                __Attack = true
                                            else
                                                __Attack = false
                                            end
                                            Tween(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                            pcall(function() 
                                            for w, k in pairs(game.Workspace.Enemies:GetChildren()) do 
                                                    if k:FindFirstChild("Humanoid") and k:FindFirstChild("HumanoidRootPart") and k.Humanoid.Health > 0 and (k.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 1000 then 
                                                        if  isnetworkowner(v.HumanoidRootPart) and (v.HumanoidRootPart.Position-PosMonAura.Position).magnitude <= getValue("Distance Bring Mob") then 
                                                            k.Head.CanCollide = false
                                                            k.Humanoid.Sit = false
                                                            k.HumanoidRootPart.CanCollide = false
                                                            k.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
                                                            k.Humanoid.JumpPower = 0
                                                            k.Humanoid.WalkSpeed = 0
                                                            k.HumanoidRootPart.CanCollide = false
                                                            k.Humanoid:ChangeState(11)
                                                        end
                                                    end
                                                end
                                            end)
                                        end)
                                    until not getValue("Auto Evo Race") or not v.Parent or v.Humanoid.Health <= 0
                                    if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 3") then 
                                        break 
                                    end
                                end
                            end   
                        until  game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 3") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Flower 3") or not getValue("Auto Evo Race")
                    end
                    if not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 2") and not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 2") then 
                        repeat wait() 
                            pcall(function()
                                Tween(game:GetService("Workspace").Flower2.CFrame)        
                            end)
                        until  game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 2") or  game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 2") or not getValue("Auto Evo Race")
                    end
                    if not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 1") and not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 1") then 
                       repeat wait() 
                            pcall(function()
                                Tween(game:GetService("Workspace").Flower1.CFrame)        
                            end)
                       until  game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 1") or  game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Flower 1") or not getValue("Auto Evo Race")
                    end
                end
                CheckIsEvo = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "1")
                if CheckIsEvo == 2 then 
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "3")
                end
            end
        end
    end
end)
RaceV3:AddButton({
Name = "Random Race",
Callback = function()
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
end
})
spawn(function()
   while wait() do
        pcall(function()
            if getValue("Mob Aura") then
                if (#game:GetService("Workspace").Enemies:GetChildren() == 0) then 
                    pcall(function() 
                        Tween(MobAuraPos)  
                    end)  
                end
                for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                    if getValue("Mob Aura") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= getValue("Distance Mob Aura") then
                        repeat wait()
                            if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                            end
                            pcall(function()
                                EquipWeapon(getValue("Weapon"))
                            end)
                            PosMonAura = v.HumanoidRootPart.CFrame
                            v.Humanoid.JumpPower = 0
                            v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.CanCollide = false
                            v.Humanoid:ChangeState(11)
                            if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 50 then
                                __Attack = true
                            else
                                __Attack = false
                            end
                            Tween(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                        until not getValue("Mob Aura") or not v.Parent or v.Humanoid.Health <= 0
                    end
                end
            end
        end)
    end
end)
spawn(function() 
    game:GetService("RunService").Stepped:Connect(function() 
        if getValue("Mob Aura") then
            for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                if getValue("Mob Aura") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= getValue("Distance Mob Aura") then
                    if isnetworkowner(v.HumanoidRootPart) and (v.HumanoidRootPart.Position-PosMonAura.Position).magnitude <= 350 then 
                        v.Head.CanCollide = false
                        v.Humanoid.Sit = false
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.CFrame = PosMonAura
                        v.Humanoid.JumpPower = 0
                        v.Humanoid.WalkSpeed = 0
                        v.HumanoidRootPart.CanCollide = false
                        v.Humanoid:ChangeState(11)
                        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                    end
                end
            end
        end
    end)
end)

local Item = {}
for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do 
    if v:IsA("Tool") then 
        table.insert(Item, v.Name)    
    end
end
for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do 
    if v:IsA("Tool") then 
        table.insert(Item, v.Name)    
    end 
end
local WeaponList = MiscTab:AddDropdown({
	Name = "Select Weapon",
	Value = getValue("Weapon"), 
	List = Item,
	Callback = function(value)
		setValue("Weapon", value)
	end
})
MiscTab:AddButton({
Name = "Refresh Weapon",
Callback = function()
    table.clear(Item)
    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do 
    if v:IsA("Tool") then 
        table.insert(Item, v.Name)    
    end
    end
    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do 
        if v:IsA("Tool") then 
            table.insert(Item, v.Name)    
        end 
    end
    WeaponList:Set(Item)
end
})
MiscTab:AddToggle({
    Name = "Fast Attack",
	Value = getValue("Fast Attack"), 
    Callback = function(value)
        setValue("Fast Attack", value)
    end
})
MiscTab:AddToggle({
    Name = "Ultra Fast Attack",
	Value = getValue("Ultra Fast Attack"), 
    Callback = function(value)
        setValue("Ultra Fast Attack", value)
    end
})
MiscTab:AddSlider({
    Name = "Attack Duration",
    Value = getValue("Attack Duration"),
    Min = 0,
    Max = 30,
    Format = function(Value) 
        return "Attack Duration : " .. tonumber(Value)
    end,
    Callback = function(Value)
        setValue("Attack Duration", tonumber(Value))
    end
})

MiscTab:AddSlider({
    Name = "Attack Cooldown",
    Value = getValue("Attack Cooldown", 5),
    Min = 0,
    Max = 100,
    Format = function (Value) 
        return "Attack Cooldown : " .. tostring(Value / 100) .. " s"    
    end,
    Callback = function(Value)
        setValue("Attack Cooldown", tonumber(Value))
    end
})
MiscTab:AddSlider({
    Name = "Distance Mob Aura",
    Value = getValue("Distance Mob Aura", 500),
    Min = 0,
    Max = 1000,
    Format = function (Value) 
        return "Distance Mob Aura : " .. tostring(Value) .. " m"    
    end,
    Callback = function(Value)
        setValue("Distance Mob Aura", tonumber(Value))
    end
})



for a,j  in pairs(game:GetService("CoreGui"):GetChildren()) do 
    if j:FindFirstChild("main") then 
        for i, v in pairs(j:GetDescendants()) do 
        if v:IsA("TextLabel") or v:IsA('TextButton') or v:IsA("ImageLabel") then
            spawn(function()
    					while task.wait() do
    						pcall( function() 
    						    local t = 5; 
    						local hue = tick() % t / t
    						local colorrr = Color3.fromHSV(hue, 1, 1)
    						v.TextColor3 = colorrr 
    						   end)
    					end
            end)    
    	    if v.Name == "sliderColored" then 
    	        spawn(function()
    					pcall(function() 
    					    while task.wait() do
    						local t = 5; 
    						local hue = tick() % t / t
    						local colorrr = Color3.fromHSV(hue, 1, 1)
    						v.ImageColor3 = colorrr
    						v.BackgroundColor3 = colorrr
    					end    
    					end)
    	        end)  
    	    end
        end
	end
    end
end
getgenv().CraftHub["Ultra Fast Attack"] = true 
getgenv().CraftHub["Attack Duration"] = 30
getgenv().CraftHub["Attack Cooldown"] = 100
