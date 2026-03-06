---
name: pm-task-create
description: "Quick task creation in Notion from conversation context. Use this when the user says /pm-task-create, '幫我開一張 task', '記一下這件事', '開卡', or describes something that needs to be tracked as a task without full project setup."
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-create-pages, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-get-users
---

## Notion Structure

- Tasks DB: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Stories DB: `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`
- Bug DB: `collection://2e8268e7-4af8-80a5-ad02-000b7bce538d`
- Modules: `collection://2e8268e7-4af8-803d-bb1b-000bbc327576`

## Your task

Create one or more Notion Tasks quickly from conversation context.

**Step 1: Extract from context**

From what the user described, determine:
- **Task name(s)** — action-oriented, e.g. `[調查] xxx`, `[修復] xxx`, `[前端] xxx`
- **Priority** — 臨時 / 高 / 中 / 低 (default: 中)
- **Stage** (所屬階段🖍️) — 前期規劃 / 開發 / 人工測試 / 更版 (default: 前期規劃)
- **Status** — 即將進行 / 進行中 (default: 即將進行)
- **Assignee** — ask if not clear from context
- **Link to Story or Bug** — if context mentions one, search and link it

**Step 2: Confirm before creating**

Show a compact preview:
```
建立 Task：
  名稱：[調查] kingway 金流商憑證
  優先級：臨時
  階段：前期規劃
  狀態：進行中
  執行者：Wayne
  Bug：[kingway] 金流通知持續噴 403
```

Ask: "確認建立嗎？" — if the user has already confirmed in context, skip this.

**Step 3: Create and return link**

Create the Task in Notion and return the URL.

If multiple tasks, create all and list all URLs.

## Naming conventions

| Type | Prefix |
|------|--------|
| 調查/排查 | `[調查]` |
| 後端修復 | `[後端]` or `[修復]` |
| 前端修復 | `[前端]` |
| 長期改善 | `[長期]` |
| 文件 | `[文件]` |
| 測試 | `[測試]` |

## Priority guide

| 優先級 | 時機 |
|--------|------|
| 臨時 | 今天或本週內必須處理的急件 |
| 高 | 重要但不緊急，本 sprint 內處理 |
| 中 | 一般需求 |
| 低 | 有空時進行 |
