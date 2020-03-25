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
	G.MediaFolder = "Interface\\AddOns\\Kiminfo\\Media\\"
	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色

------------
-- Golbal --
------------

	C.Panel = true			-- Enable panel / 啟用面板

-----------
-- Media --
-----------

	G.Tex = G.MediaFolder.."bar.tga"
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

	-- anchor, parent, x, y, width, height, alpha
	-- 錨點，父級框體，x座標，y座標，寬度，高度，透明度
	C.Panel1 = {"TOPLEFT", UIParent, 0, -2, 560, 36, 32, .6}
	-- add if you need, max to C.Panel5 / 自己加，最多到C.Panel5
	
--------------
-- Settings --
--------------
	
	-- Timer / 時鐘
	C.Time = true
	C.TimePoint =  {"TOPLEFT", UIParent, 20, -12}
	--C.TimePoint =  {"TOPLEFT", UIParent, 620, -12}
	
	-- Bags / 背包
	C.Bags = true
	--C.BagsPoint = {"LEFT", "Kiminfo_Time", "RIGHT", 24, 0}
	C.BagsPoint = {"TOPLEFT", UIParent, 100, -12}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint = {"LEFT", "Kiminfo_Bags", "RIGHT", 30, 0}
	--C.MemoryPoint = {"TOPLEFT", UIParent, 120, -12}
	
	-- System: Fps and latency / 幀數與延遲
	C.System = true
	C.SystemPoint = {"LEFT", "Kiminfo_Mem", "RIGHT", 70, 0}
	--C.SystemPoint = {"TOPLEFT", UIParent, 220, -12}
	
	-- Friends / 好友
	C.Friends = true
	C.FriendsPoint =  {"LEFT", "Kiminfo_System", "RIGHT", 30, 0}
	--C.FriendsPoint =  {"TOPLEFT", UIParent, 320, -12}
	
	-- Guild / 公會
	C.Guild = true
	C.GuildPoint = {"LEFT", "Kiminfo_Friends", "RIGHT", 30, 0}
	--C.GuildPoint = {"TOPLEFT", UIParent, 420, -12}
	--C.GuildPoint = {"CENTER", UIParent, 0, -12}
	
	-- Durability / 耐久
	C.Durability = true
	C.DurabilityPoint = {"LEFT", "Kiminfo_Guild", "RIGHT", 30, 0}
	--C.DurabilityPoint = {"TOPLEFT", UIParent, 520, -12}

	-- Zone text and Position / 地名座標
	C.Positions = true
	C.PositionsPoint = {"LEFT", "Kiminfo_Dura", "RIGHT", 24, 0}
	--C.PositionsPoint = {"TOP", UIParent, 0, -12}
	
-------------
-- Credits --
-------------

	-- NDui
	-- diminfo
	-- Tukz
	-- Aftermath
	-- HopeASD