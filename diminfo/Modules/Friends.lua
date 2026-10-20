local _, ns = ...
local C, F, G, L = unpack(ns)
if not C.Friends then return end

local format, sort, wipe = string.format, table.sort, wipe
local CreateFrame = CreateFrame
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local BNGetFriendInfo, BNGetGameAccountInfo, BNGetNumFriends = BNGetFriendInfo, BNGetGameAccountInfo, BNGetNumFriends
local C_FriendList_GetNumFriends, C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumFriends, C_FriendList.GetNumOnlineFriends

local friendTable, bnetTable = {}, {}	-- build table
local friendOnline = gsub(ERR_FRIEND_ONLINE_SS, ".+h", "")	-- get string
local friendOffline = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")
local BNET_CLIENT_WOWC = "WoC"	-- custom string for classic
local zoneColor = F.Hex(.3, 1, .3)
local mutedColor = F.Hex(.65, .65, .65)

local ClassList = {}
for class, name in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	ClassList[name] = class
end
for class, name in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	ClassList[name] = class
end

local function Multicheck(check, ...)
	for i = 1, select("#", ...) do
		if check == select(i, ...) then return true end
	end
	return false
end

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Friends", UIParent, "HorizontalLayoutFrame")
	F.RegisterModule("Friends", Stat, 0)

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text.layoutIndex = 1
	Text.align = "center"
	
--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--
	
--[[ create a popup for bn broadcast / 推送戰網廣播 ]]--
StaticPopupDialogs.SET_BN_BROADCAST = {
	text = BN_BROADCAST_TOOLTIP,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	
	OnAccept = function(self)
		if BNFeaturesEnabled() and BNConnected() then
			C_BattleNet.SetCustomMessage(self:GetEditBox():GetText())
		end
	end,
	
	OnShow = function(self)
		local currentBroadcast = ""
		if BNFeaturesEnabled() and BNConnected() then
			currentBroadcast = select(4, BNGetInfo()) or ""
		end
		self:GetEditBox():SetText(currentBroadcast)
		self:GetEditBox():SetFocus()
	end,
	
	OnHide = ChatFrameUtil.FocusActiveWindow,
	
	EditBoxOnEnterPressed = function(self)
		if BNFeaturesEnabled() and BNConnected() then
			C_BattleNet.SetCustomMessage(self:GetText())
		end
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

local function getStatus(isAFK, isDND, defaultStatus)
	if isAFK then
		return G.AFK
	elseif isDND then
		return G.DND
	end
	return defaultStatus
end

-- 普通好友保留姓名後的空白；戰網維持原來的薩滿藍色與缺職業時的灰色。
local function getCharacterText(name, level, class, status, isBNet)
	local nameColor
	if isBNet and class == "SHAMAN" then
		nameColor = F.Hex(0, .6, 1)
	elseif isBNet and class == nil then
		nameColor = mutedColor
	else
		nameColor = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class])
	end

	local text = nameColor..name..(isBNet and "|r" or " |r")..status
	if level then
		text = F.Hex(GetQuestDifficultyColor(level))..level.."|r "..text
	end
	return text
end

local function getLocationText(area, currentZone)
	return (area == currentZone and zoneColor or mutedColor)..area
end

--[[ Click function for bn friends ]]--
local function bnOnClick(self, info, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			-- Only invite same realm friends / 同服才有戰網邀請
			if info.client == BNET_CLIENT_WOWC and info.realmName == GetRealmName() and info.characterName and info.characterName ~= "" then
				InviteToGroup(info.characterName)
			end
		elseif IsShiftKeyDown() then
			-- BN msg / 戰網聊天
			ChatFrameUtil.SendBNetTell(info.accountName)
		end
	end
end

--[[ Click function for in-game friends ]]--
local function gameOnClick(self, info, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			-- In-game invite / 遊戲內邀請
			InviteToGroup(info.name)
		elseif IsShiftKeyDown() then
			-- In-game msg / 遊戲內密語
			ChatFrameUtil.OpenChat("/w "..info.name.." ", SELECTED_DOCK_FRAME)
		end
	end
end

--===========================--=======================--
---------------    [[ Build Table ]]     ---------------
--====================================================--

--[[ Sort in-game friends by name ]] --

local function sortFriends(a, b)
	return a.name < b.name
end

--[[ Build in-game friend table ]]--
local function buildFriendTable(num, currentZone)
	wipe(friendTable)

	for i = 1, num do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		
		if info and info.connected then
			local status = getStatus(info.afk, info.dnd, " ")
			local class = ClassList[info.className]
			local area = info.area or ""
			
			tinsert(friendTable, {
				name = info.name,
				nameText = getCharacterText(info.name, info.level, class, status),
				locationText = getLocationText(area, currentZone),
			})
		end
	end

	sort(friendTable, sortFriends)
end

--[[ Sort BN friends by client ]] --
local function sortBNFriends(a, b)
	if a.client and b.client then
		return a.client < b.client
	end
end

--[[ Build BN friends table ]]--
local function buildBNetTable(num, currentZone)
	wipe(bnetTable)

	for i = 1, num do
		local _, accountName, battleTag, _, charName, gameID, _, isOnline, _, isAFK, isDND = BNGetFriendInfo(i)
		if isOnline then
			local _, _, client, realmName, _, _, _, class, _, zoneName, level, gameText, _, _, _, _, _, isGameAFK, isGameBusy, _, wowProjectID = BNGetGameAccountInfo(gameID)

			local hasCharacterInfo = charName and charName ~= "" and type(level) == "number"
			class = ClassList[class]
			local accountLabel = accountName
			if not accountLabel or accountLabel == "" then
				accountLabel = BNet_GetValidatedCharacterName(charName, battleTag, client) or UNKNOWN
			end
			local tagLabel = battleTag ~= "" and battleTag or accountLabel

			local status = getStatus(isAFK or isGameAFK, isDND or isGameBusy, "")
			local infoText
			-- infotext
			if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID and hasCharacterInfo then
				if not zoneName or zoneName == "" then
					infoText = UNKNOWN
				else
					infoText = zoneName
				end
			elseif client == BNET_CLIENT_APP then
				infoText = L.Desktop
			else
				if not gameText or gameText == "" then
					infoText = UNKNOWN
				else
					infoText = gameText
				end
			end
			
			if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
				client = BNET_CLIENT_WOWC
			end
			
			local group, icon, nameText, shiftNameText, locationText, shiftLocationText
			if Multicheck(client, BNET_CLIENT_WOW, BNET_CLIENT_WOWC) then
				group = 1
				local name = BNet_GetValidatedCharacterName(charName, battleTag, BNET_CLIENT_WOW) or accountLabel
				local characterText = getCharacterText(name, hasCharacterInfo and level or nil, class, status, true)
				nameText = characterText..G.OptionColor.." ("..accountLabel..")"
				shiftNameText = characterText..G.OptionColor.." ("..tagLabel..")"
				locationText = getLocationText(infoText, currentZone)
				shiftLocationText = locationText
				if client == BNET_CLIENT_WOWC then
					icon = BNet_GetClientEmbeddedAtlas(BNET_CLIENT_WOW, 14, 14)
					if hasCharacterInfo and realmName and realmName ~= "" then
						shiftLocationText = locationText.." - "..realmName
					end
				else
					icon = CreateAtlasMarkup(BNet_GetClientAtlas("UI-ChatIcon-", BNET_CLIENT_WOW), 14, 14, 0, 0, 160, 160, 160)
				end
			else
				if Multicheck(client, "S2", "D3", "WTCG", "Hero", "Pro", "S1", "DST2", "VIPR", "ODIN", "W3") then
					group = 2
				elseif Multicheck(client, "App", "BSAp") then
					group = 3
				end
				if group then
					icon = BNet_GetClientEmbeddedAtlas(client, 14, 14)
					nameText = G.OptionColor..accountLabel.."|r"..status
					shiftNameText = G.OptionColor..tagLabel.."|r"..status
					locationText = mutedColor..infoText
					shiftLocationText = locationText
				end
			end

			-- Keep the original character name for invitations; rich presence may have no character details.
			tinsert(bnetTable, {
				accountName = accountName,
				characterName = charName,
				client = client,
				realmName = realmName,
				group = group,
				icon = icon,
				nameText = nameText,
				shiftNameText = shiftNameText,
				locationText = locationText,
				shiftLocationText = shiftLocationText,
			})
		end
	end

	sort(bnetTable, sortBNFriends)
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function RenderFriendsPanel(self)
	-- Get local
	local isShiftKeyDown = self.isShiftDown
	local numberOfFriends = C_FriendList_GetNumFriends()
	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local totalBNet, numBNetOnline = BNGetNumFriends()
	-- Get total
	local totalonline = onlineFriends + numBNetOnline
	local totalfriends = numberOfFriends + totalBNet
	local currentZone = GetRealZoneText()
	-- Get what ur murmuring
	local currentBroadcast = ""
	if BNFeaturesEnabled() and BNConnected() then
		currentBroadcast = select(4, BNGetInfo()) or ""
	end

	local tooltip = self.panel
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..FRIENDS, G.TitleColor..format("%s/%s", totalonline, totalfriends))
	
	-- Show my BN roadcast
	if currentBroadcast ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine(BATTLENET_BROADCAST)
		
		tooltip:AddText(G.OptionColor..currentBroadcast)
	end
	
	-- Options
	tooltip:AddLine(" ", G.Line)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..L.Whisper, G.OptionColor..FRIENDS..G.LeftButton)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Alt "..INVITE, G.OptionColor..BATTLENET_BROADCAST..G.RightButton)

	-- In-game online friends list
	if onlineFriends > 0 then
		buildFriendTable(numberOfFriends, currentZone)
		
		tooltip:AddLine(" ")
		tooltip:AddLine(GAME, ZONE)
		tooltip:AddSeparator(2, .6, .8, 1)
		
		for i = 1, #friendTable do
			local info = friendTable[i]
			tooltip:AddRow({info.nameText, info.locationText}, info, gameOnClick)
		end
	end
	
	-- BN online friends list
	if numBNetOnline > 0 then
		buildBNetTable(totalBNet, currentZone)

		tooltip:AddLine(" ")
		tooltip:AddLine(NAME, ZONE)
		tooltip:AddSeparator(2, .6, .8, 1)
		
		-- 維持魔獸、其他遊戲、應用程式三群及各群原本的 client 排序。
		for group = 1, 3 do
			for i = 1, #bnetTable do
				local info = bnetTable[i]
				if info.group == group then
					local nameText = isShiftKeyDown and info.shiftNameText or info.nameText
					local locationText = isShiftKeyDown and info.shiftLocationText or info.locationText
					tooltip:AddRow({info.icon.." "..nameText, locationText}, info, bnOnClick)
				end
			end
		end
	end
	
	tooltip:Layout()
end

local function OnEvent(self, event, ...)
	-- Refresh when online and offline / 上下線時強制更新
	if event == "CHAT_MSG_SYSTEM" then
		local message = select(1, ...)
		if not (string.find(message, friendOnline) or string.find(message, friendOffline)) then return end
	end

	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, numBNetOnline = BNGetNumFriends()
	Text:SetText(format(C.ClassColor and F.Hex(G.Ccolors)..FRIENDS.." |r".."%d" or FRIENDS.." %d", onlineFriends + numBNetOnline))
	self:Layout()
	if self.panel and self.panel:IsShown() then
		RenderFriendsPanel(self)
	end
end

local function OnEnter(self)
	if not self.panel then
		self.panel = F.CreateInfoPanel(self, {{justify = "LEFT"}, {justify = "RIGHT"}})
	end
	-- 只有重新移入時取樣；名單事件不因按住 Shift 密語而改換顯示模式。
	self.isShiftDown = IsShiftKeyDown()
	RenderFriendsPanel(self)
	self.panel:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			securecall(ToggleFriendsFrame, 1)
		elseif button == "RightButton" then
			if BNFeaturesEnabled() and BNConnected() then
				StaticPopup_Show("SET_BN_BROADCAST")
			end
		end
	end)
	
	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	Stat:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	Stat:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	Stat:RegisterEvent("BN_CONNECTED")
	Stat:RegisterEvent("BN_DISCONNECTED")
	Stat:RegisterEvent("BN_CUSTOM_MESSAGE_CHANGED")
	Stat:RegisterEvent("BN_CUSTOM_MESSAGE_LOADED")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("CHAT_MSG_SYSTEM")
	Stat:SetScript("OnEvent", OnEvent)