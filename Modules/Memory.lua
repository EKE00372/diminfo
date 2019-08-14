local addon, ns = ... 
local C, F, G, T = unpack(ns)
local panel = CreateFrame("Frame", nil, UIParent)

if not C.Memory then return end

	-- make addon frame anchor-able
	local Stat = CreateFrame("Frame", "diminfo_Memory")
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	Stat:EnableMouse(true)
	
	-- setup text
	local Text  = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.MemoryPoint))
	Stat:SetAllPoints(Text)

	local colorme = string.format("%02x%02x%02x", 1*255, 1*255, 1*255)
	local Total, Mem, MEMORY_TEXT, Memory, maxAddOns, statColor																	

	local function formatMem(memory)
		local mult = 10^1
		if memory > 999 then
			local mem = floor((memory/1024) * mult + 0.5) / mult
			if mem % 1 == 0 then
				return mem..F.Hex(statColor)..".0 mb|r"
			else
				return mem..F.Hex(statColor).." mb|r"
			end
		else
			local mem = floor(memory * mult + 0.5) / mult
			if mem % 1 == 0 then
				return mem..F.Hex(statColor)..".0 kb|r"
			else
				return mem..F.Hex(statColor).." kb|r"
			end
		end
	end

	local function RefreshMem(self)
		Memory = {}
		UpdateAddOnMemoryUsage()
		Total = 0
		
		for i = 1, GetNumAddOns() do
			Mem = GetAddOnMemoryUsage(i)
			Memory[i] = { select(2, GetAddOnInfo(i)), Mem, IsAddOnLoaded(i) }
			Total = Total + Mem
		end
		
		MEMORY_TEXT = formatMem(Total, true)
		table.sort(Memory, function(a, b)
			if a and b then
				return a[2] > b[2]
			end
		end)
	end
	
	local function RefreshText()
		UpdateAddOnMemoryUsage()
		tTotal = 0
		for i = 1, GetNumAddOns() do
			local tMem = GetAddOnMemoryUsage(i)
			tTotal = tTotal + tMem
		end
	end
	
	local function formatTotal(Total)
		if Total >= 1024 then
			return format(C.ClassColor and F.Hex(G.Ccolors)..ADDONS.."|r %.1f"..F.Hex(G.Ccolors).."mb|r" or ADDONS.."%.1fmb", Total / 1024)
		else
			return format(C.ClassColor and F.Hex(G.Ccolors)..ADDONS.."|r %.1f"..F.Hex(G.Ccolors).."kb|r" or ADDONS.."%.1fkb", Total)
		end
	end

	local int = 5
	local function Update(self, t)
		int = int - t
		if int < 0 then
			RefreshText()
			int = 5
		end
		Text:SetText(formatTotal(tTotal))
	end

	if diminfo.AutoCollect == nil then diminfo.AutoCollect = true end
	
	-- click function
	Stat:SetScript("OnMouseDown", function(self,btn)
		if btn == "LeftButton" then
			RefreshMem(self)
			local before = gcinfo()
			collectgarbage("collect")
			RefreshMem(self)
			print(format("|cff66C6FF%s|r%s", infoL["Garbage collected"], formatMem(before - gcinfo())))
		elseif btn == "RightButton" then
			diminfo.AutoCollect = not diminfo.AutoCollect					  
		end
		self:GetScript("OnEnter")(self)
		RefreshText()
	end)

	-- setup tooltip
	Stat:SetScript("OnEnter", function(self)
		RefreshMem(self)
		
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10);
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
		GameTooltip:ClearLines()
		
		local _, _, latencyHome, latencyWorld = GetNetStats()
		GameTooltip:AddDoubleLine(ADDONS, formatMem(Total), 0, 0.6, 1, 1, 1, 1)
		GameTooltip:AddLine(" ")
		if IsShiftKeyDown() then
			maxAddOns = #Memory
		else
			maxAddOns = math.min(C.MaxAddOns, #Memory)
		end

		for i = 1, maxAddOns do
			if Memory[i][3] then
				local color = Memory[i][2] <= 102.4 and {0,1} -- 0 - 100
				or Memory[i][2] <= 512 and {0.75,1} -- 100 - 512
				or Memory[i][2] <= 1024 and {1,1} -- 512 - 1mb
				or Memory[i][2] <= 2560 and {1,0.75} -- 1mb - 2.5mb
				or Memory[i][2] <= 5120 and {1,0.5} -- 2.5mb - 5mb
				or {1,0.1} -- 5mb +
				GameTooltip:AddDoubleLine(Memory[i][1], formatMem(Memory[i][2], false), 1, 1, 1, color[1], color[2], 0)						
			end
		end

			local more = 0
			local moreMem = 0
			if not IsShiftKeyDown() then
				for i = (C.MaxAddOns + 1), #Memory do
					if Memory[i][3] then
						more = more + 1
						moreMem = moreMem + Memory[i][2]
					end
				end
				GameTooltip:AddDoubleLine(format("%d %s (%s)",more, infoL["Hidden"], infoL["Shift"]), formatMem(moreMem),.6,.8,1,.6,.8,1)
			end

			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(infoL["Default UI Memory Usage:"],formatMem(gcinfo() - Total),.6,.8,1,1,1,1)
			GameTooltip:AddDoubleLine(infoL["Total Memory Usage:"],formatMem(collectgarbage"count"),.6,.8,1,1,1,1)
			GameTooltip:AddDoubleLine(" ","--------------",1,1,1,0.5,0.5,0.5)
			GameTooltip:AddDoubleLine(" ",infoL["AutoCollect"]..(diminfo.AutoCollect and "|cff55ff55"..ENABLE or "|cffff5555"..DISABLE),1,1,1,.4,.78,1)
			GameTooltip:Show()
	end)

	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 20)
	
	-- Auto Collect
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
