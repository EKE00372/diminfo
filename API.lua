local addon, ns = ... 
local C, F, G, DB = unpack(ns)

F.Hex = function(r, g, b)
	-- 未定義則白色
	if not r then return "|cffFFFFFF" end
	
	if type(r) == "table" then
		if(r.r) then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	
	return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

-- 創建框架
F.CreatePanel = function(anchor, parent, x, y, w, h, size)
	local panel = CreateFrame("Frame", nil, parent)
	local framelvl = parent:GetFrameLevel()
	
    panel:SetWidth(w)
	panel:SetHeight(h)
	panel:ClearAllPoints()
	panel:SetPoint(anchor, parent, x, y)
	panel:SetFrameStrata("BACKGROUND")
	panel:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	panel:SetBackdrop({
		bgFile = G.Tex,
		edgeFile = G.Tex, edgeSize = 1,
	})
	panel:SetBackdropColor( .1, .1, .1, .6)
	panel:SetBackdropBorderColor( .1, .1, .1, .6)

	sd = CreateFrame("Frame", nil, panel)
	sd:SetPoint("TOPLEFT", -size, size)
	sd:SetPoint("BOTTOMRIGHT", size, -size)
	sd:SetFrameStrata(panel:GetFrameStrata())
	sd:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	sd:SetBackdrop({
		edgeFile = G.Glow,
		edgeSize = size,
	})
	sd:SetBackdropBorderColor(0, 0, 0)

	return panel
end

if not C.Panel then return end

F.CreatePanel(unpack(C.Panel1))
if C.Panel2 then F.CreatePanel(unpack(C.Panel2)) end
if C.Panel3 then F.CreatePanel(unpack(C.Panel3)) end
if C.Panel4 then F.CreatePanel(unpack(C.Panel4)) end
if C.Panel5 then F.CreatePanel(unpack(C.Panel5)) end