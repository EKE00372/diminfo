local _, ns = ...
local C, F, G = unpack(ns)
local GameTooltip = F.Tooltip

-- Friends 和 Guild 的 tooltip 面板，管理資料列、排版及顯隱
local Panel = {}
local activePanel
-- 面板內距 (邊緣留白)、欄間距、捲軸占位寬度；皆計入 C.InfoPanel 的總尺寸上限。
local padding, columnGap, scrollBarSpace = 10, 10, 18

------

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

--[[
	panel：要加入這一列的 InfoPanel 面板物件，新 row 建在 panel.content 下。

	kind：列的種類，決定 Layout 如何排版；各種類的 texts 格式如下：
		"columns"：一般多欄資料，{第一欄文字, 第二欄文字, ...}，欄數須與 panel.columns 相同。
		"line"：左右單行文字，{左側文字, 右側文字}；公開 AddLine 會將省略值補成 ""。
		"text"：不分欄跨完整內容寬度的換行文字，{文字}，例如公會公告。
		"separator"：分隔列，{}；分隔線材質由公開 AddSeparator 接著建立／顯示。
texts：上述格式的連續文字陣列，空欄用 ""，不可用 nil 留洞。
data：這一列附帶的資料，例如好友帳號或公會成員資料；不解讀內容，原樣傳給 callback，可省略。
onClick：放開滑鼠按鍵時呼叫 onClick(row, data, button)，button 為滑鼠按鍵名稱，可省略 callback。
onEnter：滑鼠移入時呼叫 onEnter(row, data)，可省略；兩個 callback 都省略時不啟用滑鼠互動。
回傳本次建立／重用的 row 框體；只填入內容，加入全部資料後由 caller 統一呼叫 Layout()。
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
			cell = row:CreateFontString(nil, "OVERLAY", "GameTooltipText")
			cell:SetJustifyV("TOP")
			cell:SetHeight(0)
			cell:SetTextColor(1, 1, 1)
			row.cells[i] = cell
		end
		-- 同一 cell 可換成不同列型；清除舊寬度並更新換行規則，錨點統一交給 Layout。
		cell:SetWidth(0)
		cell:SetWordWrap(kind == "text")
		cell:SetNonSpaceWrap(kind == "text")
		cell:SetMaxLines(kind == "text" and 0 or 1)
		cell:SetText(text)
		cell:Show()
	end
	for i = #texts + 1, #row.cells do
		row.cells[i]:Hide()
	end
	if row.separator then row.separator:Hide() end
	row:Show()
	panel.rowCount = index
	return row
end

-- 供顯示中重畫：清內容、資料及 callback，保留框體；不隱藏面板、不重設捲動或關閉選單。
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

-- 加入一般資料列；欄寬及對齊沿用 CreateInfoPanel 的 columns 設定。
-- texts：依欄順序排列的文字，數量須與 columns 相同；空欄用 ""，不可用 nil 留洞。
-- data：原樣傳給 callback 的資料；onClick(row, data, button) 在放開滑鼠按鍵時呼叫。
-- onEnter(row, data)：滑鼠移入時呼叫；兩個 callback 皆可省略。回傳建立／重用的 row。
function Panel:AddRow(texts, data, onClick, onEnter)
	return AddRow(self, "columns", texts, data, onClick, onEnter)
end

-- 單行左右文字，適合標題／操作說明，不套用 columns；兩參數皆省略時留一空行。
-- 寬度不足時優先保留左側，右側只使用剩餘空間。
function Panel:AddLine(left, right)
	return AddRow(self, "line", {left or "", right or ""})
end

-- 跨完整內容寬度的換行文字，供公告／廣播使用，不占用名單的個別欄寬。
function Panel:AddText(text)
	return AddRow(self, "text", {text})
end

-- 分隔線橫跨內容區，不參與文字自然寬度的量測。
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

-- 模組將以 panel 為 owner 建立的原生選單存入 panel.menu，供關閉及停留判定使用。
function Panel:CloseMenu()
	-- Menu frame 可能已回 pool；只關閉仍屬於本面板的選單。
	if self.menu and self.menu:GetOwnerRegion() == self then
		self.menu:Close()
	end
	self.menu = nil
end

-- 加完全部內容後呼叫，計算欄寬、列高與捲動範圍；不負責開啟面板。
function Panel:Layout()
	local widths = self.columnWidths
	for i, column in ipairs(self.columns) do widths[i] = column.width or 1 end
	local fullWidth = 1
	-- 自然欄取該欄全部資料列的最大文字寬；標題／公告只影響整個面板的所需寬度。
	for i = 1, self.rowCount do
		local row = self.rows[i]
		if row.kind == "columns" then
			for j, column in ipairs(self.columns) do
				if not column.width then
					widths[j] = math.max(widths[j], row.cells[j]:GetUnboundedStringWidth())
				end
			end
		elseif row.kind ~= "separator" then
			local width = row.cells[1]:GetUnboundedStringWidth()
			if row.kind == "line" and row.cells[2]:GetText() ~= "" then
				width = width + columnGap + row.cells[2]:GetUnboundedStringWidth()
			end
			fullWidth = math.max(fullWidth, width)
		end
	end

	local naturalWidth = columnGap * (#widths - 1)
	for _, width in ipairs(widths) do naturalWidth = naturalWidth + width end
	local wantedWidth = math.max(naturalWidth, fullWidth)
	local maxWidth = math.min(C.InfoPanel.maxWidth, UIParent:GetWidth())
	local maxHeight = math.min(C.InfoPanel.maxHeight, UIParent:GetHeight())
	local contentWidth, contentHeight, scrolling

	-- 先不留捲軸；只有超高才再排一次，將捲軸占位算入同一總寬上限。
	for pass = 1, 2 do
		local scrollWidth = scrolling and scrollBarSpace or 0
		contentWidth = math.min(wantedWidth, maxWidth - padding * 2 - scrollWidth)
		local overflow = naturalWidth - contentWidth
		-- 超寬時由右向左縮減自然欄，固定欄不縮；上限不足容納固定配置時明確報錯。
		for i = #widths, 1, -1 do
			if overflow > 0 and not self.columns[i].width then
				local reduction = math.min(overflow, widths[i] - 1)
				widths[i] = widths[i] - reduction
				overflow = overflow - reduction
			end
		end
		assert(overflow <= 0, "Kiminfo: InfoPanel.maxWidth is too small for the fixed columns")
		naturalWidth = math.min(naturalWidth, contentWidth)

		local y = 0
		for i = 1, self.rowCount do
			local row = self.rows[i]
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -y)
			row:SetWidth(contentWidth)
			local height = G.TooltipRowHeight
			if row.kind == "separator" then
				height = 5
			elseif row.kind == "columns" then
				local x = 0
				for j, column in ipairs(self.columns) do
					local cell = row.cells[j]
					cell:ClearAllPoints()
					cell:SetPoint("TOPLEFT", row, "TOPLEFT", x, -G.TooltipRowPadding)
					cell:SetWidth(widths[j])
					cell:SetJustifyH(column.justify or "LEFT")
					height = math.max(height, cell:GetStringHeight() + G.TooltipRowPadding * 2)
					x = x + widths[j] + columnGap
				end
			elseif row.kind == "text" then
				local cell = row.cells[1]
				cell:ClearAllPoints()
				cell:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -G.TooltipRowPadding)
				cell:SetWidth(contentWidth)
				cell:SetJustifyH("LEFT")
				height = math.max(height, cell:GetStringHeight() + G.TooltipRowPadding * 2)
			else
				local left, right = row.cells[1], row.cells[2]
				local leftWidth = math.min(left:GetUnboundedStringWidth(), contentWidth)
				local rightWidth = math.min(right:GetUnboundedStringWidth(), math.max(0, contentWidth - leftWidth - columnGap))
				left:ClearAllPoints()
				left:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -G.TooltipRowPadding)
				left:SetWidth(math.max(1, contentWidth - rightWidth - (rightWidth > 0 and columnGap or 0)))
				left:SetJustifyH("LEFT")
				right:ClearAllPoints()
				right:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -G.TooltipRowPadding)
				right:SetWidth(math.max(1, rightWidth))
				right:SetJustifyH("RIGHT")
				right:SetShown(rightWidth > 0)
				height = math.max(height, left:GetStringHeight() + G.TooltipRowPadding * 2, right:GetStringHeight() + G.TooltipRowPadding * 2)
			end
			row:SetHeight(height)
			y = y + height
		end
		contentHeight = math.max(1, y)
		if scrolling or contentHeight + padding * 2 <= maxHeight then break end
		scrolling = true
	end

	local viewHeight = math.min(contentHeight, maxHeight - padding * 2)
	self:SetSize(contentWidth + padding * 2 + (scrolling and scrollBarSpace or 0), viewHeight + padding * 2)
	self.scroll:SetSize(contentWidth, viewHeight)
	self.content:SetSize(contentWidth, contentHeight)
	self.scrollRange = math.max(0, contentHeight - viewHeight)
	self.scrollBar:SetShown(scrolling == true)
	self.scrollBar:SetMinMaxValues(0, self.scrollRange)
	-- 重畫後沿用捲動位置；名單變短時限制在新的可捲動範圍內。
	local offset = math.min(self.scroll:GetVerticalScroll(), self.scrollRange)
	self.scrollBar:SetValue(offset)
	self.scroll:SetVerticalScroll(offset)
end

-- 建立初始隱藏的面板，實際父框體為 UIParent；模組各自保留並重用回傳的 panel。
-- owner：來源資訊列框體，提供定位、滑鼠停留判定及隱藏時同步關閉的生命週期。
-- columns：依顯示順序排列的欄位設定，例如 {{width = 20}, {}, {justify = "RIGHT"}}。
--   width：固定內容欄寬（不含欄間距）；省略則取整份名單中該欄的最大自然寬，不隨捲動改變。
--   justify：該欄文字的 LEFT／CENTER／RIGHT 對齊，省略為 LEFT。
-- C.InfoPanel.maxWidth／maxHeight：面板總尺寸上限，含內距與捲軸占位，另受 UIParent 尺寸限制。
-- 開啟：加入內容 → Layout() → Show()；顯示中重畫：Clear() → 加入內容 → Layout()。
function F.CreateInfoPanel(owner, columns)
	local panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	Mixin(panel, Panel)
	panel.columns = columns
	panel.rows, panel.columnWidths, panel.rowCount = {}, {}, 0
	panel:Hide()
	panel:SetFrameStrata("TOOLTIP")
	panel:SetClampedToScreen(true)
	panel:EnableMouse(true)
	panel:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
	panel:SetBackdropColor(.04, .04, .04, .95)
	panel:SetBackdropBorderColor(.3, .3, .3, 1)

	local scroll = CreateFrame("ScrollFrame", nil, panel)
	scroll:SetPoint("TOPLEFT", padding, -padding)
	scroll:EnableMouseWheel(true)
	panel.scroll = scroll
	panel.content = CreateFrame("Frame", nil, scroll)
	scroll:SetScrollChild(panel.content)

	local scrollBar = CreateFrame("Slider", nil, panel)
	scrollBar:EnableMouse(true)
	scrollBar:SetPoint("TOPRIGHT", -padding, -padding)
	scrollBar:SetPoint("BOTTOMRIGHT", -padding, padding)
	scrollBar:SetWidth(10)
	scrollBar:SetOrientation("VERTICAL")
	scrollBar:SetValueStep(20)
	scrollBar:SetObeyStepOnDrag(false)
	scrollBar:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
	local thumb = scrollBar:GetThumbTexture()
	thumb:SetSize(10, 24)
	thumb:SetVertexColor(.6, .8, 1, .8)
	panel.scrollBar = scrollBar
	scrollBar:SetScript("OnValueChanged", function(_, value)
		scroll:SetVerticalScroll(value)
	end)
	scroll:SetScript("OnMouseWheel", function(_, delta)
		scrollBar:SetValue(math.max(0, math.min(panel.scrollRange, scroll:GetVerticalScroll() - delta * 40)))
	end)

	-- 開啟時依 StickTop 定位，並關閉另一個社交面板。
	panel:SetScript("OnShow", function(self)
		if activePanel and activePanel ~= self then activePanel:Hide() end
		activePanel = self
		self:ClearAllPoints()
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
	-- 面板四邊保留 10 單位的停留範圍，涵蓋與 owner 的空隙；只擴判定、不改點擊範圍。
	-- 僅顯示期間檢查，離開保留範圍約 0.2 秒後關閉。
	-- 自有角色選單開啟時繼續保留面板，不以此輪詢好友／公會資料。
	panel:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < .1 then return end
		local menuOpen = (self.menu and self.menu:GetOwnerRegion() == self and self.menu:IsShown())
		if owner:IsMouseOver() or self:IsMouseOver(10, -10, -10, 10) or menuOpen then
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
