# local.example

Templates for private config. Skills read the real values from `~/.config/dgokcin-skills/`. Copy this dir there and fill them in:

```bash
cp -R local.example ~/.config/dgokcin-skills
```

On my laptop, dotfiles' `make skills` seeds the gitignored `local/` dir from this one and links it to `~/.config/dgokcin-skills`.

| File | Used by |
|------|---------|
| `jira.md` | create-story, get-story, log-work |
| `clusters.json` | k8s-debug |
| `gitlab-hosts` | create-pr, address-review, worktree-cleanup |
| `daily-recap.md` | daily-recap |
| `house-search.md` | save-property-to-vault, plus the steve-square-meter agent in dotfiles |
