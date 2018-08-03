local addon, ns = ...
local cfg = ns.cfg
local init = ns.init
local panel = CreateFrame("Frame", nil, UIParent)

if cfg.Friends == true then
	-- create a popup 戰網廣播
	StaticPopupDialogs.SET_BN_BROADCAST = {
		text = BN_BROADCAST_TOOLTIP,
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		editBoxWidth = 350,
		maxLetters = 127,
		OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
		OnShow = function(self) self.editBox:SetText(select(3, BNGetInfo()) ) self.editBox:SetFocus() end,
		OnHide = ChatEdit_FocusActiveWindow,
		EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
		EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		hideOnEscape = 1
	}

	-- localized references for global functions (about 50% faster)
	local format		= string.format
	local sort			= table.sort

	local Stat = CreateFrame("Frame", "diminfo_Friends")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.FriendsPoint))
	Stat:SetAllPoints(Text)

	-- 狀態判斷
	local function checkStatus()
		local status = {}
		if IsChatDND() then
			status = {false, true, false}
		elseif IsChatAFK() then
			status = {false, false, true}
		else
			status = {true, false, false}
		end
		return status
	end
	
	-- 右鍵選單
	local menuFrame = CreateFrame("Frame", "FriendRightClickMenu", UIParent, "UIDropDownMenuTemplate")
	local menuList = {
		{ text = OPTIONS_MENU, isTitle = true, notCheckable = true},
		{ text = INVITE, hasArrow = true, notCheckable = true, },
		{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true, },
		{ text = BATTLENET_BROADCAST, notCheckable = true, func = function() StaticPopup_Show("SET_BN_BROADCAST") end },		
		{ text = "", notCheckable = true},
		{ text = PLAYER_STATUS, isTitle = true, notCheckable = true},		
		{ text = "|cff2BC226"..AVAILABLE.."|r", checked = function() return checkStatus()[1] end, func = function() if IsChatAFK() then SendChatMessage("", "AFK") elseif IsChatDND() then SendChatMessage("", "DND") end end},
		{ text = "|cffE7E716"..DND.."|r", checked = function() return checkStatus()[2] end, func = function() if not IsChatDND() then SendChatMessage("", "DND") end end},
		{ text = "|cffFF0000"..AFK.."|r", checked = function() return checkStatus()[3] end, func = function() if not IsChatAFK() then SendChatMessage("", "AFK") end end},
		}

	local function inviteClick(self, arg1, arg2, checked)
		menuFrame:Hide()
		InviteUnit(arg1)
	end

	local function whisperClick(self,arg1,arg2,checked)
		menuFrame:Hide() 
		SetItemRef( "player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton" )		 
	end
	
	local function BNwhisperClick(self,arg1,arg2,checked)
		menuFrame:Hide() 
		SetItemRef( "BNplayer:"..arg1..":"..arg2, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton" )		 
	end
	
	local function HexColor(c)
		return (c.r and format("|cff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255))
	end
	
	local worldOfWarcraftString = "WOW"
	local battleNetString = "Battle.NET"
	local activezone, inactivezone = {r = 0.3, g = 1, b = 0.3}, {r = 0.65, g = 0.65, b = 0.65}
	local friendTable, BNTable = {}, {}
	local friendOnline, friendOffline = gsub(ERR_FRIEND_ONLINE_SS, "\124Hplayer:%%s\124h%[%%s%]\124h", ""), gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")
	local dataValid = false
	
	-- 遊戲好友
	local function BuildFriendTable(total)
		wipe(friendTable)
		for i = 1, total do		
			local name, level, class, area, connected, status, note = GetFriendInfo(i)
			if connected then
				if status == CHAT_FLAG_AFK then
					status = "|T"..FRIENDS_TEXTURE_AFK..":16:16:-2:0:32:32|t"
				elseif status == CHAT_FLAG_DND then
					status = "|T"..FRIENDS_TEXTURE_DND..":16:16:-2:0:32:32|t"
				else
					status = ""
				end
				for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
					if class == v then
						class = k
					end
				end
				friendTable[i] = { name, level, class, area, connected, status, note }
			end
		end
		-- 按名字排序
		sort(friendTable, function(a, b)
			if a[1] and b[1] then
				return a[1] < b[1]
			end
		end)
	end
	
	-- 戰網好友
	local function BuildBNTable(total)
		wipe(BNTable)
		for i = 1, total do
			local bnetIDAccount, accountName, battleTag, isBattleTagPresence, charName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND = BNGetFriendInfo(i)
			if isOnline then
				local _, _, _, realmName, _, faction, _, class, _, zoneName, level, gameText, _, _, _, _, _, isGameAFK, isGameBusy  = BNGetGameAccountInfo(bnetIDGameAccount)
				charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
				for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
					if class == v then
						class = k
					end
				end
				
				local status, account, infoText
				if isAFK or isGameAFK then
					status = " |T"..FRIENDS_TEXTURE_AFK..":16:16:-2:0:32:32|t"
				elseif isDND or isGameBusy then
					status = " |T"..FRIENDS_TEXTURE_DND..":16:16:-2:0:32:32|t"
				else
					status = ""
				end
				
				if client == BNET_CLIENT_WOW then
					if ( not zoneName or zoneName == "" ) then
						infoText = UNKNOWN
					else
						infoText = zoneName
					end
				else
					infoText = gameText
				end
				
				BNTable[i] = { bnetIDAccount, accountName, battleTag, isBattleTagPresence, charName, bnetIDGameAccount, client, isOnline, isAFK, isDND, status, realmName, faction, class, zoneName, level, infoText }
			end
		end
		-- 按名字排序
		sort(BNTable, function(a, b)
			if a[2] and b[2] then
				return a[2] < b[2]
			end
		end)
	end

	local function GetClientTexture(client)
		if ( client == "WoW" ) then
			return "Interface\\FriendsFrame\\Battlenet-WoWicon"
		elseif ( client == "S2" ) then
			return "Interface\\FriendsFrame\\Battlenet-Sc2icon"
		elseif ( client == "D3" ) then
			return "Interface\\FriendsFrame\\Battlenet-D3icon"
		elseif ( client == "WTCG" ) then
			return "Interface\\FriendsFrame\\Battlenet-WTCGicon"
		elseif ( client == "Hero" ) then
			return "Interface\\FriendsFrame\\Battlenet-HotSicon"
		elseif ( client == "Pro" ) then
			return "Interface\\FriendsFrame\\Battlenet-Overwatchicon"
		else
			return "Interface\\FriendsFrame\\Battlenet-Battleneticon"
		end
	end
	
	local function Update(self, event, ...)
		local _, onlineFriends = GetNumFriends()
		local _, numBNetOnline = BNGetNumFriends()

		-- 上下線時強制更新
		if event == "CHAT_MSG_SYSTEM" then
			local message = select(1, ...)
			if not (string.find(message, friendOnline) or string.find(message, friendOffline)) then return end
		elseif event == "MODIFIER_STATE_CHANGED" and messgae == "LSHIFT" then
			self:GetScript("OnEnter")(self)
		end

		-- tooltip獲取列表時強制更新
		dataValid = false
		
		Text:SetText(format(cfg.ColorClass and init.Colored..FRIENDS.." |r".."%d" or FRIENDS.." %d", onlineFriends + numBNetOnline))
		self:SetAllPoints(Text)
	end
	
	-- 右鍵選單
	Stat:SetScript("OnMouseUp", function(self, btn)
		GameTooltip:Hide()
		if btn == "LeftButton" then ToggleFriendsFrame() end
		if btn ~= "RightButton" then return end		
		
		local menuCountWhispers = 0
		local menuCountInvites = 0
		local classc, levelc, info
		menuList[2].menuList = {}
		menuList[3].menuList = {}
		
		if #friendTable > 0 then
			for i = 1, #friendTable do
				info = friendTable[i]
				if info[5] then
					menuCountInvites = menuCountInvites + 1
					menuCountWhispers = menuCountWhispers + 1
		
					local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
					if classc == nil then classc = levelc end
		
					local nametext = HexColor(levelc)..info[2].." "..HexColor(classc)..info[1]
					menuList[2].menuList[menuCountInvites] = {text = nametext, arg1 = info[1], notCheckable = true, func = inviteClick}
					menuList[3].menuList[menuCountWhispers] = {text = nametext, arg1 = info[1], notCheckable = true, func = whisperClick}
				end
			end
		end
		if #BNTable > 0 then
			for i = 1, #BNTable do
				info = BNTable[i]
				if info[8] then
					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {text = "|cff70C0F5"..info[2], arg1 = info[2], arg2 = info[1], notCheckable = true, func = BNwhisperClick}
					-- 在wow且同陣營時可邀請組隊
					if info[7] == BNET_CLIENT_WOW and info[13] == select(1, UnitFactionGroup("player")) then
						menuCountInvites = menuCountInvites + 1
						local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[14]], GetQuestDifficultyColor(info[16])
						if classc == nil then classc = levelc end
						--if UnitInParty(info[5]) or UnitInRaid(info[5]) then grouped = 1 else grouped = 2 end						
						local nametext = HexColor(levelc)..info[16].." "..HexColor(classc)..info[5]
						menuList[2].menuList[menuCountInvites] = {text = nametext, arg1 = info[5].. "-"..info[12], notCheckable = true, func = inviteClick}
					end
				end
			end
		end

		L_EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	end)
	
	-- 好友列表
	Stat:SetScript("OnEnter", function(self)		

		local numberOfFriends, onlineFriends = GetNumFriends()
		local totalBNet, numBNetOnline = BNGetNumFriends()			
		local totalonline = onlineFriends + numBNetOnline
		
		-- 無人在線
		if totalonline == 0 then return end
		-- 只檢索在線者
		if not dataValid then
			if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
			if totalBNet > 0 then BuildBNTable(totalBNet) end
			dataValid = true
		end

		local totalfriends = numberOfFriends + totalBNet
		local zonec, classc, levelc, realmc, info

		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(FRIEND, format("%s/%s", totalonline, totalfriends), 0, .6, 1, 0, .6, 1)
		
		-- 遊戲好友
		if onlineFriends > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(worldOfWarcraftString)
			
			for i = 1, #friendTable do
				info = friendTable[i]
				if info[5] then
					if GetRealZoneText() == info[4] then zonec = activezone else zonec = inactivezone end
					local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
					if classc == nil then classc = levelc end
					
					GameTooltip:AddDoubleLine(format(HexColor(levelc)..info[2].."|r "..info[1].." "..info[6]), info[4], classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
				end
			end
		end

		if numBNetOnline > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(battleNetString)

			local status = 0
			for i = 1, #BNTable do
				info = BNTable[i]
				if info[8] then
					if info[7] == BNET_CLIENT_WOW then
						local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[14]], GetQuestDifficultyColor(info[16])
						if classc == nil then classc = levelc end
						--if UnitInParty(info[5]) or UnitInRaid(info[5]) then grouped = " +" else grouped = "" end
						local clienticon = "|T"..GetClientTexture(info[7])..":0:0:0:0:64:64|t " or ""
						
						if info[4] then	-- 有tag
							GameTooltip:AddDoubleLine(format(clienticon..HexColor(levelc)..info[16].."|r "..info[5]..info[11]),info[3], classc.r, classc.g, classc.b, 1, 1, 1)
						else	-- 只有實名
							GameTooltip:AddDoubleLine(format(clienticon..HexColor(levelc)..info[16].."|r "..info[5]..info[11]),info[2], classc.r, classc.g, classc.b, 1, 1, 1)
						end
						if IsShiftKeyDown() then
							--if GetRealZoneText() == info[16] then zonec = activezone else zonec = inactivezone end
							if GetRealmName() == info[12] then realmc = activezone else realmc = inactivezone end
							GameTooltip:AddDoubleLine(format(HexColor(levelc)..info[16].."|r "..info[5]), info[12], classc.r, classc.g, classc.b, realmc.r, realmc.g, realmc.b)
						end
					else
						local clienticon = "|T"..GetClientTexture(info[7])..":0:0:0:0:64:64|t " or ""
						if info[4] then
							GameTooltip:AddDoubleLine(format(clienticon..info[5]..info[11]), info[3], 1, 1, 1, 1, 1, 1)
						else
							GameTooltip:AddDoubleLine(format(clienticon..info[5]..info[11]), info[2], 1, 1, 1, 1, 1, 1)
						end
					end
				end
			end
		end

		GameTooltip:Show()
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
	end)
	
	Stat:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	end)

	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	Stat:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	Stat:RegisterEvent("BN_FRIEND_TOON_ONLINE")
	Stat:RegisterEvent("BN_FRIEND_TOON_OFFLINE")
	Stat:RegisterEvent("BN_TOON_NAME_UPDATED")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("CHAT_MSG_SYSTEM")
	Stat:SetScript("OnEvent", Update)
end