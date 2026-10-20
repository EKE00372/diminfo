local _, ns = ...
local C, F, G, L = unpack(ns)
if not C.Bags then return end

local GameTooltip = F.Tooltip
local format = string.format
local CreateFrame = CreateFrame
local GetContainerNumFreeSlots, GetContainerNumSlots = C_Container.GetContainerNumFreeSlots, C_Container.GetContainerNumSlots

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Bags", UIParent, "HorizontalLayoutFrame")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 1
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	F.RegisterModule("Bags", Stat)

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

	local free, total = getBagSlots()
	Text:SetText(C.ClassColor and F.Hex(G.Ccolors)..BAGSLOT.." |r"..free.."/"..total or BAGSLOT.." "..free.."/"..total)
	self:Layout()
end

--[[ Tooltip update ]]--
local function OnEnter(self)
	local free, total, used = getBagSlots()
	local money = GetMoney()
	
	-- title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(BAGSLOT, free.."/"..total, 0, .6, 1, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- bag slot
	GameTooltip:AddLine(G.OptionColor..BAGSLOT)
	GameTooltip:AddDoubleLine(USE, used, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(MONEY, GetMoneyString(money), 1, 1, 1, 1, 1, 1)
	
	-- options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..BAGSLOT..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoSell..(diminfo.AutoSell and G.Enable or G.Disable)..G.RightButton, 1, 1, 1, .4, .78, 1)
	
	F.ShowTooltip()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_LOGIN")
	Stat:RegisterEvent("BAG_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			diminfo.AutoSell = not diminfo.AutoSell
			OnEnter(self)
		elseif button == "LeftButton" then
			ToggleAllBags()
		end
	end)

--=======================================================--
---------------    [[ Auto sell gray ]]     ---------------
--=======================================================--

local sellGray = CreateFrame("Frame")
	sellGray:SetScript("OnEvent", function()
		if diminfo.AutoSell == true then
			local c = 0
			
			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					local info = C_Container.GetContainerItemInfo(bag, slot)
					
					if info then
						local _, _, quality, _, _, _, _, _, _, _, sellPrice = C_Item.GetItemInfo(info.hyperlink)
						
						if quality == 0 and sellPrice > 0 then
							local price = sellPrice * info.stackCount
							C_Container.UseContainerItem(bag, slot)
							PickupMerchantItem(0)
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
	sellGray:RegisterEvent("MERCHANT_SHOW")
