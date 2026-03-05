---
name: pm-link-task
description: "Find the right Story/Epic for a Task and link them, or create a new Story if none exists. Use this when the user says /pm-link-task, '這個 task 要掛在哪', '找一下對應的 story', '幫我把 task 歸類', or has orphaned tasks that need to be attached to a project."
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-update-data-source
---

## Notion Structure

- Tasks DB: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Stories DB: `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`
- Epics DB: `collection://2d9268e74af880d69225ee4bc7269453`
- Modules: `collection://2e8268e7-4af8-803d-bb1b-000bbc327576`

## Your task

**Step 1: Identify the Task**

Ask the user which Task needs linking, or take it from context. Fetch the Task to see its current fields.

**Step 2: Search for matching Story**

Based on the Task's name, module, and description:
1. Search Stories DB for semantically related stories
2. Present top 3 matches with their names and Epics
3. Ask: "這幾個 Story 哪個最符合？還是要建新的？"

**Step 3: Link or create**

**If linking to existing Story:**
- Update the Task's `Story🖍️` field to the chosen Story
- Optionally update `模組🖍️` to match the Story's module

**If creating new Story:**
- Ask for Story name, Epic, and module
- Create the Story (see pm-project-setup for structure)
- Then link the Task to the new Story

**Step 4: Confirm**

Show the updated Task with its new Story link.

## For bulk linking

If the user has multiple orphaned tasks, process them one by one or group them by module for efficiency. Ask: "有多個 Task 需要處理嗎？我可以一起幫你整理。"
