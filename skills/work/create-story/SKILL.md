---
name: create-story
description: Create a Jira story with proper ADF formatting. Use when the user asks to create a Jira story, ticket, or issue, wants requirements or notes turned into a ticket, or says "make a story for X".
context: fork
model: sonnet
allowed-tools: mcp__claude_ai_Atlassian_MCP__getJiraIssue, Read
argument-hint: <story description or requirements>
---

# Create Jira Story

## Configuration
Read the Jira config at `~/.config/dgokcin-skills/jira.md` (template in the repo's `local.example/jira.md`). It holds cloudId, atlassianUrl, defaultProject, currentUserAccountId, and custom field IDs.

## Instructions

Create properly formatted Jira Story in the default project.

### Process

1. Parse user description from: `$ARGUMENTS`
2. **NEVER** call lookup APIs - use hardcoded values:
   - cloudId: `<cloudId>`
   - projectKey: `<defaultProject>`
   - issueTypeName: `Story`
3. Craft concise, action-oriented summary
4. Build description in **MARKDOWN** format:
   ```markdown
   ## Problem
   [What needs to be done]

   ## Proposed Solution
   [How we'll solve it]

   ## Implementation Details
   [Technical specifics]
   ```
5. Create `<reasonForChangeField>` (Reason for change) in **ADF** format - REQUIRED!
6. If acceptance criteria provided, create `<acceptanceCriteriaField>` in **ADF taskList** format
7. Execute `mcp__claude_ai_Atlassian_MCP__createJiraIssue`
8. Provide the issue URL: `[<KEY>](<atlassianUrl>/browse/<KEY>)`

### Critical Reminders

- Description = MARKDOWN, Custom fields = ADF
- NEVER put acceptance criteria in description - use `<acceptanceCriteriaField>`!
- NEVER use markdown checkboxes (`- [ ]`) - they don't render!
- Each taskItem needs a unique localId (UUID format)
- `<reasonForChangeField>` REQUIRED - always include!

### Final Reply

Reply with only `[<KEY>](<atlassianUrl>/browse/<KEY>)`.
