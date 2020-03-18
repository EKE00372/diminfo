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

	--G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.Tex = MediaFolder.."bar.tga"
	G.Fonts = STANDARD_TEXT_FONT		-- 字型 / Font
	G.FontSize = 16						-- 大小 / Font size
	G.FontFlag = "OUTLINE"				-- 描邊 / Font outline

	G.Line = "|cff7b8489---------------|r"
	G.OptionColor = "|cff99ccff"		-- .6, .8, 1 /or .4, .78, .1
	G.ErrColor = "|cffff0000"			-- 1, 0, 0
	
	G.Bags = MediaFolder.."bags.tga"
	G.Friends = MediaFolder.."friends.tga"
	G.Guild = MediaFolder.."guild.tga"
	G.Dura = MediaFolder.."dura.tga"
	G.Fps = MediaFolder.."fps.tga"
	G.Ping = MediaFolder.."ping.tga"
	G.Mem = MediaFolder.."spell.tga"
	G.He = MediaFolder.."hearth.tga"
	
	G.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
	G.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
	G.MiddleButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "
	
	G.AFK = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
	G.DND = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

-----------
-- Panel --
-----------

	-- anchor, parent, x, y, width, height, alpha1, alpha2
	-- 錨點，父級框體，x座標，y座標，寬度，高度，透明度1，透明度2
	C.Panel1 = {"TOPLEFT", UIParent, 130, -20, 40, 36, 32, 0, .8}
	C.Panel2 = {"TOPLEFT", UIParent, 170, -20, 400, 36, 32, .8, .8}
	C.Panel3 = {"TOPLEFT", UIParent, 570, -20, 100, 36, 32, .8, 0}
	
	C.Panel4 = {"TOPLEFT", UIParent, 130, -60, 40, 36, 32, 0, .8}
	C.Panel5 = {"TOPLEFT", UIParent, 170, -60, 300, 36, 32, .8, .8}
	C.Panel6 = {"TOPLEFT", UIParent, 470, -60, 100, 36, 32, .8, 0}

--------------
-- Settings --
--------------
	
	-- Timer / 時鐘
	C.Time = true
	--C.TimePoint = {"TOP", Minimap, "BOTTOM", 0, 8}
	C.TimePoint =  {"TOPLEFT", UIParent, 185, -30}
	
	-- Friends / 好友
	C.Friends = true
	C.FriendsPoint =  {"LEFT", "diminfo_Time", "RIGHT", 20, 0}
	
	-- Guild / 公會
	C.Guild = true
	C.GuildPoint = {"LEFT", "diminfo_Friends", "RIGHT", 10, 0}
	
	-- Bags / 背包
	C.Bags = true
	C.BagsPoint = {"LEFT", "diminfo_Guild", "RIGHT", 10, 0}
	
	-- Durability / 耐久
	C.Durability = true
	C.DurabilityPoint = {"LEFT", "diminfo_Bags", "RIGHT", 10, 0}

	-- Zone and Position / 地名座標
	C.Positions = true
	C.PositionsPoint = {"LEFT", "diminfo_Dura", "RIGHT", 20, 0}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint = {"TOPLEFT", UIParent, 180, -68}
	
	-- System: Fps and latency / 幀數與延遲
	C.System = true
	C.SystemPoint = {"LEFT", "diminfo_Mem", "RIGHT", 10, 0}
	
	-- Spec and Loot Spec
	C.Spec = true
	C.SpecPoint =  {"LEFT", "diminfo_System", "RIGHT", 15, 0}
	
-------------
-- Credits --
-------------

	-- NDui
	-- diminfo
	-- Tukz
	-- Aftermath
	
	-- C_Map.GetPlayerMapPosition Memory Usage
	-- https://www.wowinterface.com/forums/showthread.php?t=56290
