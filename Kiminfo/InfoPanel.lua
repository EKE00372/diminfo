local _, ns = ...
local C, F, G = unpack(ns)
local GameTooltip = F.Tooltip

-- Friends 和 Guild 的 tooltip 面板，管理資料列、排版及顯隱
local Panel = {}
local activePanel
-- 面板內距 (邊緣留白) 與欄間距；皆計入 C.InfoPanel 的尺寸上限。
local padding, columnGap = 10, 10

--======================================--
---------------	[[ Rows ]] ---------------
--======================================--

-- 橫向：資料列（row）；直向：欄位（column）

local function RowLeave(row)
	if GameTooltip:GetOwner() == row then
		GameTooltip:Hide()
	end
end

local function RowEnter(row)
	if row.onEnter then
		row.onEnter(row, row.data)
	end
end

local function RowClick(row, button)
	if row.onClick then
		RowLeave(row)
		row.onClick(row, row.data, button)
	end
end

-- 建立資料列
--[[
	panel：要加入這一列的 InfoPanel 面板物件，新 row 建在 panel.content 下。
	kind：列的種類，決定 Layout 如何排版；各種類的 texts 格式如下：
		"columns"：一般多欄資料，{第一欄文字, 第二欄文字, ...}，欄數須與 panel.columns 相同。
		"line"：左右單行文字，{左側文字, 右側文字}；公開 AddLine 會將省略值補成 ""。
		"text"：不分欄跨完整內容寬度的換行文字，{文字}，例如公會公告。
		"separator"：分隔列，{}；分隔線材質由公開 AddSeparator 接著建立／顯示。
	texts：上述格式的連續文字陣列，空欄用 ""，不可用 nil。
	data：這一列附帶的資料，例如好友帳號或公會成員資料；不解讀內容，原樣傳給 callback，可省略。
	onClick：點擊 callback，可省略；等同 onClick(row, data, button)，button 為滑鼠按鍵名稱。
	onEnter：指向 callback，可省略，等同 onEnter(row, data)。
	兩個都省略時不啟用滑鼠互動。
]]--
local function AddRow(panel, kind, texts, data, onClick, onEnter)
	local index = panel.rowCount + 1
	local row = panel.rows[index]
	if not row then
		row = CreateFrame("Button", nil, panel.content)
		row.cells = {}
		row:SetScript("OnMouseUp", RowClick)
		row:SetScript("OnEnter", RowEnter)
		row:SetScript("OnLeave", RowLeave)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		panel.rows[index] = row
	end

	row.kind, row.data = kind, data
	row.onClick, row.onEnter = onClick, onEnter
	row:EnableMouse(onClick ~= nil or onEnter ~= nil)
	for i, text in ipairs(texts) do
		local cell = row.cells[i]
		if not cell then
			-- 與原生 tooltip 一致：第一列左右兩欄使用標題字型，其餘使用內文字型。
			cell = row:CreateFontString(nil, "OVERLAY", index == 1 and "GameTooltipHeaderText" or "GameTooltipText")
			cell:SetJustifyV("MIDDLE")
			cell:SetHeight(0)
			cell:SetTextColor(1, 1, 1)
			row.cells[i] = cell
		end
		-- 重設該列格式後復用，不重覆創建資料列
		cell:SetWordWrap(kind == "text")
		cell:SetNonSpaceWrap(kind == "text")
		cell:SetMaxLines(kind == "text" and 0 or 1)
		cell:SetText(text)
		cell:Show()
	end
	for i = #texts + 1, #row.cells do
		row.cells[i]:Hide()
	end
	if row.separator and kind ~= "separator" then row.separator:Hide() end
	row:Show()
	panel.rowCount = index
	return row
end

--=======================================--
---------------	[[ Panel ]] ---------------
--=======================================--

-- 重設面板：面板開啟時資料有更新，清空現有面板內容
function Panel:Clear()
	for i = 1, self.rowCount do
		local row = self.rows[i]
		RowLeave(row)
		row:Hide()
		row.data, row.onClick, row.onEnter = nil, nil, nil
		for _, cell in ipairs(row.cells) do cell:SetText("") end
	end
	self.rowCount = 0
end

-- 加入資料列：分成四個外部入口，易讀性佳

-- 多欄：可指定單欄寬度，滑鼠行為 callback 可省略；寬度不足時優先保留左側，右側只使用剩餘空間。
function Panel:AddRow(texts, data, onClick, onEnter)
	return AddRow(self, "columns", texts, data, onClick, onEnter)
end

-- 雙欄：固定左右兩側，不可指定單欄寬度；寬度不足時優先保留左側，右側只使用剩餘空間。
function Panel:AddLine(left, right)
	return AddRow(self, "line", {left or "", right or ""})
end

-- 單欄：公告、廣播等，不參與總寬計算。
function Panel:AddText(text)
	return AddRow(self, "text", {text})
end

-- 分隔線：不參與總寬計算。
function Panel:AddSeparator()
	local row = AddRow(self, "separator", {})
	if not row.separator then
		row.separator = row:CreateTexture(nil, "ARTWORK")
		row.separator:SetColorTexture(.6, .8, 1, .6)
		row.separator:SetPoint("LEFT", 0, 0)
		row.separator:SetPoint("RIGHT", 0, 0)
		row.separator:SetHeight(1)
	end
	row.separator:Show()
end

-- 關閉額外選單：控制"邀請多開角色的好友時才會顯示的額外選單"，於好友的列表更新/面板關閉時一同關閉
function Panel:CloseMenu()
	if self.menu and self.menu:GetOwnerRegion() == self then
		self.menu:Close()
	end
	self.menu = nil
end

-- 捲動位置與方向箭頭示
function Panel:SetScrollOffset(offset)
	offset = math.max(0, math.min(self.scrollRange, offset))
	self.scroll:SetVerticalScroll(offset)
	self.scrollHint:SetText(G.OptionColor..(offset == 0 and "▼  ▼" or offset == self.scrollRange and "▲  ▲" or "▲  ▼"))
end

-- 計算尺寸與排列位置：底部方向箭頭額外加高，不占 maxHeight 的內容高度額度
function Panel:Layout()
	-- [[ 計算總寬 ]] --
	local widths = self.columnWidths
	for i, column in ipairs(self.columns) do widths[i] = column.width or 1 end
	local fullWidth = 1

	-- 自然欄取該欄全部資料列的最大文字寬度；單欄與分隔線不參與總寬計算，待總寬確定後再排列
	-- 戰網名稱的 kstring 無法取得自然寬；參考原生做法，清除先前寬度後讀 GetWidth
	for i = 1, self.rowCount do
		local row = self.rows[i]
		if row.kind == "columns" then
			for j, column in ipairs(self.columns) do
				if not column.width then
					local cell = row.cells[j]
					cell:SetWidth(0)
					widths[j] = math.max(widths[j], cell:GetWidth())
				end
			end
		elseif row.kind == "line" then
			local left, right = row.cells[1], row.cells[2]
			left:SetWidth(0)
			right:SetWidth(0)
			local width = left:GetWidth()
			if right:GetText() ~= "" then
				width = width + columnGap + right:GetWidth()
			end
			fullWidth = math.max(fullWidth, width)
		end
	end

	local naturalWidth = columnGap * (#widths - 1)
	for _, width in ipairs(widths) do naturalWidth = naturalWidth + width end
	local wantedWidth = math.max(naturalWidth, fullWidth)
	local maxWidth = math.min(C.InfoPanel.maxWidth, UIParent:GetWidth())
	local contentWidth = math.min(wantedWidth, maxWidth - padding * 2)
	local overflow = naturalWidth - contentWidth
	-- 超寬時由右向左縮減自然欄寬度，固定欄不縮。
	for i = #widths, 1, -1 do
		if overflow > 0 and not self.columns[i].width then
			local reduction = math.min(overflow, widths[i] - 1)
			widths[i] = widths[i] - reduction
			overflow = overflow - reduction
		end
	end

	local y = 0
	for i = 1, self.rowCount do
		local row = self.rows[i]
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -y)
		row:SetWidth(contentWidth)
		-- 文字垂直置中，上下留白計入列高
		local height = G.TooltipRowHeight
		if row.kind == "separator" then
			height = 5
		elseif row.kind == "columns" then
			local x = 0
			for j, column in ipairs(self.columns) do
				local cell = row.cells[j]
				cell:ClearAllPoints()
				cell:SetPoint("LEFT", row, "LEFT", x, 0)
				cell:SetWidth(widths[j])
				cell:SetJustifyH(column.justify or "LEFT")
				height = math.max(height, cell:GetStringHeight() + G.TooltipRowPadding * 2)
				x = x + widths[j] + columnGap
			end
		elseif row.kind == "text" then
			local cell = row.cells[1]
			cell:ClearAllPoints()
			cell:SetPoint("LEFT", row, "LEFT", 0, 0)
			cell:SetWidth(contentWidth)
			cell:SetJustifyH("LEFT")
			height = math.max(height, cell:GetStringHeight() + G.TooltipRowPadding * 2)
		else
			local left, right = row.cells[1], row.cells[2]
			local leftWidth = left:GetWidth()
			local rightWidth = math.min(right:GetWidth(), math.max(0, contentWidth - leftWidth - columnGap))
			left:ClearAllPoints()
			left:SetPoint("LEFT", row, "LEFT", 0, 0)
			left:SetWidth(math.max(1, contentWidth - rightWidth - (rightWidth > 0 and columnGap or 0)))
			left:SetJustifyH("LEFT")
			right:ClearAllPoints()
			right:SetPoint("RIGHT", row, "RIGHT", 0, 0)
			right:SetWidth(math.max(1, rightWidth))
			right:SetJustifyH("RIGHT")
			right:SetShown(rightWidth > 0)
			height = math.max(height, left:GetStringHeight() + G.TooltipRowPadding * 2, right:GetStringHeight() + G.TooltipRowPadding * 2)
		end
		row:SetHeight(height)
		y = y + height
	end
	local contentHeight = math.max(1, y)

	-- [[ 計算總高 ]] --
	local viewHeight = math.min(contentHeight, C.InfoPanel.maxHeight - padding * 2)
	self.scrollRange = math.max(0, contentHeight - viewHeight)
	local scrolling = (self.scrollRange > 0)
	self:SetSize(contentWidth + padding * 2, viewHeight + padding * 2 + (scrolling and G.TooltipRowHeight or 0))
	self.scroll:SetSize(contentWidth, viewHeight)
	self.content:SetSize(contentWidth, contentHeight)
	self.scrollHint:SetShown(scrolling)
	-- 重畫後沿用捲動位置；名單變短時限制在新的可捲動範圍內。
	self:SetScrollOffset(self.scroll:GetVerticalScroll())
end


--[[
	建立初始隱藏的面板
	父框體為 UIParent；模組各自保留並重用回傳的 panel
	owner：就是模組的 stat，用於定位和指向判斷
	columns：依顯示順序排列的欄位設定
		width：不含欄間距的固定欄寬，省略則取整份名單中該欄的最大自然寬
		justify：該欄文字水平對齊方向，預設 LEFT。
		例：{{width = 20}, {}, {justify = "RIGHT"}} = 第一欄20寬，第二欄不指定，第三欄靠右對齊
	
	C.InfoPanel.maxWidth/maxHeight：內容面板尺寸上限，含內距
	超高時底部額外加一列 G.TooltipRowHeight 的方向提示，不計入 maxHeight

	開啟：加入內容 → Layout() → Show()
	顯示中重繪：Clear() → 加入內容 → Layout()
]]--
function F.CreateInfoPanel(owner, columns)
	local panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	Mixin(panel, Panel)
	panel.columns = columns
	panel.rows, panel.columnWidths, panel.rowCount = {}, {}, 0
	panel:Hide()
	panel:SetFrameStrata("TOOLTIP")
	panel:SetClampedToScreen(true)
	panel:EnableMouse(true)
	panel:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	panel:SetBackdropBorderColor(.3, .3, .3, 1)

	local background = panel:CreateTexture(nil, "BACKGROUND")
	background:SetPoint("TOPLEFT", 1, -1)
	background:SetPoint("BOTTOMRIGHT", -1, 1)

	local scroll = CreateFrame("ScrollFrame", nil, panel)
	scroll:SetPoint("TOPLEFT", padding, -padding)
	scroll:EnableMouseWheel(true)
	panel.scroll = scroll
	panel.content = CreateFrame("Frame", nil, scroll)
	scroll:SetScrollChild(panel.content)

	local scrollHint = panel:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	local font, _, flags = scrollHint:GetFont()
	scrollHint:SetFont(font, 20, flags)
	scrollHint:SetHeight(G.TooltipRowHeight)
	scrollHint:SetPoint("TOP", scroll, "BOTTOM", 0, 0)
	scrollHint:SetJustifyH("CENTER")
	scrollHint:SetJustifyV("MIDDLE")
	panel.scrollHint = scrollHint
	scroll:SetScript("OnMouseWheel", function(_, delta)
		panel:SetScrollOffset(scroll:GetVerticalScroll() - delta * 40)
	end)

	panel:SetScript("OnShow", function(self)
		-- 同時只顯示一個面板
		if activePanel and activePanel ~= self then activePanel:Hide() end
		activePanel = self
		-- 沿用原生 GameTooltip 背景材質及透明度
		background:SetAtlas(_G.GameTooltip.NineSlice.Center:GetAtlas())
		background:SetVertexColor(_G.GameTooltip.NineSlice:GetCenterColor())
		background:SetAlpha(_G.GameTooltip.NineSlice.Center:GetAlpha())
		self:ClearAllPoints()
		-- 依 StickTop 定位
		self:SetPoint(C.StickTop and "TOP" or "BOTTOM", owner, C.StickTop and "BOTTOM" or "TOP", 0, C.StickTop and -10 or 10)
		self.elapsed, self.outsideTime = 0, 0
	end)
	-- 關閉時一併清除內容、捲動與自有選單；模組的 OnHide hook 另處理自身狀態。
	panel:SetScript("OnHide", function(self)
		self:CloseMenu()
		self:Clear()
		self.scroll:SetVerticalScroll(0)
		if activePanel == self then activePanel = nil end
	end)
	-- 模組的上下判定對齊 Core 的 hit rect；面板四邊保留 10 單位，離開 0.2 秒後關閉。
	panel:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < .1 then return end
		local menuOpen = (self.menu and self.menu:GetOwnerRegion() == self and self.menu:IsShown())
		if owner:IsMouseOver(10, -10, 0, 0) or self:IsMouseOver(10, -10, -10, 10) or menuOpen then
			self.outsideTime = 0
		else
			self.outsideTime = self.outsideTime + self.elapsed
			if self.outsideTime >= .2 then self:Hide() end
		end
		self.elapsed = 0
	end)
	owner:HookScript("OnHide", function() panel:Hide() end)
	return panel
end
