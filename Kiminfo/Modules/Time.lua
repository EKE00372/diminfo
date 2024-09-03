local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Time then return end

local format, date = string.format, date
local CreateFrame = CreateFrame
local C_DateAndTime_GetCurrentCalendarTime, C_Calendar_GetNumPendingInvites = C_DateAndTime.GetCurrentCalendarTime, C_Calendar.GetNumPendingInvites
local C_AreaPoiInfo_GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
local C_QuestLog_IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local C_UIWidgetManager_GetTextWithStateWidgetVisualizationInfo =  C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo
local C_MythicPlus_GetRunHistory, C_ChallengeMode_GetMapUIInfo = C_MythicPlus.GetRunHistory, C_ChallengeMode.GetMapUIInfo
local C_CVar_GetCVarBool, C_Spell_GetSpellName = C_CVar.GetCVarBool, C_Spell.GetSpellName
local GetSavedInstanceInfo, GetSavedWorldBossInfo = GetSavedInstanceInfo, GetSavedWorldBossInfo
local TIMEMANAGER_TICKER_24HOUR, TIMEMANAGER_TICKER_12HOUR = TIMEMANAGER_TICKER_24HOUR, TIMEMANAGER_TICKER_12HOUR

local LibShowUIPanel = LibStub("LibShowUIPanel-1.0")
local ShowUIPanel = LibShowUIPanel.ShowUIPanel
local HideUIPanel = LibShowUIPanel.HideUIPanel
local WeeklyRunsThreshold = 8

--[[ Weekly chest item link ]] --
local itemCache = {}
local function GetItemLink(itemID)
	local link = itemCache[itemID]
	if not link then
		link = select(2, C_Item.GetItemInfo(itemID))
		itemCache[itemID] = link
	end
	return link
end

--[[ Weekly quest ]] --
local DFQuestList = {
	-- PLAYER_DIFFICULTY_TIMEWALKER todo
	{name = C_Spell_GetSpellName(388945), id = 70866},	-- SoDK
	{name = L.GrandHunts, id = 70906},	-- Grand hunt
	{name = C_Spell_GetSpellName(386441), id = 70893},	-- Community feast
	{name = QuestUtils_GetQuestName(79226), id = 79226},-- The big dig
	{name = C_Spell_GetSpellName(418272), id = 78319},	-- The superbloom
	--70221 工匠精神
}

local TWWQuestList = {
	{name = QuestUtils_GetQuestName(83240), id = 83240},-- 劇團
	{name = C_Map.GetAreaInfo(15141), id = 83333},-- 甦醒機械
	{name = QuestUtils_GetQuestName(82946), id = 82946},-- 蠟塊
	{name = QuestUtils_GetQuestName(76586), id = 76586},-- 散布光芒
}

--[[ Torghast ]]--
--[[
local TorghastWidgets, TorghastInfo = {
	{nameID = 2925, levelID = 2930}, -- Fracture Chambers
	{nameID = 2926, levelID = 2932}, -- Skoldus Hall
	{nameID = 2924, levelID = 2934}, -- Soulforges
	{nameID = 2927, levelID = 2936}, -- Coldheart Interstitia
	{nameID = 2928, levelID = 2938}, -- Mort'regar
	{nameID = 2929, levelID = 2940}, -- The Upper Reaches
}
]]--

-- Torghast fix: Fuckking blizzard make the name on tooltip wrap like shit
local function CleanupLevelName(text)
	return gsub(text, "|n", "")
end

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Time", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.TimePoint))
	Text:SetTextColor(1, 1, 1)
	Stat:SetAllPoints(Text)

--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

--[[ Format 24/12 hour clock ]]--
local function updateTimerFormat(hour, minute)
	if C_CVar_GetCVarBool("timeMgrUseMilitaryTime") then
		return format(TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = hour < 12 and " AM" or " PM"
		
		if hour > 12 then
			hour = hour - 12
		end
		
		return format(TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

--[[ Custom api for add title line ]]--
local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text, .6, .8, 1)
		title = true
	end
end

--[[ Mythic+ run history sort order ]]--
local function sortHistory(entry1, entry2)
	if entry1.level == entry2.level then
		return entry1.mapChallengeModeID < entry2.mapChallengeModeID
	else
		return entry1.level > entry2.level
	end
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function OnEvent(self)
	local r, g, b
	if C_Calendar_GetNumPendingInvites() > 0 then 
		r, g, b = .57, 1, .57
	else
		r, g, b = 1, 1, 1
	end
	
	Text:SetTextColor(r, g, b)
end

--[[ Update data text ]]--
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 3) + elapsed
	-- Limit frequency / 限制一下更新速率
	if self.timer > 5 then
		-- Local time / 本地時間
		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		Text:SetText(updateTimerFormat(hour, minute))
		
		self.timer = 0
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	-- 獲取進度
	RequestRaidInfo()
	
	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- Game time
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true), .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true), .6, .8, 1, 1, 1, 1)
	
	-- Mythic+ and Weekly chest quest only on max level
	if UnitLevel("player") == GetMaxLevelForLatestExpansion() then
		-- Quests
		title = false
		local questList = IsShiftKeyDown() and DFQuestList or TWWQuestList
		local weeklyTitle = IsShiftKeyDown() and EXPANSION_NAME9 or WEEKLY
		
		for _, v in pairs(questList) do
			--addTitle(WEEKLY)
			addTitle(weeklyTitle)
			if v.name and C_QuestLog_IsQuestFlaggedCompleted(v.id) then
				GameTooltip:AddDoubleLine(v.name, COMPLETE, 1, 1, 1, .3, 1, .3)
			else
				GameTooltip:AddDoubleLine(v.name, INCOMPLETE, 1, 1, 1, 1, .3, .3)
			end
		end
		
		-- Mythic+ 8 runs
		title = false
		local runHistory = C_MythicPlus_GetRunHistory(false, true)
		local numRuns = runHistory and #runHistory
		
		if numRuns > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, WeeklyRunsThreshold), "("..numRuns..")", .6, .8, 1)
			sort(runHistory, sortHistory)

			for i = 1, WeeklyRunsThreshold do
				local runInfo = runHistory[i]
				if not runInfo then break end

				local name = C_ChallengeMode_GetMapUIInfo(runInfo.mapChallengeModeID)
				local r, g, b = .3, 1, .3
				if not runInfo.completed then r, g, b = 1, .3, .3 end
				GameTooltip:AddDoubleLine(name, "Lv."..runInfo.level, 1, 1, 1, r, g, b)
			end
		end
	end
	
	--[[ 副本進度 ]]--
	
	-- World boss
	title = false
	for i = 1, GetNumSavedWorldBosses() do
		local name, id, reset = GetSavedWorldBossInfo(i)
		
		if not (id == 11 or id == 12 or id == 13) then
			addTitle(RAID_INFO_WORLD_BOSS)
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 1, 1, 1)
		end
	end
	
	-- Dungeon
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, difficulty, locked, extended, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		-- 5h and 5m
		if (difficulty == 2 or difficulty == 23) and (locked or extended) then
			addTitle(DUNGEONS)
			local r, g, b
			if extended then
				r,g,b = .3, 1, .3
			else
				r, g, b = 1, 1, 1
			end
		
		GameTooltip:AddDoubleLine(difficultyName.." "..name.." |cff4cff4c("..encounterProgress.."/"..numEncounters..")|r", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- RAID
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, difficultyName, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)

		if isRaid and (locked or extended) then
			addTitle(RAID)
			local r, g, b
			if extended then
				r, g, b = .3, 1, .3
			else
				r, g, b = 1, 1, 1
			end
		
		GameTooltip:AddDoubleLine(difficultyName.." "..name.." |cff4cff4c("..encounterProgress.."/"..numEncounters..")|r", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end
	
	-- Torghast
	--[[if not TorghastInfo then
		TorghastInfo = C_AreaPoiInfo_GetAreaPOIInfo(1543, 6640)
	end
	if TorghastInfo and C_QuestLog_IsQuestFlaggedCompleted(60136) then
		title = false
		for _, value in pairs(TorghastWidgets) do
			local nameInfo = C_UIWidgetManager_GetTextWithStateWidgetVisualizationInfo(value.nameID)
			if nameInfo and nameInfo.shownState == 1 then
				addTitle(TorghastInfo.name)
				local nameText = CleanupLevelName(nameInfo.text)
				local levelInfo = C_UIWidgetManager_GetTextWithStateWidgetVisualizationInfo(value.levelID)
				local levelText = AVAILABLE
				if levelInfo and levelInfo.shownState == 1 then
					levelText = CleanupLevelName(levelInfo.text)
				end
				GameTooltip:AddDoubleLine(nameText, levelText, 1, 1, 1, 1, 1, 1)
			end
		end
	end]]--

	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..RATED_PVP_WEEKLY_VAULT..G.MiddleButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.Calendar..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..STOPWATCH_TITLE..G.RightButton)
	
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
	
	Stat:SetScript("OnLeave", function(self)
		-- normal color
		--Text:SetTextColor(1, 1, 1)
		OnEvent(self)
		-- tooltip hide
		GameTooltip:Hide()
		
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	--Stat:RegisterEvent("CALENDAR_EVENT_ALARM")
	--Stat:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
	--Stat:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST")
	--Stat:RegisterEvent("UPDATE_INSTANCE_INFO")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnUpdate", OnUpdate)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, btn)
		if btn == "RightButton"  then
			ToggleTimeManager()
		elseif btn == "LeftButton"  then
			if not CalendarFrame then LoadAddOn("Blizzard_Calendar") end
				if not CalendarFrame:IsShown() then ShowUIPanel(CalendarFrame) else HideUIPanel(CalendarFrame) end
		elseif btn == "MiddleButton" then
			if not WeeklyRewardsFrame then LoadAddOn("Blizzard_WeeklyRewards") end
			if not WeeklyRewardsFrame:IsShown() then ShowUIPanel(WeeklyRewardsFrame) else HideUIPanel(WeeklyRewardsFrame) end
		else
			return
		end
	end)