---
name: pm-project-setup
description: "Set up a new project in Notion after planning: create Story, 階段時程 (phase schedule), and Tasks. Use this when the user says /pm-project-setup, '建立專案', '開新 story', '規劃完了要建卡', or has finished planning a feature and wants to create the Notion structure."
model: sonnet
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-create-pages, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-update-data-source, mcp__claude_ai_Notion__notion-fetch, mcp__claude_ai_Notion__notion-search, mcp__claude_ai_Notion__notion-create-pages, mcp__claude_ai_Notion__notion-update-page, AskUserQuestion, Bash
---

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

Hierarchy: **Epic → Story → (階段時程 + Tasks)**

Key databases（REST DB id；不要用 `collection://` view UUID，REST 會回 404）：

| DB | REST Database ID |
|----|-----------------|
| Stories | `2d9268e74af88105a52ff323aed1cfcb` |
| Epics | `2d9268e74af880d69225ee4bc7269453` |
| Tasks | `2d9268e74af88074ae62ddfa3090f7a1` |
| 階段時程 | `2dc268e74af8809cab97f0a57e991f00` |
| Modules | `2e8268e74af8803dbb1b000bbc327576` |

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
- **Epic** — search Epics database (`collection://2d9268e7-4af8-8005-a5b3-000b2a4297b6`) to find candidates matching the feature domain
- **Module** — search Modules database (`collection://2e8268e7-4af8-803d-bb1b-000bbc327576`) to find matching modules

### 1c. Apply defaults
- **流程類型** → 簡易流程（unless the feature clearly needs PRD/Spec）
- **優先級** → 中
- **負責人** → 如果 arguments 中有指定人名，從 Known Team Members 表或 Notion user search 解析；否則詢問，以編號選項呈現
- **是否執行** → 正常執行

### 1c-2. Mandatory phase gate（STOP if missing）

在進入 1d 之前，**強制檢查 auto-extracted Tasks 是否涵蓋所有必建階段**：

- 簡易流程：**開發 / 人工測試 / 更版 / 驗收** 四張，缺一不可
- 完整流程：**前期規劃 / 後期規劃 / 開發 / 人工測試 / 更版 / 驗收** 六張，缺一不可

缺少任何階段 → 自動補齊（名稱：`[<階段>] <Story name>`），不詢問用戶。補完後在 1d 確認表格用 ✨ 標記自動補的 task，讓用戶知道補了什麼。

> 教訓：第 2 次發生「Story 建好但沒驗收 task」。Step 4 規則已列必建，但 Step 1d 確認時沒擋住 → 自動補齊才是硬閘門。

### 1d. Present confirmation form

Show a table with all values pre-filled, then ask the user to confirm or modify using numbered options. Format:

```
| 欄位 | 值 |
|------|-----|
| Story | <extracted name> |
| Epic | <best match from search> |
| 模組 | <best match from search> |
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
- `修改 Epic` — show Epic list as numbered options (from Notion search results)
- `修改模組` — show Module list as numbered options (from Notion search results)
- `修改流程` — toggle between 完整流程 / 簡易流程
- `修改優先級` — show 低 / 中 / 高 as options
- `修改 Tasks` — let user edit task list
- `全部重填` — ask each field individually

When the user selects a "修改" option, present the specific field's choices as **numbered options** using AskUserQuestion. After modification, show the updated table again and re-confirm.

Phases are pre-filled based on flow type — no need to ask unless the user wants to customize.

**Step 2: Create Story**

Create a new page in the Stories database with:
- Title: story name
- Link to Epic
- Description (if provided)
- `優先級🖍️` — 低 / 中 / 高
- `負責人1🖍️` — assignee (people property)
- `是否執行🖍️` — 正常執行 / 因故暫停 / 因故取消

Note: Stories database does NOT have a `模組🖍️` property. Module is set on Tasks only.

**Step 3: ~~Create 階段時程~~（已停用）**

> 🚫 **永遠跳過此步驟**，直接進 Step 4。階段時程不再在 pm-project-setup 流程中建立。

**Step 4: Create Tasks**

For each task, create an entry in Tasks with:
- `名稱🖍️` — task name
- `Story🖍️` — link to the Story just created
- `模組🖍️` — same module as Story
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
- If unsure about Epic, search Notion first before asking
- Task names should be action-oriented: "實作 API endpoint", "設計資料庫 schema", not "API"


---

## Maintenance

This skill is managed in the `havppen-pm-skills` repo (`~/Projects/Havppen/havppen-pm-skills`).
After editing `~/.claude/skills/pm-project-setup/SKILL.md`, sync back:

```bash
cp ~/.claude/skills/pm-project-setup/SKILL.md ~/Projects/Havppen/havppen-pm-skills/skills/pm-project-setup/SKILL.md
cd ~/Projects/Havppen/havppen-pm-skills && git add skills/pm-project-setup/SKILL.md && git commit -m "..." && git push
```