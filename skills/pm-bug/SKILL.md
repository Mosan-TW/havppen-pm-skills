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

Use the `AskUserQuestion` tool when you need the user to make a choice. Key rules:
- Up to 4 questions at once, 2–4 options each (automatically adds "Other" for custom input)
- Use `multiSelect: true` when choices are not mutually exclusive
- Put the most likely answer first with "(Recommended)" in the label

Apply `AskUserQuestion` for:
- **Assignee** — fetch workspace users (`notion-get-users`), present as options (max 4; if more than 4 people, pick the most likely candidates or use "Other")
- **Priority** — when ambiguous, ask with P0/P1/P2 as options with descriptions
- **Fix type** — when priority is P1, ask 緊急修復 vs 完整修復
- **Sprint** — always show the selected sprint name (e.g. "2026 W12") as "(Recommended)" option with "Other" fallback; never silently auto-select

**Batch mode:** When the user reports multiple bugs, auto-fill all fields you can infer, then show a plain summary table in text, followed by ONE `AskUserQuestion` call for the remaining unknown(s) (e.g., assignee). Apply the same answer to all bugs unless the user specifies otherwise via "Other".

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

**Step 3: Generate test scenarios**

Before creating Tasks, draft test scenarios for the bug fix. These will be embedded directly into the 人工測試 and 驗收 Task bodies.

**For every bug, generate at minimum:**

1. **Regression scenario** — 驗證 bug 已修復（最重要）
2. **Boundary scenario** — 邊界值、剛好符合 / 剛好不符合的情況
3. **Side-effect scenario** — 修復後相關功能沒有壞掉（smoke test）

**Language rules（同 pm-qa）：**
- 用使用者視角，不用技術用語
- 不提客戶帳號，改為「在測試環境建立相同設定」
- 用口語化的繁體中文描述 UI 元素，避免英文或技術術語，例如：
  - table → 表格
  - 分頁控制項 / pagination → 分頁切換
  - modal / dialog → 視窗、彈窗
  - button → 按鈕
  - checkbox → 勾選框
  - dropdown → 下拉選單
  - tab → 頁籤
  - loading → 載入中
  - toast / notification → 提示訊息
  - input / field → 欄位、輸入框

**Output format for 人工測試 Task body:**

```
## 自測步驟

{step-by-step 重現原 bug 的步驟，確認已修復}

1. 進入 {頁面}
2. 執行 {操作}
3. 預期：{應看到什麼}（原本是：{原本錯誤行為}）

## 測試案例

{Gherkin scenarios}
```

**Output format for 驗收 / 緊急修復 Task body:**

```
## 驗收測試案例

{Gherkin scenarios，以使用者視角描述}
```

**Gherkin template：**

```gherkin
Scenario: {場景標題（修復驗證）}
  Given {前置條件}
  When {操作}
  Then {預期結果（已修復的行為）}

Scenario: {相關功能 smoke test}
  Given {前置條件}
  When {操作}
  Then {應正常運作}
```

---

**Step 3b: Create fix Task pipeline**

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

**Step 4: Create worktree and meta.yaml**

After creating all Tasks:

1. **Derive slug** from the git branch name (e.g. `fix/membership-plan-min-price-zero` → `fix-membership-plan-min-price-zero`)

2. **Create worktree** in newscms (frontend fix) or havppen-api-v1 (backend fix) or both:
   ```bash
   # Frontend
   cd ~/Projects/Havppen/havppen/newscms
   git checkout master && git pull
   git worktree add ../worktrees/<slug> -b fix/<slug>

   # Backend
   cd ~/Projects/Havppen/havppen/havppen-api-v1
   git checkout main && git pull
   git worktree add ../worktrees/<slug> -b fix/<slug>
   ```
   Worktree path convention: `~/Projects/Havppen/havppen/worktrees/<slug>`

3. **Record worktree path in the 開發/緊急修復 Task body** — append a section:
   ```
   ## Worktree
   ~/Projects/Havppen/havppen/worktrees/<slug>
   ```

4. **Create `fixes/<slug>/meta.yaml`** in havppen-spec:
   ```yaml
   notion:
     bug: <bug-page-url>
     tasks:
       修復: <fix-task-url>      # 緊急修復 or 開發
       驗收: <uat-task-url>
       更版: <release-task-url>
   worktree: ~/Projects/Havppen/havppen/worktrees/<slug>
   ```

**Step 5: Confirm and show links**

Show the Bug page URL, all Task URLs, and worktree path in a summary table.

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