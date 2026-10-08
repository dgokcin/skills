# Skills

My agent skills, subagents, and output styles. They follow the [Agent Skills](https://agentskills.io) standard, so they work in Claude Code, Codex, Cursor, and anything else that reads `SKILL.md`.

## Install

### Claude Code plugin

```bash
claude plugin marketplace add dgokcin/skills
claude plugin install dgokcin-skills@dgokcin
```

Plugin skills are namespaced, e.g. `/dgokcin-skills:create-pr`.

### Any agent, via skills.sh

```bash
npx skills@latest add dgokcin/skills
```

### Local dev (what I use)

```bash
git clone git@github.com:dgokcin/skills.git ~/codes/skills
~/codes/skills/scripts/link-skills.sh
```

This symlinks every skill into `~/.claude/skills` and `~/.agents/skills`, agents into `~/.claude/agents` and `~/.cursor/agents`, and output styles into `~/.claude/output-styles`. Skills keep their bare names (`/create-pr`), and edits apply live. `--unlink` removes the links.

## Private config

Some skills need values that don't belong in a public repo: Jira IDs, cluster contexts, Slack IDs, GitLab hosts. Skills read them from `~/.config/dgokcin-skills/`, which `link-skills.sh` points at the gitignored `local/` dir. On first run the script seeds `local/` from [`local.example/`](local.example/).

## Skills

| Bucket | Skill | Invocation |
|--------|-------|------------|
| personal | `auto-commit`, `create-pr`, `git-conventions`, `worktree-cleanup` | model |
| personal | `address-review` | user |
| personal | `slackify`, `vault-capture`, `save-property-to-vault` | model |
| work | `create-story`, `get-story`, `log-work`, `k8s-debug`, `aws-debug` | model |
| work | `daily-recap` | user |

Retired skills sit in `skills/archived/`. They aren't installed anywhere.

See [`docs/invocation.md`](docs/invocation.md) for what user- and model-invoked mean.

## Agents and output styles

- `agents/gitops-geezer.md`: ArgoCD and GitOps reviewer
- `agents/steve-square-meter.md`: funda.nl listing analyst
- `output-styles/declaude.md`, `output-styles/terse.md`
