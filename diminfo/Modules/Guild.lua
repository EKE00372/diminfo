local _, ns = ...
local C, F, G, L = unpack(ns)
if not C.Guild then return end

local format, sort, wipe = string.format, table.sort, wipe
local CreateFrame, GetTime = CreateFrame, GetTime
local GetNumGuildMembers, GetGuildRosterInfo = GetNumGuildMembers, GetGuildRosterInfo
local C_GuildInfo_GetMOTD, C_GuildInfo_GuildRoster = C_GuildInfo.GetMOTD, C_GuildInfo.GuildRoster

local guildTable = {}
local lastRosterRequest

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Guild", UIParent, "HorizontalLayoutFrame")
	F.RegisterModule("Guild", Stat, 0)

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text.layoutIndex = 1
	Text.align = "center"
	
--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

--[[ Click function ]]--
local function OnClick(self, name, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			InviteToGroup(name)
		elseif IsShiftKeyDown() then
			ChatFrameUtil.OpenChat("/w "..name.." ", SELECTED_DOCK_FRAME)
		end
	end
end

--[[ Request fresh guild data ]]--
local function RequestGuildRoster(force)
	if not IsInGuild() then return end
	-- 原生公會頁已接手名單事件時，不重複提出同一份資料請求。
	if GuildFrame:IsShown() or (CommunitiesFrame and CommunitiesFrame:IsShown()) then return end

	local now = GetTime()
	if not force and lastRosterRequest and now - lastRosterRequest < 5 then return end

	lastRosterRequest = now
	C_GuildInfo_GuildRoster()
end

local function BuildGuildTable(sortDescending)
	wipe(guildTable)
	
	local count = 0
	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex, level, _, zone, _, _, connected, status, class = GetGuildRosterInfo(i)
		
		
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
		
		-- Show only online members / 只顯示線上成員
		if connected then
			count = count + 1
			guildTable[count] = {
				name = Ambiguate(name, "guild"),
				rankIndex = rankIndex,
				level = level,
				zone = zone,
				status = status,
				class = class,
			}
		end
	end
	
	sort(guildTable, function(a, b)
		if sortDescending then
			return a.rankIndex > b.rankIndex
		end
		return a.rankIndex < b.rankIndex
	end)
end	

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Refresh the panel without requesting another roster ]]--
local function RenderGuildPanel(self)
	-- Get local
	local total, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	local guildMotD = C_GuildInfo_GetMOTD()
	
	-- Get table
	BuildGuildTable(self.sortDescending)
	
	local tooltip = self.panel
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..guildName, G.TitleColor..(format("%d/%d", online, total)))
	tooltip:AddHeader(G.TitleColor..RANK, G.TitleColor..guildRank)
	
	-- Guild daily info
	tooltip:AddLine(" ")
	tooltip:AddLine(GUILD_MOTD)
	tooltip:AddText(G.OptionColor..guildMotD)
	
	-- Options
	tooltip:AddLine(" ", G.Line)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..L.Whisper, G.OptionColor..GUILD..G.LeftButton)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Alt "..INVITE, G.OptionColor..COMMUNITIES_INVITATION_FRAME_TYPE..G.RightButton)

	tooltip:AddLine(" ")
	tooltip:AddLine(MEMBERS, ZONE)
	tooltip:AddSeparator(2, .6, .8, 1)

	local currentZone = GetRealZoneText()
	local zoneColor, mutedColor = F.Hex(.3, 1, .3), F.Hex(.65, .65, .65)
	for i = 1, #guildTable do
		-- get table
		local info = guildTable[i]
		
		-- check zone
		local zonec = (currentZone == info.zone) and zoneColor or mutedColor

		local levelc = F.Hex(GetQuestDifficultyColor(info.level))

		local classc
		if info.class == "SHAMAN" then
			classc = F.Hex(0, .6, 1)
		else
			classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info.class])
		end

		tooltip:AddRow({levelc..info.level.."|r "..classc..info.name.."|r"..info.status, zonec..info.zone}, info.name, OnClick)
	end
	
	tooltip:Layout()
end

local function OnEvent(self, event, ...)
	local online = select(3, GetNumGuildMembers())
	local isPlayerGuildUpdate = (event == "PLAYER_GUILD_UPDATE" and select(1, ...) == "player")

	if not IsInGuild() then
		Text:SetText(C.ClassColor and F.Hex(G.Ccolors)..L.Lonely or L.Lonely)
	else
		Text:SetText(format(C.ClassColor and F.Hex(G.Ccolors)..GUILD.." |r".."%d" or GUILD.." %d", online))
	end
	self:Layout()

	if isPlayerGuildUpdate then
		lastRosterRequest = nil
		if self.panel and self.panel:IsShown() then RequestGuildRoster() end
	elseif event == "GUILD_ROSTER_UPDATE" then
		-- 常駐人數也使用名單資料，續請求不隨 tooltip 關閉而停止。
		local canRequestRosterUpdate = ...
		if canRequestRosterUpdate then RequestGuildRoster(true) end
	end

	if self.panel and self.panel:IsShown() then
		if IsInGuild() then
			RenderGuildPanel(self)
		else
			self.panel:Hide()
		end
	end
end

local function OnEnter(self)
	if not IsInGuild() then return end
	RequestGuildRoster()

	if not self.panel then
		self.panel = F.CreateInfoPanel(self, {{justify = "LEFT"}, {justify = "RIGHT"}})
	end
	-- 一次顯示期間固定排序，避免按 Shift 密語時換掉滑鼠下的成員。
	if not self.panel:IsShown() then
		self.sortDescending = IsShiftKeyDown()
	end
	RenderGuildPanel(self)
	self.panel:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			ToggleCommunitiesFrame()
		elseif button == "LeftButton" then
			securecall(ToggleFriendsFrame, 3)
		end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
	Stat:RegisterEvent("PLAYER_GUILD_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)