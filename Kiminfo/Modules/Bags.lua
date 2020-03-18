local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Bags then return end

local format = string.format

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Bags", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.BagsPoint))
	Stat:SetAllPoints(Text)

--==================================================--
---------------    [[ Bag slots ]]     ---------------
--==================================================--

local function getBagSlots()
	local free, total, used = 0, 0, 0
	
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	used = total - free
	
	return free, total, used
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Data text update ]]--
local function OnEvent(self)
	if diminfo.AutoSell == nil then
		diminfo.AutoSell = true
	end

	local free = getBagSlots()
	Text:SetText(F.addIcon(G.Bags, 12, 0, 50)..free)
	self:SetAllPoints(Text)
end

--[[ Tooltip update ]]--
local function OnEnter(self)
	local free, total, used = getBagSlots()
	local money = GetMoney()
	
	-- title
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(BAGSLOT, free.."/"..total, 0, .6, 1, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- bag slot
	GameTooltip:AddLine(G.OptionColor..BAGSLOT)
	GameTooltip:AddDoubleLine(USE, used, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(MONEY, format("%.f", (money * 0.0001)), 1, 1, 1, 1, 1, 1)
	
	-- currency
	for i = 1, GetNumWatchedTokens() do
		local name, count, icon, currencyID = GetBackpackCurrencyInfo(i)
		
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(G.OptionColor..CURRENCY)
		end
		
		if name and count then
			local _, _, _, _, _, total = GetCurrencyInfo(currencyID)
			local iconTexture = F.addIcon(icon, 14, 4, 46)
			
			if total > 0 then
				GameTooltip:AddDoubleLine(iconTexture..name, count.."/"..total, 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(iconTexture..name, count, 1, 1, 1, 1, 1, 1)
			end
		end
	end
	
	-- options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..WORLDMAP_BUTTON..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoSell..(diminfo.AutoSell and "|cff55ff55"..ENABLE or "|cffff5555"..DISABLE)..G.RightButton, 1, 1, 1, .4, .78, 1)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..CURRENCY..G.MiddleButton)
	
	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_LOGIN")
	Stat:RegisterEvent("BAG_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self,button)
		if button == "RightButton" then
			diminfo.AutoSell = not diminfo.AutoSell
			self:GetScript("OnEnter")(self)
		elseif button == "MiddleButton" then
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
				return
			end
			ToggleCharacter("TokenFrame")
		else
			ToggleAllBags()
		end
	end)

--=======================================================--
---------------    [[ Auto sell gray ]]     ---------------
--=======================================================--

local SellGray = CreateFrame("Frame")
	SellGray:SetScript("OnEvent", function()
		if diminfo.AutoSell == true then
			local c = 0
			
			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					local link = GetContainerItemLink(bag, slot)
					
					if link and (select(11, GetItemInfo(link)) ~= nil) and (select(2, GetContainerItemInfo(bag, slot)) ~= nil) then
						local price = select(11, GetItemInfo(link)) * select(2, GetContainerItemInfo(bag, slot))
						
						if select(3, GetItemInfo(link)) == 0 and price > 0 then
							UseContainerItem(bag, slot)
							PickupMerchantItem()
							c = c + price
						end
					end
				end
			end
			
			if c > 0 then
				print(format("|cff99CCFF"..L.TrashSold.."|r%s", GetMoneyString(c)))
			end
		end
	end)
	SellGray:RegisterEvent("MERCHANT_SHOW")
