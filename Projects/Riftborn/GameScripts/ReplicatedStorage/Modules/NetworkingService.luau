local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local NetworkingService = {}

local Remotes = {}

local SentRemotes = {}
local RateLimit = 75

for _, remote in ReplicatedStorage.Remotes:GetDescendants() do
	if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
		Remotes[remote.Name] = remote
	end
end

local function AssertServer()
	if not RunService:IsServer() then
		warn("Attempted to use server networking from client")
		return false
	end
	return true
end

local function AssertClient()
	if not RunService:IsClient() then
		warn("Attempted to use client networking from server")
		return false
	end
	return true
end

function NetworkingService:OnClientEvent(remoteName:string, callback)
    if not AssertClient() then return end
    
    local remote = Remotes[remoteName]
    if remote then
        remote.OnClientEvent:Connect(function(...)
            callback(...)
        end)
    end
    return
end

function NetworkingService:OnServerEvent(remoteName: string, callback)
	if not AssertServer() then return end

	local remote = Remotes[remoteName]
	if remote then
		remote.OnServerEvent:Connect(function(...)
			callback(...)
		end)
	end
	return
end

function NetworkingService:FireToServer(remoteName: string, ...)
	if not AssertClient() then return end
    
	-- warn("From Client:", remoteName)
	warn("From Client:", debug.traceback())
	local remote = Remotes[remoteName]
	if remote then
		remote:FireServer(...)
	end
end             

function NetworkingService:FireToClient(player ,remoteName:string, ...)
    if not AssertServer() then return end

	-- warn("From Server:", remoteName)
    warn("From Server:", debug.traceback())
	local remote = Remotes[remoteName]
	if remote then
		if player:IsA("Player") then
			remote:FireClient(player, ...)
		end
	end
end

function NetworkingService:FireToAll(remoteName:string,...)
	if not AssertServer() then return end

	-- warn("From Server:", remoteName)
    warn("From Server:", debug.traceback())
	local remote = Remotes[remoteName]
	if remote then
        remote:FireAllClients(...)
	end
end

function NetworkingService:FireInRange(remoteName:string, origin, range, ...)
	if not AssertServer() then return end

	-- warn("From Server:", remoteName)
    warn("From Server:", debug.traceback())
	local remote = Remotes[remoteName]
	if remote then
        if typeof(origin) ~= "Vector3" then return end
        for _,player in Players:GetPlayers() do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

			if hrp then
				local maxRange = range or 500
				local distance = (hrp.Position - origin).Magnitude

				if distance <= maxRange then
					remote:FireClient(player, ...)
				end
            end
        end
	end
end

function NetworkingService:FireToExcept(exceptPlayer:Player?, remoteName:string, ...)
	if not AssertServer() then return end

	-- warn("From Server:", remoteName)
	warn("From Server:", debug.traceback())
	local remote = Remotes[remoteName]
    if remote then
        for _,player in Players:GetPlayers() do
            if player ~= exceptPlayer then
                remote:FireClient(player, ...)
            end
        end
    end
end

function NetworkingService:FireToPlayers(players, remoteName:string, ...)
	if not AssertServer() then return end

	-- warn("From Server:", remoteName)
	warn("From Server:", debug.traceback())
	local remote = Remotes[remoteName]
	if remote then
		for _, player in pairs(players) do
			if player:IsA("Player") then
                remote:FireClient(player, ...)
			end
		end
	end
end

return NetworkingService
