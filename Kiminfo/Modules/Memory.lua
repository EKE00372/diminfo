local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Memory then return end

local format, min, max, sort, wipe = format, min, max, sort, wipe
local CreateFrame = CreateFrame
local GetNumAddOns, GetAddOnInfo, IsAddOnLoaded = GetNumAddOns, GetAddOnInfo, IsAddOnLoaded
local UpdateAddOnMemoryUsage, GetAddOnMemoryUsage = UpdateAddOnMemoryUsage, GetAddOnMemoryUsage
local collectgarbage, gcinfo = collectgarbage, gcinfo

local memoryTable, totalMemory  = {}, 0
local eventCount = 0

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Mem", UIParent)
	Stat:SetHitRectInsets(-30, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create icon ]]--
local Icon = Stat:CreateTexture(nil, "OVERLAY")
	Icon:SetSize(G.FontSize+6, G.FontSize+6)
	Icon:SetPoint("RIGHT", Stat, "LEFT", 0, 0)
	Icon:SetTexture(G.Mem)
	Icon:SetVertexColor(1, 1, 1)

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.MemoryPoint))
	Text:SetTextColor(1, 1, 1)
	Stat:SetAllPoints(Text)

--===============================================--
---------------    [[ format ]]     ---------------
--===============================================--

--[[ Format memory for tooltip list ]]--
local function formatMemory(value)
	if value > 1024 then
		return format("%.1f mb", value / 1024)
	else
		return format("%.0f kb", value)
	end
end

--[[ Format memory color for tooltip list ]]--
local function memoryColor(value, times)
	if not times then times = 1 end

	if value <= 1024*times then
		return 0, 1, 0
	elseif value <= 2048*times then
		return .75, 1, 0
	elseif value <= 3072*times then
		return 1, 1, 0
	elseif value <= 4096*times then
		return 1, .75, 0
	elseif value <= 8192*times then
		return 1, .5, 0
	else
		return 1, .1, 0
	end
end

--==============================================--
---------------    [[ Table ]]     ---------------
--==============================================--

--[[ Get enable addon number ]]--
local function updateMaxAddons()
	local numAddons = GetNumAddOns()
	local totalNum = 0
	
	for i = 1, numAddons do
		if IsAddOnLoaded(i) then
			totalNum = totalNum +1
		end
	end
	
	return totalNum
end
	
--[[ Get addon list ]]--
local function updateMemoryTable()
	local numAddons = GetNumAddOns()
	if numAddons == #memoryTable then return end

	wipe(memoryTable)
	
	for i = 1, numAddons do
		memoryTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
	end
end

--[[ Sort addon list ]]--
local function sortMemory(a, b)
	if a and b then
		return a[3] > b[3]
	end
end

--[[ Update addon memory ]]--
local function updateMemory()
	UpdateAddOnMemoryUsage()

	local total = 0
	for i = 1, #memoryTable do
		local value = memoryTable[i]
		value[3] = GetAddOnMemoryUsage(value[1])
		total = total + value[3]
	end
	sort(memoryTable, sortMemory)

	return total
end

--[[ Refresh Data text ]]--
local function RefreshText()
	updateMemoryTable()
	totalMemory = updateMemory()
	
	if totalMemory >= 1024 then
		Text:SetText(format("%.1fmb", totalMemory/1024))
	else
		Text:SetText(format("%.1fkb", totalMemory/1024))
	end
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Update when login ]]--
local function OnEvent(self)
	-- Setting
	if Kiminfo.AutoCollect == nil then
		-- I'm not sure but somebody said auto collect will make client crash so default false it
		Kiminfo.AutoCollect = false
	end
	
	-- Data text
	local totalNum = updateMaxAddons()
	Text:SetText(totalNum)
	self:SetAllPoints(Text)
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	
	-- Data text
	RefreshText()	-- Refresh at first, and get addon table for tooltip show
	Icon:SetVertexColor(0, 1, 1)
	Text:SetTextColor(0, 1, 1)
	
	-- Tooltip
	local maxAddOns = C.MaxAddOns
	local isShiftKeyDown = IsShiftKeyDown()
	local maxShown = isShiftKeyDown and #memoryTable or min(maxAddOns, #memoryTable)
	local numEnabled = 0

	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(ADDONS, 0, .6, 1)
	GameTooltip:AddLine(" ")

	-- List
	for i = 1, #memoryTable do
		local value = memoryTable[i]
		
		if value and IsAddOnLoaded(value[1]) then
			numEnabled = numEnabled + 1
			
			if numEnabled <= maxShown then
				GameTooltip:AddDoubleLine(value[2], formatMemory(value[3]), 1, 1, 1, memoryColor(value[3], 5))
			end
		end
	end
	
	-- Merge line when not shift key down / 合併統計行
	if not isShiftKeyDown and (numEnabled > maxAddOns) then
		local hiddenMemory = 0
		
		for i = (maxAddOns + 1), numEnabled do
			hiddenMemory = hiddenMemory + memoryTable[i][3]
		end
		
		GameTooltip:AddDoubleLine(format("%d %s (%s)", numEnabled - maxAddOns, L.Hidden, L.Shift), formatMemory(hiddenMemory), .6, .8, 1, .6, .8, 1)
	end

	-- Total
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L.DefaultUsage, formatMemory(gcinfo() - totalMemory), .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L.TotleUsage, formatMemory(collectgarbage("count")), .6, .8, 1, 1, 1, 1)
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.ManualCollect..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoCollect..(Kiminfo.AutoCollect and G.Enable or G.Disable)..G.RightButton)
	
	GameTooltip:Show()
end

local function OnLeave(self)
	-- Data text
	local totalNum = updateMaxAddons()
	Text:SetText(totalNum)
	
	-- Mouseover color
	Icon:SetVertexColor(1, 1, 1)
	Text:SetTextColor(1, 1, 1)
	
	-- Tooltip
	GameTooltip:Hide()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("ADDON_LOADED")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			local before = gcinfo()
			
			collectgarbage("collect")
			print(format("|cff66C6FF%s|r%s", L.Collected, formatMemory(before - gcinfo())))
		elseif btn == "RightButton" then
			Kiminfo.AutoCollect = not Kiminfo.AutoCollect
		else
			return
		end
		
		-- Update tooltip option show / 更新Tooltip內容
		OnEnter(self)
	end)
	
	--[[ Tooltip ]]-- 
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", OnLeave)

--=====================================================--
---------------    [[ Auto Collect ]]     ---------------
--=====================================================--

local autoCollect = CreateFrame("Frame")
	autoCollect:RegisterAllEvents()
	autoCollect:SetScript("OnEvent", function(self, event)
		if Kiminfo.AutoCollect == true then
			eventcount = eventCount + 1
			
			if InCombatLockdown() then return end
			if eventcount > 15000 or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
				collectgarbage("collect")
				eventcount = 0
			end
		end
	end)