----------------------
-- Dont touch this! --
----------------------

local _, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization
	
	if diminfo == nil then diminfo = {} end
	
local C, G = ns[1], ns[3]

	G.addon = "diminfo_"
	G.MediaFolder = "Interface\\AddOns\\diminfo\\Media\\"
	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色

------------
-- Golbal --
------------

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
	
--------------
-- Settings --
--------------
	
	-- Tooltip showup direction / 滑鼠提示的顯示方向
	-- Note: 如果你調整訊息列至畫面底部，將ture改為false
	-- Note: if you put databar on screen botton, change true to false.
	C.StickTop = true

	C.MaxAddOns = 30		-- 插件列表顯示數量 / Addon list maximum
	C.InfoPanel = {maxHeight = 600}	-- 好友與公會共用的面板高度上限 / Shared panel height limit

	-- 模組開關，重載後生效 / Enable modules; reload after editing
	C.Bags = true		-- 背包 / Bags
	C.Memory = true		-- 記憶體 / Memory
	C.System = true		-- 幀數與延遲 / FPS and latency
	C.Friends = true		-- 好友 / Friends
	C.Guild = true		-- 公會 / Guild
	C.Durability = true	-- 耐久 / Durability
	C.Time = true		-- 時鐘 / Time
	C.Positions = true	-- 地名與座標 / Zone and coordinates

------------
-- Layout --
------------

	C.Gap = 16	-- 模組之間的共用間距 / Gap between modules

	-- point：列錨點、父框體、X、Y / Row anchor, parent, X, Y
	-- inset：內容起點相對列左上角的X、Y / Content offset from row TOPLEFT
	-- style："Gradient"漸層或"Glass"玻璃 / Background style
	-- panel：背景寬度、高度、透明度；false或省略可關閉背景 / Width, height, alpha; false/nil hides background
	-- modules：{模組名稱, 額外水平偏移}；偏移可省略 / {Module, optional horizontal offset}
	-- 停用模組不留空位；每個模組只放一列。未列入只隱藏顯示，C.模組=false才停用功能。
	C.Layout = {
		{
			point = {"TOPLEFT", UIParent, 0, -2},
			inset = {18, -10},
			style = "Gradient",
			panel = {730, 36, .6},
			modules = {
				{"Bags", 0},
				{"Memory", 0},
				{"System", 0},
				{"Friends", 0},
				{"Guild", 0},
				{"Durability", 0},
				{"Time", 0},
				{"Positions", 0},
			},
		},
	}
	
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