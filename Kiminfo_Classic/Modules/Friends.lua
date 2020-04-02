local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Friends then return end

local LibQTip = LibStub('LibQTip-1.0')
local format = string.format
local sort = table.sort
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

-- Click function for bn friends
local function bnOnClick(self, info, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			-- 同服才有戰網邀請
			if info[6] == BNET_CLIENT_WOWC and info[7] == GetRealmName() then
				InviteToGroup(info[4])
			else 
				return
			end
		elseif IsShiftKeyDown() then
			-- 戰網聊天
			ChatFrame_SendBNetTell(info[2])
		else
			return
		end
	end
end

-- Click function for in-game friends
local function gameOnClick(self, info, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			-- 遊戲好友邀請
			InviteToGroup(info[1])
		elseif IsShiftKeyDown() then
			-- 遊戲內密語
			ChatFrame_OpenChat("/w "..info[1].." ", SELECTED_DOCK_FRAME)
		else
			return
		end
	end
end

--====================================================--
---------------    [[ Build Table ]]     ---------------
--====================================================--

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
	if a[6] and b[6] then
		return a[6] < b[6]
	end
end

local function buildBNetTable(num)
	wipe(bnetTable)

	for i = 1, num do
		local _, accountName, battleTag, _, charName, gameID, _, isOnline, _, isAFK, isDND = BNGetFriendInfo(i)
		if isOnline then
			local _, _, client, realmName, _, _, _, class, _, zoneName, level, gameText, _, _, _, _, _, isGameAFK, isGameBusy, _, wowProjectID = BNGetGameAccountInfo(gameID)

			charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
			class = F.ClassList[class]

			local status, infoText
			-- status
			if isAFK or isGameAFK then
				status = G.AFK
			elseif isDND or isGameBusy then
				status = G.DND
			else
				status = ""
			end
			-- infotext
			if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
				if not zoneName or zoneName == "" then
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
			
			if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_CLASSIC then
				client = BNET_CLIENT_WOWC
			end

			tinsert(bnetTable, {i, accountName, battleTag, charName, gameID, client, realmName, status, class, level, infoText})
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
	local online = onlineFriends + numBNetOnline
	
	-- refresh when online and offline / 上下線時強制更新
	if event == "CHAT_MSG_SYSTEM" then
		local message = select(1, ...)
		if not (string.find(message, friendOnline) or string.find(message, friendOffline)) then return end
	end
	
	Text:SetText(online)
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
	
	local tooltip = LibQTip:Acquire("KiminfoFriendsTooltip", 2, "LEFT", "RIGHT")
	tooltip:SetPoint("TOP", self, "BOTTOM", 0, -10)
	tooltip:Clear()
	tooltip:AddHeader(G.TitleColor..FRIENDS, G.TitleColor..format("%s/%s", totalonline, totalfriends))

	-- show my BN roadcast
	if currentBroadcast and currentBroadcast ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine(BATTLENET_BROADCAST)
		
		local width
		if tooltip:GetWidth() > 200 then
			width = tooltip:GetWidth() + 100
		else
			width = 300
		end

		local y, x = tooltip:AddLine()
		tooltip:SetCell(y, 1, G.OptionColor..format(currentBroadcast), nil, "LEFT", 2, nil, 0, 0, width)
	end
	
	-- options
	tooltip:AddLine(" ", G.Line)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Shift "..SLASH_WHISPER2:gsub("/(.*)","%1"), G.OptionColor..FRIENDS..G.LeftButton)
	tooltip:AddLine(G.OptionColor..G.LeftButton.."+ Alt "..INVITE, G.OptionColor..BATTLENET_BROADCAST..G.RightButton)
	
	if onlineFriends > 0 then
		buildFriendTable(numberOfFriends)
		
		tooltip:AddLine(" ")
		tooltip:AddLine(GAME, ZONE)
		tooltip:AddSeparator(2, .6, .8, 1)
		
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
				
				tooltip:AddLine(levelc..info[2].."|r "..classc..info[1].."|r"..info[5], zonec..info[4])
				
				local line = tooltip:GetLineCount()
				tooltip:SetLineScript(line, "OnMouseUp", gameOnClick, info)
			end
		end
	end
	
	if numBNetOnline > 0 then
		buildBNetTable(totalBNet)

		tooltip:AddLine(" ")
		tooltip:AddLine(NAME, ZONE)
		tooltip:AddSeparator(2, .6, .8, 1)
		
		for i = 1, #bnetTable do
			local info = bnetTable[i]
			
			if F.Multicheck(info[6], BNET_CLIENT_WOW, BNET_CLIENT_WOWC) then
				local zonec
				if GetRealZoneText() == info[11] then
					zonec = F.Hex(.3, 1, .3)
				else
					zonec = F.Hex(.65, .65, .65)
				end
				
				local levelc = F.Hex(GetQuestDifficultyColor(info[10]))
				
				local classc
				if info[9] == "SHAMAN" then
					classc = F.Hex(0, .6, 1)
				elseif info[9] == nil then
					classc = F.Hex(.65, .65, .65)
				else
					classc = F.Hex((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]])
				end
				
				if info[6] == BNET_CLIENT_WOWC then
					if isShiftKeyDown then
						tooltip:AddLine(F.addIcon(BNet_GetClientTexture(BNET_CLIENT_WOW), 14, 8, 42)..levelc..info[10].."|r "..classc..info[4].."|r"..info[8]..G.OptionColor.." ("..info[3]..")", zonec..info[11].." - "..info[7])
					else
						tooltip:AddLine(F.addIcon(BNet_GetClientTexture(BNET_CLIENT_WOW), 14, 8, 42)..levelc..info[10].."|r "..classc..info[4].."|r"..info[8]..G.OptionColor.." ("..info[2]..")", zonec..info[11])
					end
				else
					local icon = "|T"..BNet_GetClientTexture(BNET_CLIENT_WOW)..":14:14:0:0:50:50:4:46:4:46:160:160:160|t"
					local noRealm = info[11]:match("[^ -]+")
					
					if isShiftKeyDown then
						tooltip:AddLine(icon..levelc..info[10].."|r "..classc..info[4].."|r"..info[8]..G.OptionColor.." ("..info[3]..")", zonec..info[11])
					else
						tooltip:AddLine(icon..levelc..info[10].."|r "..classc..info[4].."|r"..info[8]..G.OptionColor.." ("..info[2]..")", zonec..noRealm)
					end
				end
			end
			
			local line = tooltip:GetLineCount()
			tooltip:SetLineScript(line, "OnMouseUp", bnOnClick, info)
		end
		
		for i = 1, #bnetTable do
			local info = bnetTable[i]

			if F.Multicheck(info[6], "S2", "D3", "WTCG", "Hero", "Pro", "S1", "DST2", "VIPR", "ODIN", "W3") then
				if isShiftKeyDown then
					tooltip:AddLine(F.addIcon(BNet_GetClientTexture(info[6]), 14, 8, 42)..G.OptionColor..info[3].."|r"..info[8], F.Hex(.65, .65, .65)..info[11])
				else
					tooltip:AddLine(F.addIcon(BNet_GetClientTexture(info[6]), 14, 8, 42)..G.OptionColor..info[2].."|r"..info[8], F.Hex(.65, .65, .65)..info[11])
				end
			end
			
			local line = tooltip:GetLineCount()
			tooltip:SetLineScript(line, "OnMouseUp", bnOnClick, info)
		end
		
		for i = 1, #bnetTable do
			local info = bnetTable[i]
			
			if F.Multicheck(info[6], "App", "BSAp") then
				if isShiftKeyDown then
					tooltip:AddLine(F.addIcon(BNet_GetClientTexture(info[6]), 14, 8, 42)..G.OptionColor..info[3].."|r"..info[8], F.Hex(.65, .65, .65)..info[11])
				else
					tooltip:AddLine(F.addIcon(BNet_GetClientTexture(info[6]), 14, 8, 42)..G.OptionColor..info[2].."|r"..info[8], F.Hex(.65, .65, .65)..info[11])
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

-- hide QTip tooltip
local function OnRelease(self)
	LibQTip:Release(self.tooltip)
	self.tooltip = nil  
end

-- Update mouseover tooltip
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