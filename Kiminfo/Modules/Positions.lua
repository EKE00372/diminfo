local _, ns = ...
local C, F, G, L = unpack(ns)
if not C.Positions then return end

local GameTooltip = F.Tooltip
local format, unpack = string.format, unpack
local CreateFrame = CreateFrame
local canaccessvalue = canaccessvalue
local C_Map_GetWorldPosFromMapPos, C_Map_GetBestMapForUnit = C_Map.GetWorldPosFromMapPos, C_Map.GetBestMapForUnit
local C_PvP_GetZonePVPInfo = C_PvP.GetZonePVPInfo
local C_CVar_GetCVarBool, C_CVar_SetCVar = C_CVar.GetCVarBool, C_CVar.SetCVar
local GetSubZoneText, GetZoneText = GetSubZoneText, GetZoneText

local subzone, zone, pvpType, faction
local coordX, coordY = 0, 0
local coordLine, secretValueLine
local secretValueCVars = {
	"addonChatRestrictionsForced",
	"addonEncounterRestrictionsForced",
	"addonChallengeModeRestrictionsForced",
	"addonPvPMatchRestrictionsForced",
	"addonMapRestrictionsForced",
	"addonCombatRestrictionsForced",
}
-- 顯示名字時套用的預設；隱藏時這些選項全部設為 0，不影響名條。
local namePreset = {
	{"UnitNameOwn", "0"},
	{"UnitNameNPC", "1"},
	-- NPC 子選項歸零，以對應原生「所有／無 NPC」。
	{"UnitNameFriendlySpecialNPCName", "0"},
	{"UnitNameHostleNPC", "0"},
	{"UnitNameInteractiveNPC", "0"},
	{"UnitNameNonCombatCreatureName", "1"},
	{"UnitNameFriendlyPlayerName", "1"},
	{"UnitNameFriendlyMinionName", "1"},
	{"UnitNameEnemyPlayerName", "1"},
	{"UnitNameEnemyMinionName", "0"},
}

--==========================================--
---------------	[[ Elements ]] ---------------
--==========================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Pos", UIParent, "HorizontalLayoutFrame")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 1
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	F.RegisterModule("Positions", Stat)

--===========================================--
---------------	[[ Functions ]] ---------------
--===========================================--

--[[ Zone text color ]]--
local zoneColor = {
	sanctuary = {SANCTUARY_TERRITORY, {.41, .8, .94}},
	arena = {FREE_FOR_ALL_TERRITORY, {1, .1, .1}},
	friendly = {FACTION_CONTROLLED_TERRITORY, {.1, 1, .1}},
	hostile = {FACTION_CONTROLLED_TERRITORY, {1, .1, .1}},
	contested = {CONTESTED_TERRITORY, {1, .7, 0}},
	combat = {COMBAT_ZONE, {1, .1, .1}},
	neutral = {format(FACTION_CONTROLLED_TERRITORY,FACTION_STANDING_LABEL4), {1, .93, .76}}
}

-- 原生語系字串的外層括號
for _, info in pairs(zoneColor) do
	info[1] = info[1]:gsub("^%((.*)%)$", "%1"):gsub("^（(.*)）$", "%1")
end

--[[ Format ]]--
local function formatCoords()
	return format("%.1f, %.1f", coordX*100, coordY*100)
end

-- 任一名稱選項開啟就提供「隱藏」；提示與點擊共用目前的實際設定。
local function AreNamesEnabled()
	for i = 1, #namePreset do
		if C_CVar_GetCVarBool(namePreset[i][1]) then return true end
	end
	return false
end

--[[ Secret value test CVars ]]--
local function AreSecretValueCVarsEnabled()
	for i = 1, #secretValueCVars do
		if not C_CVar_GetCVarBool(secretValueCVars[i]) then
			return false
		end
	end

	return true
end

local function SetSecretValueCVarsEnabled(enabled)
	local value = enabled and "1" or "0"

	for i = 1, #secretValueCVars do
		C_CVar_SetCVar(secretValueCVars[i], value)
	end
end

--[[ Get XY ]]--
local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local function GetPlayerMapPos(mapID)
	if not mapID then return end

	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end
	
	local mapRect = mapRects[mapID]
	if not mapRect then
		local _, mapOrigin = C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
		local _, mapExtent = C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
		if not mapOrigin or not mapExtent then return end

		mapExtent:Subtract(mapOrigin)
		mapRect = {mapOrigin, mapExtent}
	
		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])
	
	return tempVec2D.y/mapRect[2].y, tempVec2D.x/mapRect[2].x
end

--[[ Update coords ]]--
local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	
	if self.elapsed > .1 then
		self.elapsed = 0
		if not GameTooltip:IsOwned(self) or not GameTooltip:IsShown() then
			self:SetScript("OnUpdate", nil)
			coordLine, secretValueLine = nil, nil
			return
		end

		-- 只有列結構改變才重繪整個 tooltip；一般移動只更新座標文字。
		if IsInInstance() or C_CVar_GetCVarBool("minimapShowPlayerCoords") or (not G.IsForever and IsControlKeyDown()) ~= (secretValueLine ~= nil) then
			self:GetScript("OnEnter")(self)
			return
		end

		local x, y = GetPlayerMapPos(C_Map_GetBestMapForUnit("player"))
		if x then
			coordX, coordY = x, y
		else
			coordX, coordY = 0, 0
		end
		coordLine:SetText("|cffffffff"..formatCoords().."|r")
		if secretValueLine then
			secretValueLine:SetText(AreSecretValueCVarsEnabled() and G.Enable or G.Disable)
		end
		-- 內容仍是同一列，交原生 tooltip 更新寬度，不重設所有列高。
		GameTooltip:Show()
	end
end

--=========================================--
---------------	[[ Updates ]] ---------------
--=========================================--

local function OnEnter(self)
	local inInstance = IsInInstance()
	local showCoords = not inInstance and not C_CVar_GetCVarBool("minimapShowPlayerCoords")
	if not showCoords then
		self:SetScript("OnUpdate", nil)
	elseif not self:GetScript("OnUpdate") then
		self:SetScript("OnUpdate", UpdateCoords)
	end
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(G.TitleColor..zone)
	
	-- Subzone
	if pvpType and not inInstance then
		local r, g, b = unpack(zoneColor[pvpType][2])
		if subzone and subzone ~= zone then
			GameTooltip:AddLine(subzone, r, g, b)
		end
		GameTooltip:AddLine(format(zoneColor[pvpType][1], faction or ""), r, g, b)
	end

	-- Coords
	coordLine = nil
	if showCoords then
		GameTooltip:AddLine("|cffffffff"..formatCoords().."|r")
		coordLine = GameTooltip:GetLeftLine(GameTooltip:NumLines())
	end

	secretValueLine = nil
	if not G.IsForever and IsControlKeyDown() then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("Secret Value CVar", AreSecretValueCVarsEnabled() and G.Enable or G.Disable, 1, 1, 1)
		secretValueLine = GameTooltip:GetRightLine(GameTooltip:NumLines())
	end
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(G.OptionColor..G.LeftButton.."+ Shift "..(AreNamesEnabled() and L.HideNames or L.NamePreset), G.OptionColor..WORLDMAP_BUTTON..G.LeftButton)
	GameTooltip:AddDoubleLine(G.OptionColor..G.MiddleButton..(C_CVar_GetCVarBool("gxMaximize") and VIDEO_OPTIONS_WINDOWED or VIDEO_OPTIONS_FULLSCREEN), G.OptionColor..MAP_PIN..G.RightButton)
	
	F.ShowTooltip()
end

local function OnEvent(self)
	subzone, zone =  GetSubZoneText(), GetZoneText()
	local _
	pvpType, _, faction = C_PvP_GetZonePVPInfo()
	pvpType = pvpType or "neutral"

	local r, g, b = unpack(zoneColor[pvpType][2])

	Text:SetText((subzone ~= "") and subzone or zone)
	Text:SetTextColor(r, g, b)
	self:Layout()
	if GameTooltip:IsOwned(self) and GameTooltip:IsShown() then
		OnEnter(self)
	end
end

--=========================================--
---------------	[[ Scripts ]] ---------------
--=========================================--

	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", nil)
		coordLine, secretValueLine = nil, nil
		if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("ZONE_CHANGED")
	Stat:RegisterEvent("ZONE_CHANGED_INDOORS")
	Stat:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" and IsShiftKeyDown() then
			local enabled = not AreNamesEnabled()
			for i = 1, #namePreset do
				local option = namePreset[i]
				C_CVar_SetCVar(option[1], enabled and option[2] or "0")
			end
			OnEnter(self)
		elseif btn == "MiddleButton" then
			-- 原生顯示模式：視窗化／全螢幕視窗化，只更新視窗，不重啟圖形引擎。
			if C_CVar_SetCVar("gxMaximize", C_CVar_GetCVarBool("gxMaximize") and "0" or "1") then
				UpdateWindow()
				OnEnter(self)
			end
		elseif btn == "LeftButton" and IsControlKeyDown() then
			if G.IsForever then return end
			SetSecretValueCVarsEnabled(not AreSecretValueCVarsEnabled())
			OnEnter(self)
		elseif btn == "LeftButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
			ToggleFrame(WorldMapFrame)
		elseif btn == "RightButton" then
			local inInstance, instanceType = IsInInstance()
			if inInstance or instanceType ~= "none" then return end
			local map = C_Map_GetBestMapForUnit("player")
			if not map then return end

			local x, y = GetPlayerMapPos(map)
			if not x or not y then return end

			coordX, coordY = x, y
			local unitName = ""
			if UnitExists("target") and not UnitIsPlayer("target") then
				local targetName = UnitName("target")
				if canaccessvalue(targetName) then
					unitName = targetName
				end
			end

			local message = format("%s (%s) %s", zone, formatCoords(), unitName)
			if C_Map.CanSetUserWaypointOnMap(map) and C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(map, x, y)) then
				local waypointLink = C_Map.GetUserWaypointHyperlink()
				if waypointLink then
					message = waypointLink.." "..message
				end
			end
			ChatFrameUtil.OpenChat(message)
		end
	end)