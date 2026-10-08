# Maintaining this repo

- Skills live in `skills/<bucket>/<name>/`. `personal` holds general-purpose skills, `work` holds Treatwell-specific ones, and `archived` holds retired ones. A new bucket also needs an entry in `.claude-plugin/plugin.json` `skills`.
- To retire a skill, move it to `skills/archived/` and add `metadata.internal: true` to its frontmatter. Archived skills are never linked, linted, or shipped in the plugin, and `npx skills` hides them.
- Every skill has `agents/openai.yaml` next to `SKILL.md`. Run `scripts/skill-meta.sh --scaffold` for new skills, then `scripts/skill-meta.sh` to lint. Rules are in `docs/invocation.md`.
- A skill only reads files inside its own folder (`${CLAUDE_SKILL_DIR}/...`) or private config under `~/.config/dgokcin-skills/`. To reuse another skill's content, call the Skill tool with it, never `../other-skill/`.
- Never commit private values (Jira IDs, cluster names, Slack IDs, internal hosts, personal finances). Put them in `local/` (gitignored) and add a placeholder version to `local.example/`.
- Run `claude plugin validate . --strict` after touching `.claude-plugin/`.
