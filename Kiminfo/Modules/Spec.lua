local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Spec then return end

local format, min, max, sort, wipe = format, min, max, sort, wipe
local CreateFrame = CreateFrame

local pvpTalents

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

--[[ Right-click menu ]]--
local lootMenuFrame = CreateFrame("Frame", "LootSpecMenu", UIParent, "UIDropDownMenuTemplate")
local lootMenuList = {
	-- Title
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	-- default and 4 spec
	{},	{},	{},	{},	{},
}

--[[ Middle-click menu ]]--
local specMenuFrame = CreateFrame("Frame", "SpecMenu", UIParent, "UIDropDownMenuTemplate")
local specMenuList = {
	-- Title
	{ text = SPECIALIZATION, isTitle = true, notCheckable = true },
	-- 4 spec
	{},	{},	{},	{},
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
	
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- Spec
	local _, specName, _, specIcon = GetSpecializationInfo(SpecID)
	GameTooltip:AddLine(F.addIcon(specIcon, 14, 4, 46).." "..G.OptionColor..specName.."|r")
	
	-- Telent
	for t = 1, MAX_TALENT_TIERS do
		for c = 1, 3 do
			local _, name, icon, selected = GetTalentInfo(t, c, 1)
			if selected then
				GameTooltip:AddLine(F.addIcon(icon, 14, 4, 46).." ["..c.."] "..name, 1, 1, 1)
			end
		end
	end
	
	-- Pvp telent
	if UnitLevel("player") >= SHOW_PVP_TALENT_LEVEL then
		pvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
		
		if #pvpTalents > 0 then
			-- Pvp title
			local pvpTexture = select(3, GetCurrencyInfo(104))
			
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(F.addIcon(pvpTexture, 14, 4, 46).." "..PVP_TALENTS, .6, .8, 1)
			
			-- List
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
	GameTooltip:AddDoubleLine(" ", G.OptionColor..SPECIALIZATION..G.MiddleButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..TALENTS..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..SELECT_LOOT_SPECIALIZATION..G.RightButton)
	
	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		-- Mouseover color
		Text:SetTextColor(0, 1, 1)
		-- Tooltip show
		OnEnter(self)
	end)
	
	Stat:SetScript("OnLeave", function()
		-- Normal color
		Text:SetTextColor(1, 1, 1)
		-- Tooltip hide
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
	Stat:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		-- Hide tooltip when dropdown menu pop
		GameTooltip:Hide()
		
		-- Get current spec id index
		local ID = GetSpecialization()
		if not ID then return end
		-- Get current spec info
		local specID, specName = GetSpecializationInfo(ID)
		-- Get currnet loot spec
		local LootSpec = GetLootSpecialization()
		
		if button == "RightButton" then
			for i = 1, 4 do
				lootMenuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)
				lootMenuList[2].func = function() SetLootSpecialization(0) end
				lootMenuList[2].checked = LootSpec == 0 and true or false
				
				local id, name = GetSpecializationInfo(i)
				if id then
					lootMenuList[i+2].text = name
					lootMenuList[i+2].func = function() SetLootSpecialization(id) end
					lootMenuList[i+2].checked = id == LootSpec and true or false
				else
					lootMenuList[i+2] = nil
				end
			end
			EasyMenu(lootMenuList, lootMenuFrame, "cursor", 0, 0, "MENU", 3)
		elseif button == "MiddleButton" then
			for i = 1, 4 do
				local id, name = GetSpecializationInfo(i)
				if id then
					specMenuList[i+1].text = name
					specMenuList[i+1].func = function() SetSpecialization(i) end
					specMenuList[i+1].checked = id == specID and true or false
				else
					specMenuList[i+1] = nil
				end
			end
			EasyMenu(specMenuList, specMenuFrame, "cursor", 0, 0, "MENU", 3)
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