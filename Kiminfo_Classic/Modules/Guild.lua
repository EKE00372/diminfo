local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Guild then return end

local LibQTip = LibStub('LibQTip-1.0')
local format = string.format
local sort = table.sort
local guildTable = {}
local name, rank, rankindex, level, zone, connected, status, class
local C_Timer_After = C_Timer.After

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Guild", UIParent)
	Stat:SetHitRectInsets(-35, -5, -10, -10)
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
	Stat:SetAllPoints(Text)
	
--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

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

-- build guild info table
local function BuildGuildTable()
	wipe(guildTable)
	
	local count = 0
	for i = 1, GetNumGuildMembers() do
		local name, rank, rankindex, level, _, zone, _, _, connected, status, class = GetGuildRosterInfo(i)
			
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
		
		if connected then
			count = count + 1
			guildTable[count] = { name, rank, rankindex, level, zone, connected, status, class }
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

-- Update data text
local function OnEvent(self, event, ...)
	local online = select(3, GetNumGuildMembers())
	
	if not IsInGuild() then
		Text:SetText(L.Lonely)
	else
		Text:SetText(online)
	end
	
	self:SetAllPoints(Text)
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

-- Update tooltip
local function OnEnter(self)
	-- 不在公會就不顯示tooltip
	if not IsInGuild() then return end
	-- get local
	local isShiftKeyDown = IsShiftKeyDown()
	local total, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	local guildMotD = GetGuildRosterMOTD() or ""
	-- get table
	BuildGuildTable()
	
	-- create qtip
	local tooltip = LibQTip:Acquire("KiminfoGuildTooltip", 2, "LEFT", "RIGHT")
	tooltip:SetPoint("TOP", self, "BOTTOM", 0, -10)
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..guildName, G.TitleColor..(format("%d/%d", online, total)))
	tooltip:AddHeader(G.TitleColor..RANK, G.TitleColor..guildRank)
	
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
	tooltip:AddLine(" ", G.OptionColor..GUILD..G.LeftButton)
	tooltip:AddLine(" ", G.OptionColor..COMMUNITIES_INVITATION_FRAME_TYPE..G.RightButton)

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
			--local classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[8]])
			local classc
			if info[8] == "SHAMAN" then
				classc = F.Hex(0, .6, 1)
			else
				classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[8]])
			end
			
			if classc == nil then
				classc = levelc
			end
			
			local name = info[1]:match("[^-]+")	-- hide realm
			tooltip:AddLine(levelc..info[4].."|r "..classc..name.."|r"..info[7], zonec..info[5])
			
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
		if button == "RightButton" then
			ToggleCommunitiesFrame()
		else
			if not IsInGuild() then return end
			if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
			securecall(ToggleFriendsFrame, 3) 
		end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
	Stat:RegisterEvent("PLAYER_GUILD_UPDATE")
	Stat:SetScript("OnEvent", OnEvent)