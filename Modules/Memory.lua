local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Memory then return end

local format = string.format
local sort = table.sort

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Mem", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.MemoryPoint))
	Stat:SetAllPoints(Text)

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

local memoryTable, totalMemory  = {}, 0

--[[ get addon list ]]--
local function updateMemoryTable()
	local numAddons = GetNumAddOns()
	if numAddons == #memoryTable then return end

	wipe(memoryTable)
	
	for i = 1, numAddons do
		memoryTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
	end
end

--[[ sort list ]]--
local function sortMemory(a, b)
	if a and b then
		return a[3] > b[3]
	end
end

--[[ update addon memory ]]--
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

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Update data text ]]--
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 3) + elapsed
	-- 限制一下更新速率
	if self.timer > 5 then
		updateMemoryTable()
		totalMemory = updateMemory()
		
		if totalMemory >= 1024 then
			local totalmb = format("%.1f", totalMemory/1024)
			Text:SetText(C.ClassColor and totalmb..F.Hex(G.Ccolors).."mb|r" or totalmb.."mb")
		else
			local totalkb = format("%.1f", totalMemory)
			Text:SetText(C.ClassColor and totalkb..F.Hex(G.Ccolors).."kb|r" or totalkb.."kb")
		end
		
		self.timer = 0
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	local maxAddOns = C.MaxAddOns
	local isShiftKeyDown = IsShiftKeyDown()
	local maxShown = isShiftKeyDown and #memoryTable or min(maxAddOns, #memoryTable)
	local numEnabled = 0

	-- title
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(ADDONS, formatMemory(totalMemory), 0, .6, 1, .6, .8, 1)
	GameTooltip:AddLine(" ")

	-- list addon
	for i = 1, #memoryTable do
		local value = memoryTable[i]
		
		if value and IsAddOnLoaded(value[1]) then
			numEnabled = numEnabled + 1
			
			if numEnabled <= maxShown then
				GameTooltip:AddDoubleLine(value[2], formatMemory(value[3]), 1, 1, 1, memoryColor(value[3], 5))
			end
		end
	end
	
	-- 30th line when not shift key down
	if not isShiftKeyDown and (numEnabled > maxAddOns) then
		local hiddenMemory = 0
		
		for i = (maxAddOns + 1), numEnabled do
			hiddenMemory = hiddenMemory + memoryTable[i][3]
		end
		
		GameTooltip:AddDoubleLine(format("%d %s (%s)", numEnabled - maxAddOns, L.Hidden, L.Shift), formatMemory(hiddenMemory), .6, .8, 1, .6, .8, 1)
	end

	-- total
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L.DefaultUsage, formatMemory(gcinfo() - totalMemory), .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L.TotleUsage, formatMemory(collectgarbage("count")), .6, .8, 1, 1, 1, 1)
	
	-- options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.ManualCollect..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoCollect..(diminfo.AutoCollect and "|cff55ff55"..ENABLE or "|cffff5555"..DISABLE)..G.RightButton)
	
	GameTooltip:Show()
end

--[[ Update setting ]]--
local function OnEvent(self)
	if diminfo.AutoCollect == nil then
		diminfo.AutoCollect = true
	end
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			local before = gcinfo()
			collectgarbage("collect")
			print(format("|cff66C6FF%s|r%s", L.Collected, formatMemory(before - gcinfo())))
			-- 刷新一下TOOLTIP的總計
			totalMemory = updateMemory()
		elseif btn == "RightButton" then
			diminfo.AutoCollect = not diminfo.AutoCollect
			self:GetScript("OnEnter")(self)
		end
		self:GetScript("OnEnter")(self)
	end)
	
	--[[ Tooltip ]]-- 
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function()
		entered = false
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:SetScript("OnUpdate", OnUpdate)

--=====================================================--
---------------    [[ Auto Collect ]]     ---------------
--=====================================================--

local eventcount = 0
local a = CreateFrame("Frame")
	a:RegisterAllEvents()
	a:SetScript("OnEvent", function(self, event)
		if diminfo.AutoCollect == true then
			eventcount = eventcount + 1
			if InCombatLockdown() then return end
			if eventcount > 15000 or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
				collectgarbage("collect")
				eventcount = 0
			end
		end
	end)