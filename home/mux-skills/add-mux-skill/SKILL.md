---
name: add-mux-skill
description: Create and install local Mux skills into ~/.mux/skills.
---

# Add Mux Skill

Use this skill when the user asks you to add, install, or scaffold a Mux skill.

## Preferred workflow in this repo

1. Write new skills under `home/mux-skills/<skill-name>/SKILL.md`.
2. Let Home Manager sync the full directory to `~/.mux/skills/`.
3. Use `mux-skill-add` only when linking an external local directory.

## Install an existing local skill

1. Collect:
   - Skill name (example: `my-skill`)
   - Source directory path containing `SKILL.md`
2. Run:

```bash
mux-skill-add <skill-name> <source-dir>
```

3. Confirm it now exists at:

`~/.mux/skills/<skill-name>`

## Create a new skill, then install it

1. Create a folder for the new skill.
2. Add `SKILL.md` using this minimum template:

```markdown
---
name: <skill-name>
description: <short description>
---

# <Human-friendly skill title>

## When to use this skill
- <trigger 1>
- <trigger 2>

## Steps
1. <step 1>
2. <step 2>
```

3. Install it with:

```bash
mux-skill-add <skill-name> <source-dir>
```

## Notes
- `mux-skill-add` validates that `SKILL.md` exists.
- Re-running the command updates the symlink to the latest source directory.
