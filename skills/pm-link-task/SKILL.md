---
name: pm-link-task
description: "Find the right Story/Epic for a Task and link them, or create a new Story if none exists. Use this when the user says /pm-link-task, '這個 task 要掛在哪', '找一下對應的 story', '幫我把 task 歸類', or has orphaned tasks that need to be attached to a project."
model: haiku
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-update-data-source
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


---

## Maintenance

This skill is managed in the `havppen-pm-skills` repo (`~/Projects/Havppen/havppen-pm-skills`).
After editing `~/.claude/skills/pm-link-task/SKILL.md`, sync back:

```bash
cp ~/.claude/skills/pm-link-task/SKILL.md ~/Projects/Havppen/havppen-pm-skills/skills/pm-link-task/SKILL.md
cd ~/Projects/Havppen/havppen-pm-skills && git add skills/pm-link-task/SKILL.md && git commit -m "..." && git push
```
