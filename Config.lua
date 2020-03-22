----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization
	
	if diminfo == nil then diminfo = {} end
	
local C, F, G, L = unpack(ns)

	G.addon = "diminfo_"
	G.MediaFolder = "Interface\\AddOns\\diminfo\\Media\\"
	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色

------------
-- Golbal --
------------

	C.Panel = true			-- Enable panel / 啟用面板
	C.ClassColor = true		-- Enable font color / 啟用職業染色

-----------
-- Media --
-----------

	G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.Glow = G.MediaFolder.."glow.tga"
	G.Fonts = STANDARD_TEXT_FONT		-- 字型 / Font
	G.FontSize = 16						-- 大小 / Font size
	G.FontFlag = "OUTLINE"				-- 描邊 / Font outline
	
	G.Line = "|cff7b8489---------------|r"
	G.TitleColor = "|cff0099ff"		-- .6, .8, 1 /or .4, .78, .1
	G.OptionColor = "|cff99ccff"		-- .6, .8, 1 /or .4, .78, .1
	G.ErrColor = "|cffff0000"			-- 1, 0, 0
	
-----------
-- Panel --
-----------

	-- anchor, parent, x, y, width, height, shadow
	-- 錨點，父級框體，x座標，y座標，寬度，高度，陰影
	C.Panel1 = {"TOPLEFT", UIParent, 10, -5, 670, 8, 3}
	--C.Panel1 = {"TOPLEFT", UIParent, 10, -5, 710, 8, 3}
	
	-- add if you need, max to C.Panel5 / 自己加，最多到C.Panel5
	C.Panel2 = {"TOP", UIParent, 0, -5, 200, 8, 3}
	
--------------
-- Settings --
--------------
	
	-- Zone text and Position / 地名座標
	C.Positions = true
	C.PositionsPoint = {"TOP", UIParent, 0, -6}
	
	-- Bags / 背包
	C.Bags = true
	C.BagsPoint = {"TOPLEFT", UIParent, 24, -6}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint = {"LEFT", "diminfo_Bags", "RIGHT", 16, 0}
	--C.MemoryPoint = {"TOPLEFT", UIParent, 120, -6}
	
	-- System: Fps and latency / 幀數與延遲
	C.System = true
	C.SystemPoint = {"LEFT", "diminfo_Mem", "RIGHT", 16, 0}
	--C.SystemPoint = {"TOPLEFT", UIParent, 220, -6}
	
	-- 好友
	C.Friends = true
	C.FriendsPoint =  {"LEFT", "diminfo_System", "RIGHT", 16, 0}
	--C.FriendsPoint =  {"TOPLEFT", UIParent, 320, -6}
	
	-- 公會
	C.Guild = true
	C.GuildPoint = {"LEFT", "diminfo_Friends", "RIGHT", 16, 0}
	--C.GuildPoint = {"TOPLEFT", UIParent, 420, -6}
	
	-- Durability / 耐久
	C.Durability = true
	C.DurabilityPoint = {"LEFT", "diminfo_Guild", "RIGHT", 16, 0}
	--C.DurabilityPoint = {"TOPLEFT", UIParent, 520, -6}

	-- Timer / 時鐘
	C.Time = true
	C.TimePoint =  {"LEFT", "diminfo_Dura", "RIGHT", 16, 0}
	--C.TimePoint =  {"TOPLEFT", UIParent, 620, -6}
	
-------------
-- Credits --
-------------

	-- NDui
	-- diminfo
	-- Tukz
	-- Aftermath