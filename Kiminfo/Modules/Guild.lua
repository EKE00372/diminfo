local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Guild then return end

local LibQTip = LibStub('LibQTip-1.0')
local format, sort, wipe, Ambiguate = format, sort, wipe, Ambiguate
local CreateFrame, GetTime, canaccessvalue = CreateFrame, GetTime, canaccessvalue
local GetNumGuildMembers, GetGuildRosterInfo = GetNumGuildMembers, GetGuildRosterInfo
local C_GuildInfo_GetMOTD, C_GuildInfo_GuildRoster = C_GuildInfo.GetMOTD, C_GuildInfo.GuildRoster
local C_Reputation_GetGuildFactionData, C_PartyInfo_InviteUnit = C_Reputation.GetGuildFactionData, C_PartyInfo.InviteUnit

local guildTable = {}
local lastRosterRequest	-- 為跨函數讀取宣告一個初始值為nil的local讓函數用以保存狀態
local ROSTER_REQUEST_INTERVAL = 5	-- 刷新間隔

--==========================================--
---------------	[[ Elements ]] ---------------
--==========================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Guild", UIParent)
	Stat:SetHitRectInsets(-30, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create icon ]]--
local Icon = Stat:CreateTexture(nil, "OVERLAY")
	Icon:SetSize(G.FontSize+8, G.FontSize+8)
	Icon:SetPoint("RIGHT", Stat, "LEFT", 0, 0)
	Icon:SetTexture(G.Guild)
	Icon:SetVertexColor(1, 1, 1)
	
--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.GuildPoint))
	Text:SetTextColor(1, 1, 1)
	Stat:SetAllPoints(Text)

	
--===========================================--
---------------	[[ Functions ]] ---------------
--===========================================--

--[[ Request fresh guild data ]]--
local function RequestGuildRoster(force)
	if not IsInGuild() then return end

	local now = GetTime()
	if not force and lastRosterRequest and now - lastRosterRequest < ROSTER_REQUEST_INTERVAL then return end

	lastRosterRequest = now
	C_GuildInfo_GuildRoster()
end

--[[ Sort by ]] --
local function SortGuildTable(shift)
		sort(guildTable, function(a, b)
			if a and b then
				if shift then
					return a[3] > b[3]
				else
					return a[3] < b[3]
				end
			end
		end)
	end

--[[ Build guild member list table ]]--
local function BuildGuildTable()
	wipe(guildTable)
	
	local count = 0
	for i = 1, (GetNumGuildMembers() or 0) do
		local name, rank, rankindex, level, _, zone, _, _, connected, status, class = GetGuildRosterInfo(i)
			
		-- Show only online members / 只顯示線上成員
		if status == 1 then
			status = G.AFK
		elseif status == 2 then
			status = G.DND
		else
			status = ""
		end
		
		if not zone then
			zone = UNKNOWN
		end
		
		if connected and name and rankindex and level then
			count = count + 1
			guildTable[count] = { Ambiguate(name, "none"), rank, rankindex, level, zone, connected, status, class }
		end
	end
	
	SortGuildTable(IsShiftKeyDown())
end

--[[ Click function ]]--
local function buttonOnClick(self, name, btn)
	if btn == "LeftButton" and IsShiftKeyDown() then
		C_PartyInfo_InviteUnit(name)
	elseif btn == "MiddleButton" then
		ChatFrameUtil.SendTell(name, SELECTED_DOCK_FRAME)
	else
		return
	end
end

--=========================================--
---------------	[[ Updates ]] ---------------
--=========================================--

--[[ Hide QTip tooltip ]]--
local function OnRelease(self)
	if not self.tooltip then return end

	LibQTip:Release(self.tooltip)
	self.tooltip = nil
end

--[[ Update mouseover tooltip ]]--
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	
	if self.timer > .1 then
		if not self.tooltip then
			self:SetScript("OnUpdate", nil)
			return
		end

		if not self:IsMouseOver() then
			if not self.tooltip:IsMouseOver() then
				OnRelease(self)
				self:SetScript("OnUpdate", nil)
			end
		end
		
		self.timer = 0
	end
end

local function OnEnter(self)
	-- No guild no tooltip / 不在公會就不顯示tooltip
	if not IsInGuild() then return end
	RequestGuildRoster()

	-- Get local
	local total, numOnline = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	total = total or 0
	numOnline = numOnline or 0
	guildName = guildName or GUILD
	guildRank = guildRank or UNKNOWN
	
	-- Get table
	BuildGuildTable()
	
	-- Create qtip
	local tooltip = LibQTip:Acquire("KiminfoGuildTooltip", 2, "LEFT", "RIGHT")
	tooltip:SetPoint(C.StickTop and "TOP" or "BOTTOM", self, C.StickTop and "BOTTOM" or "TOP", 0, C.StickTop and -10 or 10)
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..guildName, G.TitleColor..(format("%d/%d", numOnline, total)))
	
	tooltip:AddLine(" ")
	tooltip:AddLine(GUILD)
	tooltip:AddLine(G.OptionColor..RANK, G.OptionColor..guildRank)

	local GetGuildFactionInfo = C_Reputation_GetGuildFactionData()

	-- Guild reputation
	if not GetGuildFactionInfo then
		tooltip:AddLine(G.OptionColor..REPUTATION, G.OptionColor..UNKNOWN)
	else
		local standingID = GetGuildFactionInfo.reaction
		local barMax = GetGuildFactionInfo.nextReactionThreshold
		local barMin = GetGuildFactionInfo.currentReactionThreshold
		local barValue = GetGuildFactionInfo.currentStanding
		local standingLabel = standingID and _G["FACTION_STANDING_LABEL"..standingID]

		if standingID == 8 and standingLabel then
			tooltip:AddLine(G.OptionColor..REPUTATION, G.OptionColor..standingLabel)
		elseif standingLabel and barMax and barMin and barValue and barMax > barMin then
			tooltip:AddLine(G.OptionColor..REPUTATION, G.OptionColor..standingLabel.." " ..(format("%.3f", (barValue - barMin)/(barMax - barMin))*100).."%")
		else
			tooltip:AddLine(G.OptionColor..REPUTATION, G.OptionColor..UNKNOWN)
		end
	end
	
	-- Guild daily info
	if not InCombatLockdown() then
		tooltip:AddLine(" ")
		tooltip:AddLine(GUILD_MOTD)
		
		-- Update width automatically
		local width
		if tooltip:GetWidth() > 200 then
			width = tooltip:GetWidth() + 100
		else
			width = 300
		end

		local y = tooltip:AddLine()
		local guildMotD = C_GuildInfo_GetMOTD()
		if not canaccessvalue(guildMotD) or guildMotD == nil then guildMotD = "" end
		tooltip:SetCell(y, 1, G.OptionColor..guildMotD, nil, "LEFT", 2, nil, 0, 0, width)
	end
	
	-- Options
	tooltip:AddLine(" ", G.Line)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..INVITE)
	tooltip:AddLine(G.OptionColor..G.MiddleButton..WHISPER, G.OptionColor..COMMUNITIES..G.LeftButton)

	tooltip:AddLine(" ")
	tooltip:AddLine(MEMBERS, ZONE)
	tooltip:AddSeparator(2, .6, .8, 1)
	
	for i = 1, #guildTable do
		local info = guildTable[i]
		
		if info then
			-- check zone
			local zonec
			if GetRealZoneText() == info[5] then
				zonec = F.Hex(.3, 1, .3)
			else
				zonec = F.Hex(.65, .65, .65)
			end
			
			local levelc = F.Hex(GetQuestDifficultyColor(info[4]))
			local classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[8]])
			
			if classc == nil then
				classc = levelc
			end
			
			tooltip:AddLine(levelc..info[4].."|r "..classc..info[1].."|r"..info[7], zonec..info[5])
			
			local line = tooltip:GetLineCount()
			tooltip:SetLineScript(line, "OnMouseUp", buttonOnClick, info[1])
		end
	end
	
	tooltip:UpdateScrolling(600)
	tooltip:Show()
	
	self.tooltip = tooltip
end

local function OnEvent(self, event, ...)
	local _, numOnline = GetNumGuildMembers()

	if not IsInGuild() then
		Text:SetText(L.Lonely)
	else
		Text:SetText(numOnline or 0)
	end

	self:SetAllPoints(Text)

	if event == "PLAYER_GUILD_UPDATE" then
		lastRosterRequest = nil
	elseif event == "GUILD_ROSTER_UPDATE" then
		local canRequestRosterUpdate = ...
		if canRequestRosterUpdate then RequestGuildRoster(true) end
	end

end

--=========================================--
---------------	[[ Scripts ]] ---------------
--=========================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		OnRelease(self)
		-- Mouseover color
		Icon:SetVertexColor(0, 1, 1)
		Text:SetTextColor(0, 1, 1)
		-- Tooltip show
		OnEnter(self)
	end)
	
	Stat:SetScript("OnLeave", function(self)
		-- Normal color
		Icon:SetVertexColor(1, 1, 1)
		Text:SetTextColor(1, 1, 1)
		-- Tooltip hide
		if not self.tooltip then return end
		self:SetScript("OnUpdate", OnUpdate)
	end)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
		
		if button == "LeftButton" then
			if not CommunitiesFrame then C_AddOns.LoadAddOn("Blizzard_Communities") end
			ToggleCommunitiesFrame()
		else
			return
		end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
	Stat:RegisterEvent("PLAYER_GUILD_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)