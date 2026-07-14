---
name: pm-daily
description: "Generate the daily Slack standup report from Notion tasks. Use this when the user says /pm-daily, '產生今日報表', '幫我寫今天的 slack', '今天的執行項目', or wants to prepare the daily progress update for Slack."
model: haiku
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-update-data-source, Bash
---

<!-- HAIKU-DELEGATE-MARKER -->
> **執行模型：Haiku（省用量）**
> 本 skill 為機械型流程（Notion CRUD + 格式化），不需深推理。
> 若你目前**不是** Haiku，請改用 Agent tool 派一個 `model: haiku` 的 sub-agent，
> prompt 指示它「呼叫本 skill 並完成全部步驟」，主 session 不要親自跑。
> 例外：流程中出現需判斷／取捨的 edge case，sub-agent 應回報主 session 交高階模型決定。

> **Notion MCP Fallback**: MCP 回 500 時，讀 `shared/notion-api-fallback.md` 切換到 Bash + REST API。

## Notion Structure

Hierarchy: **Group（選填，僅多階段 feature）→ Story → Task** (+ 階段時程 parallel to Task)

Key databases:
- Tasks: `2d9268e74af88074ae62ddfa3090f7a1` (REST DB id；不可用 collection:// view UUID 餵 REST API，會 404)
- Stories: `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`
- Sprints: `collection://2d9268e7-4af8-80ac-83b2-000b6dcef569`

> 🚫 **模組已廢除（2026-07-14）**：不再讀 `模組🖍️`、不再輸出【模組名稱】。舊卡可能仍有模組資料，一律忽略。

Sprint is weekly. `相對 Sprint = 當期` = this week's sprint.

## Slack Format

```
MM/DD
今日執行

Story名稱 - Task名稱

昨日完成

Story名稱 - Task名稱

未完成

Story名稱 - Task名稱
```

**Field mapping per line:**
- `Story名稱` → `Story🖍️` relation → fetch story page title
- `Task名稱` → `名稱🖍️` (may already include stage prefix like `【開發】xxx`)

If Story is empty, format as: `Task名稱`（不留空的 ` - ` 破折號）

## Task Fields

```
名稱🖍️        — task title
狀態🖍️        — 暫停 / 有空時進行 / 即將進行 / 進行中 / 已完成
所屬階段🖍️    — 未開始 / 前期規劃 / 後期規劃 / 開發 / 人工測試 / 更版 / 驗收
完成日期🖍️    — completion date
Sprint🖍️      — linked sprint
相對 Sprint   — formula: 當期 / 上期 / 下期 / 上上期 / 下下期
執行者們🖍️   — assignees
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
- `Story🖍️` page → get title for Story名稱

Batch these fetches where possible to avoid too many API calls.

**Step 4: Format and output**

Output the final draft in a code block for easy copy-paste:

```
03/05
今日執行

Story名稱 - Task名稱
Story名稱 - Task名稱

昨日完成

Story名稱 - Task名稱

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