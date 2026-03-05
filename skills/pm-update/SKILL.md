---
name: pm-update
description: "Sync the latest PM skills from the havppen-pm-skills repo. Use this when the user says /pm-update, '更新 skill', '同步 PM skill', or wants to pull the latest skill changes from the team."
allowed-tools: Bash
---

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
