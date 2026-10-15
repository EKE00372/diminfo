local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.System then return end

local GameTooltip = F.Tooltip
local format, min, max, sort, wipe = string.format, min, max, sort, table.wipe
local CreateFrame = CreateFrame
local C_AddOns_GetNumAddOns, C_AddOns_GetAddOnInfo, C_AddOns_IsAddOnLoaded = C_AddOns.GetNumAddOns, C_AddOns.GetAddOnInfo, C_AddOns.IsAddOnLoaded
local UpdateAddOnCPUUsage, GetAddOnCPUUsage, ResetCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage, ResetCPUUsage

local cpuUsageStartTime = GetTime()
local usageTable = {}
local usageString = "%.3f ms/s"

--==========================================--
---------------	[[ Elements ]] ---------------
--==========================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."System", UIParent, "HorizontalLayoutFrame")

--[[ Create fps icon ]]--
local Icon2 = Stat:CreateTexture(nil, "OVERLAY")
	Icon2.layoutIndex = 1
	Icon2.align = "center"
	Icon2:SetSize(G.FontSize, G.FontSize)
	Icon2:SetTexture(G.Fps)
	Icon2:SetVertexColor(1, 1, 1)

--[[ Create fps text ]]--
local Text2  = Stat:CreateFontString(nil, "OVERLAY")
	Text2.layoutIndex = 2
	Text2.align = "center"
	Text2:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text2:SetTextColor(1, 1, 1)

--[[ Create ping icon ]]--
local Icon1 = Stat:CreateTexture(nil, "OVERLAY")
	Icon1.layoutIndex = 3
	Icon1.align = "center"
	Icon1:SetSize(G.FontSize, G.FontSize)
	Icon1:SetTexture(G.Ping)
	Icon1:SetVertexColor(1, 1, 1)

--[[ Create ping text ]]--
local Text1  = Stat:CreateFontString(nil, "OVERLAY")
	Text1.layoutIndex = 4
	Text1.align = "center"
	Text1:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text1:SetTextColor(1, 1, 1)
	F.RegisterModule("System", Stat)

--=======================================--
---------------	[[ Color ]] ---------------
--=======================================--

--[[ latency color on tooltip ]]--
local function colorLatencyTooltip(latency)
	if latency < 300 then
		return "|cff0CD809"..latency
	elseif latency < 500 then
		return "|cffE8DA0F"..latency
	else
		return "|cffD80909"..latency
	end
end

--[[ latency color on data text ]]--
local function colorLatency(latency)
	if latency < 300 then
		return .57, 1, .57
	elseif latency < 500 then
		return 1, 1, .43
	else
		return 1, .5, .25
	end
end

--[[ fps color on data text ]]--
local function colorFPS(fps)
	if fps < 15 then
		return 1, .5, .25
	elseif fps < 30 then
		return 1, 1, .43
	else
		return .57, 1, .57
	end
end

-- 保留最新樣本的正常色，離開 hover 時直接恢復；首次取樣前維持白色。
local fpsR, fpsG, fpsB = 1, 1, 1
local latencyR, latencyG, latencyB = 1, 1, 1

local function UpdateColor(self)
	local fr, fg, fb = fpsR, fpsG, fpsB
	local lr, lg, lb = latencyR, latencyG, latencyB
	if self.isHover then
		fr, fg, fb = 0, 1, 1
		lr, lg, lb = 0, 1, 1
	end
	Text1:SetTextColor(lr, lg, lb)
	Icon1:SetVertexColor(lr, lg, lb)
	Text2:SetTextColor(fr, fg, fb)
	Icon2:SetVertexColor(fr, fg, fb)
end

--===========================================--
---------------	[[ Functions ]] ---------------
--===========================================--

local function updateUsageTable()
	local numAddons = C_AddOns_GetNumAddOns()
	if numAddons == #usageTable then return end

	wipe(usageTable)
	for i = 1, numAddons do
		usageTable[i] = {i, select(2, C_AddOns_GetAddOnInfo(i)), 0}
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

--=========================================--
---------------	[[ Updates ]] ---------------
--=========================================--

--[[ Update data text ]]--
local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer <= 1 then return end
	self.timer = 0

	local _, _, latencyHome, latencyWorld = GetNetStats()
	local fps = floor(GetFramerate())
	local lat = max(latencyHome, latencyWorld)
	fpsR, fpsG, fpsB = colorFPS(fps)
	latencyR, latencyG, latencyB = colorLatency(lat)

	Text1:SetText(lat)
	Text2:SetText(fps)
	if not self.isHover then
		UpdateColor(self)
	end
	self:Layout()
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	local _, _, latencyHome, latencyWorld = GetNetStats()
	
	-- Title
	GameTooltip:SetOwner(self, C.StickTop and "ANCHOR_BOTTOM" or "ANCHOR_TOP", 0, C.StickTop and -10 or 10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(G.TitleColor..CHAT_MSG_SYSTEM)
	GameTooltip:AddLine(" ")
	
	-- Latency
	GameTooltip:AddDoubleLine(G.OptionColor..L.Home, colorLatencyTooltip(latencyHome).."|r ms", 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(G.OptionColor..L.World, colorLatencyTooltip(latencyWorld).."|r ms", 1, 1, 1, 1, 1, 1)
	
	if GetCVar("scriptProfile") == "1" then
		updateUsageTable()
		local totalCPU = updateUsage()
		local passedTime = max(1, GetTime() - cpuUsageStartTime)
		GameTooltip:AddLine(" ")
		
		if totalCPU > 0 then
			local maxAddOns = C.MaxAddOns
			local isShiftKeyDown = IsShiftKeyDown()
			local maxShown = isShiftKeyDown and #usageTable or min(maxAddOns, #usageTable)
			local numEnabled = 0
			local hiddenUsage = 0
			
			for i = 1, #usageTable do
				local value = usageTable[i]
				if value and C_AddOns_IsAddOnLoaded(value[1]) then
					numEnabled = numEnabled + 1
					if numEnabled <= maxShown then
						local r = value[3] / totalCPU
						local g = 1.5 - r
						GameTooltip:AddDoubleLine(value[2], format(usageString, value[3] / passedTime), 1, 1, 1, r, g, 0)
					else
						hiddenUsage = hiddenUsage + value[3]
					end
				end
			end

			if not isShiftKeyDown and numEnabled > maxShown then
				GameTooltip:AddDoubleLine(G.OptionColor..format("%d %s (%s)", numEnabled - maxShown, L.Hidden, L.Shift), G.OptionColor..format(usageString, hiddenUsage / passedTime))
			end
			
		end
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(G.OptionColor..TOTAL, format(usageString, totalCPU / passedTime), 1, 1, 1, 1, 1, 1)
	end
	
	-- Options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..RELOADUI..G.MiddleButton)
	if GetCVar("scriptProfile") == "1" then
		GameTooltip:AddDoubleLine(" ", G.OptionColor..L.ResetCPU..G.LeftButton)
	end
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.CPU..(GetCVar("scriptProfile") == "1" and G.Enable or G.Disable)..G.RightButton)

	F.ShowTooltip()
end

--=========================================--
---------------	[[ Scripts ]] ---------------
--=========================================--
	
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
		elseif btn == "MiddleButton" then
			ReloadUI()
		elseif btn == "LeftButton" then
			ResetCPUUsage()
			cpuUsageStartTime = GetTime()
		end
		
		OnEnter(self)
	end)
	
	--[[ Tooltip ]]-- 
	Stat:SetScript("OnEnter", function(self)
		self.isHover = true
		UpdateColor(self)
		OnEnter(self)
	end)
	Stat:SetScript("OnLeave", function(self)
		self.isHover = false
		UpdateColor(self)
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:SetScript("OnUpdate", OnUpdate)