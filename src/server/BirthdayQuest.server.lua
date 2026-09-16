--[[
	BirthdayQuest.server.lua
	------------------------
	The prototype world, the collectibles, the quest state and the sidekick.

	The server owns all of it. The client only draws what it is told, so a
	player cannot give themselves stars.

	Location in Roblox: ServerScriptService.BirthdayQuest (a Script)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

--------------------------------------------------------------------------------
-- Remotes: how the server tells the client what to show
--------------------------------------------------------------------------------

local remotes = Instance.new("Folder")
remotes.Name = "BirthdayQuestRemotes"
remotes.Parent = ReplicatedStorage

local questUpdated = Instance.new("RemoteEvent")
questUpdated.Name = "QuestUpdated"
questUpdated.Parent = remotes

local sidekickSpoke = Instance.new("RemoteEvent")
sidekickSpoke.Name = "SidekickSpoke"
sidekickSpoke.Parent = remotes

-- The client asks for the current state as soon as its interface is ready.
-- Without this the very first QuestUpdated could be fired before the client
-- script had connected, and the counter would start out blank.
local getQuestState = Instance.new("RemoteFunction")
getQuestState.Name = "GetQuestState"
getQuestState.Parent = remotes

--------------------------------------------------------------------------------
-- World
--------------------------------------------------------------------------------

local STAR_COUNT = math.max(1, math.floor(GameConfig.Quest.StarsToCollect))

local world = Instance.new("Folder")
world.Name = "BirthdayQuestWorld"
world.Parent = Workspace

local collectiblesFolder = Instance.new("Folder")
collectiblesFolder.Name = "Collectibles"
collectiblesFolder.Parent = world

-- Remembers where each collectible floats, so the spin animation always has
-- a fixed point to orbit around.
local collectibleHomes = {}

local function makeAnchoredPart(name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function buildGround()
	if GameConfig.World.RemoveDefaultBaseplate then
		local baseplate = Workspace:FindFirstChild("Baseplate")
		if baseplate and baseplate:IsA("BasePart") then
			baseplate:Destroy()
		end
	end

	local ground = makeAnchoredPart(
		"Ground",
		Vector3.new(220, 4, 220),
		Vector3.new(0, -2, 0),
		GameConfig.World.GroundColor,
		Enum.Material.Grass
	)
	ground.Parent = world
end

local function buildSpawn()
	-- Roblox places usually ship with a SpawnLocation already. Remove any we
	-- did not make, so the hero always starts in the middle of our island.
	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("SpawnLocation") and not instance:IsDescendantOf(world) then
			instance:Destroy()
		end
	end

	local spawnPad = Instance.new("SpawnLocation")
	spawnPad.Name = "HeroSpawn"
	spawnPad.Size = Vector3.new(14, 1, 14)
	spawnPad.Position = Vector3.new(0, 0.5, 0)
	spawnPad.Color = GameConfig.World.SpawnColor
	spawnPad.Material = Enum.Material.SmoothPlastic
	spawnPad.Anchored = true
	spawnPad.TopSurface = Enum.SurfaceType.Smooth
	spawnPad.BottomSurface = Enum.SurfaceType.Smooth
	spawnPad.Duration = 0 -- no forcefield, it just looks confusing here
	spawnPad.Parent = world
end

local function makeCollectible(index, position)
	local star = Instance.new("Part")
	star.Name = "BirthdayStar" .. index
	star.Shape = Enum.PartType.Ball
	star.Size = Vector3.new(3, 3, 3)
	star.Position = position
	star.Color = GameConfig.World.StarColor
	star.Material = Enum.Material.Neon
	star.Anchored = true
	star.CanCollide = false
	star.Parent = collectiblesFolder

	local glow = Instance.new("PointLight")
	glow.Color = GameConfig.World.StarColor
	glow.Range = 14
	glow.Brightness = 2
	glow.Parent = star

	collectibleHomes[star] = position
	return star
end

local function buildPlatformsAndStars()
	local palette = GameConfig.World.PlatformColors
	local radius = 45

	for index = 1, STAR_COUNT do
		local angle = (index - 1) / STAR_COUNT * math.pi * 2
		local height = 6 + (index % 3) * 5
		local center = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)

		local platform = makeAnchoredPart(
			"Platform" .. index,
			Vector3.new(16, 1, 16),
			center,
			palette[(index - 1) % #palette + 1]
		)
		platform.Parent = world

		makeCollectible(index, center + Vector3.new(0, 4, 0))
	end
end

buildGround()
buildSpawn()
buildPlatformsAndStars()

-- Gentle spin and bob, so the stars are easy to spot.
-- Both the spin and the bob repeat every math.pi seconds of "elapsed", so
-- wrapping there keeps the motion seamless and the number small.
local elapsed = 0
RunService.Heartbeat:Connect(function(deltaTime)
	elapsed = (elapsed + deltaTime) % math.pi
	for star, home in pairs(collectibleHomes) do
		local bob = math.sin(elapsed * 2 + home.X) * 0.6
		star.CFrame = CFrame.new(home + Vector3.new(0, bob, 0)) * CFrame.Angles(0, elapsed * 2, 0)
	end
end)

--------------------------------------------------------------------------------
-- Quest state
--------------------------------------------------------------------------------

-- questState[player] = { collected = number, greeted = boolean }
local questState = {}

local function questSnapshot(player)
	local state = questState[player]
	if not state then
		return nil
	end

	return {
		collected = state.collected,
		total = STAR_COUNT,
		objective = state.collected >= STAR_COUNT
			and GameConfig.Quest.CompleteObjective
			or GameConfig.Quest.Objective,
	}
end

local function tellClientAboutQuest(player)
	local snapshot = questSnapshot(player)
	if snapshot then
		questUpdated:FireClient(player, snapshot)
	end
end

getQuestState.OnServerInvoke = function(player)
	return questSnapshot(player)
end

local function sidekickSay(player, text)
	if not text or text == "" then
		return
	end
	sidekickSpoke:FireClient(player, text, GameConfig.Dialogue.Duration)
end

local function lineForStar(count)
	local lines = GameConfig.Dialogue.OnStarCollected
	if #lines == 0 then
		return nil
	end
	return lines[(count - 1) % #lines + 1]
end

local function collectStar(player)
	local state = questState[player]
	if not state then
		return
	end

	state.collected += 1
	tellClientAboutQuest(player)

	if state.collected >= STAR_COUNT then
		sidekickSay(player, GameConfig.Dialogue.OnQuestComplete)
	else
		sidekickSay(player, lineForStar(state.collected))
	end
end

local function onStarTouched(star, otherPart)
	if not collectibleHomes[star] then
		return -- already collected
	end

	local character = otherPart:FindFirstAncestorWhichIsA("Model")
	if not character then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	-- Take the star out of play before doing anything else, so a single touch
	-- cannot be counted twice.
	collectibleHomes[star] = nil
	star.CanTouch = false
	star.Transparency = 1
	local glow = star:FindFirstChildOfClass("PointLight")
	if glow then
		glow.Enabled = false
	end

	collectStar(player)
end

for _, star in ipairs(collectiblesFolder:GetChildren()) do
	star.Touched:Connect(function(otherPart)
		onStarTouched(star, otherPart)
	end)
end

--------------------------------------------------------------------------------
-- Sidekick
--------------------------------------------------------------------------------

-- sidekicks[player] = { model = Model, connection = RBXScriptConnection }
local sidekicks = {}

local function buildSidekickModel()
	local config = GameConfig.Sidekick

	local model = Instance.new("Model")
	model.Name = "Sidekick"

	local body = makeAnchoredPart("Body", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0), config.BodyColor)
	body.CanCollide = false
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.4, 1.4, 1.4)
	head.Color = config.HeadColor
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.CFrame = body.CFrame * CFrame.new(0, 1.7, 0)
	head.Parent = model

	model.PrimaryPart = body

	local nameTag = Instance.new("BillboardGui")
	nameTag.Name = "NameTag"
	nameTag.Size = UDim2.fromOffset(200, 40)
	nameTag.StudsOffsetWorldSpace = Vector3.new(0, 2.6, 0)
	nameTag.AlwaysOnTop = true
	nameTag.MaxDistance = 120
	nameTag.Adornee = head
	nameTag.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = config.NameTagColor
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Text = config.DisplayName
	nameLabel.Parent = nameTag

	return model
end

local function removeSidekick(player)
	local sidekick = sidekicks[player]
	if not sidekick then
		return
	end

	sidekicks[player] = nil
	sidekick.connection:Disconnect()
	sidekick.model:Destroy()
end

local function spawnSidekick(player, character)
	removeSidekick(player)

	local rootPart = character:WaitForChild("HumanoidRootPart", 10)
	if not rootPart then
		return
	end

	-- The character may have died while we waited.
	if player.Character ~= character then
		return
	end

	local config = GameConfig.Sidekick
	local model = buildSidekickModel()
	model.Name = "Sidekick_" .. player.Name
	model:PivotTo(CFrame.new(rootPart.Position - rootPart.CFrame.LookVector * config.FollowDistance))
	model.Parent = world

	local connection = RunService.Heartbeat:Connect(function(deltaTime)
		if not rootPart.Parent or player.Character ~= character then
			return
		end

		local goalPosition = rootPart.Position - rootPart.CFrame.LookVector * config.FollowDistance
		local current = model:GetPivot()

		-- CFrame.lookAt errors when the two points are identical, so only aim
		-- at the hero once there is a real distance between us.
		local flatHero = Vector3.new(rootPart.Position.X, goalPosition.Y, rootPart.Position.Z)
		local goal
		if (flatHero - goalPosition).Magnitude > 0.1 then
			goal = CFrame.lookAt(goalPosition, flatHero)
		else
			goal = CFrame.new(goalPosition) * (current - current.Position)
		end

		local alpha = math.clamp(deltaTime * config.FollowSpeed, 0, 1)
		model:PivotTo(current:Lerp(goal, alpha))
	end)

	sidekicks[player] = { model = model, connection = connection }
end

--------------------------------------------------------------------------------
-- Players
--------------------------------------------------------------------------------

local function onCharacterAdded(player, character)
	spawnSidekick(player, character)

	-- The greeting is a one-time hello, not something to repeat every respawn.
	task.delay(GameConfig.Sidekick.SpawnDelay, function()
		local state = questState[player]
		if player.Parent and state and not state.greeted then
			state.greeted = true
			sidekickSay(player, GameConfig.Dialogue.Greeting)
		end
	end)
end

local function onPlayerAdded(player)
	questState[player] = { collected = 0, greeted = false }

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	player.CharacterRemoving:Connect(function()
		removeSidekick(player)
	end)

	if player.Character then
		onCharacterAdded(player, player.Character)
	end

end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Players.PlayerRemoving:Connect(function(player)
	removeSidekick(player)
	questState[player] = nil
end)
