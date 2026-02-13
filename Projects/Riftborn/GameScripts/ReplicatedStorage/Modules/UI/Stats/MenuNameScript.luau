return function(menuName)
	local statsMenu = menuName.Parent.Parent



	for _, sectionMenu in statsMenu:GetChildren()do
		if sectionMenu:IsA("Frame") then
			if sectionMenu.Name ~= "TopBar" then
				sectionMenu.Changed:Connect(function()
					if sectionMenu.Visible == true then
						menuName.Text = sectionMenu.Name
					end
				end)
			end
		end
	end
end