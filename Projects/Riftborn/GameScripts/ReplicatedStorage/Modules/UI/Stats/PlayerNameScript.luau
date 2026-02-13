return function(PlayerNameText)
	local player = game:GetService("Players").LocalPlayer
	PlayerNameText.Text = player.Name
end