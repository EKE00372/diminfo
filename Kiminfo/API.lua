local addon, ns = ... 
local C, F, G, L = unpack(ns)

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

F.ClassList = {}
for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	--[[if F.ClassList == v then
		F.ClassList = k
	end]]
	F.ClassList[v] = k
end

-- 多重條件
F.Multicheck = function(check, ...)
	for i = 1, select("#", ...) do
		if check == select(i, ...) then
			return true
		end
	end
	return false
end

-- 材質，尺寸，切邊1，切邊2
F.addIcon = function(texture, size, cut1, cut2)
	texture = texture and "|T"..texture..":"..size..":"..size..":0:0:50:50:"..cut1..":"..cut2..":"..cut1..":"..cut2.."|t" or ""
	return texture
end

-- 創建框架
F.CreatePanel = function(anchor, parent, x, y, w, h, size, a1, a2)
	local panel = CreateFrame("Frame", nil, parent)
	local framelvl = parent:GetFrameLevel()
	
    panel:SetWidth(w)
	panel:SetHeight(h)
	panel:ClearAllPoints()
	panel:SetPoint(anchor, parent, x, y)
	panel:SetFrameStrata("BACKGROUND")
	panel:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	
	panel.bg = panel:CreateTexture(nil, "BACKGROUND")
	panel.bg:SetAllPoints(panel)
	panel.bg:SetTexture(G.Tex)
	panel.bg:SetGradientAlpha("HORIZONTAL", .1,.1,.1, a1, .1,.1,.1, a2)

	--[[
	panel.bg = panel:CreateTexture(nil, "BACKGROUND")
	
	panel.bg:SetSize(h, w)
	panel.bg:SetTexture(G.Glow)
	panel.bg:SetTexCoord(0, .0875, 0, 1)
	panel.bg:SetRotation(math.rad(90))
	panel.bg:SetGradientAlpha("HORIZONTAL", .1,.1,.1, a1, .1,.1,.1, a2)
	panel.bg:SetPoint("TOP", panel, "BOTTOM", 0, 0)]]--
	--[[
	panel.bg = panel:CreateTexture(nil, "BACKGROUND")
	panel.bg:SetAllPoints(panel)
	panel.bg:SetTexture(G.Tex)
	panel.bg:SetGradientAlpha("HORIZONTAL", .1,.1,.1, a1, .1,.1,.1, a2)
	
	panel.l1 = panel:CreateTexture(nil, "BACKGROUND")
	panel.l1:SetPoint("TOP", panel, "BOTTOM")
	panel.l1:SetSize(w, size)
	panel.l1:SetTexture(G.Glow)
	--panel.l1:SetGradientAlpha("HORIZONTAL", G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, a1, G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, a2)
	panel.l1:SetGradientAlpha("HORIZONTAL", 0, 0, 0, a1, 0, 0, 0, a2)
	
	panel.l2 = panel:CreateTexture(nil, "BACKGROUND")
	panel.l2:SetPoint("BOTTOM", panel, "TOP")
	panel.l2:SetSize(w, size)
	panel.l2:SetTexture(G.Glow)
	panel.l2:SetRotation(math.rad(180))
	--panel.l2:SetGradientAlpha("HORIZONTAL", G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, a2, G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, a1)
	panel.l2:SetGradientAlpha("HORIZONTAL", 0, 0, 0, a2, 0, 0, 0, a1)
	]]--
	--[[
	panel:SetBackdrop({
		bgFile = G.Tex,
		edgeFile = G.Glow,
		edgeSize = size,
		--bgSize = 64, 
		--edgeSize = 16, 
		--insets = { left = size, right = size, top = size, bottom = size }
		insets = { left = 0, right = 0, top = -size, bottom = -size }
	})
	panel:SetBackdropColor(.1, .1, .1, .6)
	panel:SetBackdropBorderColor(0, 0, 0)
	
	--panel.bg = panel:CreateTexture(nil, "BACKGROUND")
	--panel.bg:SetPoint(panel)
	--panel.bg:SetAllPoints(panel)
	--panel.bg:SetTexture(G.Tex)
	--panel.bg:SetVertexColor(.1, .1, .1, .6)
	--panel.bg:SetGradientAlpha("HORIZONTAL", .1,.1,.1, a1, .1,.1,.1, a2)
]]--

	return panel
end

if not C.Panel then return end

F.CreatePanel(unpack(C.Panel1))
if C.Panel2 then F.CreatePanel(unpack(C.Panel2)) end
if C.Panel3 then F.CreatePanel(unpack(C.Panel3)) end
if C.Panel4 then F.CreatePanel(unpack(C.Panel4)) end
if C.Panel5 then F.CreatePanel(unpack(C.Panel5)) end
if C.Panel6 then F.CreatePanel(unpack(C.Panel6)) end