local addon, ns = ...
local cfg = ns.cfg
local init = ns.init
local panel = CreateFrame("Frame", nil, UIParent)

if cfg.Spec == true then
	-- 專精和拾取分別建立框體，共兩個
	local Stat = CreateFrame("Frame", "diminfo_Spec")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	local Stat2 = CreateFrame("Frame", "diminfo_Loot")
	Stat2:EnableMouse(true)
	Stat2:SetFrameStrata("BACKGROUND")
	Stat2:SetFrameLevel(3)
	
	local Text = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.SpecPoint))
	Stat:SetAllPoints(Text)
	local Text2 = panel:CreateFontString(nil, "OVERLAY")
	Text2:SetFont(unpack(cfg.Fonts))
	Text2:SetPoint("LEFT", Text, "RIGHT", 3, 0)
	Stat2:SetAllPoints(Text2)
		
	local int = 1
	local function Update(self, t)
		if not GetSpecialization() then
			Text:SetText(cfg.ColorClass and init.Colored..SPECIALIZATION .. "|r" .. NONE or SPECIALIZATION .. "|r" .. NONE)
		return end
		int = int - t
		if int < 0 then
			local Spec = GetSpecialization()
			local _, SpecName = GetSpecializationInfo(Spec)
			Text:SetText(cfg.ColorClass and init.Colored..SPECIALIZATION .. "|T"..select(4, GetSpecializationInfo(GetSpecialization()))..":0:0:0:0:64:64|t" or SPECIALIZATION .. "|T"..select(4, GetSpecializationInfo(GetSpecialization()))..":0:0:1:-1:64:64|t")
		end
		
		local specID = GetLootSpecialization()
		if not GetSpecialization() then
			Text2:Hide()
		elseif specID == 0 then
			Text2:SetText(cfg.ColorClass and init.Colored..LOOT .."|T"..select(4, GetSpecializationInfo(GetSpecialization()))..":0:0:0:0:64:64|t" or LOOT .." |T"..select(4, GetSpecializationInfo(GetSpecialization()))..":0:0:1:-1:64:64|t")
		else
			Text2:SetText(cfg.ColorClass and init.Colored..LOOT .."|T"..select(4, GetSpecializationInfoByID(specID))..":0:0:1:-1:64:64|t" or LOOT .."|T"..select(4, GetSpecializationInfoByID(specID))..":0:0:1:-1:64:64|t")
		end
	end

	local menuFrame = CreateFrame("Frame", "LootSpecMenu", UIParent, "UIDropDownMenuTemplate")
	local menuList = {
		{text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true},
		{notCheckable = true, func = function() SetLootSpecialization(0) end},
		{notCheckable = true},
		{notCheckable = true},
		{notCheckable = true},
		{notCheckable = true}
	}
	
	local function Checktalentgroup(index)
		return GetSpecialization(false, false, index)
	end 
	
	local function OnEvent(self, event, ...) 
		if event == "PLAYER_LOGIN" then
			self:UnregisterEvent("PLAYER_LOGIN")
		end
		-- Setup Talents Tooltip
		self:SetAllPoints(Text)
		self:SetScript("OnEnter", function(self)
				local spec = { }
				for i = 1, 7 do
					for j = 1, 3 do
						local talentID, name, iconTexture, selected, available = GetTalentInfo(i,j,1)
						if selected then
							table.insert(spec,i.." - "..name)
						end
					end
				end
				GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(TALENTS_BUTTON,0,.6,1)
				GameTooltip:AddLine(" ")
				if GetNumSpecGroups() == 1 then
					for i = 1, #spec do
						GameTooltip:AddDoubleLine(spec[i])
					end
				end
				GameTooltip:Show()
			end)
		
		self:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end
	 
	Stat:RegisterEvent("PLAYER_LOGIN")
	Stat:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnUpdate", Update)
	Stat:SetScript("OnMouseDown", function(_,btn)
		ToggleTalentFrame()
	end)
	
	Stat2:SetScript("OnEnter", function(self)
		if not GetSpecialization() then return end
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
		local specID = GetLootSpecialization()
		if specID == 0 then
			CUR_LOOT_SPEC = (select(2, GetSpecializationInfo(GetSpecialization())))
		else
			CUR_LOOT_SPEC = (select(2, GetSpecializationInfoByID(specID)))
		end
		GameTooltip:AddLine(format("%s", SELECT_LOOT_SPECIALIZATION),0,.6,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(format("%s", CUR_LOOT_SPEC),1,1,1)
		GameTooltip:Show()
	end)

	Stat2:SetScript("OnMouseUp", function()
		GameTooltip:Hide()
		local specID, specName = GetSpecializationInfo(GetSpecialization())
		for i = 1, 4 do
			menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)
			local id, name = GetSpecializationInfo(i)
			if id then
				menuList[i+2].text = name
				menuList[i+2].func = function() SetLootSpecialization(id) end
			else
				menuList[i+2] = nil
			end
		end
		L_EasyMenu(menuList, menuFrame, "cursor", 5, 0, "MENU", 2)
	end)
	
	Stat2:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
end