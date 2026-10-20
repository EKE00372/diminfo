# Kiminfo

[English](#english) | [繁體中文](#繁體中文)

## English

### About

Kiminfo is a lightweight information bar for WoW Retail and Forever, based on diminfo and originally on Tukui data-text modules. It contains nine modules.

**This addon is published only on Curse, WowInterface and GitHub. Please do not redistribute it.**

There is no in-game configuration panel. Edit [Kiminfo/Config.lua](Kiminfo/Config.lua), save the file as UTF-8, then run `/reload`. You can use [Notepad++](https://notepad-plus-plus.org/), [Notepads](https://www.notepadsapp.com/) or [AkelPad](http://akelpad.sourceforge.net/en/index.php). If you prefer an in-game configuration panel, consider another addon such as Titan Panel.

### Features

- **Bags**
  - Shows bag space, gold, currencies and WoW Token price; supports automatic junk selling.
  - Forever: shows keyring usage in the tooltip and hides WoW Token prices.
  - Left click: bags. Right click: toggle auto-sell. Middle click: currencies.
- **Durability**
  - Shows durability and item level; supports automatic repair.
  - Forever: includes the ranged weapon slot.
  - Left click: character window. Right click: toggle auto-repair.
- **Friends**
  - Shows online friends and their game details. Hold Shift to show full BattleTags.
  - List entries: Shift + left click to invite or request to join; middle click to whisper.
  - Info bar: left click opens friends; right click edits your Battle.net broadcast.
- **Guild**
  - Shows online members, guild information and the guild message.
  - Hold Shift when opening the list to reverse the rank order.
  - List entries: Shift + left click to invite; middle click to whisper. Info bar: left click opens the guild window.
- **Memory**
  - Shows addon count and memory usage. Hold Shift when hovering to expand the addon list.
  - Automatic collection is off by default; collecting memory may briefly pause the game.
  - Left click: collect memory. Right click: toggle auto-collection. Middle click: addon list.
- **Positions**
  - Shows the current zone and coordinates.
  - Left click: world map. Right click: put coordinates in chat.
  - Shift + left click: toggle overhead names. Middle click: switch windowed/borderless fullscreen mode.
- **Spec**
  - Shows specialization, loot specialization and talent loadouts.
  - Left click: talents. Right click: select specialization, loadout or loot specialization.
  - Forever: shows points spent in each talent tree; right click selects primary or secondary talents.
- **System**
  - Shows FPS, latency and optional addon CPU usage. Hold Shift when hovering to expand the addon list.
  - Left click: reset CPU stats. Right click: toggle CPU profiling, applied after `/reload`. Middle click: reload UI.
  - Shift + left click: cycle audio-output devices.
- **Time**
  - Shows the clock, lockouts, Bountiful Delves, weekly key progress and Mythic+ progress.
  - Hold Shift when hovering to view Dragonflight and The War Within weekly quests.
  - Left click: calendar. Right click: time manager. Middle click: Great Vault.
  - Forever: keeps the clock and raid lockouts; weekly quests, Delves, Mythic+ and the Great Vault are disabled.

### Settings

- Back up [Kiminfo/Config.lua](Kiminfo/Config.lua), edit the values below, save as UTF-8, then run `/reload`.
- `C.Time`, `C.Bags`, `C.Memory`, `C.System`, `C.Spec`, `C.Friends`, `C.Guild`, `C.Durability`, `C.Positions`: module switches; `true` enables, `false` disables.
- `C.StickTop = true`: tooltips below the bar; set to `false` for tooltips above it.
- `C.InfoPanel = {minWidth = 300, maxWidth = 1000, maxHeight = 600}`: shared panel size for Friends and Guild.
- `C.MaxAddOns = 30`: number of addons initially shown in Memory/System lists.
- `C.Gap = 8`: space between modules.
- `G.Fonts = STANDARD_TEXT_FONT`: font; use the game font or a font-file path.
- `G.FontSize = 16`: font size.
- `G.FontFlag = "OUTLINE"`: font outline; use `""` for no outline.
- `G.TitleColor = "|cff66ccff"`: title text color.
- `G.OptionColor = "|cff99ccff"`: option text color.
- `G.ErrColor = "|cffff0000"`: error text color.
- `G.Line`: separator text.

#### Custom layout

- Edit `C.Layout` to arrange the bar. Single-row example:

  ```lua
  C.Layout = {
      {
          point = {"TOPLEFT", UIParent, 0, -10},
          inset = {15, -10},
          panel = {720, 36, .8},
          modules = {
              {"Time", 0}, {"Bags", 0}, {"Memory", 0},
              {"System", 0}, {"Spec", 0}, {"Friends", 0},
              {"Guild", 0}, {"Durability", 0}, {"Positions", 0},
          },
      },
  }
  ```

- `point = {"TOPLEFT", UIParent, 0, -10}`: row position—anchor, reference frame, X, Y. Positive X moves right; positive Y moves up.
- `inset = {15, -10}`: content X/Y offset from the row's top-left corner.
- `panel = {720, 36, .8}`: background width, height and opacity (0–1). Use `panel = false` to hide the background.
- `modules`: module names and extra horizontal offsets, displayed from left to right in list order. Positive offsets move right; negative offsets move left.
- Reorder the `modules` entries to change their order. Removing an entry hides it; use its module switch to disable it.
- For two rows, replace the active `C.Layout` with the commented two-row example in Config.lua. Adjust each row's `point`, `inset`, `panel` and `modules`; list each module only once.

### Credits

- Tukz, Loshine, Siweia, HopeASD
- Bar texture: Peterdox
- Icon textures: SX Databar

## 繁體中文

### 關於

Kiminfo 是一個適用於 WoW 正式服與 Forever 的輕量資訊條，基於 diminfo 製作，源自 Tukui 的資訊文字模組，共有九個模組。

**本插件僅發布在 Curse、WowInterface 和 GitHub，謝絕任何搬運轉載。**

本插件沒有遊戲內設定面板。請編輯 [Kiminfo/Config.lua](Kiminfo/Config.lua)，以 UTF-8 存檔後執行 `/reload`。可使用 [Notepad++](https://notepad-plus-plus.org/)、[Notepads](https://www.notepadsapp.com/) 或 [AkelPad](http://akelpad.sourceforge.net/en/index.php)；若需要遊戲內設定面板，可考慮 Titan Panel 等其他插件。

### 功能

- **Bags／背包**
  - 顯示空餘格數、金幣、通貨與代幣價格，可自動出售灰色物品。
  - Forever：提示顯示鑰匙圈已用／總格數，隱藏代幣價格。
  - 左鍵：背包。右鍵：自動出售開關。中鍵：兌換通貨。
- **Durability／耐久度**
  - 顯示耐久度與裝等，可自動修理。
  - Forever：包含遠程武器欄位。
  - 左鍵：角色資訊。右鍵：自動修理開關。
- **Friends／好友**
  - 顯示線上好友與遊戲詳情，按住 Shift 可顯示完整 BattleTag。
  - 名單項目上 Shift＋左鍵邀請或請求加入，中鍵密語。
  - 資訊條上左鍵開啟好友視窗，右鍵編輯戰網廣播。
- **Guild／公會**
  - 顯示線上成員、公會資訊與公會訊息。
  - 開啟名單時按住 Shift，可反向排列會階。
  - 名單項目上 Shift＋左鍵邀請，中鍵密語；資訊條上左鍵開啟公會視窗。
- **Memory／記憶體**
  - 顯示插件數量與記憶體用量，按住 Shift 指向可展開插件清單。
  - 自動回收預設關閉，回收時可能短暫停頓。
  - 左鍵：手動回收。右鍵：自動回收開關。中鍵：插件列表。
- **Positions／位置**
  - 顯示目前地區與座標。
  - 左鍵：大地圖。右鍵：將座標填入聊天框。
  - Shift＋左鍵：切換頭頂名字顯示。中鍵：切換視窗／全螢幕視窗模式。
- **Spec／專精**
  - 顯示專精、拾取專精與天賦配置。
  - 左鍵：天賦頁面。右鍵：選擇專精、天賦配置或拾取專精。
  - Forever：顯示三系天賦點數，右鍵選擇主要／次要天賦。
- **System／系統**
  - 顯示幀數、延遲與可選的插件 CPU 統計，按住 Shift 指向可展開插件清單。
  - 左鍵：重置 CPU 統計。右鍵：CPU 統計開關，`/reload` 後生效。中鍵：重載介面。
  - Shift＋左鍵：輪循音效輸出設備。
- **Time／時間**
  - 顯示時鐘、副本進度、豐裕地下堡、每週鑰匙與傳奇＋進度。
  - 按住 Shift 指向，可查看巨龍時代與地心之戰的每週任務。
  - 左鍵：行事曆。右鍵：時間管理。中鍵：寶庫。
  - Forever：保留時鐘與團本 CD，不顯示週任、地下堡、傳奇＋，停用寶庫。

### 設定

- 先備份 [Kiminfo/Config.lua](Kiminfo/Config.lua)，修改下列設定，以 UTF-8 存檔後執行 `/reload`。
- `C.Time`、`C.Bags`、`C.Memory`、`C.System`、`C.Spec`、`C.Friends`、`C.Guild`、`C.Durability`、`C.Positions`：模組開關，`true` 啟用、`false` 停用。
- `C.StickTop = true`：提示顯示在資訊條下方；改為 `false` 則顯示在上方。
- `C.InfoPanel = {minWidth = 300, maxWidth = 1000, maxHeight = 600}`：好友與公會共用的面板尺寸。
- `C.MaxAddOns = 30`：記憶體／系統清單預先顯示的插件數量。
- `C.Gap = 8`：模組間距。
- `G.Fonts = STANDARD_TEXT_FONT`：字型，可使用遊戲字型或填入字型檔路徑。
- `G.FontSize = 16`：字體大小。
- `G.FontFlag = "OUTLINE"`：字體描邊；改為 `""` 可取消描邊。
- `G.TitleColor = "|cff66ccff"`：標題文字顏色。
- `G.OptionColor = "|cff99ccff"`：選項文字顏色。
- `G.ErrColor = "|cffff0000"`：錯誤文字顏色。
- `G.Line`：分隔線文字。

#### 自訂排列

- 修改 `C.Layout` 即可調整資訊條樣式，以下為單列範例：

  ```lua
  C.Layout = {
      {
          point = {"TOPLEFT", UIParent, 0, -10},
          inset = {15, -10},
          panel = {720, 36, .8},
          modules = {
              {"Time", 0}, {"Bags", 0}, {"Memory", 0},
              {"System", 0}, {"Spec", 0}, {"Friends", 0},
              {"Guild", 0}, {"Durability", 0}, {"Positions", 0},
          },
      },
  }
  ```

- `point = {"TOPLEFT", UIParent, 0, -10}`：列位置，依序為錨點、參考框體、X、Y。X 正值向右，Y 正值向上。
- `inset = {15, -10}`：內容相對列左上角的 X、Y 偏移。
- `panel = {720, 36, .8}`：背景寬度、高度、透明度（0～1）；設為 `panel = false` 可隱藏背景。
- `modules`：模組名稱與額外水平偏移，依清單順序由左向右排列。偏移正值向右、負值向左。
- 調整 `modules` 項目的順序即可換位；移除項目只隱藏顯示，停用功能請使用模組開關。
- 需要雙列時，以 Config.lua 內的雙列註釋範例取代目前啟用的 `C.Layout`，再修改各列的 `point`、`inset`、`panel`、`modules`；每個模組只放一次。

### 鳴謝

- Tukz、Loshine、Siweia、HopeASD
- 資訊條材質：Peterdox
- 圖示材質：SX Databar
