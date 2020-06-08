# diminfo

A Text Info Bar. There 8 modules.

 一個文字訊息條，有八個模組。本插件僅在 Curse、Github 和 Wowinterface 發佈，並謝絕任何轉載，**尤其拒絕 wowcat/60addons 轉載**，先前委託時光請站點撤除未果，加上去年就帶給我很多麻煩了，特此聲明；一切非授權搬運之內容與言論均與我無關，意思是有什麼問題都別來找我。

## Credits

* [Origin](http://www.wowinterface.com/downloads/info20899-diminfo.html#info) by Loshine
* [NDui](https://github.com/siweia/NDuiClassic/tree/master/Interface/AddOns/NDui/Modules/Infobar) by siweia
* Code support: HopeASD
* Texture provide: Peterodox

## Config

Just edit config.lua to change them. I suggest use [Notepad++](https://notepad-plus-plus.org/), [Notepads (Win10 only)](https://www.notepadsapp.com/) or [Akelpad](http://akelpad.sourceforge.net/en/index.php) to edit lua file. save file and /reload wow after change.

編輯 config.lua 以更改設定。推薦使用 [Notepad++](https://notepad-plus-plus.org/)、[Notepads (Win10 only)](https://www.notepadsapp.com/) 或 [Akelpad](http://akelpad.sourceforge.net/en/index.php) 來編輯 lua 檔案。編輯完存檔後 /reload 重載遊戲即可。

## Feature

<details>
<summary>English</summary>

* Class color on names and Config-able panel.
* No in-game config.
* Bags
    * Show bag slot and gold
	* Option: auto sell gray
	* Left click: open bag, right click: auto sell config
* Durability
    * Show durability and talents, color gardient to red when low durability
	* Option: auto repair
	* Left click: charactor frmae, right click: auto repair config, middle click: honor frame
* Friends
    * Show online friends
	* List retail wow friends as desaturate icon, shift when mouseover to show full BattleTag
	* Left click: friends frame, right click: post battle.net broadcast
	* Shift + Left click: send message, Alt + left click: invite
* Guild
    * Show online guild members
	* List as guild rank, shift when mouseover to reverse sequence
	* Left click: guild frame, right click: community frame
	* Shift + Left click: send massage, Alt + left click: invite
* Memory
    * Show addon memory usage, list all addon usage
	* Option: auto collect
	* Left click: collect memory manually, right click: auto collect config
* Positions
    * Show zone text and update xy coord when mouseover
	* Left click: world map, right click: post coord
* System
    * Show latency and fps, color gardient to red when low fps and high latency
	* Option: List addon cpu usage
	* Left click: reset CPU usage monitor when it enable, Right click: enable addon cpu usage monitor
* Time
    * Show time, list dungeon CDs when mouseover
	* Right click: time manager
	
</details>

<details>
<summary>中文</summary>

* Bags / 背包
	* 顯示空餘格數和金幣
	* 選項：自動賣垃圾
	* 左鍵：打開背包；右鍵：自動出售開關
* Durability / 耐久度
	* 顯示耐久度和裝等，低耐久時文字變紅
	* 選項：自動修裝
	* 左鍵：角色資訊；右鍵：自動修裝開關；中鍵：查看榮譽
* Friends / 好友
	* 顯示線上好友
	* 區分魔獸世界經典版與正式版，shift 指向時顯示完整的 BattleTag
	* 左鍵：好友視窗；右鍵：發送戰網廣播
* Guild / 公會
	* 顯示線上公會成員
	* 以會階排序，shift 指向反向排序
	* 左鍵：公會視窗；右鍵：社群視窗
* Memory / 記憶體
	* 顯示啟用插件數，指向時顯示插件列表與記憶體占用
	* 選項：自動回收冗餘記憶體
	* 左鍵：手動回收；右鍵：自動回收開關
* Positions / 位置
	* 顯示區域名稱，指向時顯示座標
	* 左鍵：大地圖；右鍵：在聊天框發送座標
* System / 系統
	* 顯示延遲與幀數，幀數過低或延遲過高時文字變色
	* 選項：列出插件 CPU 占用
	* 左鍵：啟用 CPU 占用監視時重設監控；右鍵：CPU 占用監視開關
* Time / 時間
	* 顯示時間，指向時顯示副本進度
	* 右鍵：碼錶

</details>

## Important when config

Check [Kiminfo readme](https://github.com/EKE00372/diminfo#important-when-config), it's same point.
查看 [Kiminfo readme](https://github.com/EKE00372/diminfo#important-when-config)，它們的要點是相同的。