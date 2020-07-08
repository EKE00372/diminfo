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

	C.ShowPanel = true		-- Enable panel / 啟用面板
	C.ClassColor = true		-- Enable font color / 啟用職業染色

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

	-- style, anchor, parent, x, y, width, height, alpha
	-- 風格，錨點，父級框體，x座標，y座標，寬度，高度，透明度
	
	C.Panel1 = {"Gradient", "TOPLEFT", UIParent, 0, -2, 730, 36, .6}
	--C.Panel1 = {"Glass", "TOPLEFT", UIParent, 0, -6, 860, 16, .6}
	-- add if you need, max to C.Panel5 / 自己加，最多到C.Panel5
	
	-- NOTE:
	-- 風格必需是 "Gradient" (漸變) 或 "Glass" (玻璃)
	-- style should be "Gradient" or "Glass"
	
--------------
-- Settings --
--------------
	
	-- Tooltip showup direction / 滑鼠提示的顯示方向
	-- Note: 如果你調整訊息列至畫面底部，將ture改為false
	-- Note: if you put databar on screen botton, change true to false.
	C.StickTop = true

	-- Bags / 背包
	C.Bags = true
	C.BagsPoint = {"TOPLEFT", UIParent, 18, -12}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint = {"LEFT", "diminfo_Bags", "RIGHT", 16, 0}
	--C.MemoryPoint = {"TOPLEFT", UIParent, 120, -12}
	
	-- System: Fps and latency / 幀數與延遲
	C.System = true
	C.SystemPoint = {"LEFT", "diminfo_Mem", "RIGHT", 16, 0}
	--C.SystemPoint = {"TOPLEFT", UIParent, 220, -12}
	
	-- 好友 / Friends
	C.Friends = true
	C.FriendsPoint =  {"LEFT", "diminfo_System", "RIGHT", 16, 0}
	--C.FriendsPoint =  {"TOPLEFT", UIParent, 320, -12}
	
	-- 公會 / Guild
	C.Guild = true
	C.GuildPoint = {"LEFT", "diminfo_Friends", "RIGHT", 16, 0}
	--C.GuildPoint = {"TOPLEFT", UIParent, 420, -12}
	
	-- Durability / 耐久
	C.Durability = true
	C.DurabilityPoint = {"LEFT", "diminfo_Guild", "RIGHT", 16, 0}
	--C.DurabilityPoint = {"TOPLEFT", UIParent, 520, -12}
	
	-- Timer / 時鐘
	C.Time = true
	C.TimePoint =  {"LEFT", "diminfo_Dura", "RIGHT", 16, 0}
	--C.TimePoint =  {"TOPLEFT", UIParent, 620, -12}
	
	-- Zone text and Position / 地名座標
	C.Positions = true
	C.PositionsPoint = {"LEFT", "diminfo_Time", "RIGHT", 16, 0}
	--C.PositionsPoint = {"TOP", UIParent, 0, -12}
	
-------------
-- Credits --
-------------

	-- HopeASD, Peterodox
	-- NDui
	-- https://github.com/siweia/NDuiClassic/tree/master/Interface/AddOns/NDui/Modules/Infobar
	-- diminfo
	-- https://www.wowinterface.com/downloads/info20899-diminfo.html
	
	-- To edit Position
	
	-- [欢迎来到小N老师的Lua新手讲堂] 第一讲 锚点与位置
	-- https://bbs.nga.cn/read.php?tid=4555096
	-- Wowpedia: SetPoint()
	-- https://wow.gamepedia.com/API_Region_SetPoint