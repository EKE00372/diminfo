local addon, ns = ...
local cfg = ns.cfg
local init = ns.init
local panel = CreateFrame("Frame", nil, UIParent)

if cfg.Durability == true then
	
	-- make addon frame anchor-able
	local Stat = CreateFrame("Frame", "diminfo_dura")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	-- setup text
	local Text  = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.DurabilityPoint))
	Stat:SetAllPoints(Text)

	-- 11 slots
	local localSlots = {
		[1] = {1, INVTYPE_HEAD, 1000},
		[2] = {3, INVTYPE_SHOULDER, 1000},
		[3] = {5, INVTYPE_CHEST, 1000},
		[4] = {6, INVTYPE_WAIST, 1000},
		[5] = {9, INVTYPE_WRIST, 1000},
		[6] = {10, INVTYPE_HAND, 1000},
		[7] = {7, INVTYPE_LEGS, 1000},
		[8] = {8, INVTYPE_FEET, 1000},
		[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
		[10] = {17, INVTYPE_WEAPONOFFHAND, 1000},
		[11] = {18, INVTYPE_RANGED, 1000}
	}
	
	local Total = 0
	local current, max
	
	-- tooltip
	local function OnEvent(self)
		if diminfo.AutoRepair == nil then diminfo.AutoRepair = true end
		for i = 1, 11 do
			if GetInventoryItemLink("player", localSlots[i][1]) ~= nil then
				current, max = GetInventoryItemDurability(localSlots[i][1])
				if current then
					localSlots[i][3] = current/max
					Total = Total + 1
				end
			end
		end
		table.sort(localSlots, function(a, b) return a[3] < b[3] end)
		
		if Total > 0 then
			if cfg.ColorClass then
				Text:SetText(format(gsub(init.Colored..DURABILITY.." |r".."[color]%d|r%%", "%[color%]", (init.gradient(floor(localSlots[1][3]*100)/100))), floor(localSlots[1][3]*100)))
			else			
				Text:SetText(format(gsub(DURABILITY.." |r".."[color]%d|r%%","%[color%]", (init.gradient(floor(localSlots[1][3]*100)/100))), floor(localSlots[1][3]*100)))
			end
		else
			if cfg.ColorClass then
				Text:SetText(init.Colored..infoL["none"])
			else
				Text:SetText(infoL["none"])
			end
		end
		-- Setup
		self:SetAllPoints(Text)
		self:SetScript("OnEnter", function()
			
			local total, equipped = GetAverageItemLevel()
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(DURABILITY,format("%s %d/%d", STAT_AVERAGE_ITEM_LEVEL, equipped, total), 0, .6, 1, 0, .6, 1)
			GameTooltip:AddLine(" ")
			for i = 1, 11 do
				if localSlots[i][3] ~= 1000 then
					green = localSlots[i][3]*2
					red = 1 - green
					local slotIcon = "|T"..GetInventoryItemTexture("player", localSlots[i][1])..":16:16:0:0:32:32:2:30:2:30|t " or ""
					GameTooltip:AddDoubleLine(slotIcon..localSlots[i][2], floor(localSlots[i][3]*100).."%", 1,1,1, red+1,green,0)
				end
			end
			GameTooltip:AddDoubleLine(" ","--------------",1,1,1,0.5,0.5,0.5)
			GameTooltip:AddDoubleLine(" ",infoL["AutoRepair"]..(diminfo.AutoRepair and "|cff55ff55"..ENABLE or "|cffff5555"..DISABLE), 1, 1, 1, .4, .78, 1)
			GameTooltip:Show()
		end)
		self:SetScript("OnLeave", function() GameTooltip:Hide() end)
		Total = 0
	end

	Stat:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	Stat:RegisterEvent("MERCHANT_SHOW")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			diminfo.AutoRepair = not diminfo.AutoRepair
			self:GetScript("OnEnter")(self)
		else
			ToggleCharacter("PaperDollFrame")
		end
	end)
	Stat:SetScript("OnEvent", OnEvent)
	
	-- Auto repair
	local RepairGear = CreateFrame("Frame")
	RepairGear:RegisterEvent("MERCHANT_SHOW")
	RepairGear:SetScript("OnEvent", function()
		if (diminfo.AutoRepair == true and CanMerchantRepair()) then
			local cost = GetRepairAllCost()
			if cost > 0 then
				local money = GetMoney()
				if IsInGuild() then
					local guildMoney = GetGuildBankWithdrawMoney()
					if guildMoney > GetGuildBankMoney() then
						guildMoney = GetGuildBankMoney()
					end
					if guildMoney >= cost and CanGuildBankRepair() then
						RepairAllItems(1)
						print(format("|cff99CCFF"..infoL["Repair cost covered by G-Bank"].."|r%s", GetMoneyString(cost)))
						return
					elseif guildMoney == 0 and IsGuildLeader() then
						RepairAllItems(1)
						print(format("|cff99CCFF"..infoL["Repair cost covered by G-Bank"].."|r%s", GetMoneyString(cost)))
						return
					end
				end
				if money > cost then
					RepairAllItems()
					print(format("|cff99CCFF"..infoL["Repair cost"].."|r%s", GetMoneyString(cost)))
				else
					print("|cff99CCFF"..infoL["Go farm, newbie"].."|r")
				end
			end
		end
	end)
end
