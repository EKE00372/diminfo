local addon, ns = ... 
local C, F, G = unpack(ns)

G.IsTBC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)

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

-- 材質，尺寸，切邊1，切邊2
F.addIcon = function(texture, size, cut1, cut2)
	texture = texture and "|T"..texture..":"..size..":"..size..":0:0:50:50:"..cut1..":"..cut2..":"..cut1..":"..cut2.."|t" or ""
	return texture
end

-- 模組共用專用 tooltip，保留原生字型與自然列高。
F.Tooltip = CreateFrame("GameTooltip", G.addon.."Tooltip", UIParent, "GameTooltipTemplate")

function F.ShowTooltip()
	local tooltip = F.Tooltip
	-- 沿用當前原生 tooltip 的縮放與背景，不改動文字列尺寸。
	tooltip:SetScale(GameTooltip:GetScale())
	local source = GameTooltip.NineSlice
	NineSliceUtil.ApplyLayoutByName(tooltip.NineSlice, source:GetFrameLayoutType(), source:GetFrameLayoutTextureKit())
	tooltip.NineSlice:SetCenterColor(source:GetCenterColor())
	tooltip.NineSlice:SetBorderColor(source:GetBorderColor())
	tooltip.NineSlice:SetAlpha(source:GetAlpha())
	tooltip.NineSlice.Center:SetAlpha(source.Center:GetAlpha())
	tooltip:Show()
end

-- 創建框架
local function CreatePanel(style, parent, w, h, a)
	local panel = CreateFrame("Frame", nil, parent, style == "Glass" and "BackdropTemplate" or nil)
	local framelvl = parent:GetFrameLevel()
	
	-- 中間
    panel:SetWidth(w)
	panel:SetHeight(h)
	panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	panel:SetFrameStrata("BACKGROUND")
	panel:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	
	if style == "Glass" then
		panel:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			tile = false,
			edgeFile = G.Glow,
			edgeSize = 3,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		})
		panel:SetBackdropColor( .1, .1, .1, a)
		panel:SetBackdropBorderColor(0, 0, 0)
	elseif style == "Gradient" then
		local background = panel:CreateTexture(nil, "BACKGROUND")
		background:SetAllPoints(panel)
		background:SetTexture(G.Tex)
		background:SetVertexColor(.1, .1, .1, a)
		
		-- 左側漸變
		local left = panel:CreateTexture(nil, "BACKGROUND")
		left:SetSize(60, h)
		left:SetPoint("RIGHT", panel, "LEFT", 0, 0)
		left:SetTexture(G.Tex)
		left:SetGradient("HORIZONTAL", CreateColor(.1, .1, .1, 0), CreateColor(.1, .1, .1, a))
		
		-- 右側漸變
		local right = panel:CreateTexture(nil, "BACKGROUND")
		right:SetSize(80, h)
		right:SetPoint("LEFT", panel, "RIGHT", 0, 0)
		right:SetTexture(G.Tex)
		right:SetGradient("HORIZONTAL", CreateColor(.1, .1, .1, a), CreateColor(.1, .1, .1, 0))
	end
end

G.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
G.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
G.MiddleButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

G.Enable = "|cff55ff55"..ENABLE
G.Disable = "|cffff5555"..DISABLE

G.AFK = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
G.DND = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

local modules = {}

function F.RegisterModule(name, frame, horizontalInset)
	frame:SetFrameStrata("BACKGROUND")
	horizontalInset = horizontalInset or -5
	frame:SetHitRectInsets(horizontalInset, horizontalInset, -10, -10)
	-- 保留文字原來的精確尺寸，避免原生預設四捨五入推移後續模組。
	frame.usePreciseChildSizes = true
	frame:Hide()
	modules[name] = frame
end

local function CreateLayout()
	-- 列只提供定位；關閉背景或停用其中一項時，其餘模組仍依配置排列。
	for rowIndex, layout in ipairs(C.Layout) do
		local row, previous
		for _, entry in ipairs(layout.modules) do
			local frame = modules[entry[1]]
			if frame then
				if not row then
					local parent = layout.point[2]
					row = CreateFrame("Frame", G.addon.."Row"..rowIndex, parent)
					row:SetSize(1, 1)
					row:SetPoint(unpack(layout.point))
					row:SetFrameStrata("BACKGROUND")
					row:SetFrameLevel(parent:GetFrameLevel())
					if layout.panel then
						local width, height, alpha = unpack(layout.panel)
						CreatePanel(layout.style or "Gradient", row, width, height, alpha)
					end
				end

				local offset = entry[2] or 0
				frame:SetParent(row)
				frame:SetFrameLevel(row:GetFrameLevel() + 1)
				if previous then
					frame:SetPoint("LEFT", previous, "RIGHT", C.Gap + offset, 0)
				else
					frame:SetPoint("TOPLEFT", row, "TOPLEFT", layout.inset[1] + offset, layout.inset[2])
				end
				frame:Show()
				previous = frame
			end
		end
	end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, loadedAddon)
	if loadedAddon ~= addon then return end
	self:UnregisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", nil)
	CreateLayout()
end)