local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Guild then return end

local LibQTip = LibStub('LibQTip-1.0')
local format = string.format
local sort = table.sort
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

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

-- sort by/排序
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

local function BuildGuildTable()
	wipe(guildTable)
	
	local count = 0
	for i = 1, GetNumGuildMembers() do
		local name, rank, rankindex, level, _, zone, _, _, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
			
		-- we are only interested in online members/只顯示線上成員
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
			guildTable[count] = { name, rank, rankindex, level, zone, connected, status, class, mobile }
		end
	end
	
	SortGuildTable(IsShiftKeyDown())
end

-- Click function
local function buttonOnClick(self, name, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			InviteToGroup(name)
		elseif IsShiftKeyDown() then
			ChatFrame_OpenChat("/w "..name.." ", SELECTED_DOCK_FRAME)
		else
			return
		end
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
			LoadAddOn("Blizzard_GuildUI")
			UpdateGuildMessage()
		end
	end
end

-- hide QTip tooltip
local function OnRelease(self)
	LibQTip:Release(self.tooltip)
	self.tooltip = nil  
end

-- Update when mouseover tooltip
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
	-- 不在公會就不顯示tooltip
	if not IsInGuild() then return end
	-- get local
	local isShiftKeyDown = IsShiftKeyDown()
	local total, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	local guildMotD = GetGuildRosterMOTD()
	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
	-- get table
	BuildGuildTable()
	
	-- create qtip
	local tooltip = LibQTip:Acquire("KiminfoGuildTooltip", 2, "LEFT", "RIGHT")
	tooltip:SetPoint("TOP", self, "BOTTOM", 0, -10)
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..guildName, G.TitleColor..(format("%d/%d", online, total)))
	
	tooltip:AddLine(" ")
	tooltip:AddLine(GUILD)
	tooltip:AddLine(G.OptionColor..RANK, G.OptionColor..guildRank)
		
	-- guild reputation
	if standingID == 8 then
		tooltip:AddLine(G.OptionColor..REPUTATION, G.OptionColor.._G["FACTION_STANDING_LABEL"..8])
	else
		tooltip:AddLine(G.OptionColor..REPUTATION, G.OptionColor.._G["FACTION_STANDING_LABEL"..standingID].." " ..(format("%.3f", (barValue/barMax))*100).."%")
	end
	
	-- guild daily info
	if guildMotD then
		tooltip:AddLine(" ")
		tooltip:AddLine(GUILD_MOTD)
		
		local width
		if tooltip:GetWidth() > 200 then
			width = tooltip:GetWidth() + 100
		else
			width = 300
		end

		local y, x = tooltip:AddLine()
		tooltip:SetCell(y, 1, G.OptionColor..format(guildMotD), nil, "LEFT", 2, nil, 0, 0, width)
	end
	
	-- options
	tooltip:AddLine(" ", G.Line)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..SLASH_WHISPER2:gsub("/(.*)","%1"), G.OptionColor..GUILD..G.LeftButton)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Alt "..INVITE, G.OptionColor..COMMUNITIES_INVITATION_FRAME_TYPE..G.RightButton)

	tooltip:AddLine(" ")
	tooltip:AddLine(MEMBERS, ZONE)
	tooltip:AddSeparator(2, .6, .8, 1)
	
	for i = 1, #guildTable do
		-- get table
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
		-- mouseover color
		Icon:SetVertexColor(0, 1, 1)
		Text:SetTextColor(0, 1, 1)
		-- tooltip show
		OnEnter(self)
	end)
		
	Stat:SetScript("OnLeave", function(self)
		-- normal color
		Icon:SetVertexColor(1, 1, 1)
		Text:SetTextColor(1, 1, 1)
		-- tooltip hide
		if not self.tooltip then return end
		self:SetScript("OnUpdate", OnUpdate)
	end)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
			return
		end
		if button == "RightButton" then
			ToggleCommunitiesFrame()
		else
			if not IsInGuild() then return end
			if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
			ToggleFrame(GuildFrame)
		end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
	Stat:RegisterEvent("PLAYER_GUILD_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)