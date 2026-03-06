# Havppen PM Skills

Claude Code skills for Havppen's PM workflow — daily reports, standup coaching, project setup, bug tracking, and retrospectives. Built on top of Notion.

## Skills

| Skill | Description |
|-------|-------------|
| `/pm-daily` | Generate daily Slack standup report from Notion tasks |
| `/pm-standup` | Standup coach — analyze meeting notes against task states, recommend today's focus |
| `/pm-project-setup` | After planning: create Story → 階段時程 → Tasks in Notion |
| `/pm-bug` | Report a bug and create tracking tasks |
| `/pm-sentry` | Create a Bug + investigation Task directly from a Sentry issue URL |
| `/pm-task-create` | Quick Task creation from conversation context |
| `/pm-link-task` | Find the right Story for a Task and link them |
| `/pm-retrospective` | Sprint retrospective — review completed/incomplete tasks, identify patterns, suggest improvements |
| `/pm-qa` | QA 測試設計引導 — 從功能描述產生單點行為 + 完整使用者流程測試場景，輸出 Gherkin 格式 |

## Requirements

- [Claude Code](https://claude.ai/code) installed
- [Notion MCP plugin](https://claude.ai/code/plugins) enabled in Claude Code
- [Sentry MCP plugin](https://claude.ai/code/plugins) enabled (for `/pm-sentry`)
- Access to Havppen's Notion workspace

## Installation

```bash
git clone https://github.com/Mosan-TW/havppen-pm-skills.git ~/Projects/Havppen/havppen-pm-skills
cd ~/Projects/Havppen/havppen-pm-skills
chmod +x install.sh
./install.sh
```

Then **restart Claude Code**.

## Update

```bash
cd ~/Projects/Havppen/havppen-pm-skills
git pull
./install.sh
```

Or use the built-in skill: `/pm-update`

## Usage

After installation, use the skills in any Claude Code session:

```
/pm-daily
/pm-standup
/pm-project-setup
/pm-bug
/pm-sentry
/pm-task-create
/pm-link-task
/pm-retrospective
```

You can also trigger them naturally:

| Natural language | Skill |
|-----------------|-------|
| "幫我寫今天的 Slack 報表" | `/pm-daily` |
| "貼 standup 筆記 ..." | `/pm-standup` |
| "規劃完了，幫我建 Notion 卡" | `/pm-project-setup` |
| "有個 bug 要記錄" | `/pm-bug` |
| "幫我把這個 Sentry 錯誤開成 bug" | `/pm-sentry` |
| "幫我開一張 task" | `/pm-task-create` |
| "這個 task 要掛在哪個 story" | `/pm-link-task` |
| "上週做了什麼 / sprint 回顧" | `/pm-retrospective` |
