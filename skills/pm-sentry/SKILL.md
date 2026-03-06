---
name: pm-sentry
description: "Create a Notion Bug report and investigation Task from a Sentry issue URL or ID. Use this when the user says /pm-sentry, pastes a sentry.io URL, mentions a Sentry issue ID like 'HAVPPEN-API-V1-Q7', or says '幫我把這個 Sentry 錯誤開成 bug'."
allowed-tools: mcp__sentry__get_issue_details, mcp__sentry__search_issue_events, mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-create-pages, mcp__plugin_Notion_notion__notion-get-users
---

## Notion Structure

- Bug DB: `collection://2e8268e7-4af8-80a5-ad02-000b7bce538d`
- Tasks DB: `collection://2d9268e7-4af8-8003-8d86-000b45718394`
- Modules: `collection://2e8268e7-4af8-803d-bb1b-000bbc327576`

## Your task

**Step 1: Fetch Sentry issue**

Use `mcp__sentry__get_issue_details` with the URL or issue ID provided.

Extract:
- `title` — error type and message
- `culprit` — where it happened
- `firstSeen` / `lastSeen` / `occurrences`
- Extra data: `appId`, `paymentNo`, or any domain-specific context
- Stack trace: identify first-party code frames (ignore node_modules)

**Step 2: Assess priority**

| Condition | Priority |
|-----------|----------|
| System-breaking, data loss, security | P0 |
| Core feature broken, affects many users, ongoing for <24h | P1 |
| Degraded experience, workaround exists, or long-running low-frequency | P2 |

Consider `occurrences`, `usersImpacted`, and whether it's `ongoing` vs `resolved`.

**Step 3: Diagnose root cause**

From the stack trace and extra data, provide a brief diagnosis:
- What triggered the error?
- Which service/module owns it?
- Any patterns (specific appId, specific endpoint)?

**Step 4: Create Bug in Notion**

Create a page in Bug DB with:
- `名稱🖍️` — concise title, include [appId] prefix if relevant: `[kingway] 金流通知持續噴 403`
- `等級🖍️` — P0 / P1 / P2
- `回報者🖍️` — current user

Page content (Markdown):
```
## 問題描述
{1-2 sentence summary}

- **Sentry Issue**: {issueId}
- **First Seen**: {firstSeen}
- **Last Seen**: {lastSeen}
- **Occurrences**: {count}
- **Extra context**: {appId, paymentNo, etc.}

## 發生流程
{stack trace or flow description}

## 可能原因
{bullet list of hypotheses}

## 待調查
- [ ] {investigation item 1}
- [ ] {investigation item 2}
```

**Step 5: Create investigation Task**

Create a Task linked to the Bug:
- `名稱🖍️` — `[調查] {bug title 簡短版}`
- `Bug🖍️` — link to just-created Bug
- `優先級🖍️` — 臨時 (for P0/P1) or 高 (for P2)
- `所屬階段🖍️` — 前期規劃
- `狀態🖍️` — 進行中

**Step 6: Return links**

Show Bug URL and Task URL.

## Tips

- If the stack trace only shows library frames (no first-party code), say so and suggest adding more context to Sentry (`captureException` with extra data)
- If `occurrences` is low but `usersImpacted` is high → bump priority up
- If issue has been open for months with low frequency → likely P2 unless a specific trigger was found
