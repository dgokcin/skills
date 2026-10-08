---
name: get-story
description: Fetch and display a Jira issue with all details. Use when user asks about a ticket, wants issue details, or says "what's in PROJ-123"
context: fork
model: sonnet
allowed-tools: mcp__claude_ai_Atlassian_MCP__getJiraIssue
argument-hint: <PROJ-123 or issue number>
---

# Fetch Jira Issue

## Configuration

Read the Jira config at `~/.config/dgokcin-skills/jira.md` (template in the repo's `local.example/jira.md`). It holds cloudId, atlassianUrl, defaultProject, currentUserAccountId, and custom field IDs.

## Instructions

Fetch Jira issue. Display body + comments only.

### Process

1. Parse issue key from argument-hint

   - Number only (e.g., `123`) → prepend `<defaultProject>-`
   - Full key (e.g., `PROJ-123`) → use as-is
   - Different project prefix → use that

2. Fetch:

   ```
   mcp__claude_ai_Atlassian_MCP__getJiraIssue
   - cloudId: <cloudId>
   - issueKey: <parsed key>
   ```

3. Display only:

   - **Description** (full content)
   - **Comments** (all footer and inline comments)

4. Provide the issue URL: `[<KEY>](<atlassianUrl>/browse/<KEY>)`

### Output Format

```markdown
# <KEY>

[Full description content]

## Comments

[All comments displayed in order]

View: [<KEY>](<atlassianUrl>/browse/<KEY>)
```

### Final Reply

Show the issue details and nothing else.

### Error Handling

- **Not found**: Suggest JQL search
- **Wrong project**: Confirm project key
- **No arguments**: Ask for issue key