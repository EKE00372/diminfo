-- 創建框架
local CreatePanel = function(name, w, h, parent, point)
	local panel = CreateFrame("Frame", name, UIParent)
    panel:SetWidth(w)
	panel:SetHeight(h)
	panel:SetPoint(unpack(point))
	panel:SetFrameStrata("BACKGROUND")
	panel:SetFrameLevel(2)
	panel:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1,})
	panel:SetBackdropColor( .1, .1, .1, .6)
	--panel:SetBackdropBorderColor(65/255, 74/255, 79/255)
	panel:SetBackdropBorderColor( .1, .1, .1, .6)

	sd = CreateFrame("Frame", nil, panel)
	sd:SetPoint("TOPLEFT", -5, 5)
	sd:SetPoint("BOTTOMRIGHT", 5, -5)
	sd:SetFrameStrata(parent:GetFrameStrata())
	sd:SetFrameLevel(0)
	sd:SetBackdrop({edgeFile = "Interface\\addons\\diminfo\\Media\\glow", edgeSize = 5,})
	sd:SetBackdropBorderColor(0,0,0)

	return panel
end

-- 創建面板
TopLeftPanel = CreatePanel("TopLeftPanel", 520, 8, UIParent, {"TOPLEFT", 10, -5})
--MinimapPanel = CreatePanel("MinimapPanel", 160, 160, UIParent, {"TOPLEFT", 10, -20})
BottomRightInfoPanel = CreatePanel("BottomRightInfoPanel", 450, 8, UIParent, {"BOTTOMRIGHT", -10, 5})
--[[testpanel = CreatePanel("testpanel", 100, 100, UIParent, {"center"})
TopInfoPanel = CreatePanel("TopInfoPanel", 146, 18, UIParent, {"topright", -5, -5})
BottomInfoPanel = CreatePanel("BottomInfoPanel", 560, 5, UIParent, {"bottom", 0, 5})
BottomRightInfoPanel = CreatePanel("BottomRightInfoPanel", 330, 15, UIParent, {"bottomright", -5, 5})
ChatBarPanel= CreatePanel("ChatBarPanel", 330, 15, UIParent, {"bottomleft", 5, 5})
ChatBackgroundPanel = CreatePanel("ChatBackgroundPanel", 330, 110, UIParent, {"bottomleft", 5, 25})
RightBackgroundPanel = CreatePanel("RightBackgroundPanel", 330, 110, UIParent, {"bottomright", -5, 25})
Minimappanel = CreatePanel("Minimappanel", 146, 146, UIParent, {"topright", -5, -28})]]--
--[[
--職業顏色
local classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass('player'))] 

--最大寬=解析度寬度
local getscreenwidth = tonumber(string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x+%d"))

--頂部
local topbigpanel = CreateFrame("Frame", nil, UIParent)
	topbigpanel:SetFrameStrata("BACKGROUND")
	topbigpanel:SetHeight(16)
	topbigpanel:SetWidth(getscreenwidth)
	topbigpanel:SetPoint("TOP", UIParent, "TOP", 0, 0)
	topbigpanel:SetBackdrop({
	bgFile = "Interface\\Buttons\\WHITE8x8",
	})
	topbigpanel:SetBackdropColor(0, 0, 0, 0.6)
	  
--底部
local bottompanel = CreateFrame("Frame", nil, UIParent)
	bottompanel:SetFrameStrata("BACKGROUND")
	bottompanel:SetHeight(30)
	bottompanel:SetWidth(getscreenwidth+10)
	bottompanel:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, -6)
	bottompanel:SetBackdrop({
	bgFile = "Interface\\Buttons\\WHITE8x8",
	edgeFile = "Interface\\Buttons\\WHITE8x8",
	edgeSize = 6,
	})
	bottompanel:SetBackdropColor(0, 0, 0, 0.6)
	--bottompanel:SetBackdropBorderColor(classc.r,classc.g,classc.b, 0.4)
	bottompanel:SetBackdropBorderColor(0.1,0.1,0.1, 0.9)

local bottomline = CreateFrame("Frame", nil, UIParent)
	bottomline:SetFrameStrata("BACKGROUND")
	bottomline:SetHeight(6)
	bottomline:SetWidth(getscreenwidth+10)
	bottomline:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 30)
	bottomline:SetBackdrop({
	bgFile = "Interface\\Buttons\\WHITE8x8",
	})
	bottomline:SetBackdropColor(0, 0, 0, 0.9)
]]--