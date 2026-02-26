return function(itemFrame, searchBox)

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = searchBox.Text:lower()

		for _, icon in itemFrame:GetChildren() do
			if icon:IsA("Frame") then
				local itemName = icon.Name:lower()

				if text == "" then
					icon.Visible = true
				else
					local match = false

					for word in string.gmatch(itemName, "%S+") do
						if string.sub(word, 1, #text) == text then
							match = true
							break
						end
					end

					icon.Visible = match
				end
			end
		end
	end)

end
