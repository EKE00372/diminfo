----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	
	if diminfo == nil then diminfo = {} end
	
local C, F, G, DB = unpack(ns)

	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色

local MediaFolder = "Interface\\AddOns\\diminfo\\Media\\"

------------
-- Golbal --
------------

	C.Panel = true			-- Enable panel / 啟用面板
	C.ClassColor = true		-- Enable font color / 啟用職業染色

-----------
-- Media --
-----------

	G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.Glow = MediaFolder.."glow.tga"
	G.Fonts = STANDARD_TEXT_FONT		-- 字型 / Font
	G.FontSize = 16						-- 大小 / Font size
	G.FontFlag = "OUTLINE"				-- 描邊 / Font outline
	
-----------
-- Panel --
-----------

	-- anchor, parent, x, y, width, height, shadow
	-- 錨點，父級框體，x座標，y座標，寬度，高度，陰影
	C.Panel1 = {"TOPLEFT", UIParent, 10, -5, 630, 8, 3}
	
	-- add if you need, max to C.Panel5 / 自己加，最多到C.Panel5
	--C.Panel2 = {"TOP", UIParent, 10, -5, 200, 8, 3}
	
--------------
-- Settings --
--------------
	
	-- Zone text and Position / 地名座標
	C.Positions = true
	C.PositionsPoint = {"TOP", Minimap, 0, 10}
	--C.PositionsPoint = {"TOP", UIParent, 0, -6}

	-- Timer / 時鐘
	C.Time = true
	C.TimePoint = {"TOP", Minimap, "BOTTOM", 0, 8}
	--C.TimePoint =  {"LEFT", "diminfo_dura", "RIGHT", 20, 0}
	
	-- Durability / 耐久
	C.Durability = true
	C.DurabilityPoint = {"LEFT", "diminfo_Guild", "RIGHT", 20, 0}

	-- Bags / 背包
	C.Bags = true
	--C.BagsPoint = {"LEFT", "diminfo_dura", "RIGHT", 20, 0}
	C.BagsPoint = {"TOPLEFT", UIParent, 20, -6}

	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint = {"LEFT", "diminfo_Bag", "RIGHT", 20, 0}

	-- System: Fps and latency / 幀數與延遲
	C.System = true
	C.SystemPoint = {"LEFT", "diminfo_Memory", "RIGHT", 20, 0}

	-- 好友
	C.Friends = true
	C.FriendsPoint =  {"LEFT", "diminfo_System", "RIGHT", 20, 0}
	
	-- 公會
	C.Guild = true
	C.GuildPoint = {"LEFT", "diminfo_Friends", "RIGHT", 20, 0}

-------------
-- Credits --
-------------

	-- NDui
	-- diminfo
	-- Tukz
	-- Aftermath