local _, ns = ...
local C, F, G, L = unpack(ns)
if not C.Positions then return end

local GameTooltip = F.Tooltip
local format = string.format
local CreateFrame = CreateFrame

local subzone, zone, pvpType, faction
local coordX, coordY = 0, 0
local coordLine
local mapRects = {}

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Pos", UIParent, "HorizontalLayoutFrame")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 1
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	F.RegisterModule("Positions", Stat)

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

-- 原生語系字串的外層括號
for _, info in pairs(zoneColor) do
	info[1] = info[1]:gsub("^%((.*)%)$", "%1"):gsub("^（(.*)）$", "%1")
end

--[[ Format ]]--
local function formatCoords()
	return format("%.1f, %.1f", coordX*100, coordY*100)
end

local function UpdateLocationText(self, inInstance)
	local location = (subzone ~= "") and subzone or zone
	if diminfo.ShowCoords and not inInstance then
		Text:SetText(format("%s |cffffffff(%s)|r", location, formatCoords()))
	else
		Text:SetText(location)
	end
	self:Layout()
end

--[[ Get xy ]]--
local tempVec2D = CreateVector2D(0, 0)
local function GetPlayerMapPos(mapID)
	if not mapID then return end

	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end
	
	local mapRect = mapRects[mapID]
	if not mapRect then
		local _, mapOrigin = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
		local _, mapExtent = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
		if not mapOrigin or not mapExtent then return end

		mapExtent:Subtract(mapOrigin)
		mapRect = {mapOrigin, mapExtent}
	
		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])
	
	return tempVec2D.y/mapRect[2].y, tempVec2D.x/mapRect[2].x
end

local function RefreshCoords()
	local x, y = GetPlayerMapPos(C_Map.GetBestMapForUnit("player"))
	if x then
		coordX, coordY = x, y
	else
		coordX, coordY = 0, 0
	end
end

--[[ Update coords ]]--
local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	
	if self.elapsed > .1 then
		self.elapsed = 0
		local showTooltip = (GameTooltip:IsOwned(self) and GameTooltip:IsShown())
		if not diminfo.ShowCoords and not showTooltip then
			self:SetScript("OnUpdate", nil)
			coordLine = nil
			return
		end
		if IsInInstance() then
			self:SetScript("OnUpdate", nil)
			coordLine = nil
			if diminfo.ShowCoords then UpdateLocationText(self, true) end
			if showTooltip then self:GetScript("OnEnter")(self) end
			return
		end

		-- 兩種顯示模式沿用同一個座標更新器。
		RefreshCoords()
		if diminfo.ShowCoords then UpdateLocationText(self, false) end
		if showTooltip and not diminfo.ShowCoords then
			coordLine:SetText(format("|cffffffff%s|r", formatCoords()))
			GameTooltip:Show()
		else
			coordLine = nil
		end
	end
end

local function UpdateTracking(self, inInstance)
	if not inInstance and (diminfo.ShowCoords or (GameTooltip:IsOwned(self) and GameTooltip:IsShown())) then
		self:SetScript("OnUpdate", UpdateCoords)
	else
		self:SetScript("OnUpdate", nil)
	end
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function OnEnter(self)
	local inInstance = IsInInstance()
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	
	-- Coords
	coordLine = nil
	GameTooltip:AddLine(zone, 0, .8, 1)
	if not inInstance and not diminfo.ShowCoords then
		GameTooltip:AddLine(format("|cffffffff%s|r", formatCoords()), 1, 1, 1)
		coordLine = GameTooltip:GetLeftLine(GameTooltip:NumLines())
	end
	
	-- Subzone
	if pvpType and not inInstance then
		local r, g, b = unpack(zoneColor[pvpType][2])
		if subzone ~= zone then
			GameTooltip:AddLine(subzone, r, g, b)
		end
		GameTooltip:AddLine(format(zoneColor[pvpType][1],faction or ""), r, g, b)
	end
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..WORLDMAP_BUTTON..G.LeftButton)
	GameTooltip:AddDoubleLine(G.OptionColor..G.RightButton.."+ Shift "..L.SwitchMode, G.OptionColor..L.XY..G.RightButton)
	
	F.ShowTooltip()
	UpdateTracking(self, inInstance)
end

local function OnEvent(self)
	if diminfo.ShowCoords == nil then diminfo.ShowCoords = false end
	subzone, zone = GetSubZoneText(), GetZoneText()
	local _
	pvpType, _, faction = C_PvP.GetZonePVPInfo()
	pvpType = pvpType or "neutral"

	local r, g, b = unpack(zoneColor[pvpType][2])
	local inInstance = IsInInstance()
	if diminfo.ShowCoords and not inInstance then RefreshCoords() end

	UpdateLocationText(self, inInstance)
	Text:SetTextColor(r, g, b)
	if GameTooltip:IsOwned(self) and GameTooltip:IsShown() then
		OnEnter(self)
	else
		UpdateTracking(self, inInstance)
	end
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--

	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function(self)
		coordLine = nil
		if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
		UpdateTracking(self, IsInInstance())
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("ZONE_CHANGED")
	Stat:RegisterEvent("ZONE_CHANGED_INDOORS")
	Stat:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			ToggleFrame(WorldMapFrame)
		elseif btn == "RightButton" and IsShiftKeyDown() then
			diminfo.ShowCoords = not diminfo.ShowCoords
			self.elapsed = 0
			OnEvent(self)
		elseif btn == "RightButton" then
			if IsInInstance() then return end
			local map = C_Map.GetBestMapForUnit("player")

			local x, y = GetPlayerMapPos(map)
			if not x then return end

			coordX, coordY = x, y
			ChatFrameUtil.OpenChat(format("%s (%s)", zone, formatCoords()))
		end
	end)