return function(Icons, EquipmentFolder)
	local repstor =game:GetService("ReplicatedStorage")
	local tweenService = game:GetService("TweenService")
	local player = game:GetService("Players").LocalPlayer
	local remotes = repstor.Remotes
	local itemDataBase = require(repstor.Modules.Data.ItemDataBase)
	local playerStats = player:WaitForChild("PlayerStats")
	local FormulaApplier = require(repstor.Modules.FormulaApplier)

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function SizeIncrease(scale:UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tweenService:Create(scale, info, {Scale = 1.05}):Play()
	end

	local function SizeClickDecrease(scale:UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tweenService:Create(scale, info, {Scale = 0.975}):Play()
	end

	local Equipment = {}

	for _,ArmorType in EquipmentFolder.Armors:GetChildren()  do
		if ArmorType:IsA("Frame") then
			Equipment[ArmorType.Name:split("(HoverSoundSizeChange)")[1]] = {
				Instance =  ArmorType,
				Item = nil,
				ItemID = nil,
				IconFrame = nil,
				Catagory =  "Armor"
			}
		end
	end

	for _,WeaponType in EquipmentFolder.Weapons:GetChildren() do
		if WeaponType:IsA("Frame") then
			Equipment[WeaponType.Name:split("(HoverSoundSizeChange)")[1]] = {
				Instance = WeaponType,
				Item = nil,
				ItemID = nil,
				IconFrame = nil,
				Catagory = "Weapon"
			}
		end
	end

	local function UpdateEquipmentUI(inventory , equippedItems)
		for _,info in pairs(Equipment) do
			info.Item = nil
			info.ItemID = nil
			info.IconFrame = nil
			if info.IconFrame then
				info.IconFrame:Destroy()
			end
			for _,frame:Frame? in info.Instance:GetChildren() do
				if frame:IsA("Frame") then
					frame:Destroy()
				end
			end
		end


		for itemType,itemID in pairs(equippedItems) do
			local itemData = itemDataBase:GetItemData(itemID)
			if  Equipment[itemType] then
				Equipment[itemType].Item = itemData.Name
				Equipment[itemType].ItemID = itemID
			end
		end


		for type,Info in pairs(Equipment) do
			if Info.Item ~= nil then
				local iconFrame:Frame? = Info.Instance:FindFirstChild(Info.Item)
				if not iconFrame then
					iconFrame = Icons:FindFirstChild(Info.Item):Clone()
					iconFrame.Parent = Info.Instance
					iconFrame.Size = UDim2.fromScale(1,1)
					Info.IconFrame = iconFrame
					local icon:ImageButton? =  iconFrame:FindFirstChild(iconFrame.Name)
					icon:FindFirstChild("Border"):Destroy()
					icon:FindFirstChild("EquippedIcon"):Destroy()
					icon:FindFirstChild("OwnedAmount"):Destroy()
					local itemData = itemDataBase:GetItemData(Info.ItemID)
					if not  itemData then
						print("idk")
						return 
					end

					local scale = iconFrame.Parent:FindFirstChildWhichIsA("UIScale")
					if not scale then
						scale = Instance.new("UIScale")
						scale.Parent = iconFrame.Parent
					end
					icon.MouseButton1Down:Connect(function()
						SizeClickDecrease(scale)
					end)

					icon.MouseButton1Up:Connect(function()
						SizeIncrease(scale)
					end)


					icon.MouseButton1Click:Connect(function()
						local infoPopup:Frame? = iconFrame:FindFirstChild("EquippedItemPopUp")
						if infoPopup then
							local tween = tweenService:Create(infoPopup, info, {Size = UDim2.fromScale(0, 0.905)})
							tween:Play()
							tween.Completed:Connect(function()
								infoPopup:Destroy()	
							end)
						else
							for _, otherInfoPopups:Frame? in EquipmentFolder:GetDescendants() do
								if otherInfoPopups:IsA("Frame")  then
									if otherInfoPopups.Name == "EquippedItemPopUp" then
										otherInfoPopups:Destroy()
									end
								end
							end

							infoPopup = repstor.Assets.GUI["EquippedItemPopUp"]:Clone()
							infoPopup.ItemName.Text = itemData.Name

							if itemData.Buffs then

								if itemData.Buffs.Health then
									if itemData.Buffs.Health.Percent then
										infoPopup.FinalImportantStat.Text = "+"..(itemData.Buffs.Health.Percent*100).."%HP"
									else
										infoPopup.FinalImportantStat.Text = "+"..itemData.Buffs.Health.Flat.." HP"
									end
								else
									if itemData.Buffs.Defense.Percent then
										infoPopup.FinalImportantStat.Text = (itemData.Buffs.Defense.Percent*100).."% DF"
									else
										infoPopup.FinalImportantStat.Text = "+"..itemData.Buffs.Defense.Flat.." DF"
									end
								end

							else

								if itemData.Damage then
									if playerStats[type].Final then
										local M1Damage = FormulaApplier:M1Damage({
											PlayerDamageStat = playerStats[type].Final.Value,
											FoundWeaponData = itemData,
											TargetDefenseStat = 0,

										})
										infoPopup.FinalImportantStat.Text = M1Damage.." ATK"
									end


								elseif itemData.CriticalRate then
									if playerStats[type].Percent then
										infoPopup.FinalImportantStat.Text = (itemData.CriticalRate *
											playerStats.CriticalRate.Percent.Value * 100).." %CR"
									end


								elseif itemData.CriticalDamage then
									if playerStats[type].Percent then

									end
									infoPopup.FinalImportantStat.Text = (itemData.CriticalDamage *
										playerStats.CriticalDamage.Percent.Value * 100).." %CR"
								end

							end

							if Info.Catagory == "Weapon" then
								infoPopup.AnchorPoint = Vector2.new(0,0.5)
								infoPopup.Position = UDim2.fromScale(1.205, 0.881)
							elseif Info.Catagory == "Armor" then
								infoPopup.AnchorPoint = Vector2.new(1,0.5)
								infoPopup.Position = UDim2.fromScale(-0.276,0.835)

							end
							infoPopup.Parent = iconFrame
							local tween = tweenService:Create(infoPopup, info, {Size = UDim2.fromScale(2.277, 0.905)})
							tween:Play()
						end	
					end)
				end
			end
		end
	end

	remotes.UpdateEquippedItems.OnClientEvent:Connect(function(inventory, equippedItems)	
		UpdateEquipmentUI(inventory, equippedItems)
	end)
end