local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Friends then return end

-- localized references for global functions (about 50% faster)
local format = string.format
local sort = table.sort
local friendTable, bnetTable = {}, {}
local friendOnline = gsub(ERR_FRIEND_ONLINE_SS, ".+h", "")
local friendOffline = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")
local BNET_CLIENT_WOWC = "WoV"

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Friends", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.FriendsPoint))
	Stat:SetAllPoints(Text)
	
--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--
	
	-- create a popup for bn broadcast/推送戰網廣播
	StaticPopupDialogs.SET_BN_BROADCAST = {
		text = BN_BROADCAST_TOOLTIP,
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		editBoxWidth = 350,
		maxLetters = 127,
		OnAccept = function(self)
			BNSetCustomMessage(self.editBox:GetText())
		end,
		OnShow = function(self)
			self.editBox:SetText(select(4, BNGetInfo()))
			self.editBox:SetFocus()
		end,
		OnHide = ChatEdit_FocusActiveWindow,
		EditBoxOnEnterPressed = function(self)
			BNSetCustomMessage(self:GetText())
			self:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		hideOnEscape = 1
	}

--[[ custom api for add title line ]]--
local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text)
		title = true
	end
end

--===========================--=======================--
---------------    [[ Build Table ]]     ---------------
--=========================================--=========--

local function sortFriends(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

local function buildFriendTable(num)
	wipe(friendTable)

	for i = 1, num do
		local info = C_FriendList.GetFriendInfoByIndex(i)
		
		if info and info.connected then
			local status = FRIENDS_TEXTURE_ONLINE
			if info.afk then
				status = G.AFK
			elseif info.dnd then
				status = G.DND
			else
				status = " "
			end
			
			local class = F.ClassList[info.className]
			
			tinsert(friendTable, {info.name, info.level, class, info.area, status})
		end
	end

	sort(friendTable, sortFriends)
end

local function sortBNFriends(a, b)
	if a[5] and b[5] then
		return a[5] > b[5]
	end
end

local function GetOnlineInfoText(client, isMobile, locationText)
	if not locationText or locationText == "" then
		return UNKNOWN
	end
	if isMobile then
		--return LOCATION_MOBILE_APP
		return L.Mobile
	else
		return L.Desktop
	end
	
	return locationText
end

local function buildBNetTable(num)
	wipe(bnetTable)

	for i = 1, num do
		local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
		if accountInfo then
			local accountName = accountInfo.accountName
			local battleTag = accountInfo.battleTag
			local isAFK = accountInfo.isAFK
			local isDND = accountInfo.isDND

			local gameAccountInfo = accountInfo.gameAccountInfo
			local isOnline = gameAccountInfo.isOnline
			local gameID = gameAccountInfo.gameAccountID

			if isOnline and gameID then
				local charName = gameAccountInfo.characterName
				local client = gameAccountInfo.clientProgram
				local class = gameAccountInfo.className or UNKNOWN
				local zoneName = gameAccountInfo.areaName or UNKNOWN
				local level = gameAccountInfo.characterLevel
				local gameText = gameAccountInfo.richPresence or ""
				local isGameAFK = gameAccountInfo.isGameAFK
				local isGameBusy = gameAccountInfo.isGameBusy
				local wowProjectID = gameAccountInfo.wowProjectID
				local isMobile = gameAccountInfo.isWowMobile

				charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
				class = F.ClassList[class]

				local status = FRIENDS_TEXTURE_ONLINE
				if isAFK or isGameAFK then
					status = G.AFK
				elseif isDND or isGameBusy then
					status = G.DND
				else
					status = ""
				end
				
				local infoText
				if client == BNET_CLIENT_WOW then
					if ( not zoneName or zoneName == "" ) then
						infoText = UNKNOWN
					else
						infoText = zoneName
					end
				elseif client == BNET_CLIENT_APP then
					if isMobile then
						infoText = L.App
					else
						if client == "BSAp" then
							infoText = L.Mobile
						else
							infoText = L.Desktop
						end
					end
				else
					if gameText == "" then
						infoText = UNKNOWN
					else
						infoText = gameText
					end
				end

				if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then
					client = BNET_CLIENT_WOWC
				end
				-- 戰網，TAG，名字，程式，狀態，職業，等級，地點，魔獸好戰友
				tinsert(bnetTable, {i, accountName, battleTag, charName, client, status, class, level, infoText, isMobile})
			end
		end
	end

	sort(bnetTable, sortBNFriends)
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function OnEvent(self, event, ...)
	local onlineFriends = C_FriendList.GetNumOnlineFriends()
	local _, numBNetOnline = BNGetNumFriends()
	
	-- refresh when online and offline / 上下線時強制更新
	if event == "CHAT_MSG_SYSTEM" then
		local message = select(1, ...)
		if not (string.find(message, friendOnline) or string.find(message, friendOffline)) then return end
	end

	Text:SetText(F.addIcon(G.Friends, 16, 0, 50)..format("%d", onlineFriends + numBNetOnline))
	self:SetAllPoints(Text)
end

local function OnEnter(self)
	local isShiftKeyDown = IsShiftKeyDown()
	local numberOfFriends = C_FriendList.GetNumFriends()
	local onlineFriends = C_FriendList.GetNumOnlineFriends()
	local totalBNet, numBNetOnline = BNGetNumFriends()
	
	local totalonline = onlineFriends + numBNetOnline
	local totalfriends = numberOfFriends + totalBNet
	
	local currentBroadcast = select(4, BNGetInfo(1))
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(FRIEND, format("%s/%s", totalonline, totalfriends), 0, .6, 1, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- show my BN roadcast
	if currentBroadcast and currentBroadcast ~= "" then
		GameTooltip:AddLine(BATTLENET_BROADCAST)
		GameTooltip:AddLine(G.OptionColor..currentBroadcast, .6, .8, 1)
	end
	
	if onlineFriends > 0 then
		buildFriendTable(numberOfFriends)
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("WOW")
		
		for i = 1, #friendTable do
			local info = friendTable[i]

			if info[5] then
				local zonec
				if GetRealZoneText() == info[4] then
					zonec = F.Hex(.3, 1, .3)
				else
					zonec = F.Hex(.65, .65, .65)
				end
				
				local levelc = F.Hex(GetQuestDifficultyColor(info[2]))
				local classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]])
				
				if classc == nil then
					classc = levelc
				end
				
				GameTooltip:AddDoubleLine(levelc..info[2].."|r "..classc..info[1].." |r"..info[5], zonec..info[4])
			end
		end
	end
	
	if numBNetOnline > 0 then
		buildBNetTable(totalBNet)
		
		title = false
		for i = 1, #bnetTable do
			local info = bnetTable[i]
			
			if F.Multicheck(info[5], BNET_CLIENT_WOW, BNET_CLIENT_WOWC) then
				addTitle("WoW")
				
				local zonec
				if GetRealZoneText() == info[8] then
					zonec = F.Hex(.3, 1, .3)
				else
					zonec = F.Hex(.65, .65, .65)
				end
				
				local levelc = F.Hex(GetQuestDifficultyColor(info[8]))
				local classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[7]])
			
				if classc == nil then
					classc = levelc
				end
				
				if info[5] == BNET_CLIENT_WOW then
					GameTooltip:AddDoubleLine(F.addIcon(BNet_GetClientTexture(BNET_CLIENT_WOW), 14, 4, 46)..levelc..info[8].."|r "..classc..info[4].."|r"..info[6]..G.OptionColor.." ("..info[3]..")|r", zonec..info[9])
				elseif info[5] == BNET_CLIENT_WOWC then
					local icon = "|T"..BNet_GetClientTexture(BNET_CLIENT_WOW)..":14:14:0:0:50:50:4:46:4:46:180:180:180|t"
					GameTooltip:AddLine(icon..levelc..info[8].."|r "..classc..info[4].."|r"..info[6]..G.OptionColor.." ("..info[3]..")|r")
				end
			end
		end
		
		title = false
		for i = 1, #bnetTable do
			local info = bnetTable[i]
			--號 戰網，TAG，名字，程式，狀態，職業，等級，地點，魔獸好戰友
			if F.Multicheck(info[5], "S2", "D3", "WTCG", "Hero", "Pro", "S1", "DST2", "VIPR", "ODIN", "W3") then
				addTitle(OTHER)
				if isShiftKeyDown then
					GameTooltip:AddDoubleLine(F.addIcon(BNet_GetClientTexture(info[5]), 14, 4, 46)..G.OptionColor..info[3].."|r"..info[6], F.Hex(.65, .65, .65)..info[9])
				else
					GameTooltip:AddDoubleLine(F.addIcon(BNet_GetClientTexture(info[5]), 14, 4, 46)..G.OptionColor..info[4].."|r"..info[6], F.Hex(.65, .65, .65)..info[9])
				end
			end
		end
		
		title = false
		for i = 1, #bnetTable do
			local info = bnetTable[i]
			
			if F.Multicheck(info[5], "App", "BSAp") then
				addTitle("Battle.Net")
				if isShiftKeyDown then
					GameTooltip:AddDoubleLine(F.addIcon(BNet_GetClientTexture(BNET_CLIENT_APP), 14, 4, 46)..G.OptionColor..info[3].."|r"..info[6], F.Hex(.65, .65, .65)..info[9])
				else
					GameTooltip:AddDoubleLine(F.addIcon(BNet_GetClientTexture(BNET_CLIENT_APP), 14, 4, 46)..G.OptionColor..info[4].."|r"..info[6], F.Hex(.65, .65, .65)..info[9])
				end
			end
		end
	end
	
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..FRIEND..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..BATTLENET_BROADCAST..G.RightButton)

	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
			return
		end
		
		--if button ~= "LeftButton" then return end
		if button == "LeftButton" then
			ToggleFriendsFrame()
		elseif button == "RightButton" then
			StaticPopup_Show("SET_BN_BROADCAST")
		else
			return
		end
	end)
	
	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	Stat:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("CHAT_MSG_SYSTEM")
	Stat:SetScript("OnEvent", OnEvent)