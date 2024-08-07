local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Spec then return end

local format, wipe = string.format, table.wipe
local TALENTS, SPECIALIZATION, TALENTS_BUTTON = TALENTS, SPECIALIZATION, TALENTS_BUTTON
local PVP_TALENTS, LOOT_SPECIALIZATION_DEFAULT = PVP_TALENTS, LOOT_SPECIALIZATION_DEFAULT

local CreateFrame = CreateFrame
local GetSpecialization, GetSpecializationInfo = GetSpecialization, GetSpecializationInfo
local GetLootSpecialization, GetSpecializationInfoByID = GetLootSpecialization, GetSpecializationInfoByID
local SetLootSpecialization, SetSpecialization = SetLootSpecialization, SetSpecialization
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local C_SpecializationInfo_CanPlayerUsePVPTalentUI = C_SpecializationInfo.CanPlayerUsePVPTalentUI
local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local STARTER_BUILD = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID

local pvpTalents, SpecIndex, LootIndex, newMenu, numSpecs, numLocal
local pvpTexture = C_CurrencyInfo.GetCurrencyInfo(104).iconFileID

local LibEasyMenu = LibStub:GetLibrary("LibEasyMenu")

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

-- Create menu template
local SpecMenuFrame = CreateFrame("Frame", "SpecMenu", UIParent, "UIDropDownMenuTemplate")

-- Select spec
local function selectSpec(_, specIndex)
	if SpecIndex == specIndex then return end
	SetSpecialization(specIndex)
	DropDownList1:Hide()
end

-- Check spec
local function checkSpec(self)
	return SpecIndex == self.arg1
end

-- Select loot spec
local function selectLootSpec(_, index)
	SetLootSpecialization(index)
	DropDownList1:Hide()
end

-- Check loot spec
local function checkLootSpec(self)
	return LootIndex == self.arg1
end

-- Refresh loot spec
local function refreshDefaultLootSpec()
	if not SpecIndex or SpecIndex == 5 then return end
	local mult = (3 + numSpecs) or numSpecs
	newMenu[numLocal - mult].text = format(LOOT_SPECIALIZATION_DEFAULT, select(2, GetSpecializationInfo(SpecIndex)) or NONE)
end

-- Select talent
local function selectCurrentConfig(_, configID, specID)
	if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
	if configID == STARTER_BUILD then
		C_ClassTalents.SetStarterBuildActive(true)
	else
		C_ClassTalents.LoadConfig(configID, true)
		C_ClassTalents.SetStarterBuildActive(false)
	end
	C_ClassTalents.UpdateLastSelectedSavedConfigID(specID or GetSpecializationInfo(SpecIndex), configID)
end

-- Check talent
local function checkCurrentConfig(self)
	return C_ClassTalents.GetLastSelectedSavedConfigID(self.arg2) == self.arg1
end

-- Refresh menu
local function refreshAllTraits()
	local numConfig = numLocal or 0
	local specID = GetSpecializationInfo(SpecIndex)
	local configIDs = specID and C_ClassTalents.GetConfigIDsBySpecID(specID)
	if configIDs then
		for i = 1, #configIDs do
			local configID = configIDs[i]
			if configID then
				local info = C_Traits.GetConfigInfo(configID)
				numConfig = numConfig + 1
				if not newMenu[numConfig] then newMenu[numConfig] = {} end
				newMenu[numConfig].text = info.name
				newMenu[numConfig].arg1 = configID
				newMenu[numConfig].arg2 = specID
				newMenu[numConfig].func = selectCurrentConfig
				newMenu[numConfig].checked = checkCurrentConfig
			end
		end
	end

	for i = numConfig+1, #newMenu do
		if newMenu[i] then newMenu[i].text = nil end
	end
end

-- Sperator menu
local seperatorMenu = {
	text = "",
	isTitle = true,
	notCheckable = true,
	iconOnly = true,
	icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
	iconInfo = {
		tCoordLeft = 0,
		tCoordRight = 1,
		tCoordTop = 0,
		tCoordBottom = 1,
		tSizeX = 0,
		tSizeY = 8,
		tFitDropDownSizeX = true
	},
}

-- Build menu
local function BuildSpecMenu()
	if newMenu then return end
	
	-- Build menu
	newMenu = {
		{text = SPECIALIZATION, isTitle = true, notCheckable = true},
		seperatorMenu,
		{text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true},
		{text = "", arg1 = 0, func = selectLootSpec, checked = checkLootSpec},
	}

	-- Build spec and lootspec menu
	for i = 1, 4 do
		local id, name = GetSpecializationInfo(i)
		if id then
			numSpecs = (numSpecs or 0) + 1
			tinsert(newMenu, i+1, {text = name, arg1 = i, func = selectSpec, checked = checkSpec})
			tinsert(newMenu, {text = name, arg1 = id, func = selectLootSpec, checked = checkLootSpec})
		end
	end
	
	-- Build talent menu
	tinsert(newMenu, seperatorMenu)
	tinsert(newMenu, {text = C_Spell_GetSpellInfo(384255).name, isTitle = true, notCheckable = true})
	tinsert(newMenu, {text = BLUE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_STARTER_BUILD), func = selectCurrentConfig,
		arg1 = STARTER_BUILD,	checked = function() return C_ClassTalents.GetStarterBuildActive() end,
	})
	
	numLocal = #newMenu
	refreshDefaultLootSpec()
	refreshAllTraits()
	
	-- Register even for menu update
	local frame = CreateFrame("Frame", nil, UIParent)
		frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		frame:RegisterEvent("TRAIT_CONFIG_DELETED")
		frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
		frame:SetScript("OnEvent", function()
			refreshDefaultLootSpec()
			refreshAllTraits()
		end)
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Update data text ]]--
local function OnEvent(self)
	SpecIndex = GetSpecialization()
	if not SpecIndex then return end
	
	if SpecIndex then
		local SpecIcon
		SpecIcon = F.addIcon(select(4, GetSpecializationInfo(SpecIndex)), 12, 4, 46)
		
		LootIndex = GetLootSpecialization()
		local LootIcon
		if LootIndex == 0 then
			LootIcon = SpecIcon
		else
			LootIcon = F.addIcon(select(4, GetSpecializationInfoByID(LootIndex)), 12, 4, 46)
		end
		
		Text:SetText(SpecIcon..L.Spec..LootIcon..LOOT)
	else
		Text:SetText(L.Spec..NONE..LOOT..NONE)
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	SpecIndex = GetSpecialization()
	if not SpecIndex or SpecIndex == 5 then return end
	
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- Spec
	local specID, specName, _, specIcon = GetSpecializationInfo(SpecIndex)
	GameTooltip:AddLine(F.addIcon(specIcon, 14, 4, 46).." "..G.OptionColor..specName.."|r")
	
	-- Telent
	local configID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
	local info = configID and C_Traits.GetConfigInfo(configID)
	if info and info.name then
		GameTooltip:AddLine(info.name, 1, 1, 1)
	end
	
	-- PvP telent
	if C_SpecializationInfo_CanPlayerUsePVPTalentUI() then
		pvpTalents = C_SpecializationInfo_GetAllSelectedPvpTalentIDs()
		
		if #pvpTalents > 0 then
			-- PvP title
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
	GameTooltip:AddDoubleLine(" ", G.OptionColor..TALENTS..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..SPECIALIZATION..G.RightButton)
	
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
		
		if button == "RightButton" then
			BuildSpecMenu()
			LibEasyMenu:EasyMenu(newMenu, SpecMenuFrame, "cursor", 0, 0, "MENU", 3)
		elseif button == "LeftButton" then
			if not PlayerSpellsFrame then C_AddOns.LoadAddOn("Blizzard_PlayerSpells") end
			PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
		else
			return
		end
	end)
