local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.System then return end

local format, floor, min, max, sort, wipe = string.format, math.floor, min, math.max, sort, wipe
local CreateFrame = CreateFrame
local GetNumAddOns, GetAddOnInfo = GetNumAddOns, GetAddOnInfo
local UpdateAddOnCPUUsage, GetAddOnCPUUsage, ResetCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage, ResetCPUUsage

local loginTime = GetTime()	-- Get log in time at all of first
local usageTable = {}
local usageString = "%.3f ms"

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."System", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.SystemPoint))
	Stat:SetAllPoints(Text)

--==============================================--
---------------    [[ Color ]]     ---------------
--==============================================--

--[[ Latency color ]]--
local function colorLatency(latency)
	if latency < 300 then
		return "|cff0CD809"..latency
	elseif (latency >= 300 and latency < 500) then
		return "|cffE8DA0F"..latency
	else
		return "|cffD80909"..latency
	end
end

--[[ Fps color ]]--
local function colorFPS(fps)
	if fps < 15 then
		return "|cffD80909"..fps
	elseif fps < 30 then
		return "|cffE8DA0F"..fps
	else
		return "|cff0CD809"..fps
	end
end

--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

local function updateUsageTable()
	local numAddons = GetNumAddOns()
	if numAddons == #usageTable then return end

	wipe(usageTable)
	for i = 1, numAddons do
		usageTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
	end
end

local function sortUsage(a, b)
	if a and b then
		return a[3] > b[3]
	end
end

local function updateUsage()
	UpdateAddOnCPUUsage()

	local total = 0
	for i = 1, #usageTable do
		local value = usageTable[i]
		value[3] = GetAddOnCPUUsage(value[1])
		total = total + value[3]
	end
	sort(usageTable, sortUsage)

	return total
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Update data text ]]--
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	
	if self.timer > 1 then
		local _, _, latencyHome, latencyWorld = GetNetStats()
		
		local fps = floor(GetFramerate())
		local lat = max(latencyHome, latencyWorld)
		
		Text:SetText(colorFPS(fps).."|rfps"..colorLatency(lat).."|rms")
		
		self.timer = 0
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	local _, _, latencyHome, latencyWorld = GetNetStats()
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CHAT_MSG_SYSTEM, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- Latency
	GameTooltip:AddDoubleLine(L.Home,  colorLatency(latencyHome).."|r ms", .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L.World, colorLatency(latencyWorld).."|r ms", .6, .8, 1, 1, 1, 1)
	
	-- CPU usage
	if GetCVar("scriptProfile") == "1" then
		updateUsageTable()
		local totalCPU = updateUsage()
		GameTooltip:AddLine(" ")
		
		if totalCPU > 0 then
			local maxAddOns = C.MaxAddOns
			local isShiftKeyDown = IsShiftKeyDown()
			local maxShown = isShiftKeyDown and #usageTable or min(maxAddOns, #usageTable)
			local numEnabled = 0
			
			for i = 1, #usageTable do
				local value = usageTable[i]
				if value and IsAddOnLoaded(value[1]) then
					numEnabled = numEnabled + 1
					if numEnabled <= maxShown then
						local r = value[3] / totalCPU
						local g = 1.5 - r
						GameTooltip:AddDoubleLine(value[2], format(usageString, value[3] / max(1, GetTime() - loginTime)), 1, 1, 1, r, g, 0)
					end
				end
			end

			if not isShiftKeyDown and (numEnabled > maxAddOns) then
				local hiddenUsage = 0
				for i = (maxAddOns + 1), numEnabled do
					hiddenUsage = hiddenUsage + usageTable[i][3]
				end
				GameTooltip:AddDoubleLine(format("%d %s (%s)", numEnabled - maxAddOns, L.Hidden, L.Shift), format(usageString, hiddenUsage), .6, .8, 1, .6, .8, 1)
			end
		end
	end
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	
	if GetCVar("scriptProfile") == "1" then
		GameTooltip:AddDoubleLine(" ", G.OptionColor..L.ResetCPU..G.LeftButton)
	end
	
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.CPU..(GetCVar("scriptProfile") == "1" and G.Enable or G.Disable)..G.RightButton)

	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, btn)
		if btn == "RightButton" then
			if GetCVar("scriptProfile") == "0" then
				SetCVar("scriptProfile", 1)
				print(L.ReloadOn)
			else
				SetCVar("scriptProfile", 0)
				print(L.ReloadOff)
			end
		elseif btn == "LeftButton" then
			ResetCPUUsage()
		else
			return
		end
		
		OnEnter(self)
	end)
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:SetScript("OnUpdate", OnUpdate)