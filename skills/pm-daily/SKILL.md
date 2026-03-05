---
name: pm-daily
description: "Generate the daily Slack standup report from Notion tasks. Use this when the user says /pm-daily, '產生今日報表', '幫我寫今天的 slack', '今天的執行項目', or wants to prepare the daily progress update for Slack."
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-update-data-source
---

## Notion Structure

Hierarchy: **Epic → Story → Task** (+ 階段時程 parallel to Task)

Key databases:
- Tasks: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Stories: `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`
- Modules (模組): `collection://2e8268e7-4af8-803d-bb1b-000bbc327576`
- Sprints: `collection://2d9268e7-4af8-80ac-83b2-000b6dcef569`

Sprint is weekly. `相對 Sprint = 當期` = this week's sprint.

## Slack Format

```
MM/DD
今日執行

【模組名稱】Story名稱 - Task名稱

昨日完成

【模組名稱】Story名稱 - Task名稱

未完成

【模組名稱】Story名稱 - Task名稱
```

**Field mapping per line:**
- `【模組名稱】` → `模組🖍️` relation → fetch module page title
- `Story名稱` → `Story🖍️` relation → fetch story page title
- `Task名稱` → `名稱🖍️` (may already include stage prefix like `【開發】xxx`)

If Story is empty, format as: `【模組名稱】 - Task名稱`

## Task Fields

```
名稱🖍️        — task title
狀態🖍️        — 暫停 / 有空時進行 / 即將進行 / 進行中 / 已完成
所屬階段🖍️    — 未開始 / 前期規劃 / 後期規劃 / 開發 / 人工測試 / 更版 / 驗收
完成日期🖍️    — completion date
Sprint🖍️      — linked sprint
相對 Sprint   — formula: 當期 / 上期 / 下期 / 上上期 / 下下期
執行者們🖍️   — assignees
模組🖍️        — module relation
Story🖍️       — story relation
```

## Querying Strategy

**Step 1: Fetch current sprint tasks assigned to me**
- Filter: `相對 Sprint = 當期` AND `執行者們🖍️` includes current user
- Use `notion-fetch` on the Tasks database or `notion-update-data-source` to query

**Step 2: Categorize into 3 buckets**

| Section | Filter | Reliability |
|---------|--------|-------------|
| 昨日完成 | `狀態🖍️ = 已完成` AND `完成日期🖍️ = yesterday` | ✅ 100% auto — 切完成 ✅ button auto-fills date |
| 今日執行 | `狀態🖍️ = 進行中` (current sprint, assigned to me) | ✅ auto |
| 未完成 | `狀態🖍️ = 進行中` AND `建立時間 < today` — show these as candidates | ⚠️ needs user confirmation |

**For 未完成**: Present the candidate list to the user and ask:
> 「這些是昨天規劃但沒完成的嗎？請確認或調整：」
> - [task A]
> - [task B]

Let the user confirm or remove items before including them in the final draft.

**Step 3: Resolve relations**
For each task, fetch:
- `模組🖍️` page → get title for 【模組名稱】
- `Story🖍️` page → get title for Story名稱

Batch these fetches where possible to avoid too many API calls.

**Step 4: Format and output**

Output the final draft in a code block for easy copy-paste:

```
03/05
今日執行

【模組A】Story名稱 - Task名稱
【模組B】Story名稱 - Task名稱

昨日完成

【模組C】Story名稱 - Task名稱

未完成

（請手動填入）
```

Then ask: "這個草稿準確嗎？有需要調整的地方嗎？"

## Notes

- Wayne is PM + Tech Lead, not just engineer — tasks may include planning/review items
- Tasks and HPC features are currently independent systems; do not try to cross-reference
- Keep task names as-is from Notion — don't paraphrase or summarize
- If `完成日期🖍️` is not filled in (user doesn't consistently log it), use `建立時間` or `狀態` change heuristics to guess 昨日完成


---

## Maintenance

This skill is managed in the `havppen-pm-skills` repo (`~/Projects/Havppen/havppen-pm-skills`).
After editing `~/.claude/skills/pm-daily/SKILL.md`, sync back:

```bash
cp ~/.claude/skills/pm-daily/SKILL.md ~/Projects/Havppen/havppen-pm-skills/skills/pm-daily/SKILL.md
cd ~/Projects/Havppen/havppen-pm-skills && git add skills/pm-daily/SKILL.md && git commit -m "..." && git push
```