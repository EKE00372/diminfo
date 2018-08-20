local addon, ns = ...
local cfg = ns.cfg
local init = ns.init
local panel = CreateFrame("Frame", nil, UIParent)

if cfg.Spec == true then

	-- make addon frame anchor-able
	local Stat = CreateFrame("Frame", "diminfo_Spec")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	
	-- setup text
	local Text = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.SpecPoint))
	Stat:SetAllPoints(Text)
	
	-- right-click menu
	local menuFrame = CreateFrame("Frame", "LootSpecMenu", UIParent, "UIDropDownMenuTemplate")
	local menuList = {
		{	-- title
			text = SELECT_LOOT_SPECIALIZATION,
			isTitle = true,
			notCheckable = true
		},
		{	-- default
			notCheckable = true,
			func = function()
				SetLootSpecialization(0)
			end
		},
		{notCheckable = true},
		{notCheckable = true},
		{notCheckable = true},
		{notCheckable = true},
	}
	
	local function Checktalentgroup(index)
		return GetSpecialization(false, false, index)
	end
	
	local function OnEvent(self, event, ...) 
		if not GetSpecialization() then return end
		
		-- set icon texture
		local function addIcon(texture)
			texture = texture and "|T"..texture..":0:0:0:0:50:50:4:46:4:46|t" or ""
			return texture
		end
		
		-- set text
		local spec = GetSpecialization()
		if spec then
			-- spec
			local specIcon
			specIcon = addIcon(select(4, GetSpecializationInfo(spec)))
			-- loot
			local specID = GetLootSpecialization()
			local lootIcon
			if specID == 0 then
				lootIcon = specIcon
			else
				lootIcon = addIcon(select(4, GetSpecializationInfoByID(specID)))
			end
			
			Text:SetText(cfg.ColorClass and init.Colored..infoL["Spec"]..specIcon..LOOT..lootIcon)
		else
			Text:SetText(cfg.ColorClass and init.Colored..infoL["Spec"].."|r"..NONE..LOOT..NONE or SPECIALIZATION.."|r"..NONE..LOOT..NONE)
		end
		
		-- Setup Talents Tooltip
		self:SetAllPoints(Text)
		self:SetScript("OnEnter", function(self)
		
				GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(TALENTS_BUTTON, 0, .6, 1)
				GameTooltip:AddLine(" ")
				
				local _, specName, _, specIcon = GetSpecializationInfo(GetSpecialization())
				GameTooltip:AddLine(addIcon(specIcon).." "..init.Colored..specName.."|r")
				
				-- telent
				local telentTable = { }
				if UnitLevel("player") >= 10 then
					for i = 1, 7 do
						for j = 1, 3 do
							local talentID, name, iconTexture, selected, available = GetTalentInfo(i,j,1)
							if selected then
								table.insert(telentTable, addIcon(iconTexture).." ["..j.."]"..name)
							end
						end
					end
					if GetNumSpecGroups() == 1 then
						for i = 1, #telentTable do
							GameTooltip:AddDoubleLine(telentTable[i])
						end
					end
				end
				
				-- pvp telent
				local pvpTalents
				if UnitLevel("player") >= SHOW_PVP_TALENT_LEVEL then
					pvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
					
					if #pvpTalents > 0 then
						-- pvp title
						local pvpTexture = select(3, GetCurrencyInfo(104))
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(addIcon(pvpTexture).." "..init.Colored..PVP_TALENTS.."|r")
						-- pvp telent list
						for _, talentID in next, pvpTalents do
							local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
							if name and unlocked then
								GameTooltip:AddLine(addIcon(icon).." "..name)
							end
						end
					end
					wipe(pvpTalents)
				end
				GameTooltip:Show()
			end)
		
		self:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end
	
	Stat:RegisterEvent("PLAYER_LOGIN")
	Stat:RegisterEvent("CONFIRM_TALENT_WIPE")
	Stat:RegisterEvent("PLAYER_TALENT_UPDATE")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
	Stat:SetScript("OnEvent", OnEvent)
	
	-- click function
	Stat:SetScript("OnMouseDown", function(self,button)
		if button == "RightButton" then
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
			EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 3)
		else
			if not PlayerTalentFrame then
				LoadAddOn("Blizzard_TalentUI")
			end
			ToggleTalentFrame(2)
		end
	end)
end