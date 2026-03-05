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

Ask the user for (or extract from their description):
1. **Bug title** — concise description of the issue
2. **Priority** — P0 (system down/critical), P1 (major feature broken), P2 (minor issue)
3. **Module** — which part of the system? (search modules if unsure)
4. **Affected customers** — specific customers impacted? (optional)
5. **Fix type** — 緊急修復 (hotfix, urgent) or 完整修復 (full fix, planned)?

**Step 2: Create Bug entry**

Create a new page in the Bug database with gathered information.

**Step 3: Create fix Task (optional)**

Ask: "要同時建立修復 Task 嗎？"

If yes, create a Task in Tasks DB with:
- `名稱🖍️` — `[修復] {bug title}`
- `Bug🖍️` — link to the Bug just created
- `模組🖍️` — same module
- `所屬階段🖍️` — 緊急修復 (for P0/P1) or 開發 (for P2)
- `狀態🖍️` — 即將進行 or 進行中
- `優先級🖍️` — 臨時 (for P0/P1) or 高 (for P2)
- `執行者們🖍️` — assignee (ask if not specified)

**Step 4: Confirm and show links**

Show the Bug page URL and Task URL (if created).

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