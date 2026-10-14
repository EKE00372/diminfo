local addon, ns = ... 
local C, F, G = unpack(ns)

-- multi version support prepare
--F.isNewPatch = select(4, GetBuildInfo()) >= 120000

--=========================================--
---------------	[[ Convert ]] ---------------
--=========================================--

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

--===================================================--
---------------	[[ Custom api ]]	 ---------------
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

--=========================================--
---------------	[[ Texture ]] ---------------
--=========================================--

-- 材質，為免被瞎改還是藏起來吧
G.Bags = G.MediaFolder.."bags.tga"
G.Friends = G.MediaFolder.."friends.tga"
G.Guild = G.MediaFolder.."guild.tga"
G.Dura = G.MediaFolder.."dura.tga"
G.Fps = G.MediaFolder.."fps.tga"
G.Ping = G.MediaFolder.."ping.tga"
G.Mem = G.MediaFolder.."spell.tga"
G.Alliance = G.MediaFolder.."Alliance"
G.Horde = G.MediaFolder.."Horde"

--G.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
--G.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
--G.MiddleButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

G.LeftButton = " |T"..G.MediaFolder.."MouseButtonOrange.tga:13:11:0:-2:128:32:4:28:0:32|t "
G.RightButton = " |T"..G.MediaFolder.."MouseButtonOrange.tga:13:11:0:-2:128:32:36:60:0:32|t "
G.MiddleButton = " |T"..G.MediaFolder.."MouseButtonOrange.tga:13:11:0:-2:128:32:68:92:0:32|t "

G.AFK = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:-1:16:16:1:15:1:15|t"
G.DND = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:-1:16:16:1:15:1:15|t"

G.Enable = "|cff55ff55"..ENABLE
G.Disable = "|cffff5555"..DISABLE

--=========================================--
---------------	[[ Layout ]] ----------------
--=========================================--

local modules = {}

--[[
HorizontalLayoutFrame：Blizzard 內建的橫向排版模板

1. 建立模組框體
   CreateFrame("Frame", frameName, parent, "HorizontalLayoutFrame")
   - "Frame"：建立的框體類型。
   - frameName：全域框體名稱；不需要名稱時可填 nil。
   - parent：父框體，例如 UIParent。
   - "HorizontalLayoutFrame"：套用橫向排版與自動計算尺寸的模板。

2. 設定內部元素（Texture/FontString）
   - 元素.layoutIndex：排列順序，數字由小到大且不可重複；未設定就不參與排列。
   - 元素.align = "center"：垂直置中；"bottom" 為置底，省略則置頂。
   - 元素.ignoreInLayout = true：排除該元素，不排列也不計入尺寸。
   - 參與排列的元素由模板管理錨點，不另外呼叫 SetPoint。

3. 設定間距與留白
   - Stat.spacing：模組內部元素之間的間距，預設為 0。
   - C.Gap：不同模組之間的間距，由 Core.lua 處理。
   - leftPadding/rightPadding：左/右留白。
   - topPadding/bottomPadding：上/下留白。
   - Padding 設在 Stat 上是整個內容的外圍留白；設在元素上是該元素的留白。

4. 更新尺寸與交給核心排列
   - 文字或元素尺寸更新完成後，呼叫一次 Stat:Layout()。
   - Layout() 重新排列內部元素，並更新 Stat 的完整寬高。
   - 顯示框體時模板也會呼叫 Layout()，但不會自動監聽 SetText。
   - F.RegisterModule(name, Stat) 註冊模組名稱與完整框體物件。
   - Core.lua 只將下一個模組接在前一個 Stat 的 RIGHT，不處理內部結構。
]]

-- 模組名稱、CreateFrame 建立的完整框體物件名稱
function F.RegisterModule(name, frame)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetHitRectInsets(0, 0, -10, -10)
	frame:Hide()

	modules[name] = frame
end

-- 依配置建立各列背景與模組排列，僅在初始化時呼叫。
local function CreateLayout()
	for rowIndex, layout in ipairs(C.Layout) do
		local row, previous
		for _, entry in ipairs(layout.modules) do
			local frame = modules[entry[1]]
			if frame then
				if not row then
					-- 列只提供定位；背景關閉也保留同一個內容起點。
					row = CreateFrame("Frame", G.addon.."Row"..rowIndex, layout.point[2])
					row:SetSize(1, 1)
					row:SetPoint(unpack(layout.point))
					row:SetFrameStrata("BACKGROUND")

					if layout.panel then
						local width, height, alpha = unpack(layout.panel)
						local panel = CreateFrame("Frame", nil, row)
						panel:SetSize(width, height)
						panel:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
						panel:SetFrameLevel(row:GetFrameLevel())

						local background = panel:CreateTexture(nil, "BACKGROUND")
						background:SetAllPoints(panel)
						background:SetTexture(G.Tex)
						background:SetVertexColor(.1, .1, .1, alpha)

						-- 漸層同屬 panel，顯隱與層級不再由獨立 sibling frame 管理。
						local left = panel:CreateTexture(nil, "BACKGROUND")
						left:SetSize(60, height)
						left:SetPoint("RIGHT", panel, "LEFT", 0, 0)
						left:SetTexture(G.Tex)
						left:SetGradient("HORIZONTAL", CreateColor(.1, .1, .1, 0), CreateColor(.1, .1, .1, alpha))

						local right = panel:CreateTexture(nil, "BACKGROUND")
						right:SetSize(80, height)
						right:SetPoint("LEFT", panel, "RIGHT", 0, 0)
						right:SetTexture(G.Tex)
						right:SetGradient("HORIZONTAL", CreateColor(.1, .1, .1, alpha), CreateColor(.1, .1, .1, 0))
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

-- 等所有模組完成建立才串接，排列順序不依賴 Modules.xml 的載入順序
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, loadedAddon)
	if loadedAddon ~= addon then return end
	self:UnregisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", nil)

	CreateLayout()
end)