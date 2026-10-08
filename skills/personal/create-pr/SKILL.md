---
name: create-pr
description: Create a GitHub PR or GitLab MR for the current branch, or for the branch of a repo at a given path. Use when the user asks to open, create, or raise a PR or MR, says "ship it" after committing, or wants the branch put up for review. Pass 'gh' or 'gl' to skip VCS detection, and a repo path to target a repo other than the session cwd.
argument-hint: "[gh|gl] [repo-path]"
context: fork
model: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(${CLAUDE_SKILL_DIR}/scripts/pr-status.sh *)
  - Bash(${CLAUDE_SKILL_DIR}/scripts/pr-push.sh *)
  - Bash(gh pr view *)
  - Bash(gh pr diff *)
  - Bash(gh pr create *)
  - Bash(gh pr edit *)
  - Bash(rtk gh pr view *)
  - Bash(rtk gh pr diff *)
  - Bash(rtk gh pr create *)
  - Bash(rtk gh pr edit *)
  - Bash(glab mr view *)
  - Bash(glab mr diff *)
  - Bash(glab mr create *)
  - Bash(glab mr update *)
  - Bash(rtk glab mr view *)
  - Bash(rtk glab mr diff *)
  - Bash(rtk glab mr create *)
  - Bash(rtk glab mr update *)
---

# Create Pull Request / Merge Request

> **Non-Claude tools:** if the context below still shows a raw bang-backtick
> block instead of command output, Claude's eager injection didn't run. Run
> `scripts/pr-status.sh <arguments>` yourself and use its output wherever the
> instructions say "injected".

## Configuration

Call the Skill tool with "git-conventions".

## Current Context

```!
${CLAUDE_SKILL_DIR}/scripts/pr-status.sh <<'CREATE_PR_ARGS'
$ARGUMENTS
CREATE_PR_ARGS
```

## Target Repo

- The context above comes from the repo at "Worktree root". When the user passed a repo path, that root is the path, not the session cwd. Trust it over anything the session cwd suggests.
- If the context shows `ERROR:`, stop and reply with that error. Do not retry against the session cwd or any other repo.
- The Bash tool cwd is not the target repo and `cd` does not stick, so never run plain `git` or `cd`. Every command names the repo explicitly:
  - Push: `${CLAUDE_SKILL_DIR}/scripts/pr-push.sh <worktree-root>`
  - GitHub: pass `-R <repo-slug>` to every `gh pr` command
  - GitLab: pass `-R <repo-slug>` to every `glab mr` command
- Need fresh context after a push? Re-run `${CLAUDE_SKILL_DIR}/scripts/pr-status.sh <worktree-root>`.

## VCS Selection

The injected "VCS" line already applies the hint (`gh` or `gl`) or, with no hint, the remote URL rule (`gitlab` or a host listed in `~/.config/dgokcin-skills/gitlab-hosts` means GitLab, otherwise GitHub). Use it as is.

## Instructions

Create a PR/MR for the branch at the injected "Worktree root". Permission system handles user confirmation.

### Worktrees

A worktree branch is a normal branch. Push it and open the PR/MR from it directly. Do not cherry-pick or sync it into the main repo checkout.

### Process

1. Check the context for `ERROR:`. If present, stop and report it
2. Read the injected context: VCS, repo slug, branch, base branch, PR/MR status, commits, diff
3. If "Current branch" equals "Base branch" or is detached, stop and report it. Never open a PR from the base branch
4. If "Uncommitted Changes" is not clean, mention it in the final reply. Do not commit
5. Extract ticket from branch name if present (e.g., `feature/PROJ-123-something`)
6. Craft title:
   - If Jira ticket found: `PROJ-123: Title here` (normal sentence casing!)
   - If no ticket: Use conventional commit format: `feat|fix|docs|refactor|...: Title here`
7. Build body with mandatory sections: Summary, Changes, Additional Notes
8. Push with `${CLAUDE_SKILL_DIR}/scripts/pr-push.sh <worktree-root>` (both GitHub and GitLab)
9. If MODE is UPDATE, update the existing PR/MR title and description to cover all commits on the branch. If MODE is CREATE, create it
10. Report the URL

### Execution Behavior

- If PR/MR exists: `gh pr edit <number> -R <repo-slug>` or `glab mr update <number> -R <repo-slug>`
- If no PR/MR: `gh pr create -R <repo-slug>` or `glab mr create -R <repo-slug>`
- Permission system will prompt user for confirmation
- DO NOT output commands for copy-paste
- **GitHub**: DO NOT escape backticks - CLI handles this
- **GitLab**: ESCAPE ALL BACKTICKS with backslash (\`) in description - glab CLI doesn't handle this
- Check context → Push → Create or update → Report URL

### GitHub PR Command

```bash
gh pr create -R <repo-slug> \
  --head <current-branch> \
  --base <base-branch> \
  --title "PROJ-123: Description here" \
  --body "## Summary
Brief description of changes

## Changes
- Change 1
- Change 2

## Additional Notes
Any extra context"
```

### GitLab MR Command (ugh)

**IMPORTANT**: Escape all backticks with `\` in the description!

```bash
glab mr create -R <repo-slug> \
  --source-branch <current-branch> \
  --target-branch <base-branch> \
  --title "PROJ-123: Description here" \
  --description "## Summary
Brief description of changes

## Changes
- Added \`someFunction\` to handle X
- Updated \`config.ts\` for Y

## Additional Notes
Any extra context"
```

### Update Existing PR (GitHub)

```bash
gh pr edit <number> -R <repo-slug> \
  --title "PROJ-123: Updated description" \
  --body "## Summary
Updated description of ALL changes in branch

## Changes
- All changes from all commits
- Not just the latest

## Additional Notes
Any extra context"
```

### Update Existing MR (GitLab)

**IMPORTANT**: Escape all backticks with `\` in the description!

```bash
glab mr update <number> -R <repo-slug> \
  --title "PROJ-123: Updated description" \
  --description "## Summary
Updated description of ALL changes in branch

## Changes
- Updated \`someFile.ts\` with new logic
- Refactored \`utils/helper.ts\`

## Additional Notes
Any extra context"
```

### Rules

- **USE NORMAL SENTENCE CASING** - PR/MR body is NOT lowercase like commits
- Capitalize first letters of sentences, proper nouns, headings in body sections
- Write like a human would write documentation
- Mandatory sections: Summary, Changes, Additional Notes
- After creation, provide URL: `[PR Title](URL)`
- **FORBIDDEN**: No AI attribution, no "Generated by", no "Co-Authored-By"
- **Title format**:
  - If Jira ticket in branch name: `PROJ-123: Description here`
  - If no ticket: Use conventional commits: `feat: Add new feature`, `fix: Resolve bug`, `docs: Update docs`, `refactor: Improve structure`, etc.
- Determine commit type by analyzing the changes:
  - `feat`: New features or functionality
  - `fix`: Bug fixes
  - `docs`: Documentation updates
  - `refactor`: Code refactoring without feature/fix changes
  - `perf`: Performance improvements
  - `test`: Adding/updating tests
  - `chore`: Dependencies, build config, tooling

### Final Reply

Reply with the PR/MR link as `[title](url)`, plus the worktree root it was opened from.
