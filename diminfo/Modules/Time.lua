local _, ns = ...
local C, F, G = unpack(ns)
if not C.Time then return end

local GameTooltip = F.Tooltip
local format, date = string.format, date
local GetCVarBool = GetCVarBool

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Time", UIParent, "HorizontalLayoutFrame")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 1
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	F.RegisterModule("Time", Stat)
	
--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

--[[ Custom api for add title line ]]--
local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text, .6, .8, 1)
		title = true
	end
end

local resetFormatter = CreateFromMixins(SecondsFormatterMixin)
resetFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, false, false, false)
resetFormatter:SetDesiredUnitCount(3)
resetFormatter:SetMinInterval(SecondsFormatter.Interval.Minutes)

local function formatReset(seconds)
	-- Keep minute-only CD text without rounding fractional seconds up.
	seconds = math.floor(seconds)
	if seconds < SECONDS_PER_MIN then return "" end
	return resetFormatter:Format(seconds)
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

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
		Text:SetText(GameTime_GetFormattedTime(hour, minute, true))
		self:Layout()
		
		self.timer = 0
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	-- 獲取進度
	RequestRaidInfo()
	
	local today = C_DateAndTime.GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y, m), 0, .6, 1)
	GameTooltip:AddLine(" ")

	-- Game time
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true), .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true), .6, .8, 1, 1, 1, 1)
	
	--[[ 副本進度 ]]--

	-- Dungeon
	if G.IsTBC then
		title = false
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, difficulty, locked, extended = GetSavedInstanceInfo(i)
			if difficulty == DIFFICULTY_DUNGEON_HEROIC and (locked or extended) then
				addTitle(DUNGEONS)
				local r, g, b
				if extended then
					r,g,b = .3, 1, .3
				else
					r, g, b = 1, 1, 1
				end

				GameTooltip:AddDoubleLine(name, formatReset(reset), 1, .82, 0, r, g, b)
			end
		end
	end

	-- RAID
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, difficultyName  = GetSavedInstanceInfo(i)

		if isRaid and (locked or extended) then
			addTitle(RAID)
			local r, g, b
			if extended then
				r, g, b = .3, 1, .3
			else
				r, g, b = 1, 1, 1
			end
		
		GameTooltip:AddDoubleLine(difficultyName.." - "..name, formatReset(reset), 1, .82, 0, r, g, b)
		end
	end

	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..STOPWATCH_TITLE..G.RightButton)
	
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
	Stat:SetScript("OnUpdate", OnUpdate)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, btn)
		if btn == "RightButton"  then
			ToggleFrame(TimeManagerFrame)
		end
	end)