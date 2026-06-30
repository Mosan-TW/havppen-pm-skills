---
name: pm-weekly
description: "Generate weekly progress summary from Notion Sprint tasks. Supports personal mode (my tasks) and team mode (all members). Use this when the user says /pm-weekly, '上週進度', '我的週報', '週報', 'weekly summary', or wants to review last week's completed work. Add 'team' or '團隊' for team mode."
model: haiku
allowed-tools: mcp__claude_ai_Notion__notion-fetch, mcp__claude_ai_Notion__notion-search, Agent
---

<!-- HAIKU-DELEGATE-MARKER -->
> **執行模型：Haiku（省用量）**
> 本 skill 為機械型流程（Notion CRUD + 格式化），不需深推理。
> 若你目前**不是** Haiku，請改用 Agent tool 派一個 `model: haiku` 的 sub-agent，
> prompt 指示它「呼叫本 skill 並完成全部步驟」，主 session 不要親自跑。
> 例外：流程中出現需判斷／取捨的 edge case，sub-agent 應回報主 session 交高階模型決定。

## Notion Structure

- Tasks DB: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Sprint DB: `collection://2d9268e7-4af8-80ac-83b2-000b6dcef569`
- Stories DB: `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`
- Modules DB: `collection://2e8268e7-4af8-803d-bb1b-000bbc327576`

## Team Member IDs

```
Wayne Huang:  e0aef6a9-3930-4c00-ac50-a7340ef57b19
Andrash Yang: 1ced872b-594c-8165-9f62-00022ecba6e2
Vince Guo:    173d872b-594c-81d9-8c13-0002c4f42057
```

## Mode Detection

| Trigger | Mode |
|---------|------|
| `/pm-weekly`, `上週進度`, `我的週報` | personal (Wayne only) |
| `/pm-weekly team`, `團隊週報`, `整個團隊上週` | team (all members) |

Default sprint: **上期**（last week）. User can specify otherwise.

## Workflow

### Step 1: Find Target Sprint

Fetch Sprint DB, find the sprint matching the target week by `日期區間🖍️`.

- Fetch: `notion-fetch` on Sprint DB `2d9268e74af880fab9ffc778b91c310a`
- Identify sprint by date range (e.g. `date:日期區間🖍️:start` / `end`)
- Extract the sprint page to get the `Tasks` relation list (all task URLs)

### Step 2: Batch Fetch All Tasks

Sprint typically has 60-80 tasks. **MUST use parallel agents** to fetch efficiently.

Strategy:
1. Split task URLs into batches of 12-15
2. Launch 4-5 parallel agents (model: haiku) to fetch each batch
3. Each agent fetches pages via `notion-fetch` and extracts:
   - `名稱🖍️` (title)
   - `狀態🖍️` (status)
   - `所屬階段🖍️` (phase)
   - `執行者們🖍️` (executor user IDs)
   - `date:完成日期🖍️:start` (completion date)
   - `點數🖍️` (points)
4. Agent returns structured result: `title | executor_id | status | date | points | phase`

**Agent prompt template:**
```
Fetch these Notion pages and for EACH one, report:
title | executor (match against team IDs: Wayne=e0aef6a9, Andrash=1ced872b, Vince=173d872b, or OTHER) | status | completion date (date:完成日期🖍️:start) | points (點數🖍️) | phase (所屬階段🖍️)

IDs: {batch of 12-15 IDs}

Return as a markdown table. Only include completed tasks (狀態🖍️ = 已完成) in detail. For non-completed tasks, just report the total count at the end.
```

### Step 3: Filter & Group

**Personal mode:** Keep only tasks where executor matches Wayne's ID.

**Team mode:** Group by executor (Wayne / Andrash / Vince / Other).

### Step 4: Categorize by Functional Area

Group tasks by business domain, NOT by phase. Merge related phases into one line.

**Merge rules:**
- Same bug/feature across phases (緊急修復 + 緊急更版 + 驗收) → one line, sum points
- Same feature (開發 + 更版) → one line, sum points
- Match by similar title keywords (strip phase prefix like `[開發]`, `[更版]`, `[驗收]`)

**Functional area detection** (by keywords in title or module):
- 兌換券 / 兌換 → 兌換券相關
- 課程 / 看課 / 觀看 → 課程相關
- 會員 / 登入 / 註冊 / 社群登入 → 會員相關
- 預約 → 預約相關
- 活動 → 活動相關
- 媒體 / 轉檔 / CDN / 圖片 → 媒體庫
- 報表 / 帳單 → 報表與帳單
- 前端架構 / V2 → 前端架構
- 後台 + 前期規劃 → 後台模組規劃
- Otherwise → 後台通用

### Step 5: Format Output

Use non-technical language. Bullet-point style. Concise.

**Personal mode:**
```markdown
## {name} — Sprint {n}（{date range}）｜{count} 項，{points} 點

- **{area}**：{task1}、{task2}、...（{sum}pt）
- **{area}**：{task1}（{sum}pt）
...
```

**Team mode:**
```markdown
## 團隊 — Sprint {n}（{date range}）｜{count} 項，{points} 點

### {name}｜{count} 項，{points} 點
- **{area}**：{task1}、{task2}（{sum}pt）
...

### {name}｜{count} 項，{points} 點
- ...
```

### Step 6: Write to Meeting Record (Optional)

After presenting the summary, ask:
> "要把這份週報寫進本週會議記錄嗎？"

If yes:
1. Find this week's meeting record in 每週會議記錄 DB (`2ed268e74af88001a6a3e0fbd657e42f`)
2. Search for the page with this week's date
3. Update the page content under the appropriate section (e.g. Wayne / Andrash / Vince)

## Language Rules

- Use non-technical terms (e.g. "預約完成後列表未顯示修復" not "未建立 AppointmentSessionMember")
- Merge technical phase names into plain descriptions (e.g. "修復與上線" not "緊急修復 + 緊急更版")
- Keep task descriptions short — one phrase per item
- Don't include Notion URLs in output

## Notes

- Notion search API does NOT support filtering by person property — must fetch individually then filter in code
- Sprint task count is typically 60-80, budget for 4-5 parallel agent batches
- Points without value (formula-only or missing) → show as "-"
- QA/validation tasks (executor outside team) → group under "驗收" section in team mode
- If a task appears in multiple batches (duplicate), deduplicate by title

---

## Maintenance

This skill is managed in the `havppen-pm-skills` repo (`~/Projects/Havppen/havppen-pm-skills`).
After editing, sync back:

```bash
cp .claude/skills/pm-weekly/SKILL.md ~/Projects/Havppen/havppen-pm-skills/skills/pm-weekly/SKILL.md
cd ~/Projects/Havppen/havppen-pm-skills && git add skills/pm-weekly/SKILL.md && git commit -m "feat: add pm-weekly skill" && git push
```
