local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local NetworkingService = {}

local Remotes = {}

for _, remote in ReplicatedStorage.Remotes:GetDescendants() do
	if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
		Remotes[remote.Name] = remote
	end
end

function NetworkingService:FireToServer(remoteName: string, ...)
	if not RunService:IsClient() then
		warn("Attempted to fire to server from server")
		return
	end
	--print("From Client:", remoteName)
	warn("From Client:", debug.traceback())
	local remote = Remotes[remoteName]
	if remote then
		remote:FireServer(...)
	end
end

function NetworkingService:FireToClient(player ,remoteName:string, ...)
    if not RunService:IsServer() then
        warn("Attempted to fire to client from client")
        return
    end
	--print("From Server:", remoteName)
    warn("From Server:", debug.traceback())
	local remote = Remotes[remoteName]
	if remote then
        if player == "All" then
            remote:FireAllClients(...)

        else
            if player:IsA("Player") then
				remote:FireClient(player, ...)            
            end
        end
	end
end

return NetworkingService
