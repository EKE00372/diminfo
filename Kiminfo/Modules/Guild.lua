local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Guild then return end

local LibQTip = LibStub('LibQTip-1.0')
local format, sort, wipe, Ambiguate = format, sort, wipe, Ambiguate
local CreateFrame = CreateFrame
local GetNumGuildMembers, GetGuildRosterInfo = GetNumGuildMembers, GetGuildRosterInfo
local C_Reputation_GetGuildFactionData, C_PartyInfo_InviteUnit = C_Reputation.GetGuildFactionData, C_PartyInfo.InviteUnit

local LibShowUIPanel = LibStub("LibShowUIPanel-1.0")
local ShowUIPanel = LibShowUIPanel.ShowUIPanel
local HideUIPanel = LibShowUIPanel.HideUIPanel

local guildTable = {}
local name, rank, rankindex, level, zone, connected, status, class

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

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

	
--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

--[[ Get daily massage ]]--
local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
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
	for i = 1, GetNumGuildMembers() do
		local name, rank, rankindex, level, _, zone, _, _, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
			
		-- Show only online members / 只顯示線上成員
		if mobile and not connected then
				zone = REMOTE_CHAT
				if status == 1 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t"
				elseif status == 2 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t"
				else
					status = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)
				end
		else
			if status == 1 then
				status = G.AFK
			elseif status == 2 then
				status = G.DND
			else 
				status = ""
			end
		end
		
		if not zone then
			zone = UNKNOWN
		end
		
		if connected then
			count = count + 1
			guildTable[count] = { Ambiguate(name, "none"), rank, rankindex, level, zone, connected, status, class, mobile }
		end
	end
	
	SortGuildTable(IsShiftKeyDown())
end

--[[ Click function ]]--
local function buttonOnClick(self, name, btn)
	if btn == "LeftButton" and IsShiftKeyDown() then
		C_PartyInfo_InviteUnit(name)
	elseif btn == "MiddleButton" then
		ChatFrame_OpenChat("/w "..name.." ", SELECTED_DOCK_FRAME)
	else
		return
	end
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function OnEvent(self, event, ...)
	local online = select(3, GetNumGuildMembers())
	
	if not IsInGuild() then
		Text:SetText(L.Lonely)
	else
		Text:SetText(online)
	end
	
	self:SetAllPoints(Text)
	
	if event == "PLAYER_ENTERING_WORLD" then
		if not GuildFrame and IsInGuild() then
			C_AddOns.LoadAddOn("Blizzard_GuildUI")
			UpdateGuildMessage()
		end
	end
end

--[[ Hide QTip tooltip ]]--
local function OnRelease(self)
	LibQTip:Release(self.tooltip)
	self.tooltip = nil  
end

--[[ Update mouseover tooltip ]]--
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	
	if self.timer > .1 then
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
	-- Get local
	local isShiftKeyDown = IsShiftKeyDown()
	local total, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	local guildMotD = GetGuildRosterMOTD()
	
	-- Get table
	BuildGuildTable()
	
	-- Create qtip
	local tooltip = LibQTip:Acquire("KiminfoGuildTooltip", 2, "LEFT", "RIGHT")
	tooltip:SetPoint(C.StickTop and "TOP" or "BOTTOM", self, C.StickTop and "BOTTOM" or "TOP", 0, C.StickTop and -10 or 10)
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..guildName, G.TitleColor..(format("%d/%d", online, total)))
	
	tooltip:AddLine(" ")
	tooltip:AddLine(GUILD)
	tooltip:AddLine(G.OptionColor..RANK, G.OptionColor..guildRank)

	local GetGuildFactionInfo = C_Reputation_GetGuildFactionData()
	local standingID = GetGuildFactionInfo.reaction
	local barMax = GetGuildFactionInfo.nextReactionThreshold
	local barMin = GetGuildFactionInfo.currentReactionThreshold
	local barValue = GetGuildFactionInfo.currentStanding
	
	-- Guild reputation
	if standingID == 8 then
		tooltip:AddLine(G.OptionColor..REPUTATION, G.OptionColor.._G["FACTION_STANDING_LABEL"..8])
	else
		tooltip:AddLine(G.OptionColor..REPUTATION, G.OptionColor.._G["FACTION_STANDING_LABEL"..standingID].." " ..(format("%.3f", (barValue/barMax))*100).."%")
	end
	
	-- Guild daily info
	if guildMotD then
		tooltip:AddLine(" ")
		tooltip:AddLine(GUILD_MOTD)
		
		-- Update width automatically
		local width
		if tooltip:GetWidth() > 200 then
			width = tooltip:GetWidth() + 100
		else
			width = 300
		end

		local y, x = tooltip:AddLine()
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

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
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
		--[[if InCombatLockdown() then
			UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
			return
		end]]--
		
		if button == "LeftButton" then
			if not CommunitiesFrame then C_AddOns.LoadAddOn("Blizzard_Communities") end
			if not CommunitiesFrame:IsShown() then ShowUIPanel(CommunitiesFrame) else HideUIPanel(CommunitiesFrame) end
		else
			return
		end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
	Stat:RegisterEvent("PLAYER_GUILD_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)