--[[
	Script: Coordinate and Waypoint System for Executors
	Description: Displays live locations of all players and allows the user to save personal waypoints.
	Created for use with loadstring(game:HttpGet(...))()
]]

-- ================= CONFIGURATION =================
local UPDATE_INTERVAL = 2 -- seconds | How often to refresh live player locations.
-- ===============================================


-- Prevent the script from running multiple times
if game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("CoordinatesMenu_Executor") then
	warn("Coordinate script is already running.")
	return
end

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= GUI CREATION =================

-- Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoordinatesMenu_Executor"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
mainFrame.Draggable = true
mainFrame.Active = true

-- UI Corner for rounded edges
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame
mainFrame.Parent = screenGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
titleLabel.Text = "Player & Waypoint Locations"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
local titleCorner = mainCorner:Clone()
titleCorner.Parent = titleLabel
titleLabel.Parent = mainFrame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -30, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
local closeCorner = mainCorner:Clone()
closeCorner.Parent = closeButton
closeButton.Parent = titleLabel

-- Section for Live Player Locations
local livePlayersLabel = Instance.new("TextLabel")
livePlayersLabel.Name = "LivePlayersLabel"
livePlayersLabel.Size = UDim2.new(1, -20, 0, 20)
livePlayersLabel.Position = UDim2.new(0, 10, 0, 50)
livePlayersLabel.BackgroundTransparency = 1
livePlayersLabel.Text = "Live Player Locations:"
livePlayersLabel.Font = Enum.Font.SourceSansSemibold
livePlayersLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
livePlayersLabel.TextSize = 16
livePlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
livePlayersLabel.Parent = mainFrame

local liveList = Instance.new("ScrollingFrame")
liveList.Name = "LivePlayerList"
liveList.Size = UDim2.new(1, -20, 0, 150)
liveList.Position = UDim2.new(0, 10, 0, 75)
liveList.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
liveList.BorderSizePixel = 0
local liveListLayout = Instance.new("UIListLayout")
liveListLayout.Padding = UDim.new(0, 4)
liveListLayout.Parent = liveList
liveList.Parent = mainFrame

-- Section for Personal Waypoints
local waypointsLabel = livePlayersLabel:Clone()
waypointsLabel.Name = "WaypointsLabel"
waypointsLabel.Text = "My Saved Waypoints:"
waypointsLabel.Position = UDim2.new(0, 10, 0, 235)
waypointsLabel.Parent = mainFrame

local saveWaypointButton = Instance.new("TextButton")
saveWaypointButton.Name = "SaveWaypointButton"
saveWaypointButton.Size = UDim2.new(1, -20, 0, 35)
saveWaypointButton.Position = UDim2.new(0, 10, 0, 405)
saveWaypointButton.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
saveWaypointButton.Text = "Save Current Location"
saveWaypointButton.Font = Enum.Font.SourceSansBold
saveWaypointButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveWaypointButton.TextSize = 16
local saveCorner = mainCorner:Clone()
saveCorner.Parent = saveWaypointButton
saveWaypointButton.Parent = mainFrame

local waypointList = liveList:Clone()
waypointList.Name = "WaypointList"
waypointList.Size = UDim2.new(1, -20, 0, 140)
waypointList.Position = UDim2.new(0, 10, 0, 260)
waypointList.Parent = mainFrame

-- ================= SCRIPT LOGIC =================

local myWaypoints = {}

-- Function to create a list item entry
local function createEntry(name, positionText)
	local entryFrame = Instance.new("TextLabel")
	entryFrame.Size = UDim2.new(1, 0, 0, 25)
	entryFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	entryFrame.Font = Enum.Font.Code
	entryFrame.TextSize = 14
	entryFrame.TextColor3 = Color3.fromRGB(230, 230, 230)
	entryFrame.Text = "  " .. name .. string.rep(" ", 20) .. positionText
	entryFrame.TextXAlignment = Enum.TextXAlignment.Left
	return entryFrame
end

-- Function to update the live player list
local function updateLiveList()
	liveList:ClearAllChildren()
	local listLayout = Instance.new("UIListLayout") -- Re-add layout
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = liveList
	
	for _, player in ipairs(Players:GetPlayers()) do
		local positionText = "N/A"
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local pos = player.Character.HumanoidRootPart.Position
			positionText = string.format("%d, %d, %d", pos.X, pos.Y, pos.Z)
		end
		
		local entry = createEntry(player.DisplayName, positionText)
		if player == LocalPlayer then
			entry.TextColor3 = Color3.fromRGB(120, 220, 120) -- Highlight self
		end
		entry.Parent = liveList
	end
end

-- Function to add a waypoint to the personal list
local function addWaypoint()
	if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return end
	
	local pos = LocalPlayer.Character.HumanoidRootPart.Position
	local positionText = string.format("%d, %d, %d", pos.X, pos.Y, pos.Z)
	local waypointName = "Waypoint #" .. #myWaypoints + 1
	
	table.insert(myWaypoints, {Name = waypointName, Pos = positionText})
	
	local entry = createEntry(waypointName, positionText)
	
	-- Add a delete button to the waypoint
	local deleteBtn = Instance.new("TextButton")
	deleteBtn.Size = UDim2.new(0, 20, 0.8, 0)
	deleteBtn.Position = UDim2.new(1, -25, 0.1, 0)
	deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	deleteBtn.Text = "X"
	deleteBtn.Font = Enum.Font.SourceSansBold
	deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	deleteBtn.TextSize = 12
	deleteBtn.Parent = entry
	
	deleteBtn.MouseButton1Click:Connect(function()
		for i, v in ipairs(myWaypoints) do
			if v.Name == waypointName and v.Pos == positionText then
				table.remove(myWaypoints, i)
				break
			end
		end
		entry:Destroy()
	end)
	
	entry.Parent = waypointList
end


-- ================= EVENT CONNECTIONS =================

-- Close button logic
closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Save waypoint button logic
saveWaypointButton.MouseButton1Click:Connect(addWaypoint)


-- Main loop to keep live list updated
spawn(function()
	while screenGui.Parent do
		updateLiveList()
		wait(UPDATE_INTERVAL)
	end
end)

-- Initial update
updateLiveList()
print("Coordinate & Waypoint script loaded successfully.")
