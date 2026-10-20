local _, ns = ...
local C, F, G = unpack(ns)
if not C.Spec then return end

local GameTooltip = F.Tooltip
local TALENTS, SPECIALIZATION = TALENTS, SPECIALIZATION
local CreateFrame = CreateFrame

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

-- 沿原生 Camelot 三樹標題的 currency spent，重現經典版的天賦點數格式。
local function getTalentPoints()
	local configID = C_SpecializationInfo.GetCombatConfigIDForSpecGroup(C_SpecializationInfo.GetActiveSpecGroup())
	local configInfo = configID and C_Traits.GetConfigInfo(configID)
	local treeID = configInfo and configInfo.treeIDs[1]
	if not treeID then return end

	local displayInfos = C_Traits.GetGroupDisplayInfoByTreeID(treeID)
	if #displayInfos == 0 then return end
	local groupIDs = {}
	for index, displayInfo in ipairs(displayInfos) do
		groupIDs[index] = displayInfo.groupID
	end
	local groupInfos = C_Traits.GetGroupCurrencyInfo(configID, groupIDs)
	local points = {}
	for index, displayInfo in ipairs(displayInfos) do
		points[index] = 0
		for _, groupInfo in ipairs(groupInfos) do
			if groupInfo.traitNodeGroupID == displayInfo.groupID then
				local currencyInfo = groupInfo.currencyInfos[1]
				if currencyInfo then points[index] = currencyInfo.spent end
				break
			end
		end
	end
	return table.concat(points, "/"), displayInfos, points
end

local function checkSpecGroup(groupIndex)
	return (C_SpecializationInfo.GetActiveSpecGroup() == groupIndex)
end

local function selectSpecGroup(groupIndex)
	if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
	if groupIndex > GetNumSpecGroups() or checkSpecGroup(groupIndex) then return end
	C_SpecializationInfo.SetActiveSpecGroup(groupIndex)
end

local function BuildSpecGroupMenu(_, rootDescription)
	rootDescription:CreateTitle(SPECIALIZATION)
	for groupIndex, name in ipairs({DUAL_SPEC_PRIMARY, DUAL_SPEC_SECONDARY}) do
		local button = rootDescription:CreateRadio(name, checkSpecGroup, selectSpecGroup, groupIndex)
		button:SetEnabled(groupIndex <= GetNumSpecGroups())
	end
end

Stat:SetScript("OnEvent", function(self)
	local pointsText, displayInfos, points = getTalentPoints()
	local icon = CreateAtlasMarkup(GetClassAtlas(select(2, UnitClass("player"))), 12, 12)
	if displayInfos then
		for index, displayInfo in ipairs(displayInfos) do
			if points[index] > 25 then
				icon = F.addIcon(displayInfo.icon, 12, 4, 46)
				break
			end
		end
	end
	Text:SetText(icon.." "..(pointsText or UNKNOWN))
	self:Layout()
end)
Stat:SetScript("OnEnter", function(self)
	Text:SetTextColor(0, 1, 1)
	local pointsText, displayInfos, points = getTalentPoints()
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(G.TitleColor..TALENT, G.TitleColor..(pointsText or UNKNOWN))
	if displayInfos then
		for index, displayInfo in ipairs(displayInfos) do
			GameTooltip:AddDoubleLine(F.addIcon(displayInfo.icon, 14, 4, 46).." "..displayInfo.displayName,
				points[index], 1, 1, 1, 1, 1, 1)
		end
	end
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..TALENTS..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..SPECIALIZATION..G.RightButton)
	F.ShowTooltip()
end)
Stat:SetScript("OnLeave", function()
	Text:SetTextColor(1, 1, 1)
	GameTooltip:Hide()
end)
Stat:SetScript("OnMouseDown", function(self, button)
	GameTooltip:Hide()
	if button == "RightButton" then
		MenuUtil.CreateContextMenu(self, BuildSpecGroupMenu)
	elseif button == "LeftButton" then
		if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
		PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
	end
end)
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:RegisterEvent("PLAYER_TALENT_UPDATE")
Stat:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Stat:RegisterEvent("TRAIT_CONFIG_UPDATED")
