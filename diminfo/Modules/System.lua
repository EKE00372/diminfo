local _, ns = ...
local C, F, G, L = unpack(ns)
if not C.System then return end

local GameTooltip = F.Tooltip
local format, floor, min, max, sort, wipe = string.format, math.floor, min, math.max, sort, wipe
local CreateFrame = CreateFrame
local GetNumAddOns, GetAddOnInfo, IsAddOnLoaded = C_AddOns.GetNumAddOns, C_AddOns.GetAddOnInfo, C_AddOns.IsAddOnLoaded
local UpdateAddOnCPUUsage, GetAddOnCPUUsage, ResetCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage, ResetCPUUsage

local usageStartTime = GetTime()
local usageTable = {}
local usageString = "%.3f ms/s"

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."System", UIParent, "HorizontalLayoutFrame")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text.layoutIndex = 1
	Text.align = "center"
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	F.RegisterModule("System", Stat)

--==============================================--
---------------    [[ Color ]]     ---------------
--==============================================--

--[[ Latency color ]]--
local function colorLatency(latency)
	if latency < 300 then
		return "|cff0CD809"..latency
	elseif latency < 500 then
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
	return a[3] > b[3]
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
		self:Layout()
		
		self.timer = 0
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	local _, _, latencyHome, latencyWorld = GetNetStats()
	local profilingEnabled = (GetCVar("scriptProfile") == "1")
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CHAT_MSG_SYSTEM, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- Latency
	GameTooltip:AddDoubleLine(L.Home,  colorLatency(latencyHome).."|r ms", .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L.World, colorLatency(latencyWorld).."|r ms", .6, .8, 1, 1, 1, 1)
	
	-- CPU usage
	if profilingEnabled then
		updateUsageTable()
		local totalCPU = updateUsage()
		local elapsed = max(1, GetTime() - usageStartTime)
		GameTooltip:AddLine(" ")
		
		if totalCPU > 0 then
			local maxAddOns = C.MaxAddOns
			local isShiftKeyDown = IsShiftKeyDown()
			local maxShown = isShiftKeyDown and #usageTable or min(maxAddOns, #usageTable)
			local numEnabled = 0
			local hiddenUsage = 0
			
			for i = 1, #usageTable do
				local value = usageTable[i]
				if IsAddOnLoaded(value[1]) then
					numEnabled = numEnabled + 1
					if numEnabled <= maxShown then
						local r = value[3] / totalCPU
						local g = 1.5 - r
						GameTooltip:AddDoubleLine(value[2], format(usageString, value[3] / elapsed), 1, 1, 1, r, g, 0)
					else
						hiddenUsage = hiddenUsage + value[3]
					end
				end
			end

			if numEnabled > maxShown then
				GameTooltip:AddDoubleLine(format("%d %s (%s)", numEnabled - maxShown, L.Hidden, L.Shift), format(usageString, hiddenUsage / elapsed), .6, .8, 1, .6, .8, 1)
			end
		end
	end
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	
	if profilingEnabled then
		GameTooltip:AddDoubleLine(" ", G.OptionColor..L.ResetCPU..G.LeftButton)
	end
	
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.CPU..(profilingEnabled and G.Enable or G.Disable)..G.RightButton)

	F.ShowTooltip()
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
			usageStartTime = GetTime()
		else
			return
		end
		
		OnEnter(self)
	end)
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
	end)
	
	--[[ Data text ]]--
	Stat:SetScript("OnUpdate", OnUpdate)