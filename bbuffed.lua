local addon, ns = ...
local cfg = CreateFrame("Frame")
local init = ns.init
local panel = CreateFrame("Frame", nil, UIParent)

cfg.bbuffed = true
cfg.bbuffed = {"CENTER", UIParent,0,0}

if cfg.bbuffed == true then

	local Stat = CreateFrame("Frame", "diminfo_buff", UIParent)
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	
	local Text = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.BagsPoint))
	Stat:SetAllPoints(Text)
	
	local potentialBuffs = {
		["Kings"] = {GetSpellInfo(203538)},
		["Wise"] = {GetSpellInfo(203539)},
		["Might"] = {GetSpellInfo(203528)},
		["Rune"] = {GetSpellInfo(224001)},
		["Food"] = {GetSpellInfo(225604), GetSpellInfo(225599), GetSpellInfo(160894), 
		GetSpellInfo(174306), GetSpellInfo(160881), GetSpellInfo(174307)},
		["Flask"] = {GetSpellInfo(188033), GetSpellInfo(188034), GetSpellInfo(188031), GetSpellInfo(188035)}
	}
	
	local function OnEvent(self, event, ...)
	
	local index = 0
	local lastframe = nil
	local textFrames = {}
	
	for k, v in pairs(potentialBuffs) do
		index = index + 1
		Text:SetTextColor(.4, .4, .4)
		--Text:SetShadowColor(0,0,0,0)
		Text:SetText(k)
	
		if (index == 1) then
			Text:SetPoint("RIGHT", Stat, "RIGHT", 0, 0)
		else
			Text:SetPoint("RIGHT", lastframe, "LEFT", -10, 0)
		end
	
		lastframe = Text
		textFrames[k] = Text
	end


Stat:RegisterEvent("UNIT_AURA")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetScript("OnEvent", function(arg1, arg2, unit)
	if (unit == "player") then
		for k, v in pairs(potentialBuffs) do
			local found = false
			for u = 1, #v do
				local name = select(1, UnitBuff("player", v[u]))
				if (name) then
					found = true
				end
			end
			
			if (found) then
				TextFrames[k]:SetTextColor(classc.r,classc.g,classc.b)
			else
				TextFrames[k]:SetTextColor(.4, .4, .4)		
			end
		end
	end
end)

end