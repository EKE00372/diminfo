local _, ns = ...
local C, F = unpack(ns)

local Panel = {}
local activePanel
-- 保留資訊面板原有留白：外距 10、欄距 6、列距 3，右側 3、底部 2。
local padding, columnGap, rowGap = 10, 6, 3

local function RowClick(row, button)
	if row.onClick then
		row.onClick(row, row.data, button)
	end
end

local function AddRow(panel, kind, texts, data, onClick, isHeader)
	local index = panel.rowCount + 1
	local row = panel.rows[index]
	if not row then
		row = CreateFrame("Button", nil, panel.content)
		row.cells = {}
		row:SetScript("OnMouseUp", RowClick)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		panel.rows[index] = row
	end

	row.kind, row.data, row.onClick = kind, data, onClick
	row.separatorHeight = nil
	row:EnableMouse(onClick ~= nil)
	local cellCount = kind == "text" and 1 or kind == "separator" and 0 or #panel.columns
	for i = 1, cellCount do
		local cell = row.cells[i]
		if not cell then
			cell = row:CreateFontString(nil, "OVERLAY")
			cell:SetJustifyV("MIDDLE")
			row.cells[i] = cell
		end
		cell:SetFontObject(isHeader and GameTooltipHeaderText or GameTooltipText)
		cell:SetText(texts[i] ~= nil and tostring(texts[i]) or "")
		cell:SetShown(texts[i] ~= nil)
	end
	for i = cellCount + 1, #row.cells do row.cells[i]:Hide() end
	if row.separator and kind ~= "separator" then row.separator:Hide() end
	row:Show()
	panel.rowCount = index
	return row
end

-- 公告跨兩欄；需要額外寬度時平均擴大兩欄，保留原有欄位對齊。
local function MeasureColumns(panel)
	local widths = panel.columnWidths
	for i = 1, #panel.columns do widths[i] = 0 end
	local textWidth = 0
	for i = 1, panel.rowCount do
		local row = panel.rows[i]
		if row.kind ~= "separator" then
			for j, cell in ipairs(row.cells) do
				if cell:IsShown() then
					cell:ClearAllPoints()
					cell:SetWidth(0)
					cell:SetHeight(0)
					local width = cell:GetStringWidth()
					if row.kind == "text" then
						textWidth = math.max(textWidth, math.min(width, row.maxWidth))
					else
						widths[j] = math.max(widths[j], width)
					end
				end
			end
		end
	end
	local width = columnGap * (#widths - 1)
	for _, value in ipairs(widths) do width = width + value end
	if textWidth > width then
		local extra = (textWidth - width) / #widths
		for i = 1, #widths do widths[i] = widths[i] + extra end
		width = textWidth
	end
	return width + columnGap / 2
end

function Panel:Clear()
	for i = 1, self.rowCount do
		local row = self.rows[i]
		row:Hide()
		row.data, row.onClick = nil, nil
		for _, cell in ipairs(row.cells) do cell:SetText("") end
	end
	self.rowCount = 0
end

function Panel:AddHeader(left, right)
	return AddRow(self, "columns", {left, right}, nil, nil, true)
end

function Panel:AddLine(left, right)
	return AddRow(self, "columns", {left, right})
end

function Panel:AddRow(texts, data, onClick)
	return AddRow(self, "columns", texts, data, onClick)
end

function Panel:AddText(text, maxWidth)
	if not maxWidth then
		local width = MeasureColumns(self) + padding * 2
		maxWidth = width > 200 and width + 100 or 300
	end
	local row = AddRow(self, "text", {text})
	row.maxWidth = maxWidth
	return row
end

function Panel:AddSeparator(height, r, g, b, a)
	local row = AddRow(self, "separator", {})
	row.separatorHeight = height or 1
	if not row.separator then
		row.separator = row:CreateTexture(nil, "ARTWORK")
		row.separator:SetAllPoints()
		row.separator:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	end
	local color = NORMAL_FONT_COLOR
	row.separator:SetVertexColor(r or color.r, g or color.g, b or color.b, a or 1)
	row.separator:Show()
	return row
end

function Panel:SetScrollOffset(offset)
	offset = math.max(0, math.min(self.scrollRange, offset))
	self.scroll:SetVerticalScroll(offset)
	self.slider:SetValue(offset)
end

function Panel:Layout()
	local contentWidth = MeasureColumns(self)
	local spanWidth = contentWidth - columnGap / 2
	local y = 0
	for i = 1, self.rowCount do
		local row = self.rows[i]
		if i > 1 then y = y + rowGap end
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -y)
		row:SetWidth(contentWidth)
		local height = row.separatorHeight or 0
		local x = 0
		for j, cell in ipairs(row.cells) do
			if cell:IsShown() then
				local width = row.kind == "text" and spanWidth or self.columnWidths[j]
				cell:ClearAllPoints()
				cell:SetPoint("TOPLEFT", row, "TOPLEFT", x, 0)
				cell:SetJustifyH(row.kind == "text" and "LEFT" or self.columns[j].justify or "LEFT")
				cell:SetWidth(width)
				cell:SetHeight(0)
				height = math.max(height, cell:GetHeight())
			end
			if row.kind ~= "text" then x = x + (self.columnWidths[j] or 0) + columnGap end
		end
		row:SetHeight(math.max(1, height))
		for _, cell in ipairs(row.cells) do
			if cell:IsShown() then cell:SetHeight(height) end
		end
		y = y + height
	end
	local contentHeight = y + 2

	self:SetScale(GameTooltip:GetScale())
	local viewHeight = math.min(contentHeight, C.InfoPanel.maxHeight - padding * 2)
	self.scrollRange = contentHeight - viewHeight
	local scrolling = (self.scrollRange > 0)
	self:SetSize(contentWidth + padding * 2 + (scrolling and 20 or 0), viewHeight + padding * 2)
	self.scroll:SetSize(contentWidth, viewHeight)
	self.content:SetSize(contentWidth, contentHeight)
	self.slider:SetMinMaxValues(0, self.scrollRange)
	self.slider:SetShown(scrolling)
	self:SetScrollOffset(self.scroll:GetVerticalScroll())
end

function F.CreateInfoPanel(owner, columns)
	local panel = CreateFrame("Frame", nil, UIParent, "TooltipBackdropTemplate")
	Mixin(panel, Panel)
	panel.columns = columns
	panel.rows, panel.columnWidths, panel.rowCount = {}, {}, 0
	panel.scrollRange = 0
	panel:Hide()
	panel:SetFrameStrata("TOOLTIP")
	panel:SetClampedToScreen(true)
	panel:EnableMouse(true)

	local scroll = CreateFrame("ScrollFrame", nil, panel)
	scroll:SetPoint("TOPLEFT", padding, -padding)
	scroll:EnableMouseWheel(true)
	panel.scroll = scroll
	panel.content = CreateFrame("Frame", nil, scroll)
	scroll:SetScrollChild(panel.content)

	local slider = CreateFrame("Slider", nil, panel, "BackdropTemplate")
	slider:SetOrientation("VERTICAL")
	slider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -padding, -padding)
	slider:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -padding, padding)
	slider:SetWidth(12)
	slider:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true, edgeSize = 8, tileSize = 8,
		insets = {left = 3, right = 3, top = 3, bottom = 3},
	})
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
	slider:SetMinMaxValues(0, 0)
	slider:SetValueStep(1)
	slider:SetScript("OnValueChanged", function(_, value) scroll:SetVerticalScroll(value) end)
	slider:SetValue(0)
	slider:Hide()
	panel.slider = slider
	scroll:SetScript("OnMouseWheel", function(_, delta)
		panel:SetScrollOffset(scroll:GetVerticalScroll() - delta * 40)
	end)

	panel:SetScript("OnShow", function(self)
		if activePanel and activePanel ~= self then activePanel:Hide() end
		activePanel = self
		-- 使用當前原生 tooltip 的 NineSlice 外觀，不依賴舊的 GetBackdrop。
		local source = GameTooltip.NineSlice
		NineSliceUtil.ApplyLayoutByName(self.NineSlice, source:GetFrameLayoutType(), source:GetFrameLayoutTextureKit())
		self.NineSlice:SetCenterColor(source:GetCenterColor())
		self.NineSlice:SetBorderColor(source:GetBorderColor())
		self.NineSlice:SetAlpha(source:GetAlpha())
		self.NineSlice.Center:SetAlpha(source.Center:GetAlpha())
		self:ClearAllPoints()
		self:SetPoint(C.StickTop and "TOP" or "BOTTOM", owner, C.StickTop and "BOTTOM" or "TOP", 0, C.StickTop and -10 or 10)
		self.elapsed, self.outsideTime = 0, 0
	end)
	panel:SetScript("OnHide", function(self)
		self:Clear()
		self:SetScrollOffset(0)
		if activePanel == self then activePanel = nil end
	end)
	panel:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < .1 then return end
		if owner:IsMouseOver(10, -10, 0, 0) or self:IsMouseOver(10, -10, -10, 10) then
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
