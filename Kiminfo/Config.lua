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

------------
-- Golbal --
------------

	G.addon = "Kiminfo_"
	G.MediaFolder = "Interface\\AddOns\\Kiminfo\\Media\\"

-----------
-- Media --
-----------

	G.Tex = G.MediaFolder.."bar.tga"
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

	C.Panel = true			-- Enable panel / 啟用面板
	
	-- anchor, parent, x, y, width, height, alpha
	-- 錨點，父級框體，x座標，y座標，寬度，高度，透明度
	C.Panel1 = {"TOPLEFT", UIParent, 165, -20, 420, 36, 32, .8}
	C.Panel2 = {"TOPLEFT", UIParent, 165, -60, 320, 36, 32, .8}
	-- add if you need, max to C.Panel5 / 自己加，最多到C.Panel5

--------------
-- Settings --
--------------
	
	-- Tooltip showup direction / 滑鼠提示的顯示方向
	-- if you put databar on screen botton, change true to false. / 如果你調整訊息列至畫面底部，將ture改為false
	C.StickTop = true
	
	-- Show memory usage when only mouseover / 只在指向時顯示插件占用
	-- if you have too many addons, enable this to avoid fps drop cause by memory refresh / 如果你用了很多插件，啟用它防止掉幀
	C.MemHide = false
	
	-- Timer / 時鐘
	C.Time = true
	C.TimePoint =  {"TOPLEFT", UIParent, 185, -30}
	
	-- Friends / 好友
	C.Friends = true
	C.FriendsPoint =  {"LEFT", "Kiminfo_Time", "RIGHT", 30, 0}
	
	-- Guild / 公會
	C.Guild = true
	C.GuildPoint = {"LEFT", "Kiminfo_Friends", "RIGHT", 30, 0}
	
	-- Bags / 背包
	C.Bags = true
	C.BagsPoint = {"LEFT", "Kiminfo_Guild", "RIGHT", 30, 0}
	
	-- Durability / 耐久
	C.Durability = true
	C.DurabilityPoint = {"LEFT", "Kiminfo_Bags", "RIGHT", 30, 0}

	-- Zone and Position / 地名座標
	C.Positions = true
	C.PositionsPoint = {"LEFT", "Kiminfo_Dura", "RIGHT", 20, 0}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint = {"TOPLEFT", UIParent, 200, -68}
	
	-- System: Fps and latency / 幀數與延遲
	C.System = true
	C.SystemPoint = {"LEFT", "Kiminfo_Mem", "RIGHT", 70, 0}
	
	-- Spec: Spec and Loot Spec
	C.Spec = true
	C.SpecPoint =  {"LEFT", "Kiminfo_System", "RIGHT", 15, 0}
	
-------------
-- Credits --
-------------

	-- NDui
	-- diminfo
	-- Tukz
	-- Aftermath
	-- HopeASD
	
	-- C_Map.GetPlayerMapPosition Memory Usage
	-- https://www.wowinterface.com/forums/showthread.php?t=56290
