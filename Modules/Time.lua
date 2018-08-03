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

	local int = 1
	local Hr24, Hr, Min
	local function Update(self, t)
		local pendingCalendarInvites = C_Calendar.GetNumPendingInvites()
		int = int - t
		if int < 0 then
			-- 本地時間
			if GetCVar("timeMgrUseLocalTime") == "1" then
				Hr24 = tonumber(date("%H"))
				Hr = tonumber(date("%I"))
				Min = date("%M")
				-- 24小時制
				if GetCVar("timeMgrUseMilitaryTime") == "1" then
					if pendingCalendarInvites > 0 then
					Text:SetText("|cffFF0000"..Hr24..":"..Min)
				else
					Text:SetText(Hr24..":"..Min)
				end
			else
				if Hr24>=12 then
					if pendingCalendarInvites > 0 then
						Text:SetText(cfg.ColorClass and "|cffFF0000"..Hr..":"..Min..init.Colored.."pm|r" or "|cffFF0000"..Hr..":"..Min.."|cffffffffpm|r")
					else
						Text:SetText(cfg.ColorClass and Hr..":"..Min..init.Colored.."pm|r" or Hr..":"..Min.."|cffffffffpm|r")
					end
				else
					if pendingCalendarInvites > 0 then
						Text:SetText(cfg.ColorClass and "|cffFF0000"..Hr..":"..Min..init.Colored.."am|r" or "|cffFF0000"..Hr..":"..Min.."|cffffffffam|r")
					else
						Text:SetText(cfg.ColorClass and Hr..":"..Min..init.Colored.."am|r" or Hr..":"..Min.."|cffffffffam|r")
					end
				end
			end
		else
			local Hr, Min = GetGameTime()
			if Min<10 then Min = "0"..Min end
			if GetCVar("timeMgrUseMilitaryTime") == "1" then
				if pendingCalendarInvites > 0 then			
					Text:SetText("|cffFF0000"..Hr..":"..Min.."|cffffffff|r")
				else
					Text:SetText(Hr..":"..Min.."|cffffffff|r")
				end
			else
				if Hr>=12 then
					if Hr>12 then Hr = Hr-12 end
					if pendingCalendarInvites > 0 then
						Text:SetText(cfg.ColorClass and "|cffFF0000"..Hr..":"..Min..init.Colored.."pm|r" or "|cffFF0000"..Hr..":"..Min.."|cffffffffpm|r")
					else
						Text:SetText(cfg.ColorClass and Hr..":"..Min..init.Colored.."pm|r" or Hr..":"..Min.."|cffffffffpm|r")
					end
				else
					if Hr == 0 then Hr = 12 end
					if pendingCalendarInvites > 0 then
						Text:SetText(cfg.ColorClass and "|cffFF0000"..Hr..":"..Min..init.Colored.."am|r" or "|cffFF0000"..Hr..":"..Min.."|cffffffffam|r")
					else
						Text:SetText(cfg.ColorClass and Hr..":"..Min..init.Colored.."am|r" or Hr..":"..Min.."|cffffffffam|r")
					end
				end
			end
		end		
		int = 1
		end
		self:SetAllPoints(Text)
	end
	
	local months = {
		MONTH_JANUARY,
		MONTH_FEBRUARY,
		ONTH_MARCH,
		MONTH_APRIL,
		MONTH_MAY,
		MONTH_JUNE,
		MONTH_JULY,
		MONTH_AUGUST,
		MONTH_SEPTEMBER,
		MONTH_OCTOBER,
		MONTH_NOVEMBER,
		MONTH_DECEMBER,
	}
	
	local function zsub(s,...) local t={...} for i=1,#t,2 do s=gsub(s,t[i],t[i+1]) end return s end

	Stat:SetScript("OnEnter", function(self)
		OnLoad = function(self) RequestRaidInfo() end
		local today = C_Calendar.GetDate()
		local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:ClearLines()
		--GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], months[m], d, y), 0, .6, 1)
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
		
		local oneraid
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, difficulty, locked, extended, _, isRaid, _, difficultyName  = GetSavedInstanceInfo(i)
			--if isRaid and (locked or extended) then
			if (locked or extended) then
				if not oneraid then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(LOCK_EXPIRE, .6, .8, 1)
					oneraid = true
				end
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), r,g,b, 1,1,1)
			GameTooltip:AddLine(difficultyName, 1,1,1)
			end
		end
		-- world boss/世界首領
		for i = 1, GetNumSavedWorldBosses() do
			local name, id, reset = GetSavedWorldBossInfo(i)
			if not (id == 11 or id == 12 or id == 13) then
				AddTitle(RAID_INFO_WORLD_BOSS)
				GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1,1,1, 1,1,1)
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