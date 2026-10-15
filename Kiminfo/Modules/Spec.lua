local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Spec then return end

local GameTooltip = F.Tooltip
local format, wipe = string.format, table.wipe
local TALENTS, SPECIALIZATION, TALENTS_BUTTON = TALENTS, SPECIALIZATION, TALENTS_BUTTON
local PVP_TALENTS, LOOT_SPECIALIZATION_DEFAULT = PVP_TALENTS, LOOT_SPECIALIZATION_DEFAULT

local CreateFrame = CreateFrame
local GetSpecialization, GetSpecializationInfo = GetSpecialization, GetSpecializationInfo
local GetLootSpecialization, GetSpecializationInfoByID = GetLootSpecialization, GetSpecializationInfoByID
local SetLootSpecialization, SetSpecialization = SetLootSpecialization, C_SpecializationInfo.SetSpecialization
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local C_SpecializationInfo_CanPlayerUsePVPTalentUI = C_SpecializationInfo.CanPlayerUsePVPTalentUI
local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local STARTER_BUILD = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID

local pvpTalents, SpecIndex, LootIndex
local pvpTexture = C_CurrencyInfo.GetCurrencyInfo(1792).iconFileID

--==========================================--
---------------	[[ Elements ]] ---------------
--==========================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Spec", UIParent, "HorizontalLayoutFrame")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 1
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetTextColor(1, 1, 1)
	F.RegisterModule("Spec", Stat)

--=========================================--
---------------	[[ feature ]] ---------------
--=========================================--

--[[ Right-click menu ]]--

-- Select spec
local function selectSpec(specIndex)
	if GetSpecialization() == specIndex then return end
	SetSpecialization(specIndex)
end

-- Check spec
local function checkSpec(specIndex)
	return (GetSpecialization() == specIndex)
end

-- Select loot spec
local function selectLootSpec(index)
	SetLootSpecialization(index)
end

-- Check loot spec
local function checkLootSpec(index)
	return (GetLootSpecialization() == index)
end

-- Select talent
local function selectCurrentConfig(data)
	if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
	local configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
	local loadoutIndex
	if data.configID == STARTER_BUILD then
		if C_ClassTalents.GetHasStarterBuild() then
			-- 原生選單將 Starter Build 放在所有 saved loadout 之後。
			loadoutIndex = #configIDs + 1
		end
	else
		for index, configID in ipairs(configIDs) do
			if configID == data.configID then
				loadoutIndex = index
				break
			end
		end
	end

	if loadoutIndex then
		-- 由原生天賦流程處理非同步完成、Starter 狀態及最後選取紀錄。
		C_ClassTalents.SwitchToLoadoutByIndex(loadoutIndex)
	else
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INVALID_CONFIG)
	end
end

-- Check talent
local function checkCurrentConfig(data)
	return (C_ClassTalents.GetLastSelectedSavedConfigID(data.specID) == data.configID)
end

-- 每次開啟查詢最新資料；選單的顯示、關閉與回收交由 Blizzard_Menu。
local function BuildSpecMenu(_, rootDescription)
	rootDescription:CreateTitle(SPECIALIZATION)
	for i = 1, 4 do
		local id, name = GetSpecializationInfo(i)
		if id then
			rootDescription:CreateRadio(name, checkSpec, selectSpec, i)
		end
	end

	local specIndex = GetSpecialization()
	local specID, specName
	if specIndex then
		specID, specName = GetSpecializationInfo(specIndex)
	end

	rootDescription:CreateDivider()
	rootDescription:CreateTitle(SELECT_LOOT_SPECIALIZATION)
	rootDescription:CreateRadio(format(LOOT_SPECIALIZATION_DEFAULT, specName or NONE), checkLootSpec, selectLootSpec, 0)
	for i = 1, 4 do
		local id, name = GetSpecializationInfo(i)
		if id then
			rootDescription:CreateRadio(name, checkLootSpec, selectLootSpec, id)
		end
	end

	if not specID then return end
	rootDescription:CreateDivider()
	rootDescription:CreateTitle(C_Spell_GetSpellInfo(384255).name)
	-- Starter Build 作用於點選當下的專精，不固定在開啟選單時。
	if C_ClassTalents.GetHasStarterBuild() then
		rootDescription:CreateRadio(BLUE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_STARTER_BUILD),
			function() return C_ClassTalents.GetStarterBuildActive() end,
			selectCurrentConfig, {configID = STARTER_BUILD})
	end

	local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)
	for _, configID in ipairs(configIDs) do
		local info = C_Traits.GetConfigInfo(configID)
		rootDescription:CreateRadio(info.name, checkCurrentConfig, selectCurrentConfig,
			{configID = configID, specID = specID})
	end
end

--=========================================--
---------------	[[ Updates ]] ---------------
--=========================================--

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
	self:Layout()
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
	
	F.ShowTooltip()
end

--=========================================--
---------------	[[ Scripts ]] ---------------
--=========================================--

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
			MenuUtil.CreateContextMenu(self, BuildSpecMenu)
		elseif button == "LeftButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
			if not PlayerSpellsFrame then C_AddOns.LoadAddOn("Blizzard_PlayerSpells") end
			PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
		else
			return
		end
	end)
