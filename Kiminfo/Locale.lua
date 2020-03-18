local addon, ns = ... 
local C, F, G, L = unpack(ns)

local getLocale = GetLocale()
	if getLocale == "zhTW" then
		L.AutoSell = "自動賣垃圾："
		L.TrashSold = "垃圾售出："
		
		L.AutoRepair = "自動修理："
		--L.RepairCost
		--L.Poor
		L.None = "無裝備"
		
		L.Lonely = "沒人要"
		
		L.Shift = "Shift 展開"
		L.Hidden = HIDE
		
		L.DefaultUsage = "内建插件資源占用："
		L.TotleUsage = "總資源占用："
		L.Collected = "釋放記憶體："
		L.ManualCollect = "手動釋放暫存記憶體"
		L.AutoCollect = "自動整理暫存記憶體："
		
		L.XY = "發送座標"
		
		L.Spec = "專精"
		L.Loot = LOOT
		
		L.Home = "本地"
		L.World = "世界"
		L.Latency = "延遲："
		L.CPU = "顯示 CPU 占用比例："
		L.ReloadOn = "|cff777777dim|rinfo[|cff00ff00System|r]：重載介面後顯示插件的 CPU 佔用。"
		L.ReloadOff = "|cff777777dim|rinfo[|cff00ff00System|r]：重載介面後隱藏插件的 CPU 佔用。"
		
		L.App = "魔獸好戰友"
		L.Mobile = "行動裝置"
		L.Desktop = "應用程式"
	elseif getLocale == "zhCN" then
		L.AutoSell = "自動賣垃圾："
		L.TrashSold = "垃圾售出："
		
		L.AutoRepair = "自動修理："
		--L.RepairCost
		--L.Poor
		L.None = "無裝備"
		
		L.Lonely = "沒人要"
		
		L.Shift = "Shift 展開"
		L.Hidden = HIDE
		
		L.DefaultUsage = "内建插件資源占用："
		L.TotleUsage = "總資源占用："
		L.Collected = "釋放記憶體："
		L.ManualCollect = "手動釋放暫存記憶體"
		L.AutoCollect = "自動整理暫存記憶體："
		
		L.XY = "發送座標"
		
		L.Spec = "專精"
		L.Loot = LOOT
		
		L.Home = "本地"
		L.World = "世界"
		L.Latency = "延遲："
		L.CPU = "顯示 CPU 占用比例："
		L.ReloadOn = "|cff777777dim|rinfo[|cff00ff00System|r]：重載介面後顯示插件的 CPU 佔用。"
		L.ReloadOff = "|cff777777dim|rinfo[|cff00ff00System|r]：重載介面後隱藏插件的 CPU 佔用。"
		
		L.App = "魔獸好戰友"
		L.Mobile = "行動裝置"
		L.Desktop = "應用程式"
	else
		L.AutoSell = "自動賣垃圾："
		L.TrashSold = "垃圾售出："
		
		L.AutoRepair = "自動修理："
		--L.RepairCost
		--L.Poor
		L.None = "無裝備"
		
		L.Lonely = "沒人要"
		
		L.Shift = "Shift 展開"
		L.Hidden = HIDE
		
		L.DefaultUsage = "内建插件資源占用："
		L.TotleUsage = "總資源占用："
		L.Collected = "釋放記憶體："
		L.ManualCollect = "手動釋放暫存記憶體"
		L.AutoCollect = "自動整理暫存記憶體："
		
		L.XY = "發送座標"
		
		L.Spec = "專精"
		L.Loot = LOOT
		
		L.Home = "本地"
		L.World = "世界"
		L.Latency = "延遲："
		L.CPU = "顯示 CPU 占用比例："
		L.ReloadOn = "|cff777777dim|rinfo[|cff00ff00System|r]：重載介面後顯示插件的 CPU 佔用。"
		L.ReloadOff = "|cff777777dim|rinfo[|cff00ff00System|r]：重載介面後隱藏插件的 CPU 佔用。"
		
		L.App = "魔獸好戰友"
		L.Mobile = "行動裝置"
		L.Desktop = "應用程式"
	end
--[[
if GetLocale() == "zhTW" then
	infoL = {
		["AutoSell junk"] = "自動賣垃圾：",
		["Trash sold, earned "] = "垃圾售出：",
	
		["AutoRepair"] = "自動修理：",
		["Repair cost"] = "修理花費：",
		["Go farm, newbie"] = "你真窮。",
		["none"] = "無裝備",	
	
		["No Guild"] = "沒人要",
		["Sorting"] = "排序",
		["Sorting by:"] = "排序方式：",
	
		["Shift"] = "Shift展開",
		["Hidden"] = HIDE,
	
		["Default UI Memory Usage:"] = "内建插件資源占用：",
		["Total Memory Usage:"] = "總資源占用：",
		["Garbage collected"] = "釋放記憶體：",
		["AutoCollectOption"] = "自動整理暫存記憶體：",
		["AutoCollect"] = "手動釋放",

		["Home"] = "本地",
		["Latency"] = "延遲：",
		["CPU Usage"] = "顯示CPU占用比例：",
		["Reload UI(on)"] = "|cff777777dim|rinfo[|cff00ff00System|r]：重載介面後顯示插件的CPU佔用。",
		["Reload UI(off)"] = "|cff777777dim|rinfo[|cff00ff00System|r]：重載介面後隱藏插件的CPU佔用。",
	}
elseif GetLocale() == "zhCN" then
	infoL = {
		["AutoSell junk"] = "自动卖垃圾：",
		["Trash sold, earned "] = "垃圾售出：",
	
		["AutoRepair"] = "自动修理：",
		["Repair cost"] = "修理花费：",
		["Go farm, newbie"] = "你真穷。",
		["none"] = "无装备",
	
		["No Guild"] = "没人要",
		["Sorting"] = "排序",
		["Sorting by:"] = "排序方式：",
	
		["Shift"] = "Shift展开",
		["Hidden"] = HIDE,
	
		["Default UI Memory Usage:"] = "内建插件资源占用：",
		["Total Memory Usage:"] = "总资源占用：",
		["Garbage collected"] = "释放內存：",
		["AutoCollectOption"] = "自动整理暂存：",
		["AutoCollect"] = "手动释放",

		["Home"] = "本地",
		["Latency"] = "延迟：",
		["CPU Usage"] = "显示CPU占用比例：",
		["Reload UI(on)"] = "|cff777777dim|rinfo[|cff00ff00System|r]：重载界面后显示插件的CPU佔用。",
		["Reload UI(off)"] = "|cff777777dim|rinfo[|cff00ff00System|r]：重载界面后隐藏插件的CPU佔用。",
	}
else
	infoL = {
		["AutoSell junk"] = "Auto Sell junk: ",
		["Trash sold, earned "] = "Trash sold, earned: ",

		["AutoRepair"] = "Auto Repair: ",
		["Repair cost"] = "Repair cost: ",
		["Go farm, newbie"] = "Go farm, newbie.",
		["none"] = "None",
	
		["No Guild"] = "Lonely",
		["Sorting"] = "Sorting",
		["Sorting by:"] = "Sorting by: ",
	
		["Shift"] = "Shift show all",
		["Hidden"] = "Hidden",
	
		["Default UI Memory Usage:"] = "Default UI Memory Usage: ",
		["Total Memory Usage:"] = "Total Memory Usage: ",
		["Garbage collected"] = "Garbage collected: ",
		["AutoCollect"] = "Manual Collect",
		["AutoCollectOption"] = "Auto Collect Memory: ",
	
		["Home"] = "Home",
		["Latency"] = "Latency",
		["CPU Usage"] = "Show CPU Usage",
		["Reload UI(on)"] = "|cff777777dim|rinfo[|cff00ff00System|r]: You could see addon's CPU usage after reloding UI.",
		["Reload UI(off)"] = "|cff777777dim|rinfo[|cff00ff00System|r]: You could hide the addon's CPU usage table after reloding UI.",
	}
end
]]--