---
name: pm-bug
description: "Create a bug report in Notion and optionally create fix Tasks. Use this when the user says /pm-bug, '回報 bug', '建立 bug 追蹤', '有個問題要記錄', or describes a bug that needs tracking."
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-create-pages, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-update-data-source
---

## Notion Structure

- Bug DB: `collection://2e8268e7-4af8-80a5-ad02-000b7bce538d`
- Tasks DB: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Modules: `collection://2e8268e7-4af8-803d-bb1b-000bbc327576`

Bug DB fields:
- `名稱🖍️` — bug title
- `等級🖍️` — P0 (critical), P1 (high), P2 (medium)
- `模組🖍️` — affected module
- `回報者🖍️` — reporter
- `主要客戶們🖍️` — affected customers (optional)
- `Tasks` — linked fix tasks

## Your task

**Step 1: Gather bug information**

The user may report one or multiple bugs at once. For each bug, extract from their description:
1. **Bug title** — concise description of the issue
2. **Priority** — P0/P1/P2 (infer from description; ask if unclear)
3. **Module** — search Modules DB to find the best match
4. **Affected customers** — optional, search Customers DB `collection://2e8268e7-4af8-800f-a65c-000be39698a3`
5. **Fix type** — auto-derive from priority (see below)
6. **Assignee** — fetch Notion users and ask
7. **Sprint** — search Sprint DB `collection://2d9268e7-4af8-80ac-83b2-000b6dcef569`, pick the most recent date ≤ today

**Interactive selection UX (IMPORTANT):**

When you need the user to choose from a list, always format it as numbered options. The user can reply with a number or multiple numbers (e.g. `1`, `3`, `1 3`):

```
**[欄位名稱]（回覆數字選擇）：**
`1` Option A
`2` Option B
`3` Option C
```

Apply this pattern for:
- **Assignee** — always present numbered list of workspace members
- **Priority** — present as `1` P0 / `2` P1 / `3` P2 with one-line descriptions when ambiguous
- **Fix type** — present as `1` 緊急修復 / `2` 完整修復 when priority is P1

**Batch mode:** When the user reports multiple bugs, auto-fill all fields you can infer, then present a **confirmation table** with one question at the end (e.g. assignee selection). Apply the same assignee/sprint to all bugs unless the user specifies otherwise.

Example confirmation block:

```
| # | Bug | 等級 | 模組 | 修復類型 |
|---|-----|------|------|---------|
| 1 | … | P2 | 會員限期 | 完整修復 |
| 2 | … | P2 | 兌換券 | 完整修復 |

**執行者（回覆數字，可填 1 個套用全部）：**
`1` Allison Chiu
`2` Enning Yu
`3` Vince Guo
`4` Wayne Huang
`5` 楊 以宏
```

**Step 2: Create Bug entry**

Create a new page in the Bug database with gathered information.

**Bug page content format** (use this template for the page content):

```
## 問題描述

{根據使用者描述填寫}

## 關鍵識別資料

> 例如：會員帳號、訂單號碼、問題發生時間、頁面網址、使用瀏覽器版本 等

{如有受影響客戶或其他識別資料，列在此處}

## 問題重現步驟

> 建議用數字條列式搭配畫面截圖以說明步驟。

1.
```

**Step 3: Create fix Task pipeline**

Default: always create the Task pipeline unless the user explicitly says not to. Determine fix type automatically by priority (P0/P1 → 緊急修復, P2 → 完整修復). For P1, mention the default and let the user override if needed.

Based on fix type, create a **pipeline of Tasks** with sequential dependencies (each Task's `依賴 Task🖍️` points to the previous one):

### 緊急修復 (hotfix) — 3 Tasks

| # | 名稱🖍️ prefix | 所屬階段🖍️ | 優先級🖍️ |
|---|---------------|-----------|---------|
| 1 | `[緊急修復]` | 緊急修復 | 臨時 |
| 2 | `[緊急更版]` | 緊急更版 | 臨時 |
| 3 | `[驗收]` | 驗收 | 臨時 |

### 完整修復 (full fix) — 4 Tasks

| # | 名稱🖍️ prefix | 所屬階段🖍️ | 優先級🖍️ |
|---|---------------|-----------|---------|
| 1 | `[開發]` | 開發 | 高 |
| 2 | `[人工測試]` | 人工測試 | 高 |
| 3 | `[更版]` | 更版 | 高 |
| 4 | `[驗收]` | 驗收 | 高 |

**Default fix type by priority:**
- P0 → 緊急修復
- P1 → 緊急修復 (but ask user to confirm, may be 完整修復)
- P2 → 完整修復

**All Tasks share these properties:**
- `Bug🖍️` — link to the Bug just created
- `模組🖍️` — same module as the Bug
- `狀態🖍️` — 即將進行
- `名稱🖍️` — `{prefix} {bug title}`
- `依賴 Task🖍️` — previous Task in the pipeline (except the first Task)
- `執行者們🖍️` — assignee (from Step 1)
- `Sprint🖍️` — sprint (from Step 1)

**`Git Branch🖍️` 規則（更版類 Task 專用）：**
- `[更版]` 和 `[緊急更版]` Task 必須填入 `Git Branch🖍️`
- 值為修復該 bug 的 feature branch 名稱（例如 `fix/social-login`、`hotfix/payment-timeout`）
- **避免使用 `main`**：修復應在獨立 branch 進行，再 merge 進 main，而非直接在 main 上開發
- 其他 Task（開發、人工測試、驗收 等）不需要填

**Git Branch 自動查找流程（不需詢問用戶）：**
1. 同時執行 `git branch -r --sort=-committerdate | head -30` 查詢 `newscms` 和 `havppen-api-v1` 的遠端 branches
2. 根據 bug 描述的關鍵字，比對 `fix/` 或 `hotfix/` 開頭的 branch，找最相關者
3. 如果找到匹配 → 直接填入，在最終摘要中說明找到的 branch
4. 如果找不到 → 自行命名 `fix/<kebab-case-bug-summary>`（例如 `fix/activity-auto-offline`）並填入
5. **全程不詢問用戶**，直接處理

**⚠️ Fix Branch 必須從 master（前端）或 main（後端）切出：**
- 絕對不能從 `develop` 或 `release` 切出 fix/hotfix branch
- 從錯誤 branch 切出會把未完成的功能帶進 production
- 正確做法：`git checkout master && git pull && git checkout -b fix/<name>`
- 記得提醒開發者：修完後 merge 進 master，再從 master cherry-pick 或 merge 回 develop

**⚠️ 驗收測試原則：**
- 驗收測試一律在**測試環境**用**測試帳號**執行
- 受影響客戶（`主要客戶們🖍️`）僅用於了解問題背景與重現條件，不做為測試對象
- 撰寫測試案例時不要提及客戶帳號，改寫為「在測試環境重現相同設定」

**Creation order:** Create Tasks sequentially (1 → 2 → 3 → ...) so each Task's URL is available to set as the next Task's `依賴 Task🖍️`.

**Step 4: Confirm and show links**

Show the Bug page URL and all Task URLs in a summary table.

## Priority guide

| Level | When to use |
|-------|-------------|
| P0 | System down, data loss, security issue — fix immediately |
| P1 | Core feature broken, affects many users — fix this sprint |
| P2 | Minor issue, workaround exists — schedule normally |


---

## Maintenance

This skill is managed in the `havppen-pm-skills` repo (`~/Projects/Havppen/havppen-pm-skills`).
After editing `~/.claude/skills/pm-bug/SKILL.md`, sync back:

```bash
cp ~/.claude/skills/pm-bug/SKILL.md ~/Projects/Havppen/havppen-pm-skills/skills/pm-bug/SKILL.md
cd ~/Projects/Havppen/havppen-pm-skills && git add skills/pm-bug/SKILL.md && git commit -m "..." && git push
```