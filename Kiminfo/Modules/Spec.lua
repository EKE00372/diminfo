local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Spec then return end

local format = string.format
local sort = table.sort

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Spec", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.SpecPoint))
	Text:SetTextColor(1, 1, 1)
	Stat:SetAllPoints(Text)

--================================================--
---------------    [[ feature ]]     ---------------
--================================================--

--[[ right-click menu ]]--
local menuFrame = CreateFrame("Frame", "LootSpecMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	-- title
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	-- default
	{notCheckable = true, func = function() SetLootSpecialization(0) end },
	-- 4 spec
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true},
}

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Update data text ]]--
local function OnEvent(self)
	local SpecID = GetSpecialization()
	if not SpecID then return end
	
	if SpecID then
		local SpecIcon
		SpecIcon = F.addIcon(select(4, GetSpecializationInfo(SpecID)), 12, 4, 46)
		
		local LootID = GetLootSpecialization()
		local LootIcon
		
		if LootID == 0 then
			LootIcon = SpecIcon
		else
			LootIcon = F.addIcon(select(4, GetSpecializationInfoByID(LootID)), 12, 4, 46)
		end
		
		Text:SetText(SpecIcon..L.Spec..LootIcon..LOOT)
	else
		Text:SetText(L.Spec..NONE..LOOT..NONE)
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	local SpecID = GetSpecialization()
	if not SpecID then return end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- spec
	local _, specName, _, specIcon = GetSpecializationInfo(SpecID)
	GameTooltip:AddLine(F.addIcon(specIcon, 14, 4, 46).." "..G.OptionColor..specName.."|r")
	
	-- telent
	for t = 1, MAX_TALENT_TIERS do
		for c = 1, 3 do
			local _, name, icon, selected = GetTalentInfo(t, c, 1)
			if selected then
				GameTooltip:AddLine(F.addIcon(icon, 14, 4, 46).." ["..c.."]"..name, 1, 1, 1)
			end
		end
	end
	
	-- pvp telent
	local pvpTalents
	if UnitLevel("player") >= SHOW_PVP_TALENT_LEVEL then
		pvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
		
		if #pvpTalents > 0 then
			-- pvp title
			local pvpTexture = select(3, GetCurrencyInfo(104))
			
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(F.addIcon(pvpTexture, 14, 4, 46).." "..PVP_TALENTS, .6,.8,1)
			
			-- list
			for _, talentID in next, pvpTalents do
				local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
				if name and unlocked then
					GameTooltip:AddLine(F.addIcon(icon, 14, 4, 46).." "..name, 1, 1, 1)
				end
			end
		end
		
		wipe(pvpTalents)
	end
	
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..TALENTS..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..SELECT_LOOT_SPECIALIZATION..G.RightButton)
	
	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		-- mouseover color
		Text:SetTextColor(0, 1, 1)
		-- tooltip show
		OnEnter(self)
	end)
	
	Stat:SetScript("OnLeave", function()
		-- normal color
		Text:SetTextColor(1, 1, 1)
		-- tooltip hide
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
	Stat:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		local SpecID = GetSpecialization()
		if not SpecID then return end
		
		if button == "RightButton" then
			local specID, specName = GetSpecializationInfo(SpecID)
			for i = 1, 4 do
				menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)
				local id, name = GetSpecializationInfo(i)
				
				if id then
					menuList[i+2].text = name
					menuList[i+2].func = function() SetLootSpecialization(id) end
				else
					menuList[i+2] = nil
				end
			end
			EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 3)
		else
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
				return
			end
			
			if not PlayerTalentFrame then
				LoadAddOn("Blizzard_TalentUI")
			end
			ToggleTalentFrame(2)
		end
	end)