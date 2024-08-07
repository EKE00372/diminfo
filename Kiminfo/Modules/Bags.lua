local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Bags then return end

local format = format
local CreateFrame = CreateFrame
local C_Timer_NewTicker = C_Timer.NewTicker

local C_CurrencyInfo_GetCurrencyInfo, C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo, C_CurrencyInfo.GetBackpackCurrencyInfo
local C_WowTokenPublic_UpdateMarketPrice, C_WowTokenPublic_GetCurrentMarketPrice = C_WowTokenPublic.UpdateMarketPrice, C_WowTokenPublic.GetCurrentMarketPrice
local C_Container_GetContainerNumFreeSlots, C_Container_GetContainerNumSlots = C_Container.GetContainerNumFreeSlots, C_Container.GetContainerNumSlots
local C_Container_UseContainerItem, C_Container_GetContainerItemInfo = C_Container.UseContainerItem, C_Container.GetContainerItemInfo
local C_Container_GetContainerItemEquipmentSetInfo = C_Container.GetContainerItemEquipmentSetInfo

local LibShowUIPanel = LibStub("LibShowUIPanel-1.0")
local ShowUIPanel = LibShowUIPanel.ShowUIPanel
local HideUIPanel = LibShowUIPanel.HideUIPanel

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Bags", UIParent)
	Stat:SetHitRectInsets(-30, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create icon ]]--
local Icon = Stat:CreateTexture(nil, "OVERLAY")
	Icon:SetSize(G.FontSize, G.FontSize)
	Icon:SetPoint("RIGHT", Stat, "LEFT", 0, 0)
	Icon:SetTexture(G.Bags)
	Icon:SetVertexColor(1, 1, 1)

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.BagsPoint))
	Text:SetTextColor(1, 1, 1)
	Stat:SetAllPoints(Text)

--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

--[[ Bag slots ]]--
local function getBagSlots()
	local free, total, used = 0, 0, 0
	
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + C_Container_GetContainerNumFreeSlots(i), total + C_Container_GetContainerNumSlots(i)
	end
	used = total - free
	
	return free, total, used
end

--[[ GetCurrencyInfo ]]--
local function GetBackpackCurrencyInfo(id)
	local info = C_CurrencyInfo_GetBackpackCurrencyInfo(id)
	
	if info then
		return info.name, info.quantity, info.iconFileID, info.currencyTypesID
	end
	
	return nil
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Data text update ]]--
local function OnEvent(self)
	if Kiminfo.AutoSell == nil then
		Kiminfo.AutoSell = true
	end

	local free = getBagSlots()
	Text:SetText(free)
	self:SetAllPoints(Text)
	
	-- Update token price when login
	C_WowTokenPublic_UpdateMarketPrice()
	-- Update token price every 3 min
	C_Timer_NewTicker(180, function () C_WowTokenPublic_UpdateMarketPrice() end)
end

--[[ Tooltip update ]]--
local function OnEnter(self)
	local free, total, used = getBagSlots()
	local money = GetMoney()
	local tokenMoney = C_WowTokenPublic_GetCurrentMarketPrice() or 0
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(BAGSLOT, free.."/"..total, 0, .6, 1, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- Bag slot and money
	GameTooltip:AddLine(G.OptionColor..BAGSLOT)
	GameTooltip:AddDoubleLine(USE, used, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(MONEY, GetMoneyString(money), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(TOKEN_FILTER_LABEL, (tokenMoney > 0 and GetMoneyString(tokenMoney)) or UNAVAILABLE, 1, 1, 1, 1, 1, 1)
	
	-- Currency
	for i = 1, 10 do
		local name, count, icon, currencyID = GetBackpackCurrencyInfo(i)
		
		if name and i == 1 then
			local iconTexture = C_CurrencyInfo_GetCurrencyInfo(104).iconFileID
			
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(F.addIcon(iconTexture, 14, 4, 46).." "..G.OptionColor..CURRENCY)
		end
		
		if name and count then
			local total = C_CurrencyInfo_GetCurrencyInfo(currencyID).maxQuantity
			local iconTexture = F.addIcon(icon, 14, 4, 46)
			
			if total > 0 then
				GameTooltip:AddDoubleLine(iconTexture.." "..name, count.."/"..total, 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(iconTexture.." "..name, count, 1, 1, 1, 1, 1, 1)
			end
		end
	end
	
	-- Tier charge
	local chargeInfo = C_CurrencyInfo_GetCurrencyInfo(2912) -- S4
	if chargeInfo then
		if GetNumWatchedTokens() < 1 then GameTooltip:AddLine(" ") end
		local iconTexture = "|T"..chargeInfo.iconFileID..":13:15:0:0:50:50:4:46:4:46|t"
		GameTooltip:AddDoubleLine(iconTexture.." "..chargeInfo.name, chargeInfo.quantity.."/"..chargeInfo.maxQuantity, 1, 1, 1, 1, 1, 1)
	end
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..CURRENCY..G.MiddleButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..BAGSLOT..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoSell..(Kiminfo.AutoSell and G.Enable or G.Disable)..G.RightButton, 1, 1, 1, .4, .78, 1)
	
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
	
	Stat:SetScript("OnLeave", function()
		-- Normal color
		Icon:SetVertexColor(1, 1, 1)
		Text:SetTextColor(1, 1, 1)
		-- Tooltip hide
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_LOGIN")
	Stat:RegisterEvent("BAG_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self,button)
		if button == "RightButton" then
			Kiminfo.AutoSell = not Kiminfo.AutoSell
			OnEnter(self)
		elseif button == "LeftButton" then
			ToggleAllBags()
		elseif button == "MiddleButton" then
			if not CharacterFrame:IsShown() then ShowUIPanel(CharacterFrame) ToggleCharacter("TokenFrame") else HideUIPanel(CharacterFrame) end
		else
			return
		end
	end)

--=======================================================--
---------------    [[ Auto sell gray ]]     ---------------
--=======================================================--

local sellGray = CreateFrame("Frame")
	sellGray:SetScript("OnEvent", function()
		if Kiminfo.AutoSell == true then
			local c = 0
			
			for bag = 0, 4 do
				for slot = 1, C_Container_GetContainerNumSlots(bag) do
					local info = C_Container_GetContainerItemInfo(bag, slot)
					if info then
						local count, quality, link, noValue, itemID = info.stackCount, info.quality, info.hyperlink, info.hasNoValue, info.itemID
						local isInSet = C_Container_GetContainerItemEquipmentSetInfo(bag, slot)
						
						if link and not noValue and not isInSet and quality == 0 then
							local price = select(11, GetItemInfo(link)) * count
						
							if price > 0 then
								C_Container_UseContainerItem(bag, slot)
								c = c + price
							end
						end
					end
				end
			end
			
			if c > 0 then
				print(format("|cff99CCFF"..L.TrashSold.."|r%s", GetMoneyString(c)))
			end
		end
	end)
	sellGray:RegisterEvent("MERCHANT_SHOW")