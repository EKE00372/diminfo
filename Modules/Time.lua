local addon, ns = ... 
local C, F, G = unpack(ns)
local panel = CreateFrame("Frame", nil, UIParent)

if not C.Time then return end

	-- make addon frame anchor-able
	local Stat = CreateFrame("Frame", "diminfo_Time")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	-- setup text
	local Text  = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.TimePoint))
	Stat:SetAllPoints(Text)

	local function Update(self, elapsed)
		self.timer = (self.timer or 0) + elapsed
		if self.timer > 1 then
			-- 本地時間
			local hour, minute
			if GetCVarBool("timeMgrUseLocalTime") then
				hour, minute = tonumber(date("%H")), tonumber(date("%M"))
			else
				hour, minute = GetGameTime()
			end
			-- 24小時制
			if GetCVarBool("timeMgrUseMilitaryTime") then
				Text:SetText(format(TIMEMANAGER_TICKER_24HOUR, hour, minute))
			else
				Text:SetText(format(TIMEMANAGER_TICKER_12HOUR..(hour < 12 and "AM" or "PM"), hour, minute))
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
		
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, zsub(GameTime_GetLocalTime(true), "%s*AM", " am", "%s*PM", " pm"), .6, .8, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, zsub(GameTime_GetGameTime(true), "%s*AM", " am", "%s*PM", " pm"), .6, .8, 1, 1, 1, 1)
		
		local title
		local function addTitle(text)
			if not title then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(text, .6, .8, 1)
				title = true
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
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnUpdate", Update)
	Stat:RegisterEvent("UPDATE_INSTANCE_INFO")
	Stat:SetScript("OnMouseDown", function(self, btn)
		if btn == "RightButton"  then
			if not TimeManagerFrame:IsShown() then
				ShowUIPanel(TimeManagerFrame)
			else
				HideUIPanel(TimeManagerFrame)
			end
		else
			ToggleChannelFrame()
		end
	end)
	Update(Stat, 10)