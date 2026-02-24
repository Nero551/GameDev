local CamVectors = {}

function CamVectors:UpdateCamVectors(char, argumentData)
	local camLookVector = argumentData.CamLookVector
	local camRightVector = argumentData.CamRightVector
	
	local CharacterVitalsService = require(script.Parent)
	local  cameraVectors = CharacterVitalsService:GetVital(char, "CamVectors")
	cameraVectors.CamLook =  camLookVector
	cameraVectors.CamRight = camRightVector
end

return CamVectors
