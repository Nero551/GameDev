return function(PlayerNameText)
	local Player = game:GetService("Players").LocalPlayer
	PlayerNameText.Text = Player.Name
end