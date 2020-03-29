local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.System == true then return end

local format = string.format
local loginTime = GetTime()	-- to get log in time at all of first
local usageTable = {}
local usageString = "%.3f ms"

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."System", UIParent)
	Stat:SetHitRectInsets(-65, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

-- 反著錨點：PING值會爆，FPS最多只有三位數

--[[ Create ping text ]]--
local Text1  = Stat:CreateFontString(nil, "OVERLAY")
	Text1:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text1:SetPoint(unpack(C.SystemPoint))
	Stat:SetAllPoints(Text1)

--[[ Create ping icon ]]--
local Icon1 = Stat:CreateTexture(nil, "OVERLAY")
	Icon1:SetSize(G.FontSize, G.FontSize)
	Icon1:SetPoint("RIGHT", Stat, "LEFT", 0, 0)
	Icon1:SetTexture(G.Ping)
	Icon1:SetVertexColor(1, 1, 1)
	
--[[ Create fps text ]]--
local Text2  = Stat:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text2:SetPoint("RIGHT", Icon1, "LEFT", 0, 0)
	
--[[ Create ping icon ]]--
local Icon2 = Stat:CreateTexture(nil, "OVERLAY")
	Icon2:SetSize(G.FontSize, G.FontSize)
	Icon2:SetPoint("RIGHT", Text2, "LEFT", 0, 0)
	Icon2:SetTexture(G.Fps)
	Icon2:SetVertexColor(1, 1, 1)

--==============================================--
---------------    [[ Color ]]     ---------------
--==============================================--

--[[ latency color on data text ]]--
local function colorLatencyTooltip(latency)
	if latency < 300 then
		return "|cff0CD809"..latency
	elseif (latency > 300 and latency < 500) then
		return "|cffE8DA0F"..latency
	else
		return "|cffD80909"..latency
	end
end

--[[ latency color on data text ]]--
local function colorLatency(latency)
	if latency < 300 then
		return .57, 1, .57
	elseif (latency > 300 and latency < 500) then
		return 1, 1, .43
	else
		return 1, .5, 25
	end
	
	return r, g, b
end

--[[ fps color on data text ]]--
local function colorFPS(fps)
	if fps < 15 then
		return 1, .5, 25
	elseif fps < 30 then
		return 1, 1, .43
	else
		return .57, 1, .57
	end
	
	return r, g, b
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
	
	if self.isHover == true then
		Text1:SetTextColor(0, 1, 1)
		Text2:SetTextColor(0, 1, 1)
		Icon1:SetVertexColor(0, 1, 1)
		Icon2:SetVertexColor(0, 1, 1)
	else
		if self.timer > 1 then
			local _, _, latencyHome, latencyWorld = GetNetStats()
			
			local fps = floor(GetFramerate())
			local lat = math.max(latencyHome, latencyWorld)
			local fr, fb, fg = colorFPS(fps)
			local lr, lb, lg = colorLatency(lat)

			Text1:SetText(lat)
			Text1:SetTextColor(lr, lb, lg)
			Icon1:SetVertexColor(lr, lb, lg)

			Text2:SetText(fps)
			Text2:SetTextColor(fr, fb, fg)
			Icon2:SetVertexColor(fr, fb, fg)
			
			self.timer = 0
		end
	end
end

--[[ Update tooltip ]]--
local function OnEnter(self)
	local _, _, latencyHome, latencyWorld = GetNetStats()
	
	-- title
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CHAT_MSG_SYSTEM, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- latency
	GameTooltip:AddDoubleLine(L.Home,  colorLatencyTooltip(latencyHome).."|r ms", .6, .8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L.World, colorLatencyTooltip(latencyWorld).."|r ms", .6, .8, 1, 1, 1, 1)
	
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
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(TOTAL, format(usageString, totalCPU/ max(1, GetTime() - loginTime)), .6, .8, 1, 1, 1, 1)
	end
	
	-- options
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.CPU..(GetCVar("scriptProfile") == "1" and "|cff55ff55"..ENABLE or "|cffff5555"..DISABLE)..G.RightButton)

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
		end
		self:GetScript("OnEnter")(self)
	end)
	
	--[[ Tooltip ]]-- 
	Stat:SetScript("OnEnter", function(self)
		self.isHover = true
		OnEnter(self)
	end)
	Stat:SetScript("OnLeave", function(self)
		self.isHover = false
		GameTooltip:Hide()
	end)
	
	--[[ Data text ]]--
	Stat:SetScript("OnUpdate", OnUpdate)