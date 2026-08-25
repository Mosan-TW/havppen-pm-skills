> ## ⚠️ 此 repo 已於 2026-08-25 廢棄（DEPRECATED）
>
> 唯一來源改為 **`havppen-spec/.claude/skills/pm-*/SKILL.md`**。
>
> 廢棄原因：實際上只有 WenHong 一人使用，靠手動 `cp` 同步的雙份機制長期漂移
> （廢棄當下 12 支中有 8 支不同步、1 支從未推送）。維持兩份的成本高於價值。
>
> **不要再從這裡安裝或編輯**。此 repo 內容停留在 2026-08-12，已過期。
> 若未來團隊真的要共用，重開一個以 spec repo 為 upstream 的自動同步機制，不要復活 `install.sh`。

# Havppen PM Skills

給 Havppen 團隊用的 Claude Code Skills，涵蓋 PM、開發者、QA 的日常工作流程，整合 Notion 與 Sentry。

## Skills 一覽

### PM 日常

| Skill | 說明 | 觸發方式 |
|-------|------|---------|
| `/pm-standup` | Standup 教練 — 分析會議筆記，推薦今天的 focus | 貼 standup 筆記 |
| `/pm-daily` | 產生每日 Slack 進度報表 | 「幫我寫今天的 Slack 報表」 |
| `/pm-retrospective` | Sprint 回顧 — 盤點完成/未完成、識別模式、產出改善建議 | 「上週做了什麼 / sprint 回顧」 |

### 專案管理

| Skill | 說明 | 觸發方式 |
|-------|------|---------|
| `/pm-project-setup` | 規劃完後建立 Story → 階段時程 → Tasks | 「規劃完了，幫我建 Notion 卡」 |
| `/pm-task-create` | 從對話快速開 Task，不需要完整 Story | 「幫我開一張 task / 開卡」 |
| `/pm-link-task` | 找到對應的 Story 並連結 Task | 「這個 task 要掛在哪個 story」 |

### Bug 追蹤

| Skill | 說明 | 觸發方式 |
|-------|------|---------|
| `/pm-bug` | 回報 Bug，建立追蹤 Task | 「有個 bug 要記錄」 |
| `/pm-sentry` | 從 Sentry Issue URL 自動建 Bug + 調查 Task | 貼 sentry.io 連結 |

### 測試

| Skill | 說明 | 使用對象 |
|-------|------|---------|
| `/pm-qa` | 從功能描述產生測試場景（單點行為 + 完整使用者流程），輸出 Gherkin 格式 | QA |

### 維護

| Skill | 說明 |
|-------|------|
| `/pm-update` | 同步最新 skills（從此 repo pull + 安裝）|

---

## 安裝

### 前置需求

- [Claude Code](https://claude.ai/code) 已安裝
- Claude Code 已啟用以下 MCP 插件：
  - **Notion MCP**（所有 pm-* skills 必須）
  - **Sentry MCP**（`/pm-sentry` 需要）
- 已加入 Havppen 的 Notion workspace

### 安裝步驟

```bash
git clone https://github.com/Mosan-TW/havppen-pm-skills.git ~/Projects/Havppen/havppen-pm-skills
cd ~/Projects/Havppen/havppen-pm-skills
chmod +x install.sh
./install.sh
```

安裝完成後，**重啟 Claude Code** 即可使用。

### 更新

```bash
cd ~/Projects/Havppen/havppen-pm-skills
git pull
./install.sh
```

或在 Claude Code 對話中輸入 `/pm-update`。

---

## 使用方式

安裝後，在任意 Claude Code 對話中直接輸入指令，或用自然語言觸發：

- 「把 standup 筆記貼給我看看」→ `/pm-standup`
- 「這個功能要怎麼測？」→ `/pm-qa`
- 「幫我把這個 Sentry 錯誤開成 bug」→ `/pm-sentry`
- 「上週做了什麼？」→ `/pm-retrospective`
- 「幫我開一張 task」→ `/pm-task-create`
- 「規劃完了，幫我建 Notion 卡」→ `/pm-project-setup`
