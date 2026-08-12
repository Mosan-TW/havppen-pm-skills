---
name: pm-task-create
description: "Quick task creation in Notion from conversation context. Use this when the user says /pm-task-create, '幫我開一張 task', '記一下這件事', '開卡', or describes something that needs to be tracked as a task without full project setup."
model: haiku
allowed-tools: mcp__plugin_Notion_notion__notion-fetch, mcp__plugin_Notion_notion__notion-create-pages, mcp__plugin_Notion_notion__notion-update-page, mcp__plugin_Notion_notion__notion-search, mcp__plugin_Notion_notion__notion-get-users, mcp__claude_ai_Notion__notion-fetch, mcp__claude_ai_Notion__notion-create-pages, mcp__claude_ai_Notion__notion-update-page, mcp__claude_ai_Notion__notion-search, Bash
---

> **Notion MCP Fallback**: MCP 回 500 時，讀 `shared/notion-api-fallback.md` 切換到 Bash + REST API。

## Notion Structure

⚠️ REST API 一律用【倉庫】DB ID；`collection://` 是 MCP view，REST 呼叫會 404。

| DB | MCP collection:// | REST Database ID（倉庫） |
|----|-------------------|-------------------------|
| Tasks | — | `2d9268e74af88074ae62ddfa3090f7a1` |
| Stories | `collection://2d9268e7-4af8-8166-8238-000bd8445fdb`（⚠️ 未共享） | `2d9268e74af88105a52ff323aed1cfcb` |
| Bug | `collection://2e8268e7-4af8-80a5-ad02-000b7bce538d` | `2e8268e74af880a5ad02000b7bce538d` |
| Sprint | `collection://2d9268e7-4af8-80ac-83b2-000b6dcef569` | `2d9268e74af880ac83b2000b6dcef569` |

完整對照：`shared/notion-api-fallback.md`。如 REST 404，先確認 ID 來源是【倉庫】不是 view。

## Story Task 建立 SOP（必讀：一個 Story 必建 5 張卡）

若 context 是「幫這個 Story 建 task」或「story task」類的指示，**必須建立以下 5 張卡，缺一不可**：

> ⚠️ **卡片命名規則（Notion 自動化）**：Task link Story 後，自動化會把名稱改為 `Story名 - {卡名}`；link Bug 則改為 `{Bug名} - {卡名}`。因此卡名**只寫階段 / 動作本身**，不要重複 Story / Bug 名、不要加 `[階段]` 前綴，否則名稱重複。只有**未 link Story/Bug 的臨時卡**才寫完整描述。

> 2026-08-12 起「人工測試」拆兩張卡（QA 執行一張、開發者自測一張），**body 內容完全相同**，只差卡名後綴與執行者。

| 卡片名稱 | 所屬階段 | 點數 | 特殊欄位要求 |
|------|----------|------|-------------|
| `開發` | 開發 | 問用戶（只問開發點數） | — |
| `人工測試 (QA)` | 人工測試 | 不壓（空白） | 執行者=QA；**必貼白話 checklist**（不能貼 URL） |
| `人工測試 (開發者)` | 人工測試 | 不壓（空白） | 執行者=本次開發者；body 與 `人工測試 (QA)` 逐字相同 |
| `更版` | 更版 | 1 | **必填 Git Branch**（從 meta.yaml 或 worktree 查）|
| `驗收` | 驗收 | 不壓（空白） | **必貼驗收 checklist**（與兩張人工測試卡內容相同） |

### 建立流程

1. **先問**：優先級（臨時 / 高 / 中 / 低）　※🚫 模組已廢除（2026-07-14），不要問、不要填
2. **不要問點數**（除了開發卡）：更版固定 1，人工測試 (QA)／人工測試 (開發者)／驗收不壓
3. **逐一建立 5 張卡**：確認後一次性建立，不要只建一張
4. **建完更版卡後立刻填 Git Branch**（Step 4.5 之前）
5. **建完人工測試 (QA)／人工測試 (開發者)／驗收卡後必貼白話 checklist**（Step 4.5）：
   - 從 `features/<slug>/qa-gherkin.md` 或 `fixes/<slug>/qa-gherkin.md` 起草（如為 Gherkin 來源，先轉譯成 checklist 格式再貼）
   - 直接貼內容到 block body，**不要貼 GitHub URL**（QA 無法存取）
   - 格式：見下方 Step 4.5b

### 確認預覽格式（Story Task 版）

```
Story Task 建立計畫：
  Story：<Story 名稱>
  優先級：高
  執行者：Wayne
  Sprint：Sprint XX

  5 張卡（卡名只寫階段，Notion 自動化會補 Story名 前綴）：
  1. 開發 — 開發 / 點數：5
  2. 人工測試 (QA) — 人工測試 / 無點數 / 將貼 checklist / 執行者：QA
  3. 人工測試 (開發者) — 人工測試 / 無點數 / 內容與上一張相同 / 執行者：開發者本人
  4. 更版 — 更版 / 點數：1 / Git Branch：feat/xxx
  5. 驗收 — 驗收 / 無點數 / 內容與人工測試相同

確認後建立？
```

---

## Your task

Create one or more Notion Tasks quickly from conversation context.

**Step 1: Extract from context**

From what the user described, determine:
- **Task name(s)** — action-oriented；**有 link Story/Bug 時只寫動作本身**（如 `調查`、`修復`、`前端修復`，自動化會補前綴）；未 link 的臨時卡才寫完整描述（如 `調查 kingway 金流商憑證`）
- **Priority** (優先級🖍️) — 臨時 / 高 / 中 / 低 (default: 中)
- **Stage** (所屬階段🖍️) — 未開始 / 前期規劃 / 開發 / 人工測試 / 更版 / 驗收 / 緊急修復 / 緊急更版 (default: 前期規劃)
- **Status** (狀態🖍️) — 即將進行 / 進行中 / 已完成 (default: 即將進行)
- **Assignee** (執行者們🖍️) — ask if not clear from context; use `notion-search` with `query_type: "user"` to resolve name to user ID
- **Points** (點數🖍️) — 1 / 2 / 3 / 5 / 8 / 13 / 21 — ask if not clear
- **Sprint** (Sprint🖍️) — auto-detect current sprint from Sprint DB
- **Story or Bug link** — if context mentions one, search and link it
- **Completion date** (完成日期🖍️) — if status is 已完成, ask or infer

**Step 2: Auto-resolve references**

Before confirming, resolve these automatically (in parallel):
1. **Sprint**: Search Sprint DB for the sprint whose date range covers today (or the relevant date)
2. **Story/Bug**: Search if context mentions a related story or bug
3. **Assignee**: If name is mentioned, search for the Notion user ID
4. **Git Branch**（所屬階段 = 更版 或 緊急更版 時必填）: 自動查找 feature branch
   - 先從對話 context 找 branch name
   - 找不到則查 worktree：`git -C ~/Projects/Havppen/havppen/newscms worktree list` 和 `git -C ~/Projects/Havppen/havppen/havppen-api-v1 worktree list`
   - 仍找不到則查最近有改動的遠端 branch：`git -C <repo> branch -r --sort=-committerdate | head -20`
   - 都找不到就自行根據 feature/fix slug 命名，不要問用戶

**Step 3: Confirm before creating**

Show a compact preview with ALL fields:
```
建立 Task：
  名稱：調查（已 link Bug，自動化會補「{Bug名} - 」前綴）
  優先級：臨時
  階段：前期規劃
  狀態：進行中
  執行者：Wayne
  點數：3
  Sprint：Sprint 10 (2026-03-09)
  Bug：[kingway] 金流通知持續噴 403
  完成日期：—
```

If any field is unknown or ambiguous, ask the user.
If the user has already confirmed in context, skip confirmation.

**Step 4: Create the task**

Create the Task in Notion with all resolved fields.

**Step 4.5a: 更版卡必須補正式站 PR 連結（BLOCKING）**

如果所屬階段是「更版」或「緊急更版」，建立完 Task 後必須立即：

1. 從 `features/<slug>/meta.yaml` 或 `fixes/<slug>/meta.yaml` 讀取 `repos` 清單（slug 從 context 或 Git Branch 推斷）
2. 對每個 repo + branch，執行：
   ```bash
   # newscms（前端）
   gh pr list --repo Mosan-TW/newscms --head <branch> --base master --json number,title,url
   # havppen-api-v1（後端）
   gh pr list --repo Mosan-TW/havppen-api-v1 --head <branch> --base main --json number,title,url
   ```
3. 把找到的 PR 以 **paragraph block** 寫入更版卡內容：
   ```
   PATCH /v1/blocks/{task_id}/children
   blocks: [
     { type: "paragraph", paragraph: { rich_text: [
       { type: "text", text: { content: "前端 PR: " } },
       { type: "text", text: { content: "#NNN 標題", link: { url: "https://github.com/..." } } }
     ] } },
     ...
   ]
   ```
4. 若某 repo 找不到 PR，跳過（不報錯）；若完全找不到任何 PR，在卡片內寫「尚無正式站 PR」
5. meta.yaml 不存在時，只查當前 context 已知的 branch / repo

**不可跳過此步驟。**

---

**Step 4.5c: 建立 Bug 卡時，回報時間必須含時間（BLOCKING）**

若 context 需要同時建立 Bug 卡（Notion Bug DB），`回報時間` 必須使用 **datetime** 格式，不能只填日期：

```
"date:回報時間:start": "2026-06-16T17:30:00+08:00",   ✅
"date:回報時間:is_datetime": 1                          ✅

"date:回報時間:start": "2026-06-16"                    ❌ 時間丟失
```

若當下時間未知，執行 `date '+%Y-%m-%dT%H:%M:%S+08:00'` 取得當下 datetime。

---

**Step 4.5b: 人工測試 (QA) / 人工測試 (開發者) / 驗收 卡必須補白話 checklist（BLOCKING — 不可在卡片建好後才想到）**

⚠️ **執行順序**：在 Step 4 建卡之前，先根據 context **主動起草測試情境**，再建卡、再貼入。不是「建完再找」。

如果最終建出的卡中有「人工測試 (QA)」「人工測試 (開發者)」或「驗收」，**每張卡都必須有內容**，缺一不可：

1. **主動產出測試情境**（不等用戶要求）：
   - 優先讀 `features/<slug>/qa-gherkin.md` 或 `fixes/<slug>/qa-gherkin.md`（若是 Gherkin 格式，轉譯成下方 checklist 格式，不直接貼 Gherkin 原文）
   - 若無現成檔案，根據功能/修復描述自行起草，至少包含：
     - Regression scenario（驗證問題已修復 / 功能正常）
     - Boundary scenario（邊界值）
     - Side-effect scenario（相關功能沒壞）
   - 無法起草才問用戶，但必須先嘗試

2. **body 格式：白話 checklist**（不是 Gherkin code block）。每個測試情境依序寫成：
   - `heading_3` — 情境標題（含編號，如「1. xxx」）
   - `callout`（emoji ℹ️）— 前置條件
   - 一串 `to_do`（`checked: false`）— 操作/確認步驟，文字以「操作：」「確認：」開頭，交錯排列
   - 情境之間插入 `divider`

   ```
   PATCH /v1/blocks/{task_id}/children
   blocks: [
     { type: "heading_3", heading_3: { rich_text: [{ text: { content: "1. xxx" } }] } },
     { type: "callout", callout: { rich_text: [{ text: { content: "前置條件：..." } }], icon: { type: "emoji", emoji: "ℹ️" } } },
     { type: "to_do", to_do: { rich_text: [{ text: { content: "操作：..." } }], checked: false } },
     { type: "to_do", to_do: { rich_text: [{ text: { content: "確認：..." } }], checked: false } },
     { type: "divider", divider: {} },
     ...
   ]
   ```
3. 不可用純 paragraph 或 Gherkin code block 取代上述結構
4. 人工測試 (QA)／人工測試 (開發者)／驗收 三張卡內容必須逐字相同

**人工測試 (QA) / 人工測試 (開發者) / 驗收卡 body 空白 = 此步驟未完成，不算建卡完成。**

**Step 5: Post-creation validation**

After creating, fetch the created task and check these required fields:

| 欄位 | 必填條件 |
|------|----------|
| 名稱🖍️ | 永遠必填 |
| 優先級🖍️ | 永遠必填 |
| 所屬階段🖍️ | 永遠必填 |
| 狀態🖍️ | 永遠必填 |
| 執行者們🖍️ | 永遠必填 |
| 點數🖍️ | 永遠必填 |
| Sprint🖍️ | 永遠必填 |
| ~~模組🖍️~~ | 🚫 已廢除（2026-07-14），不填 |
| Story🖍️ 或 Bug🖍️ | 至少填一個（臨時事項可例外） |
| 完成日期🖍️ | 狀態 = 已完成 時必填 |
| Git Branch🖍️ | 所屬階段 = 更版 或 緊急更版 時必填 |

If any required field is empty:
1. List the missing fields
2. Ask user for the values
3. Update the task with the missing values
4. Re-fetch and verify all fields are filled

Return the task URL when done.

## Naming conventions

**有 link Story/Bug 的卡**：只寫動作 / 階段本身（自動化會補 `Story名 - ` 或 `{Bug名} - ` 前綴）：

| Type | 卡名 |
|------|------|
| 調查/排查 | `調查` |
| 後端修復 | `後端修復` |
| 前端修復 | `前端修復` |
| 長期改善 | `長期改善` |
| 文件 | `文件` |
| 測試 | `測試` |
| Bug 緊急修復 | `緊急修復` |
| Bug 緊急更版 | `緊急更版` |

**未 link Story/Bug 的臨時卡**：寫完整描述（如 `調查 kingway 金流商憑證`），否則卡名無 context。

## Priority guide

| 優先級 | 時機 |
|--------|------|
| 臨時 | 今天或本週內必須處理的急件 |
| 高 | 重要但不緊急，本 sprint 內處理 |
| 中 | 一般需求 |
| 低 | 有空時進行 |

## Points guide (Fibonacci)

| 點數 | 大小 |
|------|------|
| 1 | 半小時內完成（更版、簡單配置） |
| 2 | 1-2 小時 |
| 3 | 半天 |
| 5 | 一天 |
| 8 | 2-3 天 |
| 13 | 一週 |
| 21 | 超過一週（建議拆分） |
