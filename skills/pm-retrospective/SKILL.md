---
name: pm-retrospective
description: "Sprint retrospective: review completed and incomplete tasks, identify patterns in bugs and delays, and generate improvement suggestions. Use this when the user says /pm-retrospective, 'sprint 回顧', '本週檢討', '上週做了什麼', or wants to review the past sprint."
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-update-data-source
---

## Notion Structure

- Tasks DB: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Stories DB: `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`
- Bug DB: `collection://2e8268e7-4af8-80a5-ad02-000b7bce538d`
- Sprint DB: `collection://2d9268e7-4af8-80ac-83b2-000b6dcef569`

## Your task

Generate a sprint retrospective report based on Notion data.

**Step 1: Determine scope**

Ask (or infer from context):
- **Sprint**: 當期（本週）or 上期（上週）？Default: 上期
- **Team member**: 全體 or 指定人員？Default: current user

**Step 2: Fetch data**

From Tasks DB, fetch tasks where `相對 Sprint = 當期/上期`:
- Fields: `名稱🖍️`, `狀態🖍️`, `所屬階段🖍️`, `執行者們🖍️`, `優先級🖍️`, `完成日期🖍️`, `Story🖍️`, `Bug🖍️`

From Bug DB, fetch bugs created this sprint:
- Fields: `名稱🖍️`, `等級🖍️`, `狀態`

**Step 3: Categorize tasks**

| 類別 | 條件 |
|------|------|
| ✅ 完成 | 狀態 = 已完成 |
| 🔄 進行中（跨週） | 狀態 = 進行中 |
| ⏸ 暫停/延後 | 狀態 = 暫停 |
| ❌ 未啟動 | 狀態 = 即將進行（Sprint 已結束但未開始）|

**Step 4: Generate report**

```markdown
## Sprint 回顧 — {日期區間}

### ✅ 本週完成（{n} 項）
- {task name} — {執行者}
...

### 🔄 跨週進行中（{n} 項）
- {task name} — {執行者}（原因：{推測或空白}）
...

### 🐛 本週新增 Bug（{n} 項）
- {bug title} — {等級}
...

### 📊 數據
- 完成率：{完成數}/{總數} = {%}
- 新增 Bug 數：{n}（P0: {n}, P1: {n}, P2: {n}）

### 💡 改善建議
{根據本週模式自動生成 2-3 條建議}
```

**Step 5: Improvement suggestions**

Automatically identify patterns and suggest improvements:

| 模式 | 建議 |
|------|------|
| 多個任務跨週未完成 | 任務切割過大，建議拆成 2~3 小時可完成的單位 |
| Bug 數量 > 完成 Task 數的 30% | 測試覆蓋不足，建議在開發階段加入 checklist |
| 有 P0/P1 Bug 且本週才發現 | 缺少 UAT / User Journey 場景測試 |
| 同一模組連續出現 Bug | 模組有技術債，建議安排重構 Task |
| 有 Task 標記「暫停」 | 確認 blocker 是否已解除，或需要重排優先級 |

**Step 6: Optional — update Notion**

Ask: "要把這份回顧記錄到 Notion 嗎？"

If yes, create a page under the Sprint record.

## Tone

直接、有洞察，不只是列清單。每個建議要有具體的下一步行動，不是空話。
