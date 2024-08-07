local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Positions then return end

local format, unpack = string.format, unpack
local CreateFrame = CreateFrame
local C_Map_GetWorldPosFromMapPos, C_Map_GetBestMapForUnit = C_Map.GetWorldPosFromMapPos, C_Map.GetBestMapForUnit
local C_PvP_GetZonePVPInfo = C_PvP.GetZonePVPInfo
local GetSubZoneText, GetZoneText = GetSubZoneText, GetZoneText
local LibShowUIPanel = LibStub("LibShowUIPanel-1.0")
local ShowUIPanel = LibShowUIPanel.ShowUIPanel
local HideUIPanel = LibShowUIPanel.HideUIPanel

local subzone, zone, pvpType, faction
local coordX, coordY = 0, 0

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Pos", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.PositionsPoint))
	Stat:SetAllPoints(Text)

--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

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

--[[ Get XY ]]--
local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local function GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end
	
	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {}
		mapRect[1] = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		mapRect[2] = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		mapRect[2]:Subtract(mapRect[1])
	
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
			self:SetScript("OnUpdate", nil)
		end
		self:GetScript("OnEnter")(self)
		
		self.elapsed = 0
	end
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function OnEvent(self)
	subzone, zone =  GetSubZoneText(), GetZoneText()
	pvpType, _, faction = C_PvP_GetZonePVPInfo()
	pvpType = pvpType or "neutral"
	
	local r, g, b = unpack(zoneColor[pvpType][2])
	
	Text:SetText((subzone ~= "") and subzone or zone)
	Text:SetTextColor(r, g, b)
end

local function OnEnter(self)
	self:SetScript("OnUpdate", UpdateCoords)
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	
	-- Coords
	if not IsInInstance() then
		GameTooltip:AddLine(zone, 0, .8, 1)
		GameTooltip:AddLine(format("|cffffffff%s|r", formatCoords()), 1, 1, 1)
	else
		GameTooltip:AddLine(zone, 0, .8, 1)
	end
	
	-- Subzone
	if pvpType and not IsInInstance() then
		local r, g, b = unpack(zoneColor[pvpType][2])
		if subzone and subzone ~= zone then
			GameTooltip:AddLine(subzone, r, g, b)
		end
		GameTooltip:AddLine(format(zoneColor[pvpType][1], faction or ""), r, g, b)
	end
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..WORLDMAP_BUTTON..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..MAP_PIN..G.RightButton)
	
	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--

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
	Stat:SetScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			if not WorldMapFrame:IsShown() then ShowUIPanel(WorldMapFrame) else HideUIPanel(WorldMapFrame) end
		elseif btn == "RightButton" then
			if not IsInInstance() then
				local map = C_Map_GetBestMapForUnit("player")
				local x, y = GetPlayerMapPos(map)
				local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
				local unitName = hasUnit and UnitName("target") or ""
				
				C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(map, x, y))
				ChatFrame_OpenChat(format("%s %s (%s) %s", C_Map.GetUserWaypointHyperlink(), zone, formatCoords(), unitName), chatFrame)
			end
		else
			return
		end
	end)