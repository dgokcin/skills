# Skills

My agent skills. They follow the [Agent Skills](https://agentskills.io) standard, so they work in Claude Code, Codex, Cursor, and anything else that reads `SKILL.md`.

## Install

```bash
npx skills@latest add dgokcin/skills
```

The [`skills` CLI](https://github.com/vercel-labs/skills) lets you pick the skills and agents you want. Add `-g` to install for your user instead of the current project.

My own laptop installs them through [dotfiles](https://github.com/dgokcin/dotfiles) with `make skills`. That runs the same picker, then links each skill back into a clone of this repo so edits apply live.

## Private config

Some skills need values that don't belong in a public repo, like Jira IDs, cluster contexts, Slack IDs, and GitLab hosts. Skills read them from `~/.config/dgokcin-skills/`. Copy [`local.example/`](local.example/) there and fill in your own values:

```bash
cp -R local.example ~/.config/dgokcin-skills
```

## Skills

| Bucket | Skill | Invocation |
|--------|-------|------------|
| personal | `auto-commit`, `create-pr`, `git-conventions`, `worktree-cleanup` | model |
| personal | `address-review` | user |
| personal | `slackify`, `vault-capture`, `save-property-to-vault` | model |
| work | `create-story`, `get-story`, `log-work`, `k8s-debug`, `aws-debug` | model |
| work | `daily-recap` | user |

Retired skills sit in `skills/archived/`. The `skills` CLI hides them.

See [`docs/invocation.md`](docs/invocation.md) for what user- and model-invoked mean.
