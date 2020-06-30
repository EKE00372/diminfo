local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Friends then return end

local LibQTip = LibStub('LibQTip-1.0')
local format, sort, wipe = format, sort, wipe
local CreateFrame = CreateFrame
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_FriendList_GetNumOnlineFriends, BNGetNumFriends = C_FriendList.GetNumOnlineFriends, BNGetNumFriends

local title	-- Custom line
local friendTable, bnetTable = {}, {}	-- build table
local friendOnline = gsub(ERR_FRIEND_ONLINE_SS, ".+h", "")	-- get string
local friendOffline = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")
local BNET_CLIENT_WOWC = "WoC"	-- custom string for classic

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

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

--[[ Custom api for add title line ]]--
local function addLine(tooltip)
	if not title then
		tooltip:AddSeparator(2, .6, .8, 1)
		title = true
	end
end

--[[ Click function for in-game friends ]]--
local function gameOnClick(self, info, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			-- In-game invite / 遊戲內邀請
			InviteToGroup(info[1])
		elseif IsShiftKeyDown() then
			-- In-game msg / 遊戲內密語
			ChatFrame_OpenChat("/w "..info[1].." ", SELECTED_DOCK_FRAME)
		else
			return
		end
	end
end

--[[ Click function for bn friends ]]--
local function bnOnClick(self, info, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			-- BN invite / 戰網邀請
			if info[5] == BNET_CLIENT_WOW then
				InviteToGroup(info[4].."-"..info[10])
			end
		elseif IsShiftKeyDown() then
			-- BN msg / 戰網聊天
			ChatFrame_SendBNetTell(info[2])
		else
			return
		end
	end
end

--====================================================--
---------------    [[ Build Table ]]     ---------------
--====================================================--

--[[ Sort in-game friends by level ]] --
local function sortFriends(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

--[[ Build in-game friend table ]]--
local function buildFriendTable(num)
	wipe(friendTable)

	for i = 1, num do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		
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
			
			-- name, level, class, area, status / 名字，等級，職業，地區，狀態
			tinsert(friendTable, {info.name, info.level, class, info.area, status})
		end
	end

	sort(friendTable, sortFriends)
end

--[[ Sort BN friends by client ]] --
local function sortBNFriends(a, b)
	if a[5] and b[5] then
		return a[5] > b[5]
	end
end

--[[ Build BN friends table ]]--
local function buildBNetTable(num)
	wipe(bnetTable)

	for i = 1, num do
		local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
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
				local realmName = gameAccountInfo.realmName or ""
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
					-- Print area when friend is playing wow / 玩魔獸顯示地區
					if ( not zoneName or zoneName == "" ) then
						infoText = UNKNOWN
					else
						infoText = zoneName
					end
				elseif client == BNET_CLIENT_APP then
					-- Print moblie instead app name because it's a long string / 魔獸好戰友太囉嗦了
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
					-- Print currently activity when frined is playing other games / 玩其他遊戲顯示狀態
					if gameText == "" then
						infoText = UNKNOWN
					else
						infoText = gameText
					end
				end
				
				-- Check classic or retail / 區分經典和正式
				if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then
					client = BNET_CLIENT_WOWC
				end
				
				--number - bn, tag, name, client, status, class, level, aera, app / 編號 - 戰網，TAG，名字，程式，狀態，職業，等級，地點，魔獸好戰友
				tinsert(bnetTable, {i, accountName, battleTag, charName, client, status, class, level, infoText, realmName, isMobile})
			end
		end
	end

	sort(bnetTable, sortBNFriends)
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function OnEvent(self, event, ...)
	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, numBNetOnline = BNGetNumFriends()
	local online = onlineFriends + numBNetOnline
	
	-- Refresh when online and offline / 上下線時強制更新
	if event == "CHAT_MSG_SYSTEM" then
		local message = select(1, ...)
		if not (string.find(message, friendOnline) or string.find(message, friendOffline)) then return end
	end

	Text:SetText(online)
	self:SetAllPoints(Text)
end

local function OnEnter(self)
	-- Get local
	local isShiftKeyDown = IsShiftKeyDown()
	local numberOfFriends = C_FriendList.GetNumFriends()
	local onlineFriends = C_FriendList.GetNumOnlineFriends()
	local totalBNet, numBNetOnline = BNGetNumFriends()
	-- Get total
	local totalonline = onlineFriends + numBNetOnline
	local totalfriends = numberOfFriends + totalBNet
	-- Get what ur murmuring
	local currentBroadcast = select(4, BNGetInfo(1))
	
	-- Create qtip
	local tooltip = LibQTip:Acquire("KiminfoFriendsTooltip", 2, "LEFT", "RIGHT")
	tooltip:SetPoint(C.StickTop and "TOP" or "BOTTOM", self, C.StickTop and "BOTTOM" or "TOP", 0, C.StickTop and -10 or 10)
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..FRIENDS, G.TitleColor..format("%s/%s", totalonline, totalfriends))

	-- Show my BN roadcast
	if currentBroadcast and currentBroadcast ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine(BATTLENET_BROADCAST)
		
		-- Update width automatically
		local width
		if tooltip:GetWidth() > 200 then
			width = tooltip:GetWidth() + 100
		else
			width = 300
		end

		local y, x = tooltip:AddLine()
		tooltip:SetCell(y, 1, G.OptionColor..format(currentBroadcast), nil, "LEFT", 2, nil, 0, 0, width)
	end
	
	-- Options
	tooltip:AddLine(" ", G.Line)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..SLASH_WHISPER2:gsub("/(.*)","%1"), G.OptionColor..FRIENDS..G.LeftButton)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Alt "..INVITE, G.OptionColor..BATTLENET_BROADCAST..G.RightButton)

	-- In-game online friends list
	if onlineFriends > 0 then
		buildFriendTable(numberOfFriends)
		
		tooltip:AddLine(" ")
		tooltip:AddLine(GAME, ZONE)
		
		title = false
		for i = 1, #friendTable do
			local info = friendTable[i]
			addLine(tooltip)
			
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
			
			tooltip:AddLine(levelc..info[2].."|r "..classc..info[1].."|r"..info[5], zonec..info[4])
			
			local line = tooltip:GetLineCount()
			tooltip:SetLineScript(line, "OnMouseUp", gameOnClick, info)
		end
	end
	
	-- BN online friends list
	if numBNetOnline > 0 then
		buildBNetTable(totalBNet)
		
		tooltip:AddLine(" ")
		tooltip:AddLine(NAME, ZONE)
		
		title = false
		for i = 1, #bnetTable do
			local info = bnetTable[i]
			addLine(tooltip)
			
			if F.Multicheck(info[5], BNET_CLIENT_WOW, BNET_CLIENT_WOWC) then
				local zonec
				if GetRealZoneText() == info[9] then
					zonec = F.Hex(.3, 1, .3)
				else
					zonec = F.Hex(.65, .65, .65)
				end
				
				local levelc = F.Hex(GetQuestDifficultyColor(info[8]))
				local classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[7]])
			
				if classc == nil then
					classc = levelc
				end
				
				local icon
				if info[5] == BNET_CLIENT_WOW then
					icon = F.addIcon(BNet_GetClientTexture(BNET_CLIENT_WOW), 14, 4, 46)
				else
					icon = "|T"..BNet_GetClientTexture(BNET_CLIENT_WOW)..":14:14:0:0:50:50:4:46:4:46:160:160:160|t"
				end
				
				if isShiftKeyDown then
					tooltip:AddLine(icon.." "..levelc..info[8].."|r "..classc..info[4].."|r"..info[6]..G.OptionColor.." ("..info[3]..")", zonec..info[9])
				else
					tooltip:AddLine(icon.." "..levelc..info[8].."|r "..classc..info[4].."|r"..info[6]..G.OptionColor.." ("..info[2]..")", zonec..info[9])
				end
			else
				if isShiftKeyDown then
					tooltip:AddLine(F.addIcon(BNet_GetClientTexture(info[5]), 14, 4, 46).." "..G.OptionColor..info[3].."|r"..info[6], F.Hex(.65, .65, .65)..info[9])
				else
					tooltip:AddLine(F.addIcon(BNet_GetClientTexture(info[5]), 14, 4, 46).." "..G.OptionColor..info[4].."|r"..info[6], F.Hex(.65, .65, .65)..info[9])
				end
			end
			
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

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", function(self)
		-- 先清除舊的tooltip，相當於重設一次，以避免重新指向stat的時候如果tooltip還沒隱藏可能出現的問題......大概吧
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
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
			return
		end
		
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