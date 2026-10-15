local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Guild then return end

local format, sort, wipe, Ambiguate = format, sort, wipe, Ambiguate
local CreateFrame, GetTime, canaccessvalue = CreateFrame, GetTime, canaccessvalue
local GetNumGuildMembers, GetGuildRosterInfo = GetNumGuildMembers, GetGuildRosterInfo
local C_GuildInfo_GetMOTD, C_GuildInfo_GuildRoster = C_GuildInfo.GetMOTD, C_GuildInfo.GuildRoster
local C_Reputation_GetGuildFactionData, C_PartyInfo_InviteUnit = C_Reputation.GetGuildFactionData, C_PartyInfo.InviteUnit

local guildTable = {}
local lastRosterRequest	-- 為跨函數讀取宣告一個初始值為nil的local讓函數用以保存狀態

--==========================================--
---------------	[[ Elements ]] ---------------
--==========================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Guild", UIParent, "HorizontalLayoutFrame")

--[[ Create icon ]]--
local Icon = Stat:CreateTexture(nil, "OVERLAY")
	Icon.layoutIndex = 1
	Icon.align = "center"
	Icon:SetSize(G.FontSize+8, G.FontSize+8)
	Icon:SetTexture(G.Guild)
	Icon:SetVertexColor(1, 1, 1)
	
--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 2
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetTextColor(1, 1, 1)
	F.RegisterModule("Guild", Stat)

	
--===========================================--
---------------	[[ Functions ]] ---------------
--===========================================--

--[[ Request fresh guild data ]]--
local function RequestGuildRoster(force)
	if not IsInGuild() then return end

	local now = GetTime()
	if not force and lastRosterRequest and now - lastRosterRequest < 5 then return end

	lastRosterRequest = now
	C_GuildInfo_GuildRoster()
end

--[[ Build guild member list table ]]--
local function BuildGuildTable(sortDescending)
	wipe(guildTable)
	
	local count = 0
	for i = 1, (GetNumGuildMembers() or 0) do
		local name, _, rankIndex, level, _, zone, _, _, connected, status, class = GetGuildRosterInfo(i)
			
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
		
		if connected and name and rankIndex and level then
			count = count + 1
			guildTable[count] = {
				name = Ambiguate(name, "none"),
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

--[[ Refresh the visible panel without requesting another roster ]]--
local function RenderGuildPanel(self)
	local panel = self.panel
	panel:Clear()

	-- Get local
	local total, numOnline = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	total = total or 0
	numOnline = numOnline or 0
	guildName = guildName or GUILD
	guildRank = guildRank or UNKNOWN
	
	-- Get table
	BuildGuildTable(self.sortDescending)
	
	panel:AddLine(G.TitleColor..guildName, G.TitleColor..(format("%d/%d", numOnline, total)))
	
	panel:AddLine()
	panel:AddLine(GUILD)
	panel:AddLine(G.OptionColor..RANK, G.OptionColor..guildRank)

	local GetGuildFactionInfo = C_Reputation_GetGuildFactionData()

	-- Guild reputation
	if not GetGuildFactionInfo then
		panel:AddLine(G.OptionColor..REPUTATION, G.OptionColor..UNKNOWN)
	else
		local standingID = GetGuildFactionInfo.reaction
		local barMax = GetGuildFactionInfo.nextReactionThreshold
		local barMin = GetGuildFactionInfo.currentReactionThreshold
		local barValue = GetGuildFactionInfo.currentStanding
		local standingLabel = standingID and _G["FACTION_STANDING_LABEL"..standingID]

		if standingID == 8 and standingLabel then
			panel:AddLine(G.OptionColor..REPUTATION, G.OptionColor..standingLabel)
		elseif standingLabel and barMax and barMin and barValue and barMax > barMin then
			panel:AddLine(G.OptionColor..REPUTATION, G.OptionColor..standingLabel.." " ..(format("%.3f", (barValue - barMin)/(barMax - barMin))*100).."%")
		else
			panel:AddLine(G.OptionColor..REPUTATION, G.OptionColor..UNKNOWN)
		end
	end
	
	-- Guild daily info
	if not InCombatLockdown() then
		panel:AddLine()
		panel:AddLine(GUILD_MOTD)
		local guildMotD = C_GuildInfo_GetMOTD()
		if not canaccessvalue(guildMotD) or guildMotD == nil then guildMotD = "" end
		panel:AddText(G.OptionColor..guildMotD)
	end
	
	-- Options
	panel:AddLine(" ", G.Line)
	panel:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..INVITE)
	panel:AddLine(G.OptionColor..G.MiddleButton..WHISPER, G.OptionColor..COMMUNITIES..G.LeftButton)

	panel:AddLine()
	panel:AddRow({MEMBERS, ZONE})
	panel:AddSeparator()
	
	local currentZone = GetRealZoneText()
	local zoneColor, mutedColor = F.Hex(.3, 1, .3), F.Hex(.65, .65, .65)
	for i = 1, #guildTable do
		local info = guildTable[i]
		local zonec = (currentZone == info.zone) and zoneColor or mutedColor
		local levelc = F.Hex(GetQuestDifficultyColor(info.level))
		local classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info.class])
		panel:AddRow({levelc..info.level.."|r "..classc..info.name.."|r"..info.status, zonec..info.zone}, info.name, buttonOnClick)
	end
	
	panel:Layout()
end

local function OnEvent(self, event, ...)
	local _, numOnline = GetNumGuildMembers()

	if not IsInGuild() then
		Text:SetText(L.Lonely)
	else
		Text:SetText(numOnline or 0)
	end
	self:Layout()

	if event == "PLAYER_GUILD_UPDATE" then
		lastRosterRequest = nil
	elseif event == "GUILD_ROSTER_UPDATE" then
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

--=========================================--
---------------	[[ Scripts ]] ---------------
--=========================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		-- Mouseover color
		Icon:SetVertexColor(0, 1, 1)
		Text:SetTextColor(0, 1, 1)
		if not IsInGuild() then return end
		RequestGuildRoster()

		if not self.panel then
			-- 等級、姓名與狀態合為左欄，區域為右欄；兩欄皆自然寬，超過面板上限時先縮右欄。
			self.panel = F.CreateInfoPanel(self, {{}, {justify = "RIGHT"}})
			self.panel:HookScript("OnHide", function()
				self.sortDescending = nil
			end)
		end
		-- 一次顯示期間固定排序，避免按 Shift 邀請時換掉滑鼠下的成員。
		if not self.panel:IsShown() then
			self.sortDescending = IsShiftKeyDown()
		end
		RenderGuildPanel(self)
		self.panel:Show()
	end)
	
	Stat:SetScript("OnLeave", function(self)
		-- Normal color
		Icon:SetVertexColor(1, 1, 1)
		Text:SetTextColor(1, 1, 1)
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