# Kiminfo

A Info Bar.

一個訊息條。

## Info

Kiminfo based on diminfo (and it based on tukui data text modules). There are 9 modules.

Kiminfo 是基於 diminfo 製作的訊息條 (而它源自於 tukui)，有九個模組。**本插件僅發布在 Curse、Wowinterface 和 Github，謝絕任何搬運轉載。**

## Notice

NO in-game config. If you need, try other else such like Titan Panel.

這是一個沒有遊戲內控制台的插件，有此需求請用別的，例如 Titan Panel。

## Config

Just edit config.lua to change them. I suggest use [Notepad++](https://notepad-plus-plus.org/), [Notepads (Win10 only)](https://www.notepadsapp.com/) or [Akelpad](http://akelpad.sourceforge.net/en/index.php) to edit lua file. save file and /reload wow after change.

編輯 config.lua 以更改設定。推薦使用 [Notepad++](https://notepad-plus-plus.org/)、[Notepads (Win10 only)](https://www.notepadsapp.com/) 或 [Akelpad](http://akelpad.sourceforge.net/en/index.php) 來編輯 lua 檔案。編輯完存檔後 /reload 重載遊戲即可。

## Feature

<details>
<summary>English</summary>

* Bags
	* Show bag slot, gold, checking currency and Dragonflight tier charge count
	* Option: auto sell gray
	* Left click: open bag, right click: auto sell config, middle click: currency frame
* Durability
	* Show durability and item level, color gardient to red when low durability
	* Option: auto repair
	* Left click: charactor frmae, right click: auto repair config
* Friends
	* Show online friends
	* List classic wow friends as desaturate icon, shift when mouseover to show full BattleTag when login other game or app
	* Left click: friends frame, right click: post battle.net broadcast
* Guild
	* Show online guild members
	* List as guild rank
	* Left click: community frame, right click: old guild frame
* Memory
	* Show addon number and switch to memory usage when moueseover, list all addon usage
	* Option: auto collect, disable by default
	* Left click: collect memory manually, right click: auto collect config, middle click: addon list
* Positions
	* Show zone text and update xy coord when mouseover
	* Left click: world map, right click: post coord with Blizzard map pin, if have target will send target name also.
* Spec
	* Show spec and loot spec, list telent when mouseover
	* Left click: telent frame, right click: menu for spec switch, telent switch and loot spec switch
* System
	* Show latency and fps, color gardient to red when low fps and high latency
	* Option: List addon cpu usage, list all addon cpu usage, disable by default
	* Right click: enable addon cpu usage monitor
* Time
	* Show time, list dungeon CDs, mythic+ 8 best run history and Dragonflight weekly chest quests check when mouseover
	* Left click: calender, right click: time manager
</details>

<details>
<summary>中文</summary>

* Bags / 背包
	* 顯示空餘格數、金幣，正在追蹤的兌換通貨和巨龍時代的裝備轉化次數
	* 選項：自動賣垃圾
	* 左鍵：打開背包；右鍵：自動出售開關；中鍵：兌換通貨列表
* Durability / 耐久度
	* 顯示耐久度和裝等，低耐久時文字變紅
	* 選項：自動修裝
	* 左鍵：角色資訊；右鍵：自動修裝開關
* Friends / 好友
	* 顯示線上好友
	* 區分魔獸世界經典版與正式版，shift 指向時顯示完整的 BattleTag
	* 左鍵：好友視窗；右鍵：發送戰網廣播
* Guild / 公會
	* 顯示線上公會成員
	* 以會階排序，shift 指向反向排序
	* 左鍵：社群公會視窗；右鍵：傳統公會視窗
* Memory / 記憶體
	* 顯示啟用插件數，指向時顯示插件列表與記憶體占用
	* 選項：自動回收冗餘記憶體，預設關閉
	* 左鍵：手動回收；右鍵：自動回收開關；中鍵：開啟插件列表
* Positions / 位置
	* 顯示區域名稱，指向時顯示座標
	* 左鍵：大地圖；右鍵：在聊天框發送包含地圖標記的座標，如果有目標一併發送目標名字
* Spec / 專精
	* 顯示當前專精與拾取專精，指向時列出天賦
	* 左鍵：天賦頁面；右鍵：切換專精、天賦、拾取
* System / 系統
	* 顯示延遲與幀數，幀數過低或延遲過高時文字變色
	* 選項：列出插件 CPU 占用，預設關閉
	* 左鍵：啟用 CPU 占用監視時重設監控；右鍵：CPU 占用監視開關
* Time / 時間
	* 顯示時間，指向時顯示副本進度、巨龍時代的每周任務檢查和八場最佳傳奇+地城
	* 左鍵：行事曆；右鍵：碼錶，中鍵：寶庫

</details>

## Important when config

<details>
<summary>English</summary>
	
### Do not forget

Kiminfo use `Time` module as starting anchored and it anchored on UIParent, other modules anchored modules on it's left. For example, as default Config setting, `Time` module is the first loaded and `Bags` module is second. This order is also **modules load order**.

```lua
	C.Time = true
	C.TimePoint =  {"TOPLEFT", UIParent, 15, -20}
	
	-- Bags / 背包
	C.Bags = true
	C.BagsPoint = {"LEFT", "Kiminfo_Time", "RIGHT", 30, 0}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint =  {"LEFT", "Kiminfo_Bags", "RIGHT", 30, 0}
```

If you wanna change info bar position, just change `Time` module position; but if you wanna change modules order, Should not forget change load order in `Modules/Modules.xml`, or they cannot get anchor **because a modules cannot anchor on another modules which load later then itself**.

For example, if you wanna change `Bags` modules to `Guild` modules right, should do this:

```diff
<Ui xmlns="http://www.blizzard.com/wow/ui/">
	<Script file="Time.lua"/>
- 	<Script file="Bags.lua"/>
	<Script file="Memory.lua"/>
	<Script file="System.lua"/>
	<Script file="Spec.lua"/>
	<Script file="Friends.lua"/>
	<Script file="Guild.lua"/>
+ 	<Script file="Bags.lua"/>
	<Script file="Durability.lua"/>
	<Script file="Positions.lua"/>
</Ui>
```

And then change anchor：

```diff
	-- Timer / 時鐘
	C.Time = true
	C.TimePoint =  {"TOPLEFT", UIParent, 15, -20}
	
- 	-- Bags / 背包
- 	C.Bags = true
- 	C.BagsPoint = {"LEFT", "Kiminfo_Time", "RIGHT", 30, 0}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
- 	C.MemoryPoint =  {"LEFT", "Kiminfo_Bags", "RIGHT", 30, 0}
+ 	C.MemoryPoint =  {"LEFT", "Kiminfo_Time", "RIGHT", 30, 0}

	... omit ...
	
	-- Guild / 公會
	C.Guild = true
	C.GuildPoint = {"LEFT", "Kiminfo_Friends", "RIGHT", 30, 0}
	
+ 	-- Bags / 背包
+ 	C.Bags = true
+ 	C.BagsPoint = {"LEFT", "Kiminfo_Guild", "RIGHT", 30, 0}
```

</details>

<details>
<summary>中文</summary>

### Do not forget

Kiminfo 以最左的模塊`時間`作為起始錨點，其錨點於遊戲定義的父級框體，而其他模塊則錨點於它左邊的前一個模塊，例如預設樣式中的`背包`即錨點於`時間`，而`插件`又錨點於背包。這個順序同時也是模組的**載入順序**。

```lua
	C.Time = true
	C.TimePoint =  {"TOPLEFT", UIParent, 15, -20}
	
	-- Bags / 背包
	C.Bags = true
	C.BagsPoint = {"LEFT", "Kiminfo_Time", "RIGHT", 30, 0}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
	C.MemoryPoint =  {"LEFT", "Kiminfo_Bags", "RIGHT", 30, 0}
```

若你打算移動整條訊息條，調整`時間`模組的位置即可；但若打算更改模組的顯示順序，不要忘記同時更改`Modules/Modules.xml`中的模組載入順序。如果沒有更改插件將無法正常運作，**因為插件無法使先載入的模組錨點於後載入的模組**。

舉例，若你想要將背包模組移至公會模組右方，就要將載入順序更改為：

```diff
<Ui xmlns="http://www.blizzard.com/wow/ui/">
	<Script file="Time.lua"/>
- 	<Script file="Bags.lua"/>
	<Script file="Memory.lua"/>
	<Script file="System.lua"/>
	<Script file="Spec.lua"/>
	<Script file="Friends.lua"/>
	<Script file="Guild.lua"/>
+ 	<Script file="Bags.lua"/>
	<Script file="Durability.lua"/>
	<Script file="Positions.lua"/>
</Ui>
```

再將錨點變更為：

```diff
	-- Timer / 時鐘
	C.Time = true
	C.TimePoint =  {"TOPLEFT", UIParent, 15, -20}
	
- 	-- Bags / 背包
- 	C.Bags = true
- 	C.BagsPoint = {"LEFT", "Kiminfo_Time", "RIGHT", 30, 0}
	
	-- Memory / 記憶體占用列表
	C.Memory = true
	C.MaxAddOns = 30
- 	C.MemoryPoint =  {"LEFT", "Kiminfo_Bags", "RIGHT", 30, 0}
+ 	C.MemoryPoint =  {"LEFT", "Kiminfo_Time", "RIGHT", 30, 0}

	... 中略 ...
	
	-- Guild / 公會
	C.Guild = true
	C.GuildPoint = {"LEFT", "Kiminfo_Friends", "RIGHT", 30, 0}
	
+ 	-- Bags / 背包
+ 	C.Bags = true
+ 	C.BagsPoint = {"LEFT", "Kiminfo_Guild", "RIGHT", 30, 0}
```

</details>

## My Layout example

This is my layout, an example for edit. You can check original code at `Template\Custom`

這是我自己使用的樣式，作為例子供參考。也可在 `Template\Custom` 查閱。

<details>
<summary>Modules.xml</summary>

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
	<Script file="Time.lua"/>
	<Script file="Bags.lua"/>
	<Script file="Memory.lua"/>
	<Script file="System.lua"/>
	<Script file="Spec.lua"/>
	<Script file="Friends.lua"/>
	<Script file="Guild.lua"/>
	<Script file="Durability.lua"/>
	<Script file="Positions.lua"/>
</Ui>
```
</details>

<details>
<summary>Conifg.lua</summary>

```lua
-----------
-- Panel --
-----------

	-- Enable panel / 啟用面板
	C.Panel = true
	
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
```

</details>

## Credits

* Tukz, Loshine, Siweia, HopeASD
* Bar texture support: Peterdox
* Icon texture from SX Databar.
