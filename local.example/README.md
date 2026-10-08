# local.example

Templates for private config. Copy this dir to `local/` (gitignored) and fill in real values:

```bash
cp -R local.example local
```

`scripts/link-skills.sh` links `local/` to `~/.config/dgokcin-skills`, which is the path skills read from.

| File | Used by |
|------|---------|
| `jira.md` | create-story, get-story, log-work |
| `clusters.json` | k8s-debug |
| `gitlab-hosts` | create-pr, address-review, worktree-cleanup |
| `daily-recap.md` | daily-recap |
| `house-search.md` | save-property-to-vault, steve-square-meter |
