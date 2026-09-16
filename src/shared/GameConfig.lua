--[[
	GameConfig
	----------
	Every personal detail for Birthday Quest lives here.

	If you want to change a name, an age, a colour, or anything the sidekick
	says, change it in THIS file only. No other script needs editing.

	Location in Roblox: ReplicatedStorage.GameConfig (a ModuleScript)
]]

local GameConfig = {}

-- The player. He is the hero of the whole adventure.
GameConfig.Hero = {
	-- CHANGE ME: the birthday boy's name.
	DisplayName = "Birthday Hero",
	-- CHANGE ME: the age he is turning.
	Age = 10,
}

-- The younger brother. He is an NPC that follows the hero around.
GameConfig.Sidekick = {
	-- CHANGE ME: the little brother's name.
	DisplayName = "Little Brother",
	-- CHANGE ME: his age.
	Age = 6,

	-- How he looks. He is built out of plain parts, so no paid assets.
	BodyColor = Color3.fromRGB(85, 170, 255),
	HeadColor = Color3.fromRGB(255, 221, 171),
	NameTagColor = Color3.fromRGB(255, 255, 255),

	-- How he moves.
	FollowDistance = 7, -- studs behind the hero
	FollowSpeed = 5, -- higher = snappier, lower = floatier
	SpawnDelay = 1, -- seconds to wait after the hero spawns
}

-- The quest itself.
GameConfig.Quest = {
	Title = "Birthday Quest",
	Objective = "Collect the birthday stars!",

	-- How many collectibles exist. The world builds itself around this
	-- number, so you can safely change it.
	StarsToCollect = 6,

	CompleteObjective = "You found them all! Happy birthday!",
}

-- Everything the sidekick says. Keep it short and friendly.
GameConfig.Dialogue = {
	-- Said once, just after the hero spawns.
	Greeting = "Happy birthday! I'll follow you everywhere today!",

	-- Picked in order as stars are collected. If there are more stars than
	-- lines, the list simply repeats.
	OnStarCollected = {
		"Wow, you got one!",
		"Nice jump!",
		"I saw another one over there!",
		"You're so fast!",
		"Almost there!",
		"One more, you can do it!",
	},

	-- Said when every star is collected.
	OnQuestComplete = "You did it! Best birthday ever!",

	-- How long a line stays on screen, in seconds.
	Duration = 4,
}

-- Look and feel of the prototype world.
GameConfig.World = {
	GroundColor = Color3.fromRGB(106, 171, 90),
	SpawnColor = Color3.fromRGB(255, 214, 92),
	StarColor = Color3.fromRGB(255, 221, 51),

	-- Platform colours are used one after another, then they repeat.
	PlatformColors = {
		Color3.fromRGB(255, 137, 172),
		Color3.fromRGB(129, 199, 255),
		Color3.fromRGB(180, 148, 255),
		Color3.fromRGB(139, 227, 160),
	},

	-- The prototype builds its own island. Roblox's default place already
	-- has a part called "Baseplate"; leaving it in makes the island look
	-- odd, so we remove it. Set this to false to keep it.
	RemoveDefaultBaseplate = true,
}

-- Colours for the on-screen interface.
GameConfig.UI = {
	PanelColor = Color3.fromRGB(28, 32, 48),
	TextColor = Color3.fromRGB(255, 255, 255),
	AccentColor = Color3.fromRGB(255, 221, 51),
	DialogueColor = Color3.fromRGB(40, 60, 100),
}

return GameConfig
