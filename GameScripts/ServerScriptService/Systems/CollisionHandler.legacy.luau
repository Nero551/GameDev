--CollisionHandler

local runService = game:GetService("RunService")
local  players = game:GetService("Players")

local function HandleCollisionGroups(character)
	for _, v in character:GetDescendants() do
		if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") or v:IsA("Part") then
			v.CollisionGroup = "Players"
		end
	end
end

local function characterAdded(character:Model)
	runService.Heartbeat:Wait()
	character.Parent = workspace.World.Live
	HandleCollisionGroups(character)
end
local function handleCharacterAdded(player)
	if player.Character then
	    characterAdded(player.Character)
	end
	player.CharacterAdded:Connect(characterAdded)
end

players.PlayerAdded:Connect(function(player)
	handleCharacterAdded(player)
end)

for _, player in players:GetPlayers() do
		handleCharacterAdded(player)
end

-----Handle CollisionGroups For Non-Players-----
for _, v:Model in workspace.World.Live:GetChildren() do
	if not players:GetPlayerFromCharacter(v) then
		HandleCollisionGroups(v)
	end
end