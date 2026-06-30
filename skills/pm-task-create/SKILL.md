---
name: pm-task-create
description: "Quick task creation in Notion from conversation context. Use this when the user says /pm-task-create, '幫我開一張 task', '記一下這件事', '開卡', or describes something that needs to be tracked as a task without full project setup."
model: haiku
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-create-pages, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-get-users, mcp__claude_ai_Notion__notion-fetch, mcp__claude_ai_Notion__notion-create-pages, mcp__claude_ai_Notion__notion-update-page, mcp__claude_ai_Notion__notion-search
---

<!-- HAIKU-DELEGATE-MARKER -->
> **執行模型：Haiku（省用量）**
> 本 skill 為機械型流程（Notion CRUD + 格式化），不需深推理。
> 若你目前**不是** Haiku，請改用 Agent tool 派一個 `model: haiku` 的 sub-agent，
> prompt 指示它「呼叫本 skill 並完成全部步驟」，主 session 不要親自跑。
> 例外：流程中出現需判斷／取捨的 edge case，sub-agent 應回報主 session 交高階模型決定。

## Notion Structure

- Tasks DB: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Stories DB: `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`
- Bug DB: `collection://2e8268e7-4af8-80a5-ad02-000b7bce538d`
- Modules: `collection://2e8268e7-4af8-803d-bb1b-000bbc327576`
- Sprint DB: `collection://2d9268e7-4af8-80ac-83b2-000b6dcef569`

## Your task

Create one or more Notion Tasks quickly from conversation context.

**Step 1: Extract from context**

From what the user described, determine:
- **Task name(s)** — action-oriented, e.g. `[調查] xxx`, `[修復] xxx`, `[前端] xxx`
- **Priority** (優先級🖍️) — 臨時 / 高 / 中 / 低 (default: 中)
- **Stage** (所屬階段🖍️) — 未開始 / 前期規劃 / 開發 / 人工測試 / 更版 / 驗收 / 緊急修復 / 緊急更版 (default: 前期規劃)
- **Status** (狀態🖍️) — 即將進行 / 進行中 / 已完成 (default: 即將進行)
- **Assignee** (執行者們🖍️) — ask if not clear from context; use `notion-search` with `query_type: "user"` to resolve name to user ID
- **Points** (點數🖍️) — 1 / 2 / 3 / 5 / 8 / 13 / 21 — ask if not clear
- **Module** (模組🖍️) — search Modules DB to find matching module
- **Sprint** (Sprint🖍️) — auto-detect current sprint from Sprint DB
- **Story or Bug link** — if context mentions one, search and link it
- **Completion date** (完成日期🖍️) — if status is 已完成, ask or infer

**Step 2: Auto-resolve references**

Before confirming, resolve these automatically (in parallel):
1. **Sprint**: Search Sprint DB for the sprint whose date range covers today (or the relevant date)
2. **Module**: Search Modules DB by keyword from the task name/context
3. **Story/Bug**: Search if context mentions a related story or bug
4. **Assignee**: If name is mentioned, search for the Notion user ID

**Step 3: Confirm before creating**

Show a compact preview with ALL fields:
```
建立 Task：
  名稱：[調查] kingway 金流商憑證
  優先級：臨時
  階段：前期規劃
  狀態：進行中
  執行者：Wayne
  點數：3
  模組：金流
  Sprint：Sprint 10 (2026-03-09)
  Bug：[kingway] 金流通知持續噴 403
  完成日期：—
```

If any field is unknown or ambiguous, ask the user.
If the user has already confirmed in context, skip confirmation.

**Step 4: Create the task**

Create the Task in Notion with all resolved fields.

**Step 5: Post-creation validation**

After creating, fetch the created task and check these required fields:

| 欄位 | 必填條件 |
|------|----------|
| 名稱🖍️ | 永遠必填 |
| 優先級🖍️ | 永遠必填 |
| 所屬階段🖍️ | 永遠必填 |
| 狀態🖍️ | 永遠必填 |
| 執行者們🖍️ | 永遠必填 |
| 點數🖍️ | 永遠必填 |
| Sprint🖍️ | 永遠必填 |
| 模組🖍️ | 永遠必填 |
| Story🖍️ 或 Bug🖍️ | 至少填一個（臨時事項可例外） |
| 完成日期🖍️ | 狀態 = 已完成 時必填 |

If any required field is empty:
1. List the missing fields
2. Ask user for the values
3. Update the task with the missing values
4. Re-fetch and verify all fields are filled

Return the task URL when done.

## Naming conventions

| Type | Prefix |
|------|--------|
| 調查/排查 | `[調查]` |
| 後端修復 | `[後端]` or `[修復]` |
| 前端修復 | `[前端]` |
| 長期改善 | `[長期]` |
| 文件 | `[文件]` |
| 測試 | `[測試]` |
| Bug 緊急修復 | `【Bug-緊急修復】` |
| Bug 緊急更版 | `【Bug-緊急更版】` |

## Priority guide

| 優先級 | 時機 |
|--------|------|
| 臨時 | 今天或本週內必須處理的急件 |
| 高 | 重要但不緊急，本 sprint 內處理 |
| 中 | 一般需求 |
| 低 | 有空時進行 |

## Points guide (Fibonacci)

| 點數 | 大小 |
|------|------|
| 1 | 半小時內完成（更版、簡單配置） |
| 2 | 1-2 小時 |
| 3 | 半天 |
| 5 | 一天 |
| 8 | 2-3 天 |
| 13 | 一週 |
| 21 | 超過一週（建議拆分） |
