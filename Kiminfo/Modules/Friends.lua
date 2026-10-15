local _, ns = ...
local C, F, G, L = unpack(ns)
if not C.Friends then return end

local GameTooltip = F.Tooltip
local format, sort, wipe = format, sort, wipe
local CreateFrame = CreateFrame
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_FriendList_GetNumOnlineFriends, BNGetNumFriends = C_FriendList.GetNumOnlineFriends, BNGetNumFriends
local InviteToGroup = C_PartyInfo.InviteUnit -- Replace old InviteToGroup()

local friendTable, bnetTable = {}, {}	-- build table
local BNET_CLIENT_WOWC = "WoWC"	-- custom string for classic
local BNET_CLIENT_BSAP = "BSAp"
local region = {[1] = "US", [2] = "KR", [3] = "EU", [4] = "TW", [5] = "CN",}
local normalColor = F.Hex(1, 1, 1)
local zoneColor = F.Hex(.3, 1, .3)
local mutedColor = F.Hex(.65, .65, .65)
local classFilenameByLocalizedName = {}

for classFilename, className in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	classFilenameByLocalizedName[className] = classFilename
end

if LOCALIZED_CLASS_NAMES_FEMALE then
	for classFilename, className in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		classFilenameByLocalizedName[className] = classFilename
	end
end

--=======================================--
--------------- [[ Cache ]] ---------------
--=======================================--

--[[ cache client icon ]]--
local cache = {}
local function GetIconTexture(titleID)
	if cache[titleID] then
		return cache[titleID]
	end

	C_Texture.GetTitleIconTexture(titleID, Enum.TitleIconVersion.Medium, function(success, texture)
		if success then
		cache[titleID] = texture
		end
	end)
	
	return cache[titleID] or "Interface\\CHATFRAME\\UI-ChatIcon-Battlenet"
end

--[[ client list ]]--
local bnet_client = {
	BNET_CLIENT_WOW,	-- WoW
	"WoWC",	-- WoWC/WoW Classic
	"GRY",	-- Warcraft Arclight Rumble
	"W1",	-- Warcraft Orcs & Humans
	"W1R",	-- Warcraft I Remastered
	"W2",	-- Warcraft II Battle.net Edition
	"W2R",	-- Warcraft II Remastered
	"W3",	-- Warcraft III Reforged

	"D1" ,	-- Diablo
	"OSI",	-- Diablo II Resurrected
	"D3",	-- Diablo III
	"Fen",	-- Diablo IV
	"ANBS",	-- Diablo Immortal

	"S1",	-- SC
	"S2" ,	-- SC2
	"WTCG",	-- WTCG
	BNET_CLIENT_APP,	-- Battlenet desktop
	BNET_CLIENT_CLNT,	-- Battlenet client
	BNET_CLIENT_BSAP,	-- Battlenet mobile
	"Hero",	-- HotS
	"Pro",	-- Overwatch
	"DST2",	-- Destiny2
	"RTRO",	-- Blizzard Arcade Collection
	"WLBY",	-- Crash Bandicoot 4

	"AUKS",	-- CallofDuty
	"ZEUS",	-- CallofDuty BlackOpsColdWaricon
	"VIPR",	-- CallOfDuty BlackOps4
	"ODIN",	-- CallOfDuty MWicon
	"LAZR",	-- CallOfDuty MW2icon
	"FORE",	-- CallOfDuty Vanguard
	"SPOT",	-- CallofDuty Modern Warfare III
}

--[[ cache when load ]]--
for _, v in ipairs(bnet_client) do
	GetIconTexture(v)
end

--==========================================--
--------------- [[ Elements ]] ---------------
--==========================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Friends", UIParent, "HorizontalLayoutFrame")

--[[ Create icon ]]--
local Icon = Stat:CreateTexture(nil, "OVERLAY")
	Icon.layoutIndex = 1
	Icon.align = "center"
	Icon:SetSize(G.FontSize+8, G.FontSize+8)
	Icon:SetTexture(G.Friends)
	Icon:SetVertexColor(1, 1, 1)
	
--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 2
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetTextColor(1, 1, 1)
	F.RegisterModule("Friends", Stat)
	
--===========================================--
--------------- [[ Functions ]] ---------------
--===========================================--
	
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
			C_BattleNet.SetCustomMessage(self.EditBox:GetText())
		end
	end,

	OnShow = function(self)
		local currentBroadcast = ""
		if BNFeaturesEnabled() and BNConnected() then
			currentBroadcast = select(4, BNGetInfo()) or ""
		end

		self.EditBox:SetText(currentBroadcast)
		self.EditBox:SetFocus()
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

--[[ Get friend status texture ]]--
local function getStatus(isAFK, isDND, defaultStatus)
	if isAFK then
		return G.AFK
	elseif isDND then
		return G.DND
	end

	return defaultStatus
end

--[[ Build a nil-safe character label ]]--
local function getCharacterText(name, level, classFilename, status)
	local levelColor = normalColor
	local levelText = ""

	if level then
		levelColor = F.Hex(GetQuestDifficultyColor(level))
		levelText = levelColor..level.."|r "
	end

	local classColor
	if classFilename then
		classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFilename]
		classColor = classColor or RAID_CLASS_COLORS[classFilename]
	end

	local nameColor = classColor and F.Hex(classColor) or levelColor
	return levelText..nameColor..name.."|r"..status
end

--[[ Build location text without leaving empty separators ]]--
local function getLocationText(area, regionName, currentZone)
	local location = area

	if regionName ~= "" then
		location = location ~= "" and location.." - "..regionName or regionName
	end

	if location == "" then
		return ""
	end

	local color = area ~= "" and area == currentZone and zoneColor or mutedColor
	return color..location
end

local function getClassFilename(gameAccountInfo)
	local classFilename = gameAccountInfo.classFilename
	if not classFilename or classFilename == "" then
		classFilename = gameAccountInfo.className and classFilenameByLocalizedName[gameAccountInfo.className]
	end
	return classFilename
end

local function getGameIcon(gameAccountInfo)
	local client = gameAccountInfo.clientProgram
	if client == BNET_CLIENT_WOW and gameAccountInfo.wowProjectID == WOW_PROJECT_ID then
		if gameAccountInfo.factionName == "Horde" then
			return F.addIcon(G.Horde, 14, 2, 48)
		elseif gameAccountInfo.factionName == "Alliance" then
			return F.addIcon(G.Alliance, 14, 2, 48)
		end
	end
	return "|T"..GetIconTexture(client)..":14:14:0:0:50:50|t"
end

-- 名單位置會變動，詳細資料與邀請每次都從帳號身分重新定位。
local function getGameAccounts(bnetAccountID)
	local friendIndex = BNGetFriendIndex(bnetAccountID)
	if not friendIndex then return end
	local accountInfo = C_BattleNet_GetFriendAccountInfo(friendIndex)
	if not accountInfo then return end

	local gameAccounts = {}
	for i = 1, C_BattleNet.GetFriendNumGameAccounts(friendIndex) do
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, i)
		if gameAccountInfo and gameAccountInfo.isOnline then
			tinsert(gameAccounts, gameAccountInfo)
		end
	end
	return accountInfo, gameAccounts
end

-- 詳情與角色選單共用完整名稱；主列表維持簡短名稱。
local function getGameAccountLabel(gameAccountInfo, accountInfo)
	local client = gameAccountInfo.clientProgram
	local name = BNet_GetValidatedCharacterName(gameAccountInfo.characterName or "", accountInfo.battleTag, client) or ""
	if name == "" then name = accountInfo.accountName end
	if client == BNET_CLIENT_WOW then
		local realmName = gameAccountInfo.realmName or ""
		if realmName ~= "" then name = name.."-"..realmName end
		name = getCharacterText(name, gameAccountInfo.characterLevel, getClassFilename(gameAccountInfo),
			getStatus(gameAccountInfo.isGameAFK, gameAccountInfo.isGameBusy, ""))
	end
	return getGameIcon(gameAccountInfo).." "..name
end

local function canInviteGameAccount(gameAccountInfo)
	return gameAccountInfo.playerGuid ~= nil
		and FriendsListUtil.GetGameAccountPartyInviteRestriction(gameAccountInfo) == BattleNetFriendPartyInviteRestrictionType.None
end

local function inviteGameAccount(target)
	local _, gameAccounts = getGameAccounts(target.bnetAccountID)
	if not gameAccounts then return end
	for _, gameAccountInfo in ipairs(gameAccounts) do
		if gameAccountInfo.gameAccountID == target.gameAccountID and gameAccountInfo.playerGuid == target.playerGuid then
			if canInviteGameAccount(gameAccountInfo) then
				FriendsListUtil.InviteOrRequestToJoin(gameAccountInfo.playerGuid, gameAccountInfo.gameAccountID)
			end
			return
		end
	end
end

local function gameOnEnter(row, info)
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(info.nameText, 1, 1, 1, true)
	if info.area ~= "" then GameTooltip:AddLine(info.area, 1, 1, 1, true) end
	F.ShowTooltip()
end

local function bnOnEnter(row, info)
	local accountInfo, gameAccounts = getGameAccounts(info.bnetAccountID)
	if not accountInfo then return end
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(accountInfo.accountName ~= "" and accountInfo.accountName or accountInfo.battleTag)
	for _, gameAccountInfo in ipairs(gameAccounts) do
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(getGameAccountLabel(gameAccountInfo, accountInfo), 1, 1, 1, true)
		local location = gameAccountInfo.clientProgram == BNET_CLIENT_WOW and gameAccountInfo.areaName or gameAccountInfo.richPresence
		if location and location ~= "" then GameTooltip:AddLine(location, .65, .65, .65, true) end
	end
	F.ShowTooltip()
end

--[[ Click function for in-game friends ]]--
local function gameOnClick(_, info, btn)
	if info.name == "" then return end

	if btn == "LeftButton" and IsShiftKeyDown() then
		-- In-game invite / 遊戲內邀請
		InviteToGroup(info.name)
	elseif btn == "MiddleButton" then
		-- In-game msg / 遊戲內密語
		ChatFrameUtil.SendTell(info.name, SELECTED_DOCK_FRAME)
	end
end

--[[ Click function for bn friends ]]--
local function bnOnClick(_, info, btn)
	if btn == "LeftButton" and IsShiftKeyDown() then
		local accountInfo, gameAccounts = getGameAccounts(info.bnetAccountID)
		if not accountInfo then return end
		local characters = {}
		for _, gameAccountInfo in ipairs(gameAccounts) do
			if gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
				tinsert(characters, gameAccountInfo)
			end
		end
		if #characters == 0 then return end
		if #characters == 1 and canInviteGameAccount(characters[1]) then
			FriendsListUtil.InviteOrRequestToJoin(characters[1].playerGuid, characters[1].gameAccountID)
			return
		end

		-- 選單隸屬面板，不隨可重用的 row 改綁；選項保存穩定身分。
		local panel = Stat.panel
		panel.menu = MenuUtil.CreateContextMenu(panel, function(_, rootDescription)
			rootDescription:CreateTitle(TRAVEL_PASS_INVITE)
			for _, gameAccountInfo in ipairs(characters) do
				local enabled = canInviteGameAccount(gameAccountInfo)
				local label = getGameAccountLabel(gameAccountInfo, accountInfo)
				if not enabled then label = label..CANNOT_COOPERATE_LABEL end
				local button = rootDescription:CreateButton(label, inviteGameAccount, {
					bnetAccountID = info.bnetAccountID,
					gameAccountID = gameAccountInfo.gameAccountID,
					playerGuid = gameAccountInfo.playerGuid,
				})
				button:SetEnabled(enabled)
			end
		end)
	elseif btn == "MiddleButton" and info.accountName ~= "" then
		-- BN msg / 戰網聊天
		ChatFrameUtil.SendBNetTell(info.accountName, SELECTED_DOCK_FRAME)
	end
end

--=============================================--
--------------- [[ Build Table ]] ---------------
--=============================================--

--[[ Sort in-game friends by name ]] --
local function sortFriends(a, b)
	return a.name < b.name
end

--[[ Build in-game friend table ]]--
local function buildFriendTable(num)
	wipe(friendTable)

	for i = 1, num do
		local info = C_FriendList_GetFriendInfoByIndex(i)

		if info and info.connected then
			local name = info.name or ""
			local area = info.area or ""
			local classFilename = info.className and classFilenameByLocalizedName[info.className]
			local status = getStatus(info.afk, info.dnd, " ")

			tinsert(friendTable, {
				name = name,
				area = area,
				nameText = getCharacterText(name, info.level, classFilename, status),
			})
		end
	end

	sort(friendTable, sortFriends)
end

--[[ Sort BN friends by client ]] --
local function sortBNFriends(a, b)
	if a.client == b.client then
		return a.sortName < b.sortName
	end

	return a.client > b.client
end

--[[ Build BN friends table ]]--
local function buildBNetTable(num)
	wipe(bnetTable)

	for i = 1, num do
		local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
		if accountInfo then
			local gameAccountInfo = accountInfo.gameAccountInfo

			if gameAccountInfo and gameAccountInfo.isOnline and gameAccountInfo.gameAccountID then
				local accountName = accountInfo.accountName
				local battleTag = accountInfo.battleTag
				local characterName = gameAccountInfo.characterName or ""
				local client = gameAccountInfo.clientProgram
				local area = gameAccountInfo.areaName or ""

				local displayName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or ""
				if displayName == "" then
					displayName = accountName
				end

				local status = getStatus(
					accountInfo.isAFK or gameAccountInfo.isGameAFK,
					accountInfo.isDND or gameAccountInfo.isGameBusy,
					""
				)

				local infoText
				if client == BNET_CLIENT_WOW then
					-- Print area when friend is playing WoW / 玩魔獸顯示地區
					infoText = area
				elseif gameAccountInfo.isWowMobile then
					-- Runtime field still used by Blizzard although omitted from API docs.
					infoText = L.App
				elseif client == BNET_CLIENT_BSAP then
					infoText = L.Mobile
				elseif client == BNET_CLIENT_APP or client == BNET_CLIENT_CLNT then
					infoText = L.Desktop
				else
					-- Print current activity when playing other games / 玩其他遊戲顯示狀態
					infoText = gameAccountInfo.richPresence or ""
				end

				-- Check whether the friend is on the same WoW project / 判斷是否為相同魔獸版本
				local wowProjectID = gameAccountInfo.wowProjectID
				local isSameWoWProject = (client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID)
				if client == BNET_CLIENT_WOW and wowProjectID and not isSameWoWProject then
					client = BNET_CLIENT_WOWC
				end

				local isWoW = (client == BNET_CLIENT_WOW or client == BNET_CLIENT_WOWC)
				local nameText, shiftNameText
				if isWoW then
					local characterText = getCharacterText(displayName, gameAccountInfo.characterLevel, getClassFilename(gameAccountInfo), status)
					local normalAccount = accountName ~= "" and G.OptionColor.." ("..accountName..")" or ""
					local shiftAccount = battleTag ~= "" and G.OptionColor.." ("..battleTag..")" or normalAccount
					nameText = characterText..normalAccount
					shiftNameText = characterText..shiftAccount
				else
					local shiftName = battleTag ~= "" and battleTag or displayName
					nameText = G.OptionColor..displayName.."|r"..status
					shiftNameText = G.OptionColor..shiftName.."|r"..status
				end

				tinsert(bnetTable, {
					bnetAccountID = accountInfo.bnetAccountID,
					accountName = accountName,
					area = area,
					client = client,
					infoText = infoText ~= "" and mutedColor..infoText or "",
					icon = getGameIcon(gameAccountInfo),
					isWoW = isWoW,
					nameText = nameText,
					regionName = region[gameAccountInfo.regionID] or "",
					shiftNameText = shiftNameText,
					sortName = accountName ~= "" and accountName or displayName,
				})
			end
		end
	end

	sort(bnetTable, sortBNFriends)
end

--=========================================--
--------------- [[ Updates ]] ---------------
--=========================================--

local function RenderFriendsPanel(self)
	self.isShiftDown = IsShiftKeyDown()
	local isShiftKeyDown = self.isShiftDown
	local panel = self.panel
	panel:Clear()

	local numberOfFriends = C_FriendList.GetNumFriends()
	local onlineFriends = C_FriendList.GetNumOnlineFriends()
	local totalBNet, numBNetOnline = BNGetNumFriends()
	totalBNet = totalBNet or 0
	numBNetOnline = numBNetOnline or 0
	-- Get total
	local totalonline = onlineFriends + numBNetOnline
	local totalfriends = numberOfFriends + totalBNet
	local currentZone = GetRealZoneText()
	-- Get what ur murmuring
	local currentBroadcast = ""
	if BNFeaturesEnabled() and BNConnected() then
		currentBroadcast = select(4, BNGetInfo()) or ""
	end

	panel:AddLine(G.TitleColor..FRIENDS, G.TitleColor..format("%s/%s", totalonline, totalfriends))

	-- Show my BN broadcast
	if currentBroadcast ~= "" then
		panel:AddLine()
		panel:AddLine(BATTLENET_BROADCAST)
		panel:AddText(G.OptionColor..currentBroadcast)
	end
	
	-- Options
	panel:AddLine(" ", G.Line)
	panel:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..INVITE, G.OptionColor..FRIENDS..G.LeftButton)
	panel:AddLine(G.OptionColor..G.MiddleButton..WHISPER, G.OptionColor..BATTLENET_BROADCAST..G.RightButton)

	-- In-game online friends list
	if onlineFriends > 0 then
		buildFriendTable(numberOfFriends)
		
		panel:AddLine()
		panel:AddLine(GAME, ZONE)
		panel:AddSeparator()
		
		for i = 1, #friendTable do
			local info = friendTable[i]
			panel:AddRow({"", info.nameText, getLocationText(info.area, "", currentZone)}, info, gameOnClick, gameOnEnter)
		end
	end
	
	-- BN online friends list
	if numBNetOnline > 0 then
		buildBNetTable(totalBNet)
		
		panel:AddLine()
		panel:AddLine(NAME, ZONE)
		panel:AddSeparator()
		
		for i = 1, #bnetTable do
			local info = bnetTable[i]
			local nameText = isShiftKeyDown and info.shiftNameText or info.nameText
			local locationText = info.infoText
			if info.isWoW then
				local regionName = isShiftKeyDown and info.regionName or ""
				locationText = getLocationText(info.area, regionName, currentZone)
			end

			panel:AddRow({info.icon, nameText, locationText}, info, bnOnClick, bnOnEnter)
		end
	end
	
	panel:Layout()
end

local function OnEvent(self, event, key)
	if event == "MODIFIER_STATE_CHANGED" then
		local isShiftKey = key == "LSHIFT" or key == "RSHIFT"
		if isShiftKey and self.panel and self.panel:IsShown() and IsShiftKeyDown() ~= self.isShiftDown then
			RenderFriendsPanel(self)
		end
		return
	end

	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, numBNetOnline = BNGetNumFriends()
	numBNetOnline = numBNetOnline or 0
	local online = onlineFriends + numBNetOnline

	Text:SetText(online)
	self:Layout()

	if self.panel and self.panel:IsShown() then
		self.panel:CloseMenu()
		RenderFriendsPanel(self)
	end
end

--=========================================--
--------------- [[ Scripts ]] ---------------
--=========================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		-- Mouseover color
		Icon:SetVertexColor(0, 1, 1)
		Text:SetTextColor(0, 1, 1)
		if not self.panel then
			-- 圖示固定 20px；名稱、區域為自然寬，超過面板上限時先縮右欄。
			self.panel = F.CreateInfoPanel(self, {{width = 20}, {}, {justify = "RIGHT"}})
			self.panel:HookScript("OnHide", function()
				self:UnregisterEvent("MODIFIER_STATE_CHANGED")
				self.isShiftDown = nil
			end)
		end
		RenderFriendsPanel(self)
		if not self.panel:IsShown() then
			self:RegisterEvent("MODIFIER_STATE_CHANGED")
			self.panel:Show()
		end
	end)
	
	Stat:SetScript("OnLeave", function()
		-- Normal color
		Icon:SetVertexColor(1, 1, 1)
		Text:SetTextColor(1, 1, 1)
	end)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)		
		if button == "LeftButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
			ToggleFriendsFrame()
		elseif button == "RightButton" then
			if BNFeaturesEnabled() and BNConnected() then
				StaticPopup_Show("SET_BN_BROADCAST")
			end
		else
			return
		end
	end)
	
	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	Stat:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	Stat:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	Stat:RegisterEvent("BN_CONNECTED")
	Stat:RegisterEvent("BN_CUSTOM_MESSAGE_CHANGED")
	Stat:RegisterEvent("BN_CUSTOM_MESSAGE_LOADED")
	Stat:RegisterEvent("BN_DISCONNECTED")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)