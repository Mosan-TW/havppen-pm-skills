---
name: pm-update
description: "Sync the latest PM skills from the havppen-pm-skills repo. Use this when the user says /pm-update, '更新 skill', '同步 PM skill', or wants to pull the latest skill changes from the team."
model: haiku
allowed-tools: Bash
---

<!-- HAIKU-DELEGATE-MARKER -->
> **執行模型：Haiku（省用量）**
> 本 skill 為機械型流程（Notion CRUD + 格式化），不需深推理。
> 若你目前**不是** Haiku，請改用 Agent tool 派一個 `model: haiku` 的 sub-agent，
> prompt 指示它「呼叫本 skill 並完成全部步驟」，主 session 不要親自跑。
> 例外：流程中出現需判斷／取捨的 edge case，sub-agent 應回報主 session 交高階模型決定。

## Your task

Sync the latest skills from the `havppen-pm-skills` repo to `~/.claude/skills/`.

**Step 1: Find the repo**

Check if the repo exists at `~/Projects/Havppen/havppen-pm-skills`.
If not found, tell the user to clone it first:
```bash
git clone https://github.com/Mosan-TW/havppen-pm-skills.git ~/Projects/Havppen/havppen-pm-skills
```

**Step 2: Pull latest**

```bash
cd ~/Projects/Havppen/havppen-pm-skills && git pull
```

Show the git output so the user knows what changed.

**Step 3: Run install**

```bash
cd ~/Projects/Havppen/havppen-pm-skills && ./install.sh
```

**Step 4: Report**

Tell the user:
- Which skills were updated (based on install.sh output)
- Remind them to **restart Claude Code** for changes to take effect

---

## Maintenance

This skill is managed in the `havppen-pm-skills` repo (`~/Projects/Havppen/havppen-pm-skills`).
After editing `~/.claude/skills/pm-update/SKILL.md`, sync back:

```bash
cp ~/.claude/skills/pm-update/SKILL.md ~/Projects/Havppen/havppen-pm-skills/skills/pm-update/SKILL.md
cd ~/Projects/Havppen/havppen-pm-skills && git add skills/pm-update/SKILL.md && git commit -m "..." && git push
```
