if GetLocale() == "zhTW" then
	infoL = {
		["AutoSell junk"] = "自動賣垃圾：",
		["Trash sold, earned "] = "垃圾售出：",
	
		["AutoRepair"] = "自動修理：",
		["Repair cost covered by G-Bank"] = "修理花費公款：",
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
		["AutoCollect"] = "自動整理暫存記憶體：",

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
		["Repair cost covered by G-Bank"] = "修理花费公款：",
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
		["Garbage collected"] = "释放记忆体：",
		["AutoCollect"] = "自动整理暂存记忆体：",

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
		["Repair cost covered by G-Bank"] = "Repair cost covered by Guild Bank: ",
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
		["AutoCollect"] = "AutoCollect: ",
	
		["Home"] = "Home",
		["Latency"] = "Latency",
		["CPU Usage"] = "Show CPU Usage",
		["Reload UI(on)"] = "|cff777777dim|rinfo[|cff00ff00System|r]: You could see addon's CPU usage after reloding UI.",
		["Reload UI(off)"] = "|cff777777dim|rinfo[|cff00ff00System|r]: You could hide the addon's CPU usage table after reloding UI.",
	}
end
