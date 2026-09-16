--[[
	BirthdayQuestUI.client.lua
	--------------------------
	Draws the quest tracker at the top of the screen and the sidekick's
	speech bubble at the bottom.

	This script only displays what the server sends. It never decides
	anything about the quest itself.

	Location in Roblox: StarterPlayer.StarterPlayerScripts.BirthdayQuestUI
	(a LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local remotes = ReplicatedStorage:WaitForChild("BirthdayQuestRemotes")
local questUpdated = remotes:WaitForChild("QuestUpdated")
local sidekickSpoke = remotes:WaitForChild("SidekickSpoke")
local getQuestState = remotes:WaitForChild("GetQuestState")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UI = GameConfig.UI

--------------------------------------------------------------------------------
-- Small helpers
--------------------------------------------------------------------------------

local function round(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local function pad(instance, amount)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, amount)
	padding.PaddingBottom = UDim.new(0, amount)
	padding.PaddingLeft = UDim.new(0, amount)
	padding.PaddingRight = UDim.new(0, amount)
	padding.Parent = instance
	return padding
end

--------------------------------------------------------------------------------
-- Build the interface
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BirthdayQuestUI"
screenGui.ResetOnSpawn = false -- keep the tracker when the hero respawns
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Quest tracker -----------------------------------------------------------

local questPanel = Instance.new("Frame")
questPanel.Name = "QuestPanel"
questPanel.AnchorPoint = Vector2.new(0.5, 0)
questPanel.Position = UDim2.new(0.5, 0, 0, 12)
-- Scale-based sizing keeps this readable on a desktop monitor and on a tablet.
questPanel.Size = UDim2.fromScale(0.42, 0.16)
questPanel.BackgroundColor3 = UI.PanelColor
questPanel.BackgroundTransparency = 0.15
questPanel.BorderSizePixel = 0
questPanel.Parent = screenGui
round(questPanel, 12)
pad(questPanel, 10)

local panelSizeLimit = Instance.new("UISizeConstraint")
panelSizeLimit.MinSize = Vector2.new(240, 86)
panelSizeLimit.MaxSize = Vector2.new(520, 150)
panelSizeLimit.Parent = questPanel

local panelLayout = Instance.new("UIListLayout")
panelLayout.FillDirection = Enum.FillDirection.Vertical
panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
panelLayout.Padding = UDim.new(0, 4)
panelLayout.Parent = questPanel

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.LayoutOrder = 1
titleLabel.Size = UDim2.fromScale(1, 0.30)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextScaled = true
titleLabel.TextColor3 = UI.AccentColor
titleLabel.Text = GameConfig.Quest.Title
titleLabel.Parent = questPanel

local objectiveLabel = Instance.new("TextLabel")
objectiveLabel.Name = "Objective"
objectiveLabel.LayoutOrder = 2
objectiveLabel.Size = UDim2.fromScale(1, 0.24)
objectiveLabel.BackgroundTransparency = 1
objectiveLabel.Font = Enum.Font.Gotham
objectiveLabel.TextScaled = true
objectiveLabel.TextColor3 = UI.TextColor
objectiveLabel.Text = GameConfig.Quest.Objective
objectiveLabel.Parent = questPanel

local countLabel = Instance.new("TextLabel")
countLabel.Name = "Count"
countLabel.LayoutOrder = 3
countLabel.Size = UDim2.fromScale(1, 0.22)
countLabel.BackgroundTransparency = 1
countLabel.Font = Enum.Font.FredokaOne
countLabel.TextScaled = true
countLabel.TextColor3 = UI.TextColor
countLabel.Text = "Stars: 0 / " .. GameConfig.Quest.StarsToCollect
countLabel.Parent = questPanel

local barBackground = Instance.new("Frame")
barBackground.Name = "ProgressBar"
barBackground.LayoutOrder = 4
barBackground.Size = UDim2.fromScale(1, 0.12)
barBackground.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
barBackground.BorderSizePixel = 0
barBackground.Parent = questPanel
round(barBackground, 6)

local barFill = Instance.new("Frame")
barFill.Name = "Fill"
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = UI.AccentColor
barFill.BorderSizePixel = 0
barFill.Parent = barBackground
round(barFill, 6)

-- Sidekick speech bubble --------------------------------------------------

local dialoguePanel = Instance.new("Frame")
dialoguePanel.Name = "SidekickDialogue"
dialoguePanel.AnchorPoint = Vector2.new(0.5, 1)
dialoguePanel.Position = UDim2.new(0.5, 0, 1, -18)
dialoguePanel.Size = UDim2.fromScale(0.5, 0.14)
dialoguePanel.BackgroundColor3 = UI.DialogueColor
dialoguePanel.BackgroundTransparency = 1
dialoguePanel.BorderSizePixel = 0
dialoguePanel.Visible = false
dialoguePanel.Parent = screenGui
round(dialoguePanel, 12)
pad(dialoguePanel, 10)

local dialogueSizeLimit = Instance.new("UISizeConstraint")
dialogueSizeLimit.MinSize = Vector2.new(260, 78)
dialogueSizeLimit.MaxSize = Vector2.new(620, 140)
dialogueSizeLimit.Parent = dialoguePanel

local dialogueLayout = Instance.new("UIListLayout")
dialogueLayout.FillDirection = Enum.FillDirection.Vertical
dialogueLayout.SortOrder = Enum.SortOrder.LayoutOrder
dialogueLayout.Padding = UDim.new(0, 2)
dialogueLayout.Parent = dialoguePanel

local speakerLabel = Instance.new("TextLabel")
speakerLabel.Name = "Speaker"
speakerLabel.LayoutOrder = 1
speakerLabel.Size = UDim2.fromScale(1, 0.32)
speakerLabel.BackgroundTransparency = 1
speakerLabel.Font = Enum.Font.FredokaOne
speakerLabel.TextScaled = true
speakerLabel.TextXAlignment = Enum.TextXAlignment.Left
speakerLabel.TextColor3 = UI.AccentColor
speakerLabel.TextTransparency = 1
speakerLabel.Text = GameConfig.Sidekick.DisplayName
speakerLabel.Parent = dialoguePanel

local dialogueLabel = Instance.new("TextLabel")
dialogueLabel.Name = "Line"
dialogueLabel.LayoutOrder = 2
dialogueLabel.Size = UDim2.fromScale(1, 0.60)
dialogueLabel.BackgroundTransparency = 1
dialogueLabel.Font = Enum.Font.Gotham
dialogueLabel.TextScaled = true
dialogueLabel.TextWrapped = true
dialogueLabel.TextXAlignment = Enum.TextXAlignment.Left
dialogueLabel.TextColor3 = UI.TextColor
dialogueLabel.TextTransparency = 1
dialogueLabel.Text = ""
dialogueLabel.Parent = dialoguePanel

--------------------------------------------------------------------------------
-- Reacting to the server
--------------------------------------------------------------------------------

local function applyQuestState(state)
	if type(state) ~= "table" then
		return
	end

	local total = math.max(1, state.total or GameConfig.Quest.StarsToCollect)
	local collected = math.clamp(state.collected or 0, 0, total)

	countLabel.Text = string.format("Stars: %d / %d", collected, total)
	objectiveLabel.Text = state.objective or GameConfig.Quest.Objective

	TweenService:Create(barFill, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(collected / total, 1),
	}):Play()
end

local fadeIn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Each new line gets its own ticket. Only the newest line is allowed to hide
-- the bubble, so a quick second line does not get cut short by the first.
local latestLine = 0

local function hideDialogue()
	TweenService:Create(dialoguePanel, fadeOut, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(speakerLabel, fadeOut, { TextTransparency = 1 }):Play()

	local tween = TweenService:Create(dialogueLabel, fadeOut, { TextTransparency = 1 })
	tween.Completed:Connect(function()
		if dialogueLabel.TextTransparency >= 1 then
			dialoguePanel.Visible = false
		end
	end)
	tween:Play()
end

local function showDialogue(text, duration)
	if type(text) ~= "string" or text == "" then
		return
	end

	latestLine += 1
	local myLine = latestLine

	speakerLabel.Text = GameConfig.Sidekick.DisplayName
	dialogueLabel.Text = text
	dialoguePanel.Visible = true

	TweenService:Create(dialoguePanel, fadeIn, { BackgroundTransparency = 0.15 }):Play()
	TweenService:Create(speakerLabel, fadeIn, { TextTransparency = 0 }):Play()
	TweenService:Create(dialogueLabel, fadeIn, { TextTransparency = 0 }):Play()

	local seconds = tonumber(duration) or GameConfig.Dialogue.Duration
	task.delay(seconds, function()
		if latestLine == myLine then
			hideDialogue()
		end
	end)
end

questUpdated.OnClientEvent:Connect(applyQuestState)
sidekickSpoke.OnClientEvent:Connect(showDialogue)

-- Ask for the starting numbers now that everything above is connected.
local ok, state = pcall(function()
	return getQuestState:InvokeServer()
end)
if ok then
	applyQuestState(state)
end
