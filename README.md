# Kiminfo

[English](#english) | [繁體中文](#繁體中文)

## English

### About

Kiminfo is a lightweight information bar for WoW Retail, based on diminfo and originally on Tukui data-text modules. It contains nine modules.

**This addon is published only on Curse, WowInterface and GitHub. Please do not redistribute it.**

There is no in-game configuration panel. Edit [Kiminfo/Config.lua](Kiminfo/Config.lua), save the file as UTF-8, then run `/reload`. You can use [Notepad++](https://notepad-plus-plus.org/), [Notepads](https://www.notepadsapp.com/) or [AkelPad](http://akelpad.sourceforge.net/en/index.php). If you prefer an in-game configuration panel, consider another addon such as Titan Panel.

### Features

- **Bags**
  - Shows free bag slots; the tooltip lists bag usage, gold, WoW Token price and tracked currencies.
  - Optional automatic sale of poor-quality items.
  - Left click: bags. Right click: toggle automatic selling. Middle click: currencies.
- **Durability**
  - Shows durability and item level; low durability changes the text toward red.
  - Optional automatic repair.
  - Left click: character window. Right click: toggle automatic repair.
- **Friends**
  - Shows online in-game and Battle.net friends in a shared, scrollable two-column panel.
  - Battle.net order: favorites on your WoW version, other friends on the same version, other WoW versions, other games, then application-only connections. Hold Shift to display full BattleTags.
  - Friends on your WoW version use faction icons when available; other WoW versions use the WoW icon.
  - Hover a list entry for active-game details, including multiple simultaneous games or WoW characters; application connections are excluded from these details.
  - On a list entry, Shift + left click invites or requests to join; multiple WoW characters offer a selection menu. Middle click whispers.
  - On the info bar, left click opens friends; right click edits your Battle.net broadcast.
- **Guild**
  - Shows online members, guild name, your rank and reputation, and the guild message when available.
  - Members are sorted by rank. Hold Shift when opening the panel to reverse the order; the chosen direction stays fixed while the panel is open.
  - On a list entry, Shift + left click invites; middle click whispers.
  - On the info bar, left click opens the guild/community window.
- **Memory**
  - Shows the loaded addon count; hovering switches the text to memory usage in MB and lists addon usage. The tooltip uses KB below 1024 KB and MB otherwise; hold Shift when hovering to expand the list.
  - Optional automatic garbage collection, disabled by default; collection can briefly pause the client.
  - Left click: collect memory manually. Right click: toggle automatic collection. Middle click: addon list.
- **Positions**
  - Shows the current zone. The tooltip updates coordinates outside instances, unless Blizzard's minimap-coordinate display is enabled.
  - Left click: world map. Right click: prepare coordinates in chat, with a Blizzard map pin where supported and an accessible non-player target name when available.
  - Shift + left click: toggle overhead names between hidden and the preset; nameplates are unchanged. The tooltip shows the next action.
  - Middle click: toggle windowed/borderless fullscreen mode; the tooltip shows the next mode.
- **Spec**
  - Shows current and loot specializations; hovering lists talent loadouts.
  - Left click: talents. Right click: a native context menu for specialization, talent loadout and loot-specialization selection.
- **System**
  - Shows FPS and home/world latency; low FPS or high latency changes the text color.
  - Optional addon CPU statistics in milliseconds per second, disabled by default; hold Shift when hovering to expand the list.
  - Left click: reset CPU statistics. Right click: toggle CPU profiling, applied after `/reload`. Middle click: reload the UI.
  - Shift + left click: cycle audio-output devices and print the selected device in chat.
- **Time**
  - Shows local or realm time, saved instance/world-boss lockouts, and reset times.
  - At maximum level, shows available Bountiful Delves, weekly key progress and the best eight Mythic+ runs. Regular Bountiful Delves show the daily-reset countdown; The Labyrinth of Kindo'jan is listed when its Bountiful map marker is available, without a countdown.
  - Hold Shift when hovering to replace the Delve list with Dragonflight and The War Within weekly-quest checks.
  - Left click: calendar. Right click: time manager/stopwatch. Middle click: Great Vault.

### Panel settings

Friends and Guild use `InfoPanel`, with two naturally sized columns separated by a gap. Announcements wrap to the width established by the other contents. The panel uses the native GameTooltip background appearance.

`C.InfoPanel = {maxWidth = 1000, maxHeight = 600}` sets the width and content-panel height limits. If the natural width exceeds the limit, natural columns shrink from right to left. If the content is too tall, use the mouse wheel to scroll; the bottom arrows indicate the available directions and add one extra row beyond `maxHeight`.

`C.StickTop = true` places tooltips below the info bar; use `false` for a bar at the bottom of the screen. `C.MaxAddOns` limits the initial Memory/System addon lists. Font, title/option/error colors and the separator are configured in the same file.

### Layout

`C.Layout` controls row positions, backgrounds and module order. **Do not reorder XML scripts to change the display.**

#### Module switches

- `C.Time`, `C.Bags`, `C.Memory`, `C.System`, `C.Spec`, `C.Friends`, `C.Guild`, `C.Durability` and `C.Positions` enable their modules. Set one to `false` and reload to disable the entire module, including its background functionality. Remaining modules close the gap.
- Removing a module from `C.Layout` only hides its info-bar display. If its switch remains `true`, background functionality such as merchant events can remain active.
- Each module may appear in only one row. An empty row, or one whose listed modules are all disabled, has no visible contents or background.

#### Single-row example

```lua
-- Gap between complete module bounds
C.Gap = 8

-- point: anchor, parent, x, y
-- inset: x, y, relative to the row's top-left corner
-- panel: middle-background width, height, alpha
-- modules: {module name, extra horizontal offset}
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
```

| Setting | Meaning |
| --- | --- |
| `point` | Positions the row, not the optional background. |
| `inset` | Offsets the first complete module from the row's top-left corner, not its individual FontString. |
| `panel` | Fixed middle-background width, height and alpha; gradients extend on both sides. It does not resize to the contents. |
| `C.Gap` | Common spacing between complete module bounds. |
| `offset` | Extra horizontal shift; omitted means 0, and negative values are allowed. |

`point` anchors an invisible 1×1 row locator. Contents always start from its top-left corner and extend to the right; choosing another anchor does not align the full panel or content width to that edge. Background dimensions do not affect row positioning.

The first enabled module starts at `inset + offset`, without a leading gap. Later modules follow the previous enabled module with `C.Gap + offset`. For example, `{"System", 3}` also moves every subsequent module 3 units to the right. A disabled module contributes neither space nor offset.

Each module owns its icon sizing, internal arrangement and complete frame size. Its native `HorizontalLayoutFrame` is laid out after display-text changes, so `Stat:GetWidth()` reflects the current contents. The core receives only `RegisterModule(name, frame)` and anchors the next frame to the previous frame's right edge.

The complete frame height includes the tallest internal element. `inset` positions the first complete frame rather than its first text; check vertical placement and spacing in-game after changing the first module or font.

#### Backgrounds

Set a row's `panel` to `false`, `nil`, or omit it to hide the background and both gradients. Text, icons and interaction remain positioned by `point` and `inset`.

```lua
point = {"TOPLEFT", UIParent, 0, -10},
inset = {15, -10},
panel = false,
```

With an offset of 0, the first module still starts at `(15, -20)` relative to UIParent's top-left corner. Turning the background on again does not move the contents. Use `inset = {0, 0}` if `point` should directly specify the content origin.

#### Custom rows

- Back up [Kiminfo/Config.lua](Kiminfo/Config.lua), then edit `C.Layout`. Each table defines one row with its own `point`, `inset`, optional `panel` and `modules`. Add row tables for a multi-row layout, with each module assigned only once.
- Config.lua includes a commented-out Custom two-row example beneath the active single-row layout. To use it, replace the active `C.Layout` with the example, save and reload. No separate Public/Custom template files are needed.
- The example's upper row contains Time, Friends, Guild, Bags, Durability and Positions; the lower row contains Memory, System and Spec.
- Old `C.*Point` and `C.Panel1`–`C.Panel5` settings are no longer used. Move positions and backgrounds into `C.Layout` rather than mixing both formats.

#### Loading and display order

The TOC loads `Config.lua → Core.lua → InfoPanel.lua → Locale.lua → Modules/Modules.xml`. Core.lua provides shared helpers, module registration and row/background layout; InfoPanel.lua provides the shared Friends/Guild panel.

After the modules register their display frames, Kiminfo's `ADDON_LOADED` handler calls local `CreateLayout()` once, arranging frames in `C.Layout` order. Display order is independent of XML load order; Time does not have to be the first displayed module.

### Credits

- Tukz, Loshine, Siweia, HopeASD
- Bar texture: Peterdox
- Icon textures: SX Databar

## 繁體中文

### 關於

Kiminfo 是一個適用於 WoW 正式服的輕量資訊條，基於 diminfo 製作，源自 Tukui 的資訊文字模組，共有九個模組。

**本插件僅發布在 Curse、WowInterface 和 GitHub，謝絕任何搬運轉載。**

本插件沒有遊戲內設定面板。請編輯 [Kiminfo/Config.lua](Kiminfo/Config.lua)，以 UTF-8 存檔後執行 `/reload`。可使用 [Notepad++](https://notepad-plus-plus.org/)、[Notepads](https://www.notepadsapp.com/) 或 [AkelPad](http://akelpad.sourceforge.net/en/index.php)；若需要遊戲內設定面板，可考慮 Titan Panel 等其他插件。

### 功能

- **Bags／背包**
  - 顯示空餘格數；提示中列出背包用量、金幣、魔獸代幣價格及正在追蹤的兌換通貨。
  - 可選擇自動出售灰色物品。
  - 左鍵：背包。右鍵：自動出售開關。中鍵：兌換通貨。
- **Durability／耐久度**
  - 顯示耐久度與裝等，低耐久時文字逐漸變紅。
  - 可選擇自動修理。
  - 左鍵：角色資訊。右鍵：自動修理開關。
- **Friends／好友**
  - 以共用的可捲動雙欄面板顯示遊戲內及戰網線上好友。
  - 戰網排序：同魔獸版本的摯友、其他同版本好友、其他魔獸版本好友、其他遊戲、僅登入應用程式的好友。按住 Shift 顯示完整 BattleTag。
  - 同魔獸版本好友在陣營資料可用時顯示陣營圖示；其他魔獸版本顯示魔獸圖示。
  - 指向名單項目可查看正在玩的遊戲，包括同時登入多個遊戲或魔獸角色；詳情不列入應用程式連線。
  - 名單項目上 Shift＋左鍵邀請或請求加入；有多個魔獸角色時提供選擇選單。中鍵密語。
  - 資訊條上左鍵開啟好友視窗；右鍵編輯自己的戰網廣播。
- **Guild／公會**
  - 顯示線上成員、公會名稱、自己的會階與聲望，以及非空的公會今日訊息。
  - 成員依會階排序；開啟面板時按住 Shift 可反向排序，該次顯示期間維持同一排序方向。
  - 名單項目上 Shift＋左鍵邀請，中鍵密語。
  - 資訊條上左鍵開啟公會／社群視窗。
- **Memory／記憶體**
  - 顯示已載入插件數；指向時文字改為 MB 記憶體用量，並列出各插件用量。提示中小於 1024 KB 使用 KB，其餘使用 MB；按住 Shift 指向可展開清單。
  - 自動回收記憶體預設關閉；回收可能使遊戲短暫停頓。
  - 左鍵：手動回收。右鍵：自動回收開關。中鍵：插件列表。
- **Positions／位置**
  - 顯示目前地區；在副本外指向時更新座標，若已啟用暴雪小地圖座標顯示則不重複顯示。
  - 左鍵：大地圖。右鍵：將座標填入聊天框，在支援時附上暴雪地圖標記，並於可讀取時附上非玩家目標名稱。
  - Shift＋左鍵：在全部隱藏與預設名字顯示設定間切換，不影響名條；提示顯示下一次操作。
  - 中鍵：切換視窗模式／全螢幕視窗模式，提示顯示下一個模式。
- **Spec／專精**
  - 顯示當前專精與拾取專精，指向時列出天賦配置。
  - 左鍵：天賦頁面。右鍵：以原生快捷選單切換專精、天賦配置與拾取專精。
- **System／系統**
  - 顯示幀數與本地／世界延遲；幀數過低或延遲過高時文字變色。
  - 插件 CPU 統計以每秒毫秒數顯示，預設關閉；按住 Shift 指向可展開清單。
  - 左鍵：重置 CPU 統計。右鍵：CPU 統計開關，`/reload` 後生效。中鍵：重載介面。
  - Shift＋左鍵：輪循音效輸出設備，並在聊天框顯示所選設備。
- **Time／時間**
  - 顯示本地或伺服器時間、副本／世界首領進度及重置時間。
  - 滿級時顯示目前可用的豐裕地下堡、每週鑰匙進度及八場最佳傳奇＋地城。一般豐裕地下堡顯示每日重置倒數；金多詹的迷宮在豐裕地圖標記可用時列出，不顯示倒數。
  - 按住 Shift 指向，將地下堡清單換成巨龍時代與地心之戰的每週任務檢查。
  - 左鍵：行事曆。右鍵：時間管理／碼錶。中鍵：寶庫。

### 面板設定

好友與公會使用共用的 `InfoPanel`，兩欄皆為自然寬度，欄間保留間距。廣播與公會訊息依其他內容算出的寬度換行，不自行撐寬面板；背景沿用原生 GameTooltip 的外觀。

`C.InfoPanel = {maxWidth = 1000, maxHeight = 600}` 設定寬度與內容面板高度上限。自然寬超過上限時由右向左縮減自然欄；內容過高時使用滑鼠滾輪捲動，底部箭頭提示可捲動方向，另加一列高度，不計入 `maxHeight`。

`C.StickTop = true` 將提示放在資訊條下方；資訊條位於畫面底部時改為 `false`。`C.MaxAddOns` 限制記憶體／系統模組初始顯示的插件數量。字型、標題／選項／錯誤顏色與分隔線也在同一檔案設定。

### 排列設定

`C.Layout` 統一管理列位置、背景與模組順序。**調整顯示順序不需要修改 XML 載入清單。**

#### 模組開關

- `C.Time`、`C.Bags`、`C.Memory`、`C.System`、`C.Spec`、`C.Friends`、`C.Guild`、`C.Durability`、`C.Positions` 控制九個模組。設為 `false` 並重載，才會停用整個模組及其背景功能；其他模組會接續排列，不留下空位。
- 只從 `C.Layout` 移除項目代表不顯示該模組；若對應開關仍為 `true`，商人事件等背景功能仍可能運作，不等於停用模組。
- 每個模組只配置於一列；空列或列內模組全部停用時，不顯示內容與背景。

#### 單列範例

```lua
-- 完整模組排列範圍之間的通用間距
C.Gap = 8

-- point：列錨點、相對框體、X、Y
-- inset：內容起點相對列左上角的 X、Y
-- panel：中段背景寬度、高度、透明度
-- modules：{模組名稱, 額外水平偏移}
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
```

| 設定 | 用途 |
| --- | --- |
| `point` | 定位整列，不是背景專屬座標。 |
| `inset` | 第一個完整模組相對列左上角的內容起點，不是個別 FontString 的錨點。 |
| `panel` | 固定中段背景寬度、高度與透明度；左右漸層向外延伸，不自動依內容調整寬度。 |
| `C.Gap` | 完整模組排列範圍之間的通用間距。 |
| `offset` | 額外水平偏移，可省略為 0，也可使用負值。 |

`point` 定位的是不可見的 1×1 列定位框，內容固定由其左上角向右排列。改用其他錨點不代表將整段背景或內容的同名邊對齊；背景尺寸不參與列定位。

首個啟用模組使用 `inset + offset`，不額外加 gap；後續模組接前一個啟用模組，間距為 `C.Gap + offset`。例如 `{"System", 3}` 會將 System 及其後的模組多向右移 3。停用項不占位，也不累加其 offset。

圖示大小、素材留白校正、內部排列與完整框體尺寸由各模組處理。模組在顯示文字更新後整理自己的原生 `HorizontalLayoutFrame`，`Stat:GetWidth()` 便反映當下內容；核心只接收 `RegisterModule(name, frame)`，將下一個完整框體接到前一個框體的右側。

完整框體高度包含模組內最高的元素；`inset` 定位第一個完整框體，而非第一段文字。更換首項模組或字型後，仍須在遊戲中校準垂直位置與間距。

#### 背景設定

將該列的 `panel` 設為 `false`、`nil` 或省略，只關閉背景及左右漸層；文字、圖示與互動仍依 `point`、`inset` 定位。

```lua
point = {"TOPLEFT", UIParent, 0, -10},
inset = {15, -10},
panel = false,
```

首個模組的 offset 為 0 時，內容起點仍在 UIParent 左上角的 `(15, -20)`；重新開啟背景也不會移動內容。若要直接以 `point` 指定內容起點，可以將 `inset` 設為 `{0, 0}`。

#### 自訂列

- 先備份 [Kiminfo/Config.lua](Kiminfo/Config.lua)，再編輯 `C.Layout`。其中每個 table 代表一列，各自設定 `point`、`inset`、可選的 `panel` 與 `modules`。需要多列時新增列的 table，並將各模組分配到其中一列。
- Config.lua 的單列設定下方已有以長註釋停用的 Custom 雙列範例。使用時以範例取代目前啟用的 `C.Layout`，存檔後重載；不需要獨立的 Public／Custom 模板檔。
- 範例上排為 Time、Friends、Guild、Bags、Durability、Positions；下排為 Memory、System、Spec。
- 舊的 `C.*Point`、`C.Panel1`–`C.Panel5` 已不再使用；請將位置及背景設定遷入 `C.Layout`，不要混用新舊格式。

#### 載入與顯示順序

TOC 載入順序為 `Config.lua → Core.lua → InfoPanel.lua → Locale.lua → Modules/Modules.xml`。Core.lua 集中共用 helper、模組註冊與列／背景排列；InfoPanel.lua 提供好友與公會的共用面板。

各模組註冊顯示框體後，Kiminfo 的 `ADDON_LOADED` 階段呼叫一次 local `CreateLayout()`，統一按 `C.Layout` 排列。因此顯示順序與 XML 中各模組的載入順序分離，不要求 Time 必須作為第一個顯示模組。

### 鳴謝

- Tukz、Loshine、Siweia、HopeASD
- 資訊條材質：Peterdox
- 圖示材質：SX Databar
