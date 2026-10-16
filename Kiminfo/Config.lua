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

	G.Line = "|cff7b8489---------------|r"	-- or ffd100
	G.TitleColor = "|cff66ccff"				-- or 0099FF
	G.OptionColor = "|cff99ccff"
	G.ErrColor = "|cffff0000"
	
--------------
-- Settings --
--------------
	
	-- Tooltip showup direction / 滑鼠提示的顯示方向
	-- If you put databar on screen botton, change true to false. / 如果你調整訊息列至畫面底部，將ture改為false
	C.StickTop = true

	-- Friends & Guild panel size / 好友、公會面板尺寸
	-- Size should not exceed 1200*600 / 尺寸建議不超過 1200*600
	C.InfoPanel = {maxWidth = 1000, maxHeight = 600}
	
	-- Enable modules; changes take effect after reload / 模組開關，重載後生效
	
	C.Time = true		-- Timer / 時鐘
	C.Bags = true		-- Bags / 背包
	C.Memory = true		-- Memory / 記憶體占用列表	
	C.System = true		-- System: Fps and latency / 幀數與延遲
	C.MaxAddOns = 30	-- Addon list maximum / 插件列表顯示數量
	C.Spec = true		-- Spec: Spec and Loot Spec / 專精與拾取專精
	C.Friends = true	-- Friends / 好友
	C.Guild = true		-- Guild / 公會
	C.Durability = true	-- Durability / 耐久
	C.Positions = true	-- Zone and Position / 地名與座標

------------
-- Layout --
------------

	-- Gap between module layout bounds / 模組排列範圍之間的通用間距
	C.Gap = 8

	-- point: anchor, parent, x, y / 列錨點、相對框體、X、Y
	-- inset: x, y / 內容排列起點相對列左上角的 X、Y；不是個別 FontString 的舊錨點
	-- panel: width, height, alpha / 中段背景寬度、高度、透明度；左右漸層另向外延伸
	-- panel = nil（省略）或 false 關閉整組背景，內容位置與排列不變。
	-- modules: {module, offset} / 模組名稱、額外水平偏移；offset 省略為 0，可正可負
	-- 首個啟用模組使用 inset + offset；後續模組接前一個啟用模組，間距為 C.Gap + offset。
	-- offset 會推移該模組及後續模組；停用項不保留空位，也不累加它的 offset。
	-- 每個模組只配置於一列；整列沒有啟用模組時，內容與背景都不顯示。
	-- 未列入 Layout 只隱藏該模組的顯示；要停用整個模組及背景功能，請將對應 C.模組名稱 設為 false。
	C.Layout = {
		{
			point = {"TOPLEFT", UIParent, 0, -10},
			inset = {15, -10},
			panel = {720, 36, .8},
			modules = {
				{"Time", 0},
				{"Bags", 0},
				{"Memory", 0},
				{"System", 0},
				{"Spec", 0},
				{"Friends", 0},
				{"Guild", 0},
				{"Durability", 0},
				{"Positions", 0},
			},
		},
	}

	-- Custom layout example / 雙列範例
	-- Replace the C.Layout above with this block, then /reload. / 使用時以此段 C.Layout 取代上方單列設定，再重載介面。
	--[[
	C.Layout = {
		{
			point = {"TOPLEFT", UIParent, 288, -20},
			inset = {22, -10},
			panel = {420, 36, .8},
			modules = {
				{"Time", 0},
				{"Friends", 0},
				{"Guild", 0},
				{"Bags", 0},
				{"Durability", 0},
				{"Positions", 0},
			},
		},
		{
			point = {"TOPLEFT", UIParent, 288, -60},
			inset = {15, -8},
			panel = {320, 36, .8},
			modules = {
				{"Memory", 0},
				{"System", 0},
				{"Spec", 0},
			},
		},
	}
	]]--

-------------
-- Credits --
-------------

	-- Tukz, Loshine, Siweia, HopeASD
	-- Bar texture support: Peterdox
	-- Icon texture from SX Databar.NDui
	
	-- C_Map.GetPlayerMapPosition Memory Usage
	-- https://www.wowinterface.com/forums/showthread.php?t=56290
