local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Time then return end

local format, date = string.format, date
local CreateFrame = CreateFrame
local C_DateAndTime_GetCurrentCalendarTime, C_Calendar_GetNumPendingInvites = C_DateAndTime.GetCurrentCalendarTime, C_Calendar.GetNumPendingInvites
local C_AreaPoiInfo_GetAreaPOIInfo, C_Map_GetMapInfo = C_AreaPoiInfo.GetAreaPOIInfo, C_Map.GetMapInfo
local C_QuestLog_IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local C_MythicPlus_GetRunHistory, C_MythicPlus_RequestMapInfo = C_MythicPlus.GetRunHistory, C_MythicPlus.RequestMapInfo
local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local GetSavedInstanceInfo, GetSavedWorldBossInfo = GetSavedInstanceInfo, GetSavedWorldBossInfo
local TIMEMANAGER_TICKER_24HOUR = TIMEMANAGER_TICKER_24HOUR
local WeeklyRunsThreshold = 8

--======================================--
--------------- [[ Data ]] ---------------
--======================================--

--[[ Cache ]] --

local itemCache = {}
local function LoadItemLink(itemID)
	local item = Item:CreateFromItemID(itemID)
	item:ContinueOnItemLoad(function()
		local link = item:GetItemLink()
		if link then
			itemCache[itemID] = link
		end
	end)
end

local function LoadSpellName(entry)
	local spell = Spell:CreateFromSpellID(entry.spellID)
	spell:ContinueOnSpellLoad(function()
		local name = spell:GetSpellName()
		if name then
			entry.name = name
		end
	end)
end

local function LoadQuestName(entry)
	QuestEventListener:AddCallback(entry.questID, function()
		local name = QuestUtils_GetQuestName(entry.questID)
		if name and name ~= "" then
			entry.name = name
		end
	end)
end

-- [[ Delves ]] --

local delvesKeys = {91175, 91176, 91177, 91178}
local keyName = C_CurrencyInfo.GetCurrencyInfo(3028).name

local delveList = {
	{uiMapID = 2393, delveID = 8426}, -- 學院災禍
	{uiMapID = 2424, delveID = 8428}, -- 幻日廣場
	{uiMapID = 2405, delveID = 8430}, -- 戮日者聖所
	{uiMapID = 2405, delveID = 8432}, -- 影衛崗哨
	{uiMapID = 2413, delveID = 8434}, -- 怨鬥坑洞
	{uiMapID = 2413, delveID = 8436}, -- 回憶裂口
	{uiMapID = 2395, delveID = 8438}, -- 暗影領區
	{uiMapID = 2393, delveID = 8440}, -- 黑暗之途
	{uiMapID = 2437, delveID = 8442}, -- 暮光墓穴
	{uiMapID = 2437, delveID = 8444}, -- 阿塔阿曼
}

--[[ Weekly quest ]] --

local DFQuestList = {
	-- PLAYER_DIFFICULTY_TIMEWALKER todo
	{name = "", questID = 70866, spellID = 388945},	-- SoDK
	{name = "", questID = 70906, itemID = 200468},	-- Grand hunt
	{name = "", questID = 70893, spellID = 386441},	-- Community feast
	{name = "", questID = 79226},-- The big dig
	{name = "", questID = 78319, spellID = 418272},	-- The superbloom
	--70221 工匠精神
}

local TWWQuestList = {
	{name = "", questID = 83240},-- 劇團
	{name = "", questID = 83333, areaID = 15141},-- 甦醒機械
	{name = "", questID = 82946},-- 蠟塊
	{name = "", questID = 76586},-- 散布光芒
}

local function LoadQuestListNames(questList)
	for _, entry in ipairs(questList) do
		if entry.itemID then
			if not itemCache[entry.itemID] then
				LoadItemLink(entry.itemID)
			end
		elseif not entry.name or entry.name == "" then
			if entry.spellID then
				LoadSpellName(entry)
			elseif entry.areaID then
				local name = C_Map.GetAreaInfo(entry.areaID)
				if name then
					entry.name = name
				end
			else
				LoadQuestName(entry)
			end
		end
	end
end

local function LoadQuestNames()
	LoadQuestListNames(DFQuestList)
	LoadQuestListNames(TWWQuestList)
end

--==========================================--
---------------	[[ Elements ]] ---------------
--==========================================--

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

--===========================================--
---------------	[[ Functions ]] ---------------
--===========================================--

--[[ Format 24 hour clock ]]--
local function updateTimerFormat(hour, minute)
	return format(TIMEMANAGER_TICKER_24HOUR, hour, minute)
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

local function addQuestList(text, questList)
	title = false
	for _, entry in ipairs(questList) do
		addTitle(text)
		local name = (entry.itemID and itemCache[entry.itemID]) or entry.name or ""
		if C_QuestLog_IsQuestFlaggedCompleted(entry.questID) then
			GameTooltip:AddDoubleLine(name, COMPLETE, 1, 1, 1, .3, 1, .3)
		else
			GameTooltip:AddDoubleLine(name, INCOMPLETE, 1, 1, 1, 1, .3, .3)
		end
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

--=========================================--
---------------	[[ Updates ]] ---------------
--=========================================--

--[[ Update tooltip ]]--
local function OnEnter(self, isShiftDown)
	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- Game time
	local localHour, localMinute = tonumber(date("%H")), tonumber(date("%M"))
	local realmHour, realmMinute = GetGameTime()
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, updateTimerFormat(localHour, localMinute), .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, updateTimerFormat(realmHour, realmMinute), .6, .8, 1, 1, 1, 1)
	
	-- Mythic+ and Weekly chest quest only on max level
	if UnitLevel("player") == GetMaxLevelForLatestExpansion() then
		
		-- Quests

		if isShiftDown then
			-- DF
			addQuestList(EXPANSION_NAME9, DFQuestList)

			-- TWW
			addQuestList(EXPANSION_NAME10, TWWQuestList)
		end
		
		-- Delve key
		title = false
		local currentKeys, maxKeys = 0, #delvesKeys
		for _, questID in ipairs(delvesKeys) do
			if C_QuestLog_IsQuestFlaggedCompleted(questID) then
				currentKeys = currentKeys + 1
			end
		end
		if currentKeys > 0 then
			local r, g, b
			if currentKeys == maxKeys then r, g, b = 1, 0, 0 else r, g, b = 0, 1, 0 end
			addTitle(WEEKLY)
			GameTooltip:AddDoubleLine(keyName, format("%d/%d", currentKeys, #delvesKeys), 1, 1, 1, r, g, b)
		end
		
		-- Delves
		if not isShiftDown then
			title = false
			for _, v in ipairs(delveList) do
				local delveInfo = C_AreaPoiInfo_GetAreaPOIInfo(v.uiMapID, v.delveID)
				if delveInfo then
					local mapInfo = C_Map_GetMapInfo(v.uiMapID)
					if mapInfo then
						addTitle(delveInfo.description)
						GameTooltip:AddDoubleLine(mapInfo.name .. " - " .. delveInfo.name, SecondsToTime(GetQuestResetTime(), true, nil, 3), 1, 1, 1, 1, 1, 1)
					end
				end
			end
		end
		--end
		
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

	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..RATED_PVP_WEEKLY_VAULT..G.MiddleButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.Calendar..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..STOPWATCH_TITLE..G.RightButton)
	
	GameTooltip:Show()
end

--[[ Update data text ]]--
local function OnEvent(self, event, key)
	if event == "MODIFIER_STATE_CHANGED" then
		local isShiftKey = key == "LSHIFT" or key == "RSHIFT"
		if isShiftKey and GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
			local isShiftDown = IsShiftKeyDown()
			if isShiftDown ~= self.isShiftDown then
				self.isShiftDown = isShiftDown
				OnEnter(self, isShiftDown)
			end
		end
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		RequestRaidInfo()
		C_MythicPlus_RequestMapInfo()
		LoadQuestNames()
	end

	local r, g, b
	if C_Calendar_GetNumPendingInvites() > 0 then 
		r, g, b = .57, 1, .57
	else
		r, g, b = 1, 1, 1
	end
	
	Text:SetTextColor(r, g, b)
end

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

--=========================================--
---------------	[[ Scripts ]] ---------------
--=========================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		-- mouseover color
		Text:SetTextColor(0, 1, 1)
		self.isShiftDown = IsShiftKeyDown()
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
		RequestRaidInfo()
		C_MythicPlus_RequestMapInfo()
		-- tooltip show
		OnEnter(self, self.isShiftDown)
	end)
	
	Stat:SetScript("OnLeave", function(self)
		self:UnregisterEvent("MODIFIER_STATE_CHANGED")
		self.isShiftDown = nil
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
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnUpdate", OnUpdate)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, btn)	
		if btn == "RightButton"  then
			ToggleTimeManager()
		elseif btn == "LeftButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
			if not CalendarFrame then C_AddOns.LoadAddOn("Blizzard_Calendar") end
			ToggleCalendar()
		elseif btn == "MiddleButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
			if not WeeklyRewardsFrame then C_AddOns.LoadAddOn("Blizzard_WeeklyRewards") end
			if not WeeklyRewardsFrame:IsShown() then ShowUIPanel(WeeklyRewardsFrame) else HideUIPanel(WeeklyRewardsFrame) end
		else
			return
		end
	end)