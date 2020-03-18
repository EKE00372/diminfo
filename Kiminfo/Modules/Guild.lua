local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Guild then return end

local format = string.format
local sort = table.sort

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Guild", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.GuildPoint))
	Stat:SetAllPoints(Text)
	
--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--
--[[
local function scrollBarHook(self, delta)
	local scrollBar = self.ScrollBar
	scrollBar:SetValue(scrollBar:GetValue() - delta*50)
end
]]--

local guildTable = {}
local name, rank, level, zone, connected, status, class, mobile

-- sort by/排序
--[[
local function SortGuildTable(shift)
		sort(guildTable, function(a, b)
			if a and b then
				if shift then
					return a[10] < b[10]
				else
					return a[C.Sortingby] < b[C.Sortingby]
				end
			end
		end)
	end
	]]--
local function BuildGuildTable()
	wipe(guildTable)
	
	local count = 0
	for i = 1, GetNumGuildMembers() do
		local name, rank, _, level, _, zone, _, _, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
			
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
				status = " "
			end
		end
		
		if not zone then
			zone = UNKNOWN
		end
		
		if connected then
			count = count + 1
			guildTable[count] = { name, rank, level, zone, connected, status, class, mobile }
		end
	end
	
	--SortGuildTable(IsShiftKeyDown())
end	
--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function OnEvent(self, event, ...)
	local online = select(3, GetNumGuildMembers())
	
	if not IsInGuild() then
		--Text:SetText(C.ClassColor and F.Hex(G.Ccolors)..L.Lonely or L.Lonely)
		Text:SetText(F.addIcon(G.Guild, 16, 0, 50)..L.Lonely)
	else
		Text:SetText(F.addIcon(G.Guild, 16, 0, 50)..format("%d", online))
	end
	--[[
	if event == "PLAYER_ENTERING_WORLD" then
		if not GuildFrame and IsInGuild() then
			LoadAddOn("Blizzard_GuildUI")
			UpdateGuildMessage()
		end
	end]]--
end

local function OnEnter(self)
	if not IsInGuild() then return end
	
	BuildGuildTable()
	local shown = 0
	local maxShown = C.MaxAddOns
	
	local total, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	local guildMotD = GetGuildRosterMOTD()
	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(format(guildName), format(format("%d/%d", online, total)), 0, .6, 1, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- guild rank
	GameTooltip:AddLine(GUILD)
	GameTooltip:AddDoubleLine(RANK, guildRank, 1, 1, 1, 1, 1, 1)
	
	-- guild reputation
	if standingID == 8 then
		GameTooltip:AddDoubleLine(REPUTATION, _G["FACTION_STANDING_LABEL"..8], 1, 1, 1, 1, 1, 1)
	else
		GameTooltip:AddDoubleLine(REPUTATION, _G["FACTION_STANDING_LABEL"..standingID].." " ..(format("%.3f", (barValue/barMax))*100).."%", 1, 1, 1, 1, 1, 1)
	end
	
	-- guild daily info
	if guildMotD ~= "" then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(GUILD_MOTD)
		GameTooltip:AddLine(G.OptionColor..format(guildMotD), 1, 1, 1, 1)	-- shold wrap text
	end
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(MEMBERS)
	
	for i = 1, #guildTable do
		-- get table
		local info = guildTable[i]
		
		if info then
			shown = shown + 1
			
			if shown <= maxShown then
				-- check zone
				local zonec
				if GetRealZoneText() == info[4] then
					zonec = F.Hex(.3, 1, .3)
				else
					zonec = F.Hex(.65, .65, .65)
				end
				
				local levelc = F.Hex(GetQuestDifficultyColor(info[3]))
				local classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[7]])
				
				--guildTable[count] = { name, rank, level, zone, connected, status, class, mobile }
				GameTooltip:AddDoubleLine(levelc..info[3].."|r "..classc..info[1].."|r"..info[6], zonec..info[4])
			end
		end
	end
	
	if online - maxShown > 1 then
		GameTooltip:AddLine(G.OptionColor..(online - maxShown).." "..L.Hidden)
	end

	-- options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..GUILD..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..COMMUNITIES..G.RightButton)
	
	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function()
		GameTooltip:Hide()
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