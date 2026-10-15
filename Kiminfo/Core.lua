local addon, ns = ... 
local C, F, G = unpack(ns)

-- multi version support prepare
--F.isNewPatch = select(4, GetBuildInfo()) >= 120000

--======================================================--
---------------	[[ Resource and Texture ]] ---------------
--======================================================--

-- 原生 tooltip 與 InfoPanel 共用的最低列高及文字上下留白。
G.TooltipRowHeight, G.TooltipRowPadding = 20, 0

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

-- 狀態圖示：左右各留 1px 透明邊，上下裁切置中；Y=-2 對齊文字。
G.AFK = "|T"..FRIENDS_TEXTURE_AFK..":13:15:0:-2:16:16:0:15:1:14|t"
G.DND = "|T"..FRIENDS_TEXTURE_DND..":13:15:0:-2:16:16:0:15:1:14|t"

G.Enable = "|cff55ff55"..ENABLE
G.Disable = "|cffff5555"..DISABLE

--================================================--
---------------	[[ Custom API ]]	 ---------------
--================================================--

-- 色碼轉換
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

-- 專用 GameTooltip：共用行距
F.Tooltip = CreateFrame("GameTooltip", G.addon.."Tooltip", UIParent, "GameTooltipTemplate")
F.Tooltip:SetScript("OnShow", GameTooltip_OnShow)

-- 設定最小行高
function F.ShowTooltip()
	local tooltip = F.Tooltip
	local spacing = G.TooltipRowPadding * 2

	for i = 1, tooltip:NumLines() do
		local left, right = tooltip:GetLeftLine(i), tooltip:GetRightLine(i)
		-- 原生框體重用文字列；先清除上次高度，避免較長內容撐高下一次。
		left:SetHeight(0)
		right:SetHeight(0)
		local height = math.max(G.TooltipRowHeight - spacing, left:GetStringHeight())
		if right:IsShown() then height = math.max(height, right:GetStringHeight()) end
		left:SetHeight(height)
		right:SetHeight(height)
	end
	tooltip:SetCustomLineSpacing(spacing)
	tooltip:Show()
end


--=========================================--
---------------	[[ Layout ]] ----------------
--=========================================--

local modules = {}

--[[
模組排版：Blizzard 原生能力與 Kiminfo 自訂配置
以下 Stat 指套用 HorizontalLayoutFrame 的模組框體；元素指其中的 Texture/FontString。

一、Blizzard 原生：排列模組內部元素，計算完整寬高

1. 建立排版框體
   CreateFrame("Frame", frameName, parent, "HorizontalLayoutFrame")
   -> local Stat = CreateFrame("Frame", G.addon.."module", UIParent, "HorizontalLayoutFrame")
   - Stat：模組使用的名稱，下同。
   - HorizontalLayoutFrame：Blizzard 原生橫向排版模板。
     依 layoutIndex 橫向排列內部的各個元素並管理錨點。
	 根據參與元素的現有寬高、spacing 與 Padding，計算並更新整個 Stat 的完整寬高。
     圖示尺寸及文字內容仍由模組設定，不是模板替每個子元素指定固定寬高。

2. 設定元素
   - 元素.layoutIndex：排列順序，數字由小到大且不可重複；未設定者不受模板管理，不計入模板提供的尺寸。
   - 元素.align：垂直對齊方式，.align = "center"：垂直置中；"bottom" 為置底，省略則置頂。
   - 元素.ignoreInLayout = true：排除該元素，不排列也不計入尺寸。
   - 參與排列的元素由模板管理錨點，不另外呼叫 SetPoint。

3. 設定間距與留白（未設定時皆為 0）
   - Stat.spacing：排版框體內相鄰元素的間距，設在 Stat，不是元素.spacing。
   - Stat.leftPadding/rightPadding：整個內容的左/右留白。
   - Stat.topPadding/bottomPadding：整個內容的上/下留白。
   - 元素也可設定同名四邊 Padding，在排列時加入該元素周圍的單獨留白。
   - 上述間距與留白均由原生模板處理，並計入 Stat 的完整尺寸。

4. 更新尺寸
   - 文字或元素尺寸更新完成後，呼叫一次 Stat:Layout()，重新排列並更新完整寬高。
   - 顯示框體時模板也會呼叫 Layout()，但不會自動監聽 SetText。

二、Kiminfo 自訂：註冊模組，排列整個 Stat 與各列背景

1. F.RegisterModule(name, Stat)：保存模組名稱與框體，供初始化時依配置排列。
2. C.Layout：指定各列起點、模組順序、內容內縮、個別模組 offset 與背景 panel。
3. C.Gap：不同 Stat 之間的共用間距，再加上該模組配置的額外水平 offset。
4. 本插件的 ADDON_LOADED 事件中，由 CreateLayout() 統一排列：
   - 第一個啟用模組使用該列起點、內縮與額外 offset；後繼模組接在前一個 Stat 的 RIGHT。
   - Core.lua 不處理模組內部結構，只使用原生模板算出的完整框體尺寸。
]]

-- 參數：模組名稱、CreateFrame 建立的完整框體物件名稱
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

-- 載入
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, loadedAddon)
	if loadedAddon ~= addon then return end
	self:UnregisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", nil)

	CreateLayout()
end)