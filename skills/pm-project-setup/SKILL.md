---
name: pm-project-setup
description: "Set up a new project in Notion after planning: create Story, 階段時程 (phase schedule), and Tasks. Use this when the user says /pm-project-setup, '建立專案', '開新 story', '規劃完了要建卡', or has finished planning a feature and wants to create the Notion structure."
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-create-pages, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-update-data-source
---

## Notion Structure

Hierarchy: **Epic → Story → (階段時程 + Tasks)**

Key databases:
- Stories: `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`
- 階段時程: `collection://2dc268e7-4af8-809cab97-f0a57e991f00`
- Tasks: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Modules: `collection://2e8268e7-4af8-803d-bb1b-000bbc327576`

## Your task

**Step 1: Gather information**

Ask the user for (or extract from their description):
1. **Story name** — what is this feature called?
2. **Epic** — which Epic does this belong to? (search or ask)
3. **Module** (`模組🖍️`) — which module/category?
4. **Phases** (`階段時程`) — what are the development phases? (e.g., 前期規劃, 開發, 人工測試, 更版)
5. **Tasks** — what are the initial tasks for the first phase?

If the user has already described the feature, extract as much as possible and confirm before creating.

**Step 2: Create Story**

Create a new page in the Stories database with:
- Title: story name
- Link to Epic
- Link to Module
- Description (if provided)

**Step 3: Create 階段時程**

For each phase, create an entry in 階段時程 linked to the Story.

**Step 4: Create Tasks**

For each task, create an entry in Tasks with:
- `名稱🖍️` — task name
- `Story🖍️` — link to the Story just created
- `模組🖍️` — same module as Story
- `所屬階段🖍️` — matching phase
- `狀態🖍️` — 即將進行
- `執行者們🖍️` — assignee (ask if not specified)
- `Sprint🖍️` — current sprint (ask if needed)

**Step 5: Confirm**

Show a summary of what was created and confirm with the user.

## Notes

- Prefer creating a few well-defined tasks over many vague ones
- If unsure about Epic, search Notion first before asking
- Task names should be action-oriented: "實作 API endpoint", "設計資料庫 schema", not "API"
