local _, ns = ...
local C, F, G, L = unpack(ns)
if not C.Friends then return end

local LibQTip = LibStub('LibQTip-1.0')
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
local Stat = CreateFrame("Frame", G.addon.."Friends", UIParent)
	Stat:SetHitRectInsets(-30, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create icon ]]--
local Icon = Stat:CreateTexture(nil, "OVERLAY")
	Icon:SetSize(G.FontSize+8, G.FontSize+8)
	Icon:SetPoint("RIGHT", Stat, "LEFT", 0, 0)
	Icon:SetTexture(G.Friends)
	Icon:SetVertexColor(1, 1, 1)
	
--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.FriendsPoint))
	Text:SetTextColor(1, 1, 1)
	Stat:SetAllPoints(Text)
	
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
		-- BN invite / 戰網邀請
		if info.inviteTarget ~= "" then
			InviteToGroup(info.inviteTarget)
		end
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
				local accountName = accountInfo.accountName or ""
				local battleTag = accountInfo.battleTag or ""
				local characterName = gameAccountInfo.characterName or ""
				local client = gameAccountInfo.clientProgram or ""
				local area = gameAccountInfo.areaName or ""
				local realmName = gameAccountInfo.realmName or ""
				local classFilename = gameAccountInfo.classFilename
				if not classFilename or classFilename == "" then
					classFilename = gameAccountInfo.className and classFilenameByLocalizedName[gameAccountInfo.className]
				end

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
				local isSameWoWProject = client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID
				if client == BNET_CLIENT_WOW and wowProjectID and not isSameWoWProject then
					client = BNET_CLIENT_WOWC
				end

				local isWoW = F.Multicheck(client, BNET_CLIENT_WOW, BNET_CLIENT_WOWC)
				local icon
				if isWoW then
					icon = "|T"..GetIconTexture(BNET_CLIENT_WOW)..":14:14:0:0:50:50|t"
					if isSameWoWProject then
						if gameAccountInfo.factionName == "Horde" then
							icon = F.addIcon(G.Horde, 14, 2, 48)
						elseif gameAccountInfo.factionName == "Alliance" then
							icon = F.addIcon(G.Alliance, 14, 2, 48)
						end
					end
				else
					icon = "|T"..GetIconTexture(client)..":14:14:0:0:50:50|t"
				end

				local inviteTarget = ""
				if isSameWoWProject and characterName ~= "" then
					inviteTarget = characterName
					if realmName ~= "" then
						inviteTarget = inviteTarget.."-"..realmName
					end
				end

				local characterText = getCharacterText(displayName, gameAccountInfo.characterLevel, classFilename, status)
				local normalAccount = accountName ~= "" and G.OptionColor.." ("..accountName..")" or ""
				local shiftAccount = battleTag ~= "" and G.OptionColor.." ("..battleTag..")" or normalAccount
				local normalName = displayName
				local shiftName = battleTag ~= "" and battleTag or normalName

				tinsert(bnetTable, {
					accountName = accountName,
					area = area,
					client = client,
					infoText = infoText ~= "" and mutedColor..infoText or "",
					inviteTarget = inviteTarget,
					isWoW = isWoW,
					nameText = isWoW and icon.." "..characterText..normalAccount or icon.." "..G.OptionColor..normalName.."|r"..status,
					regionName = region[gameAccountInfo.regionID] or "",
					shiftNameText = isWoW and icon.." "..characterText..shiftAccount or icon.." "..G.OptionColor..shiftName.."|r"..status,
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

local function OnEnter(self)
	-- Get local
	self.isShiftDown = IsShiftKeyDown()
	local isShiftKeyDown = self.isShiftDown
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

	-- Create qtip
	local tooltip = LibQTip:Acquire("KiminfoFriendsTooltip", 2, "LEFT", "RIGHT")
	tooltip:ClearAllPoints()
	tooltip:SetPoint(C.StickTop and "TOP" or "BOTTOM", self, C.StickTop and "BOTTOM" or "TOP", 0, C.StickTop and -10 or 10)
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..FRIENDS, G.TitleColor..format("%s/%s", totalonline, totalfriends))

	-- Show my BN roadcast
	if currentBroadcast ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine(BATTLENET_BROADCAST)
		
		-- Update width automatically
		local width
		if tooltip:GetWidth() > 200 then
			width = tooltip:GetWidth() + 100
		else
			width = 300
		end

		local y = tooltip:AddLine()
		tooltip:SetCell(y, 1, G.OptionColor..currentBroadcast, nil, "LEFT", 2, nil, 0, 0, width)
	end
	
	-- Options
	tooltip:AddLine(" ", G.Line)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..INVITE, G.OptionColor..FRIENDS..G.LeftButton)
	tooltip:AddLine(G.OptionColor..G.MiddleButton..WHISPER, G.OptionColor..BATTLENET_BROADCAST..G.RightButton)

	-- In-game online friends list
	if onlineFriends > 0 then
		buildFriendTable(numberOfFriends)
		
		tooltip:AddLine(" ")
		tooltip:AddLine(GAME, ZONE)
		tooltip:AddSeparator(2, .6, .8, 1)
		
		for i = 1, #friendTable do
			local info = friendTable[i]
			tooltip:AddLine(info.nameText, getLocationText(info.area, "", currentZone))

			local line = tooltip:GetLineCount()
			tooltip:SetLineScript(line, "OnMouseUp", gameOnClick, info)
		end
	end
	
	-- BN online friends list
	if numBNetOnline > 0 then
		buildBNetTable(totalBNet)
		
		tooltip:AddLine(" ")
		tooltip:AddLine(NAME, ZONE)
		tooltip:AddSeparator(2, .6, .8, 1)
		
		for i = 1, #bnetTable do
			local info = bnetTable[i]
			local nameText = isShiftKeyDown and info.shiftNameText or info.nameText
			local locationText = info.infoText
			if info.isWoW then
				local regionName = isShiftKeyDown and info.regionName or ""
				locationText = getLocationText(info.area, regionName, currentZone)
			end

			tooltip:AddLine(nameText, locationText)

			local line = tooltip:GetLineCount()
			tooltip:SetLineScript(line, "OnMouseUp", bnOnClick, info)
		end
	end
	
	tooltip:UpdateScrolling(600)
	tooltip:Show()
	
	self.tooltip = tooltip
end

--[[ Hide QTip tooltip ]]--
local function OnRelease(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	self:SetScript("OnUpdate", nil)
	self.isShiftDown = nil
	self.timer = nil
	LibQTip:Release(self.tooltip)
	self.tooltip = nil
end

--[[ Update mouseover tooltip ]]--
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed

	if self.timer > .1 then
		if not self:IsMouseOver() and (not self.tooltip or not self.tooltip:IsMouseOver()) then
			OnRelease(self)
			return
		end

		self.timer = 0
	end
end

local function OnEvent(self, event, key)
	if event == "MODIFIER_STATE_CHANGED" then
		local isShiftKey = key == "LSHIFT" or key == "RSHIFT"
		if isShiftKey and self.tooltip and IsShiftKeyDown() ~= self.isShiftDown then
			OnEnter(self)
		end
		return
	end

	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, numBNetOnline = BNGetNumFriends()
	numBNetOnline = numBNetOnline or 0
	local online = onlineFriends + numBNetOnline

	Text:SetText(online)
	self:SetAllPoints(Text)

	if self.tooltip then
		OnEnter(self)
	end
end

--=========================================--
--------------- [[ Scripts ]] ---------------
--=========================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		-- 先清除舊的tooltip，相當於重設一次，以避免重新指向stat的時候如果tooltip還沒隱藏可能出現的問題......大概吧
		OnRelease(self)
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
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