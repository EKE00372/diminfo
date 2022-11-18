local addon, ns = ... 
local C, F, G, L = unpack(ns)

-- localized references for global functions (about 50% faster)
local format = string.format
local CreateFrame = CreateFrame
local CreateColor = CreateColor

--================================================--
---------------    [[ Convert ]]     ---------------
--================================================--

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

-- 職業列表轉換
F.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	F.ClassList[v] = k
end

--===================================================--
---------------    [[ Custom api ]]     ---------------
--===================================================--

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

--==============================================--
---------------    [[ Panel ]]     ---------------
--==============================================--

-- 創建框架
F.CreatePanel = function(anchor, parent, x, y, w, h, size, a)
	local panel = CreateFrame("Frame", nil, parent)
	local framelvl = parent:GetFrameLevel()
	
	-- 中間
    panel:SetWidth(w)
	panel:SetHeight(h)
	panel:ClearAllPoints()
	panel:SetPoint(anchor, parent, x, y)
	panel:SetFrameStrata("BACKGROUND")
	panel:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	
	panel.bg = panel:CreateTexture(nil, "BACKGROUND")
	panel.bg:SetAllPoints(panel)
	panel.bg:SetTexture(G.Tex)
	panel.bg:SetVertexColor(.1, .1, .1, a)
	
	-- 左側漸變
	local left = CreateFrame("Frame", nil, parent)
	left:SetSize(60, h)
	left:ClearAllPoints()
	left:SetPoint("RIGHT", panel, "LEFT", 0, 0)
	left:SetFrameStrata("BACKGROUND")
	left:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	
	left.bg = left:CreateTexture(nil, "BACKGROUND")
	left.bg:SetAllPoints(left)
	left.bg:SetTexture(G.Tex)
	--left.bg:SetGradientAlpha("HORIZONTAL", .1, .1, .1, 0, .1, .1, .1, a)
	left.bg:SetGradient("HORIZONTAL", CreateColor(.1, .1, .1, 0), CreateColor(.1, .1, .1, a))
	
	-- 右側漸變
	local right = CreateFrame("Frame", nil, parent)
	right:SetSize(80, h)
	right:ClearAllPoints()
	right:SetPoint("LEFT", panel, "RIGHT", 0, 0)
	right:SetFrameStrata("BACKGROUND")
	right:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	
	right.bg = right:CreateTexture(nil, "BACKGROUND")
	right.bg:SetAllPoints(right)
	right.bg:SetTexture(G.Tex)
	--right.bg:SetGradientAlpha("HORIZONTAL", .1, .1, .1, a, .1, .1, .1, 0)
	right.bg:SetGradient("HORIZONTAL", CreateColor(.1, .1, .1, a), CreateColor(.1, .1, .1, 0))

	return panel
end

--================================================--
---------------    [[ Texture ]]     ---------------
--================================================--

-- 材質，為免被瞎改還是藏起來吧
G.Bags = G.MediaFolder.."bags.tga"
G.Friends = G.MediaFolder.."friends.tga"
G.Guild = G.MediaFolder.."guild.tga"
G.Dura = G.MediaFolder.."dura.tga"
G.Fps = G.MediaFolder.."fps.tga"
G.Ping = G.MediaFolder.."ping.tga"
G.Mem = G.MediaFolder.."spell.tga"
G.Alliance = G.MediaFolder.."Alliance"
G.WOWIcon = G.MediaFolder.."WoW_Yellow"

--G.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
--G.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
--G.MiddleButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

G.LeftButton = " |T"..G.MediaFolder.."MouseButtonOrange.tga:13:11:0:-2:128:32:4:28:0:32|t "
G.RightButton = " |T"..G.MediaFolder.."MouseButtonOrange.tga:13:11:0:-2:128:32:36:60:0:32|t "
G.MiddleButton = " |T"..G.MediaFolder.."MouseButtonOrange.tga:13:11:0:-2:128:32:68:92:0:32|t "

G.AFK = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
G.DND = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

G.Enable = "|cff55ff55"..ENABLE
G.Disable = "|cffff5555"..DISABLE


if not C.Panel then return end

if C.Panel1 then F.CreatePanel(unpack(C.Panel1)) end
if C.Panel2 then F.CreatePanel(unpack(C.Panel2)) end
if C.Panel3 then F.CreatePanel(unpack(C.Panel3)) end
if C.Panel4 then F.CreatePanel(unpack(C.Panel4)) end
if C.Panel5 then F.CreatePanel(unpack(C.Panel5)) end