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
local TopLeftPanel = CreatePanel("TopLeftPanel", 540, 8, UIParent, {"TOPLEFT", 10, -5})
local BottomRightInfoPanel = CreatePanel("BottomRightInfoPanel", 470, 8, UIParent, {"BOTTOMRIGHT", -10, 5})
