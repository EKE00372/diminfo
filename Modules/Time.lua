local addon, ns = ...
local cfg = ns.cfg
local init = ns.init
local panel = CreateFrame("Frame", nil, UIParent)

if cfg.Time == true then

	-- make addon frame anchor-able
	local Stat = CreateFrame("Frame", "diminfo_Time")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	-- setup text
	local Text  = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.TimePoint))
	Stat:SetAllPoints(Text)

	local function Update(self, elapsed)
		self.timer = (self.timer or 0) + elapsed
		if self.timer > 1 then
			-- 有邀請時變色
			local color = C_Calendar.GetNumPendingInvites() > 0 and "|cffFF0000" or ""
			-- 本地時間
			local hour, minute
			if GetCVarBool("timeMgrUseLocalTime") then
				hour, minute = tonumber(date("%H")), tonumber(date("%M"))
			else
				hour, minute = GetGameTime()
			end
			-- 24小時制
			if GetCVarBool("timeMgrUseMilitaryTime") then
				Text:SetText(format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute))
			else
				Text:SetText(format(color..TIMEMANAGER_TICKER_12HOUR..init.Colored..(hour < 12 and "AM" or "PM"), hour, minute))
			end
	
			self.timer = 0
		end
	end

	
	local function zsub(s,...)
		local t={...}
			for i=1,#t,2 do
				s=gsub(s,t[i],t[i+1])
			end
		return s
	end

	Stat:SetScript("OnEnter", function(self)
	
		OnLoad = function(self) RequestRaidInfo() end
		
		local today = C_Calendar.GetDate()
		local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
		
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:ClearLines()

		GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0,.6,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, zsub(GameTime_GetLocalTime(true), "%s*AM", "am", "%s*PM", "pm"), .6, .8, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, zsub(GameTime_GetGameTime(true), "%s*AM", "am", "%s*PM", "pm"), .6, .8, 1, 1, 1, 1)
		--[[GameTooltip:AddLine(" ")
		
		local pvp = GetNumWorldPVPAreas()
		for i=1, pvp do
			local timeleft = select(5, GetWorldPVPAreaInfo(i))
			local name = select(2, GetWorldPVPAreaInfo(i))
			local inprogress = select(3, GetWorldPVPAreaInfo(i))
			local inInstance, instanceType = IsInInstance()
			if not ( instanceType == "none" ) then
				timeleft = QUEUE_TIME_UNAVAILABLE
			elseif inprogress then
				timeleft = WINTERGRASP_IN_PROGRESS
			else
				local hour = tonumber(format("%01.f", floor(timeleft/3600)))
				local min = format(hour>0 and "%02.f" or "%01.f", floor(timeleft/60 - (hour*60)))
				local sec = format("%02.f", floor(timeleft - hour*3600 - min *60)) 
				timeleft = (hour>0 and hour..":" or "")..min..":"..sec
			end
			GameTooltip:AddDoubleLine(name,timeleft,.6,.8,1,1,1,1)
		end
		
		--Hr = tonumber(date("%I"))
		--Min = date("%M")]]--
		
		local title
		local function addTitle(text)
			if not title then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(text, .6, .8, 1)
				title = true
			end
		end

		-- world boss/世界首領
		for i = 1, GetNumSavedWorldBosses() do
			local name, id, reset = GetSavedWorldBossInfo(i)
			if not (id == 11 or id == 12 or id == 13) then
				addTitle(RAID_INFO_WORLD_BOSS)
				GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, .82, 0, 1,1,1)
			end
		end
		
		-- 5H
		title = false
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, difficulty, locked, extended = GetSavedInstanceInfo(i)

			if difficulty == 2 and (locked or extended) then
				addTitle(PLAYER_DIFFICULTY2)
				local r,g,b
				if extended then
					r,g,b = .3, 1, .3
				else
					r,g,b = 1,1,1
				end
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, .82, 0, r,g,b)
			end
		end
		
		-- 5M
		title = false
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, difficulty, locked, extended = GetSavedInstanceInfo(i)

			if difficulty == 23 and (locked or extended) then
				addTitle(PLAYER_DIFFICULTY6)
				local r,g,b
				if extended then
					r,g,b = .3, 1, .3
				else
					r,g,b = 1,1,1
				end
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, .82, 0, r,g,b)
			end
		end

		-- RAID
		title = false
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, _, locked, extended, _, isRaid, _, difficultyName  = GetSavedInstanceInfo(i)

			if isRaid and (locked or extended) then
				addTitle(GUILD_CHALLENGE_TYPE2)
				local r,g,b
				if extended then
					r,g,b = .3, 1, .3
				else
					r,g,b = 1,1,1
				end
			GameTooltip:AddDoubleLine(difficultyName.." - "..name, SecondsToTime(reset, true, nil, 3), 1, .82, 0, r,g,b)
			end
		end
		

		
		GameTooltip:Show()
	end)
	
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Stat:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnUpdate", Update)
	Stat:RegisterEvent("UPDATE_INSTANCE_INFO")
	Stat:SetScript("OnMouseDown", function(self, btn)
		if btn == "RightButton"  then
			ToggleTimeManager()
		else
			GameTimeFrame:Click()
		end
	end)
	Update(Stat, 10)
end