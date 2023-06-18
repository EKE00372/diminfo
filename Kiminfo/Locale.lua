local addon, ns = ... 
local C, F, G, L = unpack(ns)

local getLocale = GetLocale()
	if getLocale == "zhTW" then
		
		L.AutoSell = "自動賣垃圾："
		L.TrashSold = "垃圾售出："
		
		L.AutoRepair = "自動修理："
		L.None = "無裝備"
		
		L.Lonely = "沒人要"
		
		L.Shift = "Shift 展開"
		L.Hidden = HIDE
		
		L.DefaultUsage = "内建插件資源占用"
		L.TotleUsage = "總資源占用"
		L.Collected = "釋放記憶體："
		L.ManualCollect = "手動釋放暫存記憶體"
		L.AutoCollect = "自動整理暫存記憶體："
		L.CollectWarning = "|cff00ffffKim|rinfo[|cff00ff00Memory|r]：|cffff0000注意：危險功能！|r啟用自動整理暫存記憶體可能使遊戲主程式周期性凍結。"

		L.Spec = "專精"
		L.Loot = LOOT
		
		L.Home = "本地"
		L.World = "世界"
		L.CPU = "顯示 CPU 占用比例："
		L.ResetCPU = "重置 CPU 占用列表"
		L.ReloadOn = "|cff00ffffKim|rinfo[|cff00ff00System|r]：重載介面後顯示插件的 CPU 占用。"
		L.ReloadOff = "|cff00ffffKim|rinfo[|cff00ff00System|r]：重載介面後隱藏插件的 CPU 占用。"
		
		L.App = "魔獸好戰友"
		L.Mobile = "行動裝置"
		L.Desktop = "應用程式"
		L.GrandHunts = "大狩獵"
		
	elseif getLocale == "zhCN" then
		
		L.AutoSell = "自动卖垃圾："
		L.TrashSold = "垃圾售出："
		
		L.AutoRepair = "自动修理："
		L.None = "无装备"
		
		L.Lonely = "沒人要"
		
		L.Shift = "Shift 展开"
		L.Hidden = HIDE
		
		L.DefaultUsage = "内置插件内存占用"
		L.TotleUsage = "总内存占用"
		L.Collected = "释放內存："
		L.ManualCollect = "手动释放"
		L.AutoCollect = "自动整理內存："
		L.CollectWarning = "|cff00ffffKim|rinfo[|cff00ff00Memory|r]：|cffff0000注意：危险功能！|r启用自动整理內存可能使客户端周期性冻结。"
			
		L.Spec = "专精"
		L.Loot = "拾取"
		
		L.Home = "本地"
		L.World = "世界"
		L.CPU = "显示 CPU 占用比例："
		L.ResetCPU = "重置 CPU 占用列表"
		L.ReloadOn = "|cff00ffffKim|rinfo[|cff00ff00System|r]：重载界面后显示插件的 CPU 占用。"
		L.ReloadOff = "|cff00ffffKim|rinfo[|cff00ff00System|r]：重载界面后隐藏插件的 CPU 占用。"
		
		L.App = "随身助手"
		L.Mobile = "移动装置"
		L.Desktop = "桌面应用"
		L.GrandHunts = "大狩猎"
		
	elseif getLocale == "ruRU" then
		
		L.AutoSell = "Автопродажа барахла: "
		L.TrashSold = "Мусор продал, заработал "
		
		L.AutoRepair = "Авторемонт: "
		L.None = "Не экипирован"
		
		L.Lonely = "Одинокий"
		
		L.Shift = "Shift показать все"
		L.Hidden = "Скрытый"
		
		L.DefaultUsage = "Использование памяти пользовательского интерфейса по умолчанию"
		L.TotleUsage = "Общее Использование Памяти"
		L.Collected = "Сборка мусора: "
		L.ManualCollect = "Ручной Сбор"
		L.AutoCollect = "Автоматический Сбор Памяти: "
		L.CollectWarning = "|cff00ffffKim|rinfo[|cff00ff00Memory|r]: |cffff0000NOTICE: DANGER!|r Auto collected memory may cause your client freeze."
		
		L.Spec = "Спек"
		L.Loot = LOOT
		
		L.Home = "Домой"
		L.World = "Мир"
		L.CPU = "Показать загрузку процессора: "
		L.ResetCPU = "Сброс загрузку процессора"
		L.ReloadOn = "|cff00ffffKim|rinfo[|cff00ff00Система|r]: Вы увидите загрузку процессора аддона после перезагрузки пользовательского интерфейса."
		L.ReloadOff = "|cff00ffffKim|rinfo[|cff00ff00Система|r]: Вы можете скрыть таблицу использования процессора аддона после перезагрузки пользовательского интерфейса."
		
		L.App = "Портативный помощник"
		L.Mobile = "Мобильный"
		L.Desktop = "Рабочий стол"
		L.GrandHunts = "Grand Hunts"
		
	else
		L.AutoSell = "Auto Sell junk: "
		L.TrashSold = "Trash sold, earned "
		
		L.AutoRepair = "Auto Repair: "
		L.None = "None"
		
		L.Lonely = "Lonely"
		
		L.Shift = "Shift show all"
		L.Hidden = "Hidden"
		
		L.DefaultUsage = "Default UI Memory Usage"
		L.TotleUsage = "Total Memory Usage"
		L.Collected = "Garbage collected: "
		L.ManualCollect = "Manual Collect"
		L.AutoCollect = "Auto Collect Memory: "
		L.CollectWarning = "|cff00ffffKim|rinfo[|cff00ff00Memory|r]: |cffff0000NOTICE: DANGER!|r Auto collected memory may cause your client freeze."
		
		L.Spec = "Spec"
		L.Loot = LOOT
		
		L.Home = "Home"
		L.World = "World"
		L.CPU = "Show CPU Usage: "
		L.ResetCPU = "Reset CPU Usage"
		L.ReloadOn = "|cff00ffffKim|rinfo[|cff00ff00System|r]: You would see addon's CPU usage after reloding UI."
		L.ReloadOff = "|cff00ffffKim|rinfo[|cff00ff00System|r]: You could hide the addon's CPU usage table after reloding UI."
		
		L.App = "Companion"
		L.Mobile = "Mobile"
		L.Desktop = "Desktop"
		L.GrandHunts = "Grand Hunts"
	end
