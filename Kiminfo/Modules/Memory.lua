local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Memory then return end

local GameTooltip = F.Tooltip
local format, min, sort, wipe = string.format, min, sort, table.wipe
local CreateFrame = CreateFrame
local C_AddOns_GetNumAddOns, C_AddOns_GetAddOnInfo, C_AddOns_IsAddOnLoaded = C_AddOns.GetNumAddOns, C_AddOns.GetAddOnInfo, C_AddOns.IsAddOnLoaded
local UpdateAddOnMemoryUsage, GetAddOnMemoryUsage = UpdateAddOnMemoryUsage, GetAddOnMemoryUsage
local collectgarbage, gcinfo = collectgarbage, gcinfo

local memoryTable, totalMemory  = {}, 0
local eventCount = 0
local autoCollect = CreateFrame("Frame")

--==========================================--
---------------	[[ Elements ]] ---------------
--==========================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Mem", UIParent, "HorizontalLayoutFrame")

--[[ Create icon ]]--
local Icon = Stat:CreateTexture(nil, "OVERLAY")
	Icon.layoutIndex = 1
	Icon.align = "center"
	Icon:SetSize(G.FontSize+6, G.FontSize+6)
	Icon:SetTexture(G.Mem)
	Icon:SetVertexColor(1, 1, 1)

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 2
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetTextColor(1, 1, 1)
	F.RegisterModule("Memory", Stat)

--========================================--
---------------	[[ format ]] ---------------
--========================================--

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

--=======================================--
---------------	[[ Table ]]	---------------
--=======================================--

--[[ Get enable addon number ]]--
local function updateMaxAddons()
	local numAddons = C_AddOns_GetNumAddOns()
	local totalNum = 0
	
	for i = 1, numAddons do
		if C_AddOns_IsAddOnLoaded(i) then
			totalNum = totalNum +1
		end
	end
	
	return totalNum
end
	
--[[ Get addon list ]]--
local function updateMemoryTable()
	local numAddons = C_AddOns_GetNumAddOns()
	if numAddons == #memoryTable then return end

	wipe(memoryTable)
	
	for i = 1, numAddons do
		memoryTable[i] = {i, select(2, C_AddOns_GetAddOnInfo(i)), 0}
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
		Text:SetText(format("%.1fmb", totalMemory/1024))
	end
	Stat:Layout()
end

--=========================================--
---------------	[[ Updates ]] ---------------
--=========================================--

-- [[ Register switch ]]--
local function updateAutoCollect()
	if Kiminfo.AutoCollect then
		autoCollect:RegisterAllEvents()
	else
		autoCollect:UnregisterAllEvents()
		eventCount = 0
	end
end

--[[ Update when login ]]--
local function OnEvent(self, event, loadedAddon)
	-- Setting
	if event == "ADDON_LOADED" then
		if loadedAddon ~= addon then return end

		if Kiminfo.AutoCollect == nil then
			-- I'm not sure but somebody said auto collect will make client crash so default false it
			Kiminfo.AutoCollect = false
		end

		updateAutoCollect()
		self:UnregisterEvent("ADDON_LOADED")
	end
	
	-- Data text
	local totalNum = updateMaxAddons()
	Text:SetText(totalNum)
	self:Layout()
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
	local hiddenMemory = 0

	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(G.TitleColor..ADDONS)
	GameTooltip:AddLine(" ")

	-- List
	for i = 1, #memoryTable do
		local value = memoryTable[i]
		
		if value and C_AddOns_IsAddOnLoaded(value[1]) then
			numEnabled = numEnabled + 1
			
			if numEnabled <= maxShown then
				GameTooltip:AddDoubleLine(value[2], formatMemory(value[3]), 1, 1, 1, memoryColor(value[3], 5))
			else
				hiddenMemory = hiddenMemory + value[3]
			end
		end
	end

	-- Merge line when not shift key down / 合併統計行
	if numEnabled > maxShown then
		GameTooltip:AddDoubleLine(G.OptionColor..format("%d %s (%s)", numEnabled - maxShown, L.Hidden, L.Shift), G.OptionColor..formatMemory(hiddenMemory))
	end

	-- Total
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(G.OptionColor..L.DefaultUsage, formatMemory(gcinfo() - totalMemory), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(G.OptionColor..L.TotleUsage, formatMemory(collectgarbage("count")), 1, 1, 1, 1, 1, 1)
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..ADDON_LIST..G.MiddleButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.ManualCollect..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoCollect..(Kiminfo.AutoCollect and G.Enable or G.Disable)..G.RightButton)
	

	F.ShowTooltip()
end

local function OnLeave(self)
	-- Data text
	local totalNum = updateMaxAddons()
	Text:SetText(totalNum)
	self:Layout()
	
	-- Mouseover color
	Icon:SetVertexColor(1, 1, 1)
	Text:SetTextColor(1, 1, 1)
	
	-- Tooltip
	GameTooltip:Hide()
end

--=========================================--
---------------	[[ Scripts ]] ---------------
--=========================================--
	
	--[[ Data text ]]--
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("ADDON_LOADED")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			local before = gcinfo()
			
			collectgarbage("collect")
			print(format(G.OptionColor.."%s|r%s", L.Collected, formatMemory(before - gcinfo())))
		elseif btn == "RightButton" then
			Kiminfo.AutoCollect = not Kiminfo.AutoCollect
			updateAutoCollect()
			print(L.CollectWarning)
		elseif btn == "MiddleButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
			if AddonList:IsShown() then AddonList_OnCancel() else ShowUIPanel(AddonList) end
		else
			return
		end
		
		-- Update tooltip option show / 更新Tooltip內容
		OnEnter(self)
	end)
	
	--[[ Tooltip ]]-- 
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", OnLeave)

--==============================================--
---------------	[[ Auto Collect ]] ---------------
--==============================================--

	autoCollect:SetScript("OnEvent", function(self, event)
		if Kiminfo.AutoCollect == true then
			eventCount = eventCount + 1
			
			if InCombatLockdown() then return end
			if eventCount > 15000 or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
				collectgarbage("collect")
				eventCount = 0
			end
		end
	end)