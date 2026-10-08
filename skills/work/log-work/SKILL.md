---
name: log-work
description: Create a Jira story for work already done on the current branch, written as a to-do, and move it to Code Review. Use only when the user explicitly says "log this work" or "make a ticket for what I did". Never invoke it from create-pr.
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git branch:*), AskUserQuestion, mcp__claude_ai_Atlassian_MCP__createJiraIssue, mcp__claude_ai_Atlassian_MCP__transitionJiraIssue, Read
---

# Log Work

Read the Jira config at `~/.config/dgokcin-skills/jira.md` (template in the repo's `local.example/jira.md`). It holds cloudId, atlassianUrl, defaultProject, currentUserAccountId, and custom field IDs. Never call lookup APIs.

## Process

1. Gather what was done from this conversation plus:
   - `git log --oneline main..HEAD`
   - `git diff --stat main...HEAD`
2. Write it up as if the work still needs doing:
   - **summary**: imperative, at most 10 words ("Fix runner cache eviction")
   - **description** (markdown): `## Problem` and `## Proposed Solution`, 1 to 3 sentences each
   - **<reasonForChangeField>** (Reason for the change): one ADF paragraph, one sentence. Required.
3. Call `AskUserQuestion` before creating anything. Put the drafted summary and reason in the question text, header `Jira`, with these options:
   - **Create story (Recommended)**: create it as drafted
   - **Use existing ticket**: the user types the key via "Other"
   - **Skip ticket**: don't create anything
4. Act on the answer:
   - **Create story**: continue to step 5. If the user typed edits via "Other", apply them first.
   - **Use existing ticket**: reply with that key and stop.
   - **Skip ticket**: stop.
5. Call `createJiraIssue`:
   - cloudId `<cloudId>`, projectKey `<defaultProject>`, issueTypeName `Story`
   - assignee `currentUserAccountId` from the config
   - no acceptance criteria, labels, or other custom fields
6. Call `transitionJiraIssue` on the new key with transitionId `101` (moves it to **Code Review**).
7. Reply with only `[<KEY>](<atlassianUrl>/browse/<KEY>)`.
