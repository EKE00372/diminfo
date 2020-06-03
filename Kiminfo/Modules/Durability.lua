local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Durability then return end

local format, floor, max, sort, modf, select = string.format, math.floor, max, sort, math.modf, select
local CreateFrame = CreateFrame
local GetInventoryItemLink, GetInventoryItemDurability, GetInventoryItemTexture = GetInventoryItemLink, GetInventoryItemDurability, GetInventoryItemTexture

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Dura", UIParent)
	Stat:SetHitRectInsets(-30, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create icon ]]--
local Icon = Stat:CreateTexture(nil, "OVERLAY")
	Icon:SetSize(G.FontSize+8, G.FontSize+8)
	Icon:SetPoint("RIGHT", Stat, "LEFT", 0, 0)
	Icon:SetTexture(G.Dura)
	Icon:SetVertexColor(1, 1, 1)

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.DurabilityPoint))
	Text:SetTextColor(1, 1, 1)
	Stat:SetAllPoints(Text)

--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

--[[ Data text color gardient ]]--
local function GradientColor(perc)
	perc = perc > 1 and 1 or perc < 0 and 0 or perc -- Stay between 0-1
	
	local seg, relperc = modf(perc*2)
	local r1, g1, b1, r2, g2, b2 = select(seg*3+1, 1, .5, .25, 1, 1, .43, .57, 1, .57, 0, 0, 0) -- R -> Y -> G
	local r, g, b = r1+(r2-r1)*relperc, g1+(g2-g1)*relperc, b1+(b2-b1)*relperc
	
	return r, g, b
end

--[[ Slots ]]--
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
}	

--[[ Sort slots by durability ]]--
local function sortSlots(a, b)
	if a and b then
		return (a[3] == b[3] and a[1] < b[1]) or (a[3] < b[3])
	end
end

--[[ Get durability ]]--
local function getItemDurability()
	local numSlots = 0
	
	for i = 1, 10 do
		localSlots[i][3] = 1000
		
		local index = localSlots[i][1]
		
		if GetInventoryItemLink("player", index) then
			local current, max = GetInventoryItemDurability(index)
			
			if current then
				localSlots[i][3] = current/max
				numSlots = numSlots + 1
			end
		end
	end
	sort(localSlots, sortSlots)

	return numSlots
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Data text update ]]--
local function OnEvent(self)
	if Kiminfo.AutoRepair == nil then
		Kiminfo.AutoRepair = true
	end
	
	local numSlots = getItemDurability()
	local r, g, b = GradientColor((floor(localSlots[1][3]*100)/100))
	
	if numSlots > 0 then
		Text:SetText(floor(localSlots[1][3]*100))
		Text:SetTextColor(r, g, b)
		Icon:SetVertexColor(r, g, b)
	else
		Text:SetText(L.None)
		Text:SetTextColor(1, 1, 1)
		Icon:SetVertexColor(1, 1, 1)
	end
	self:SetAllPoints(Text)
end

--[[ Tooltip update ]]--
local function OnEnter(self)
	local total, equipped = GetAverageItemLevel()
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL, format("%d/%d", equipped, total), 0, .6, 1, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- Slot item list
	for i = 1, 10 do
		if localSlots[i][3] ~= 1000 then
			local slot = localSlots[i][1]
			local green = localSlots[i][3]*2
			local red = 1 - green

			GameTooltip:AddDoubleLine(F.addIcon(GetInventoryItemTexture("player", slot), 14, 4, 46)..localSlots[i][2], floor(localSlots[i][3]*100), 1, 1, 1, red+1, green, 0)
		end
	end
	
	-- Otpions
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..CHARACTER_INFO..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoRepair..(Kiminfo.AutoRepair and G.Enable or G.Disable)..G.RightButton)
	
	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		-- Mouseover color
		Icon:SetVertexColor(0, 1, 1)
		Text:SetTextColor(0, 1, 1)
		-- Tooltip show
		OnEnter(self)
	end)
	
	Stat:SetScript("OnLeave", function(self)
		-- Refresh data text color
		OnEvent(self)
		-- Tooltip hide
		GameTooltip:Hide()
	end)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			Kiminfo.AutoRepair = not Kiminfo.AutoRepair
			OnEnter(self)
		else
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
				return
			end
			ToggleCharacter("PaperDollFrame")
		end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	Stat:RegisterEvent("MERCHANT_SHOW")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)

--====================================================--
---------------    [[ Auto repair ]]     ---------------
--====================================================--

local RepairGear = CreateFrame("Frame")
	RepairGear:RegisterEvent("MERCHANT_SHOW")
	RepairGear:SetScript("OnEvent", function()
		if (Kiminfo.AutoRepair == true and CanMerchantRepair()) then
			local money = GetMoney()
			local cost, canRepair = GetRepairAllCost()
			
			-- Can repair and cost more than 0 / 可以修裝而且花費大於零
			if canRepair and cost > 0 then
				if IsInGuild() then
					local guildMoney = GetGuildBankWithdrawMoney()
					
					-- When withdraw amount more than guild money / 可提領金額大於公會餘額
					if guildMoney > GetGuildBankMoney() then
						guildMoney = GetGuildBankMoney()
					end
					-- Use guild repair if you can / 優先使用公會修理
					if guildMoney >= cost and CanGuildBankRepair() then
						RepairAllItems(1)
						print(format("|cff99CCFF"..GUILDCONTROL_OPTION15.."|r%s", GetMoneyString(cost)))
						return
					elseif guildMoney == 0 and IsGuildLeader() then
						RepairAllItems(1)
						print(format("|cff99CCFF"..GUILDCONTROL_OPTION15.."|r%s", GetMoneyString(cost)))
						return
					end
				end
				
				if money > cost then
					RepairAllItems()
					print(format("|cff99CCFF"..REPAIR_COST.."|r%s", GetMoneyString(cost)))
				else
					print("|cff99CCFF"..ERR_NOT_ENOUGH_MONEY.."|r")
				end
			end
		end
	end)