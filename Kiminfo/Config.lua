----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization
	
	if Kiminfo == nil then Kiminfo = {} end
	
local C, F, G, L = unpack(ns)

	G.addon = "Kiminfo_"
	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色

------------
-- Golbal --
------------

	C.Panel = true			-- Enable panel / 啟用面板
	C.ClassColor = true		-- Enable font color / 啟用職業染色

-----------
-- Media --
-----------

	G.MediaFolder = "Interface\\AddOns\\Kiminfo\\Media\\"
	G.Tex = G.MediaFolder.."bar.tga"
	G.Fonts = STANDARD_TEXT_FONT		-- 字型 / Font
	G.FontSize = 16						-- 大小 / Font size
	G.FontFlag = "OUTLINE"				-- 描邊 / Font outline

	G.Line = "|cff7b8489---------------|r"
	G.OptionColor = "|cff99ccff"		-- .6, .8, 1 /or .4, .78, .1
	G.ErrColor = "|cffff0000"			-- 1, 0, 0
	
-----------
-- Panel --
-----------

	-- anchor, parent, x, y, width, height, alpha
	-- 錨點，父級框體，x座標，y座標，寬度，高度，透明度
	C.Panel1 = {"TOPLEFT", UIParent, 170, -20, 410, 36, 32, .8}
	C.Panel2 = {"TOPLEFT", UIParent, 170, -60, 316, 36, 32, .8}

--------------
-- Settings --
--------------
	
	-- Timer / 時鐘
	C.Time = true
	--C.TimePoint = {"TOP", Minimap, "BOTTOM", 0, 8}
	C.TimePoint =  {"TOPLEFT", UIParent, 185, -30}
	
	-- Friends / 好友
	C.Friends = true
	C.FriendsPoint =  {"LEFT", "Kiminfo_Time", "RIGHT", 20, 0}
	
	-- Guild / 公會
	C.Guild = true
	C.GuildPoint = {"LEFT", "Kiminfo_Friends", "RIGHT", 10, 0}
	
	-- Bags / 背包
	C.Bags = true
	C.BagsPoint = {"LEFT", "Kiminfo_Guild", "RIGHT", 10, 0}
	
	-- Durability / 耐久
	C.Durability = true
	C.DurabilityPoint = {"LEFT", "Kiminfo_Bags", "RIGHT", 10, 0}

	-- Zone and Position / 地名座標
	C.Positions = true
	C.PositionsPoint = {"LEFT", "Kiminfo_Dura", "RIGHT", 20, 0}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint = {"TOPLEFT", UIParent, 180, -68}
	
	-- System: Fps and latency / 幀數與延遲
	C.System = true
	C.SystemPoint = {"LEFT", "Kiminfo_Mem", "RIGHT", 10, 0}
	
	-- Spec and Loot Spec
	C.Spec = true
	C.SpecPoint =  {"LEFT", "Kiminfo_System", "RIGHT", 15, 0}
	
-------------
-- Credits --
-------------

	-- NDui
	-- Kiminfo
	-- Tukz
	-- Aftermath
	
	-- C_Map.GetPlayerMapPosition Memory Usage
	-- https://www.wowinterface.com/forums/showthread.php?t=56290
