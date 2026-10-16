local _, ns = ...
local G, L = ns[3], ns[4]

local getLocale = GetLocale()
	if getLocale == "zhTW" then
		
		L.Calendar = SLASH_CALENDAR2:gsub("/(.*)","%1")
		
		L.AutoSell = "自動賣垃圾："
		L.TrashSold = "垃圾售出："
		
		L.AutoRepair = "自動修理："
		L.None = "無裝備"
		
		L.Lonely = "獨行"
		L.NamePreset = "顯示名字"
		L.HideNames = "隱藏名字"
		
		L.Shift = "Shift 展開"
		L.Hidden = HIDE
		
		L.DefaultUsage = "内建插件資源占用"
		L.TotleUsage = "總資源占用"
		L.Collected = "釋放記憶體："
		L.ManualCollect = "回收記憶體"
		L.AutoCollect = "自動回收記憶體："
		L.CollectWarning = "|cff00ffffKim|rinfo[|cff00ff00Memory|r]："..G.ErrColor.."危險功能！|r啟用自動整理暫存記憶體可能使遊戲主程式周期性凍結。"

		L.Spec = "專精"
		
		L.Home = "本地"
		L.World = "世界"
		L.CPU = "CPU 統計："
		L.ResetCPU = "重置 CPU 統計"
		L.SwitchAudioOutput = "切換音效輸出"
		L.ReloadOn = "|cff00ffffKim|rinfo[|cff00ff00System|r]："..G.OptionColor.."重載介面後顯示。|r"
		L.ReloadOff = "|cff00ffffKim|rinfo[|cff00ff00System|r]："..G.OptionColor.."重載介面後隱藏。|r"
		
		L.App = "魔獸好戰友"
		L.Mobile = "行動裝置"
		L.Desktop = "應用程式"
		
	elseif getLocale == "zhCN" then
		
		L.Calendar = "行事历"
		
		L.AutoSell = "自动卖垃圾："
		L.TrashSold = "垃圾售出："
		
		L.AutoRepair = "自动修理："
		L.None = "无装备"
		
		L.Lonely = "独行"
		L.NamePreset = "显示名字"
		L.HideNames = "隐藏名字"
		
		L.Shift = "Shift 展开"
		L.Hidden = HIDE
		
		L.DefaultUsage = "内置插件内存占用"
		L.TotleUsage = "总内存占用"
		L.Collected = "释放內存："
		L.ManualCollect = "回收内存"
		L.AutoCollect = "自动回收内存："
		L.CollectWarning = "|cff00ffffKim|rinfo[|cff00ff00Memory|r]："..G.ErrColor.."危险功能！|r启用自动整理內存可能使客户端周期性冻结。"
			
		L.Spec = "专精"
		
		L.Home = "本地"
		L.World = "世界"
		L.CPU = "CPU 统计："
		L.ResetCPU = "重置 CPU 统计"
		L.SwitchAudioOutput = "切换音效输出"
		L.ReloadOn = "|cff00ffffKim|rinfo[|cff00ff00System|r]："..G.OptionColor.."重载界面后显示插件的 CPU 占用。|r"
		L.ReloadOff = "|cff00ffffKim|rinfo[|cff00ff00System|r]："..G.OptionColor.."重载界面后隐藏插件的 CPU 占用。|r"
		
		L.App = "随身助手"
		L.Mobile = "移动装置"
		L.Desktop = "桌面应用"
		
	elseif getLocale == "ruRU" then
		
		L.Calendar = SLASH_CALENDAR1:gsub("/(.*)","%1")
		
		L.AutoSell = "Автопродажа барахла: "
		L.TrashSold = "Мусор продал, заработал "
		
		L.AutoRepair = "Авторемонт: "
		L.None = "Не экипирован"
		
		L.Lonely = "Одинокий"
		L.NamePreset = "Показать имена"
		L.HideNames = "Скрыть имена"
		
		L.Shift = "Shift показать все"
		L.Hidden = "Скрытый"
		
		L.DefaultUsage = "Использование памяти пользовательского интерфейса по умолчанию"
		L.TotleUsage = "Общее Использование Памяти"
		L.Collected = "Сборка мусора: "
		L.ManualCollect = "Сборка мусора"
		L.AutoCollect = "Автоматическая сборка мусора: "
		L.CollectWarning = "|cff00ffffKim|rinfo[|cff00ff00Memory|r]: "..G.ErrColor.."NOTICE: DANGER!|r Auto collected memory may cause your client freeze."
		
		L.Spec = "Спек"
		
		L.Home = "Домой"
		L.World = "Мир"
		L.CPU = "Статистика ЦП: "
		L.ResetCPU = "Сбросить статистику ЦП"
		L.SwitchAudioOutput = "Сменить устройство вывода звука"
		L.ReloadOn = "|cff00ffffKim|rinfo[|cff00ff00Система|r]: "..G.OptionColor.."Вы увидите загрузку процессора аддона после перезагрузки пользовательского интерфейса.|r"
		L.ReloadOff = "|cff00ffffKim|rinfo[|cff00ff00Система|r]: "..G.OptionColor.."Вы можете скрыть таблицу использования процессора аддона после перезагрузки пользовательского интерфейса.|r"
		
		L.App = "Портативный помощник"
		L.Mobile = "Мобильный"
		L.Desktop = "Рабочий стол"
		
	else
		L.Calendar = SLASH_CALENDAR1:gsub("/(.*)","%1")
		
		L.AutoSell = "Auto Sell junk: "
		L.TrashSold = "Trash sold, earned "
		
		L.AutoRepair = "Auto Repair: "
		L.None = "None"
		
		L.Lonely = "Lonely"
		L.NamePreset = "Show names"
		L.HideNames = "Hide names"
		
		L.Shift = "Shift show all"
		L.Hidden = "Hidden"
		
		L.DefaultUsage = "Default UI Memory Usage"
		L.TotleUsage = "Total Memory Usage"
		L.Collected = "Garbage collected: "
		L.ManualCollect = "Collect garbage"
		L.AutoCollect = "Auto collect memory: "
		L.CollectWarning = "|cff00ffffKim|rinfo[|cff00ff00Memory|r]: "..G.ErrColor.."DANGER!|r Auto collected memory may cause your client freeze."
		
		L.Spec = "Spec"
		
		L.Home = "Home"
		L.World = "World"
		L.CPU = "CPU statistics: "
		L.ResetCPU = "Reset CPU statistics"
		L.SwitchAudioOutput = "Switch audio output"
		L.ReloadOn = "|cff00ffffKim|rinfo[|cff00ff00System|r]: "..G.OptionColor.."You would see addon's CPU usage after reloding UI.|r"
		L.ReloadOff = "|cff00ffffKim|rinfo[|cff00ff00System|r]: "..G.OptionColor.."You could hide the addon's CPU usage table after reloding UI.|r"
		
		L.App = "Companion"
		L.Mobile = "Mobile"
		L.Desktop = "Desktop"
	end
