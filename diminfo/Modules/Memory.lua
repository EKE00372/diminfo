local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Memory then return end

local GameTooltip = F.Tooltip
local format, min, sort, wipe = string.format, min, table.sort, wipe
local CreateFrame = CreateFrame
local GetNumAddOns, GetAddOnInfo, IsAddOnLoaded = C_AddOns.GetNumAddOns, C_AddOns.GetAddOnInfo, C_AddOns.IsAddOnLoaded
local UpdateAddOnMemoryUsage, GetAddOnMemoryUsage = UpdateAddOnMemoryUsage, GetAddOnMemoryUsage
local collectgarbage = collectgarbage

local memoryTable, totalMemory  = {}, 0
local eventCount = 0
local autoCollect = CreateFrame("Frame")

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Mem", UIParent, "HorizontalLayoutFrame")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 1
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	F.RegisterModule("Memory", Stat)

--===============================================--
---------------    [[ format ]]     ---------------
--===============================================--

local function formatMemory(value)
	if value > 1024 then
		return format("%.1f mb", value / 1024)
	else
		return format("%.0f kb", value)
	end
end

local function memoryColor(value, times)
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
	return a[3] > b[3]
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
		local totalmb = format("%.1f", totalMemory/1024)
		Text:SetText(C.ClassColor and F.Hex(G.Ccolors)..ADDONS.." |r"..totalmb.."mb|r" or ADDONS.." "..totalmb.."mb")
	else
		local totalkb = format("%.1f", totalMemory)
		Text:SetText(C.ClassColor and F.Hex(G.Ccolors)..ADDONS.." |r"..totalkb..F.Hex(G.Ccolors).."kb|r" or ADDONS.." "..totalkb.."kb")
	end
	Stat:Layout()
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

local function updateAutoCollect()
	if diminfo.AutoCollect then
		autoCollect:RegisterAllEvents()
	else
		autoCollect:UnregisterAllEvents()
		eventCount = 0
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	-- Data text
	RefreshText()
	
	local maxAddOns = C.MaxAddOns
	local isShiftKeyDown = IsShiftKeyDown()
	local maxShown = isShiftKeyDown and #memoryTable or min(maxAddOns, #memoryTable)
	local numEnabled = 0
	local hiddenMemory = 0

	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(ADDONS, formatMemory(totalMemory), 0, .6, 1, .6, .8, 1)
	GameTooltip:AddLine(" ")

	-- List addon
	for i = 1, #memoryTable do
		local value = memoryTable[i]
		
		if IsAddOnLoaded(value[1]) then
			numEnabled = numEnabled + 1
			
			if numEnabled <= maxShown then
				GameTooltip:AddDoubleLine(value[2], formatMemory(value[3]), 1, 1, 1, memoryColor(value[3], 5))
			else
				hiddenMemory = hiddenMemory + value[3]
			end
		end
	end
	
	-- 30th line when not shift key down
	if numEnabled > maxShown then
		GameTooltip:AddDoubleLine(format("%d %s (%s)", numEnabled - maxShown, L.Hidden, L.Shift), formatMemory(hiddenMemory), .6, .8, 1, .6, .8, 1)
	end

	-- total
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L.DefaultUsage, formatMemory(collectgarbage("count") - totalMemory), .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L.TotleUsage, formatMemory(collectgarbage("count")), .6, .8, 1, 1, 1, 1)
	
	-- options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.ManualCollect..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoCollect..(diminfo.AutoCollect and G.Enable or G.Disable)..G.RightButton)
	
	F.ShowTooltip()
end

local function OnLeave(self)
	-- Data text
	local totalNum = updateMaxAddons()
	Text:SetText(C.ClassColor and F.Hex(G.Ccolors)..ADDONS.." |r"..totalNum or totalNum)
	self:Layout()
	
	-- Tooltip
	if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
end

--[[ Update setting ]]--
local function OnEvent(self, event, loadedAddon)
	-- Setting
	if event == "ADDON_LOADED" and loadedAddon == addon then
		if diminfo.AutoCollect == nil then
			-- I'm not sure but somebody said auto collect will make client crash so default false it
			diminfo.AutoCollect = false
		end
		updateAutoCollect()
	end
	
	-- Data text
	local totalNum = updateMaxAddons()
	Text:SetText(C.ClassColor and F.Hex(G.Ccolors)..ADDONS.." |r"..totalNum or totalNum)
	self:Layout()
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
			local before = collectgarbage("count")
			
			collectgarbage("collect")
			print(format("|cff66C6FF%s|r%s", L.Collected, formatMemory(before - collectgarbage("count"))))
		elseif btn == "RightButton" then
			diminfo.AutoCollect = not diminfo.AutoCollect
			updateAutoCollect()
		else
			return
		end
		
		OnEnter(self)
	end)
	
	--[[ Tooltip ]]-- 
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", OnLeave)

--=====================================================--
---------------    [[ Auto Collect ]]     ---------------
--=====================================================--

	autoCollect:SetScript("OnEvent", function(self, event)
		if diminfo.AutoCollect == true then
			eventCount = eventCount + 1
			
			if InCombatLockdown() then return end
			if eventCount > 15000 or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
				collectgarbage("collect")
				eventCount = 0
			end
		end
	end)