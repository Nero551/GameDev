local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local remotes = replicatedStorage.Remotes

local cam = workspace.CurrentCamera
local camRightVectorValue = script.Parent.Parent:WaitForChild("CamRightVector")
local camLookVectorValue = script.Parent.Parent:WaitForChild("CamLookVector")

-- Updates every frame
runService.Heartbeat:Connect(function()
	
	local  camLookVector = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
	local  camRightVector = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit
	camRightVectorValue.Value = camRightVector
	camLookVectorValue.Value = camLookVector
	remotes.UpdateCamVectors:FireServer(camLookVector, camRightVector)
end)