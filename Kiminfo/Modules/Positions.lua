local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Positions then return end

local format, unpack = string.format, unpack
local CreateFrame = CreateFrame
local canaccessvalue = canaccessvalue
local C_Map_GetWorldPosFromMapPos, C_Map_GetBestMapForUnit = C_Map.GetWorldPosFromMapPos, C_Map.GetBestMapForUnit
local C_PvP_GetZonePVPInfo = C_PvP.GetZonePVPInfo
local C_CVar_GetCVarBool, C_CVar_SetCVar = C_CVar.GetCVarBool, C_CVar.SetCVar
local GetSubZoneText, GetZoneText = GetSubZoneText, GetZoneText

local subzone, zone, pvpType, faction
local coordX, coordY = 0, 0
local secretValueCVars = {
	"addonChatRestrictionsForced",
	"addonEncounterRestrictionsForced",
	"addonChallengeModeRestrictionsForced",
	"addonPvPMatchRestrictionsForced",
	"addonMapRestrictionsForced",
	"addonCombatRestrictionsForced",
}

--==========================================--
---------------	[[ Elements ]] ---------------
--==========================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Pos", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.PositionsPoint))
	Stat:SetAllPoints(Text)

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

--[[ Format ]]--
local function formatCoords()
	return format("%.1f, %.1f", coordX*100, coordY*100)
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
		local x, y = GetPlayerMapPos(C_Map_GetBestMapForUnit("player"))
		if x then
			coordX, coordY = x, y
		else
			coordX, coordY = 0, 0
		end
		self:GetScript("OnEnter")(self)
		
		self.elapsed = 0
	end
end

--=========================================--
---------------	[[ Updates ]] ---------------
--=========================================--

local function OnEvent(self)
	subzone, zone =  GetSubZoneText(), GetZoneText()
	pvpType, _, faction = C_PvP_GetZonePVPInfo()
	pvpType = pvpType or "neutral"
	
	local r, g, b = unpack(zoneColor[pvpType][2])
	
	Text:SetText((subzone ~= "") and subzone or zone)
	Text:SetTextColor(r, g, b)
end

local function OnEnter(self)
	local inInstance = IsInInstance()
	if inInstance then
		self:SetScript("OnUpdate", nil)
	elseif not self:GetScript("OnUpdate") then
		self:SetScript("OnUpdate", UpdateCoords)
	end
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(zone, 0, .6, 1)
	
	-- Subzone
	if pvpType and not inInstance then
		local r, g, b = unpack(zoneColor[pvpType][2])
		if subzone and subzone ~= zone then
			GameTooltip:AddLine(subzone, r, g, b)
		end
		GameTooltip:AddLine(format(zoneColor[pvpType][1], faction or ""), r, g, b)
	end

	-- Coords
	if not inInstance then
		GameTooltip:AddLine(format("|cffffffff%s|r", formatCoords()), 1, 1, 1)
	end

	if IsControlKeyDown() then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("Secret Value CVar", AreSecretValueCVarsEnabled() and G.Enable or G.Disable, 1, 1, 1, 1, 1, 1)
	end
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..WORLDMAP_BUTTON..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..MAP_PIN..G.RightButton)
	
	GameTooltip:Show()
end

--=========================================--
---------------	[[ Scripts ]] ---------------
--=========================================--

	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", nil)
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("ZONE_CHANGED")
	Stat:RegisterEvent("ZONE_CHANGED_INDOORS")
	Stat:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" and IsControlKeyDown() then
			SetSecretValueCVarsEnabled(not AreSecretValueCVarsEnabled())
			OnEnter(self)
		elseif btn == "LeftButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
			ToggleFrame(WorldMapFrame)
		elseif btn == "RightButton" then
			local inInstance, instanceType = IsInInstance()
			if (not inInstance) and (instanceType == "none") then
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
				
				if C_Map.CanSetUserWaypointOnMap(map) and C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(map, x, y)) then
					local waypointLink = C_Map.GetUserWaypointHyperlink()
					if waypointLink then
						ChatFrameUtil.OpenChat(format("%s %s (%s) %s", waypointLink, zone, formatCoords(), unitName))
						return
					end
				end

				ChatFrameUtil.OpenChat(format("%s (%s) %s", zone, formatCoords(), unitName))
			end
		else
			return
		end
	end)