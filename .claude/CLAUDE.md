# Maintaining this repo

- This repo holds Agent Skills only, and stays harness-agnostic. Subagents, output styles, hooks, and installers live in dotfiles, which installs these skills with `make skills`.
- Skills live in `skills/<bucket>/<name>/`. `personal` holds general-purpose skills, `work` holds Treatwell-specific ones, and `archived` holds retired ones. The folder name must match the frontmatter `name`.
- To retire a skill, move it to `skills/archived/` and add `metadata.internal: true` to its frontmatter. Archived skills are never linted, and `npx skills` hides them.
- Every skill has `agents/openai.yaml` next to `SKILL.md`. Run `scripts/skill-meta.sh --scaffold` for new skills, then `scripts/skill-meta.sh` to lint. Rules are in `docs/invocation.md`.
- A skill only reads files inside its own folder (`${CLAUDE_SKILL_DIR}/...`) or private config under `~/.config/dgokcin-skills/`. To reuse another skill's content, call the Skill tool with it, never `../other-skill/`.
- Never commit private values (Jira IDs, cluster names, Slack IDs, internal hosts, personal finances). Put them in `local/` (gitignored) and add a placeholder version to `local.example/`.
- Check discovery with `npx skills@latest add . --list` after adding, renaming, or archiving a skill.
