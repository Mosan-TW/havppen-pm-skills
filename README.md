# Havppen PM Skills

Claude Code skills for Havppen's PM workflow — daily reports, standup coaching, project setup, and bug tracking. Built on top of Notion.

## Skills

| Skill | Description |
|-------|-------------|
| `/pm-daily` | Generate daily Slack standup report from Notion tasks |
| `/pm-standup` | Standup coach — analyze meeting notes against task states, recommend today's focus |
| `/pm-project-setup` | After planning: create Story → 階段時程 → Tasks in Notion |
| `/pm-bug` | Report a bug and create tracking tasks |
| `/pm-link-task` | Find the right Story for a Task and link them |

## Requirements

- [Claude Code](https://claude.ai/code) installed
- [Notion MCP plugin](https://claude.ai/code/plugins) enabled in Claude Code
- Access to Havppen's Notion workspace

## Installation

```bash
git clone https://github.com/havppen/havppen-pm-skills.git
cd havppen-pm-skills
chmod +x install.sh
./install.sh
```

Then **restart Claude Code**.

## Update

```bash
cd havppen-pm-skills
git pull
./install.sh
```

## Usage

After installation, use the skills in any Claude Code session:

```
/pm-daily
/pm-standup
/pm-project-setup
/pm-bug
/pm-link-task
```

You can also trigger them naturally:
- "幫我寫今天的 Slack 報表" → `/pm-daily`
- "貼 standup 筆記 ..." → `/pm-standup`
- "規劃完了，幫我建 Notion 卡" → `/pm-project-setup`
- "有個 bug 要記錄" → `/pm-bug`
- "這個 task 要掛在哪個 story" → `/pm-link-task`
