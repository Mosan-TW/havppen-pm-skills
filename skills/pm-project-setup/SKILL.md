---
name: pm-project-setup
description: "Set up a new project in Notion after planning: create Story, 階段時程 (phase schedule), and Tasks. Use this when the user says /pm-project-setup, '建立專案', '開新 story', '規劃完了要建卡', or has finished planning a feature and wants to create the Notion structure."
model: haiku
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-create-pages, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-update-data-source, mcp__claude_ai_Notion__notion-fetch, mcp__claude_ai_Notion__notion-search, mcp__claude_ai_Notion__notion-create-pages, mcp__claude_ai_Notion__notion-update-page, AskUserQuestion, Bash
---

<!-- HAIKU-DELEGATE-MARKER -->
> **執行模型：Haiku（省用量）**
> 本 skill 為機械型流程（Notion CRUD + 格式化），不需深推理。
> 若你目前**不是** Haiku，請改用 Agent tool 派一個 `model: haiku` 的 sub-agent，
> prompt 指示它「呼叫本 skill 並完成全部步驟」，主 session 不要親自跑。
> 例外：流程中出現需判斷／取捨的 edge case，sub-agent 應回報主 session 交高階模型決定。

> **Notion MCP Fallback**: MCP 回 500 時，讀 `shared/notion-api-fallback.md` 切換到 Bash + REST API。

## Known Team Members

| 名稱 | Notion User ID |
|------|----------------|
| wayne | `e0aef6a9-3930-4c00-ac50-a7340ef57b19` |

When the user's arguments contain a known name (case-insensitive), use it as the default 負責人 and 執行者.
If the name is not in this table, search Notion users via `notion-search` with `query_type: "user"` to resolve.

## Arguments

The skill accepts optional arguments in the format:
```
/pm-project-setup [name] <feature description>
```

- If the first word matches a known team member name, use it as the default assignee
- Everything else is the feature description
- Examples:
  - `/pm-project-setup wayne 刪除兌換券：跳提醒` → 負責人=Wayne
  - `/pm-project-setup emily 新增報表功能` → search "emily" in Notion users
  - `/pm-project-setup 刪除兌換券` → no default assignee, ask user to select

## Notion Structure

Hierarchy: **Group（選填）→ Story → (階段時程 + Tasks)**

> **Group 填寫規則**：只有 feature 需拆成多個階段時才建立 / 關聯 Group。
> Story 命名 `<Group名>｜第N階段`（如 `電子報改版｜第一階段`），Group = `電子報改版`。
> 單一階段的 feature **不填 Group**，`Group🖍️` 欄位留空。

Key databases（REST DB id；不要用 `collection://` view UUID，REST 會回 404）：

| DB | REST Database ID |
|----|-----------------|
| Stories | `2d9268e74af88105a52ff323aed1cfcb` |
| StoryGroup（原 Epics） | `2d9268e74af880d69225ee4bc7269453` |
| Tasks | `2d9268e74af88074ae62ddfa3090f7a1` |
| 階段時程 | `2dc268e74af8809cab97f0a57e991f00` |

> ⚠️ 看到 `collection://...` 形式的 ID 一律當 view，**不可餵給 REST API**。若需 search/query 找正確 DB id，從既有 page 反查 `parent.database_id`。

完整對照表：`shared/notion-api-fallback.md`。若 REST 呼叫 404，先檢查是否誤用舊 view ID。

## Phase Types

**完整流程**（大型功能，需 PRD + Spec）：
1. 前期規劃 — PRD 規劃階段
2. 後期規劃 — Spec 規劃階段
3. 開發
4. 人工測試 — 請 QA 進行測試
5. 更版 — 每週更版，QA 驗收

**簡易流程**（小型功能，規劃寫在 Story）：
1. 開發 — 規劃直接寫在 Story，排開發時間
2. 更版 — 每週更版，QA 驗收

## Valid values for 所屬階段🖍️

與階段時程對應，另加：
- 前期規劃 / 後期規劃 / 開發 / 人工測試 / 更版
- 驗收
- 緊急修復
- 緊急更版

## Your task

**Step 1: Gather & confirm information**

Extract as much as possible from the user's description, apply sensible defaults, then present a **pre-filled confirmation form** for the user to review. Use `AskUserQuestion` with predefined options wherever possible.

### 1a. Auto-extract from user input
- **Story name** — from the feature description
- **Tasks** — from numbered items or sub-points in the description

### 1b. Lookup from Notion (do these in parallel)
- **Group** — **僅在 feature 拆多階段時才查**（Story 名含 `｜第N階段`、或用戶明說分階段）。search StoryGroup database（REST DB id `2d9268e74af880d69225ee4bc7269453`）找既有 Group，沒有就建新 Group（名稱 = 不含階段字尾的 feature 名）。單一階段 feature 跳過此項，Group 留空

> 🚫 **模組已廢除（2026-07-14）**：`模組🖍️` 欄位不再使用，Story 與 Task 都不填、也不要 search Modules database。

### 1c. Apply defaults
- **流程類型** → 簡易流程（unless the feature clearly needs PRD/Spec）
- **優先級** → 中
- **負責人** → 如果 arguments 中有指定人名，從 Known Team Members 表或 Notion user search 解析；否則詢問，以編號選項呈現
- **是否執行** → 正常執行

### 1c-2. Mandatory phase gate（STOP if missing）

在進入 1d 之前，**強制檢查 auto-extracted Tasks 是否涵蓋所有必建階段**：

- 簡易流程：**開發 / 人工測試 / 更版 / 驗收** 四張，缺一不可
- 完整流程：**前期規劃 / 後期規劃 / 開發 / 人工測試 / 更版 / 驗收** 六張，缺一不可

缺少任何階段 → 自動補齊（名稱：`<階段>`，如 `開發`、`人工測試`；**不加 Story 名**），不詢問用戶。補完後在 1d 確認表格用 ✨ 標記自動補的 task，讓用戶知道補了什麼。

> 教訓：第 2 次發生「Story 建好但沒驗收 task」。Step 4 規則已列必建，但 Step 1d 確認時沒擋住 → 自動補齊才是硬閘門。

### 1d. Present confirmation form

Show a table with all values pre-filled, then ask the user to confirm or modify using numbered options. Format:

```
| 欄位 | 值 |
|------|-----|
| Story | <extracted name> |
| Group | <多階段時填 best match，否則「—（單一階段，不需 Group）」> |
| 流程 | 簡易流程 |
| 優先級 | 中 |
| 負責人 | <從 arguments 解析 or ⚠️ 請選擇> |
| 是否執行 | 正常執行 |

Tasks（所屬階段：開發）:
1. <task 1>
2. <task 2>
```

Then use AskUserQuestion with options like:
- `確認，開始建立` — proceed with all values as shown
- `修改 Group` — show Group list as numbered options (from Notion search results)；也可選「不需 Group」清空
- `修改流程` — toggle between 完整流程 / 簡易流程
- `修改優先級` — show 低 / 中 / 高 as options
- `修改 Tasks` — let user edit task list
- `全部重填` — ask each field individually

When the user selects a "修改" option, present the specific field's choices as **numbered options** using AskUserQuestion. After modification, show the updated table again and re-confirm.

Phases are pre-filled based on flow type — no need to ask unless the user wants to customize.

**Step 2: Create Story**

> ⚠️ **寫內文前必讀 `shared/notion-card-writing-style.md`**（單一事實來源）。
> Story 卡是給 PM / QA 看的，**內文一律白話**：禁檔案路徑、行號、程式碼片段、變數 / DTO / 資料表 / 端點名稱、框架術語堆疊（GQL / REST / client-side / adapter / view…）。技術細節留 `features/<slug>/context.md` 與 openspec change，內文最後用一句話指路過去即可。
> Story 段落結構（客戶要什麼 / 現在的狀況 / 規劃時查到的事 / 決定怎麼做 / 要避開的坑 / 影響範圍 / 需要注意 / 詳細規格）與改寫對照範例見該檔。
> **判準**：把卡片拿給不寫 code 的同事看，他能不能講出「這張卡在做什麼、為什麼要做、做完會怎樣」。不能就是還不夠白話。

Create a new page in the Stories database with:
- Title: story name（多階段時命名 `<Group名>｜第N階段`）
- `Group🖍️` — 僅多階段 feature 才 link Group；單一階段留空
- Description (if provided)
- **內文第一個 block 必為 callout**，寫一句話 TL;DR（story 內文一律很長，需可一眼掃到重點）。寫「這支 story 在做什麼 + 解什麼痛點」一句話，不要貼規劃內文。**禁止留空**
- `優先級🖍️` — 低 / 中 / 高
- `負責人1🖍️` — assignee (people property)
- `是否執行🖍️` — 正常執行 / 因故暫停 / 因故取消

> ⚠️ Stories DB **沒有** `模組🖍️`，也**沒有** `一句話描述` 欄位（2026-07-14 以 REST `GET /v1/databases` 實查確認）。不要嘗試寫入這兩個 property，會 400。

**Step 3: ~~Create 階段時程~~（已停用）**

> 🚫 **永遠跳過此步驟**，直接進 Step 4。階段時程不再在 pm-project-setup 流程中建立。

**Step 4: Create Tasks**

> ⚠️ **卡片命名規則（Notion 自動化）**：Task link Story 後，自動化會改寫名稱補上 Story 名。
> 因此 `名稱🖍️` **只寫階段 / 動作本身**（如 `開發`、`人工測試`、`更版`、`驗收`、`第一階段方向評估`），
> **不要重複 Story 名、不要加 `[階段]` 前綴**，否則會出現重複名稱。

For each task, create an entry in Tasks with:
- `名稱🖍️` — task name（只寫階段 / 動作，見上方命名規則）
- `Story🖍️` — link to the Story just created
- `所屬階段🖍️` — matching phase
- `狀態🖍️` — 即將進行
- `執行者們🖍️` — assignee (ask if not specified)
- `Sprint🖍️` — current sprint (ask if needed)

⚠️ **必建 Task 清單（缺一不可）：**
- 完整流程：前期規劃 / 後期規劃 / 開發 / 人工測試 / 更版 / **驗收**
- 簡易流程：開發 / 人工測試 / 更版 / **驗收**
- 驗收 Task 依賴（`依賴 Task🖍️`）= 更版 Task；不得省略

⚠️ **人工測試 Task 與驗收 Task 的 body 必須一模一樣**——兩張都由 QA 執行，內容應一致；都用 **Gherkin 格式 + 非技術語言**（畫面看到什麼、按了什麼按鈕、出現什麼提示），禁 DB query / API path / schema 等技術細節。兩張卡都不能留空。

**Step 5: Summary**

Show a summary of what was created with clickable Notion links:

```
✅ 建立完成！

| 項目 | 名稱 | 連結 |
|------|------|------|
| Story | <name> | <notion URL> |
| 階段時程 | 開發 | <notion URL> |
| 階段時程 | 更版 | <notion URL> |
| Task | <task 1> | <notion URL> |
| Task | <task 2> | <notion URL> |
```

## Notes

- Prefer creating a few well-defined tasks over many vague ones
- Group 判斷：feature 有分階段（第一階段 / 第二階段…）才需要 Group；不確定時先問用戶「這個功能會分階段嗎？」，不要預設建 Group
- Task names should be action-oriented: "實作 API endpoint", "設計資料庫 schema", not "API"；且不含 Story 名（自動化會補）


---

## Maintenance

This skill is managed in the `havppen-pm-skills` repo (`~/Projects/Havppen/havppen-pm-skills`).
**唯一來源是 `~/Projects/Havppen/havppen/havppen-spec/.claude/skills/pm-project-setup/SKILL.md`**（pm-* 系列**不在** `~/.claude/skills/`，別往那裡找）。改完後同步回 pm-skills repo：

```bash
cp ~/Projects/Havppen/havppen/havppen-spec/.claude/skills/pm-project-setup/SKILL.md ~/Projects/Havppen/havppen-pm-skills/skills/pm-project-setup/SKILL.md
cd ~/Projects/Havppen/havppen-pm-skills && git add skills/pm-project-setup/SKILL.md && git commit -m "..." && git push
```