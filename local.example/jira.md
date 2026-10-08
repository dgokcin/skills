# Jira Configuration Constants

## Hardcoded Values - NEVER waste tokens looking these up!

| Constant | Value |
|----------|-------|
| **cloudId** | `<your-cloud-id>` |
| **defaultProject** | `PROJ` |
| **atlassianUrl** | `https://<your-site>.atlassian.net` |
| **currentUserAccountId** | `<your-account-id>` |

## PROJ Issue Type IDs - No need to fetch!

| Type | ID |
|------|-----|
| Story | `<story-type-id>` |
| Task | `<task-type-id>` |
| Bug | `<bug-type-id>` |
| Sub-task | `<subtask-type-id>` |
| Epic | `<epic-type-id>` |
| Spike | `<spike-type-id>` |
| Support | `<support-type-id>` |

## Required Custom Fields for PROJ

| Field ID | Name | Required | Format |
|----------|------|----------|--------|
| `customfield_<reason-field-id>` | Reason for the change | **YES** | ADF paragraph |
| `customfield_<acceptance-criteria-field-id>` | Acceptance Criteria and NFR | No | ADF taskList (checkboxes!) |
| `customfield_<team-field-id>` | Team | No | - |
| `customfield_<scheduled-date-field-id>` | Scheduled Date | No | - |
| `customfield_<resources-field-id>` | Resources Required | No | - |

## Critical Rules

- **NEVER** call `getAccessibleAtlassianResources` - use hardcoded cloudId
- **NEVER** call `atlassianUserInfo` - use hardcoded accountId
- **NEVER** call `listJiraProjects` unless user explicitly mentions a non-PROJ project
- **NEVER** call `listJiraProjectIssueTypesMetadata` - use hardcoded issue type IDs
- **DEFAULT** to PROJ project unless user explicitly mentions another project prefix

## Format Rules

| Field | Format |
|-------|--------|
| `description` | **MARKDOWN** - `## headings`, `- bullets`, ``` code ``` |
| `customfield_<reason-field-id>` | **ADF** paragraph - REQUIRED! |
| `customfield_<acceptance-criteria-field-id>` | **ADF** taskList - renders as checkboxes! |

**CRITICAL**:
- NEVER put acceptance criteria in description - use `customfield_<acceptance-criteria-field-id>`!
- NEVER use markdown checkboxes (`- [ ]`) in description - they don't render!
- Each taskItem needs a unique localId (use UUID format)

## ADF Templates

### Simple Paragraph (for `customfield_<reason-field-id>` - Reason for change)
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [{"type": "text", "text": "YOUR REASON HERE"}]
    }
  ]
}
```

### Task List with Checkboxes (for `customfield_<acceptance-criteria-field-id>` - Acceptance Criteria)
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "taskList",
      "attrs": {"localId": "generate-unique-uuid-here"},
      "content": [
        {
          "type": "taskItem",
          "attrs": {"localId": "ac-1-uuid", "state": "TODO"},
          "content": [{"type": "text", "text": "First acceptance criterion"}]
        },
        {
          "type": "taskItem",
          "attrs": {"localId": "ac-2-uuid", "state": "TODO"},
          "content": [{"type": "text", "text": "Second acceptance criterion"}]
        }
      ]
    }
  ]
}
```

### Bullet List (for general lists, NOT acceptance criteria)
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "Item 1"}]}
          ]
        }
      ]
    }
  ]
}
```

## Description Template (MARKDOWN)

```markdown
## Problem
[What issue or need exists - be specific]

## Current State
[How things work now - include relevant details]

## Proposed Solution
[What changes are needed - be actionable]

## Implementation Details
[Technical specifics if applicable]

## References
- Related links/docs
```

**NOTE**: Do NOT put acceptance criteria in the description! Use `customfield_<acceptance-criteria-field-id>` with ADF taskList format instead!
