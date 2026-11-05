---
name: performance-review
description: "Draft your mid-year or year-end self review and peer reviews from your vault, Slack, repos and Jira, in your own voice, ready to paste into the review forms."
disable-model-invocation: true
argument-hint: "[mid-year|year-end] [self] [peer names...] (asks for form links and your notes)"
metadata:
  internal: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - SendMessage
  - ListAgents
  - TaskStop
  - AskUserQuestion
  - ToolSearch
  - Bash(date:*)
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(grep:*)
  - Bash(find:*)
  - Bash(stat:*)
  - Bash(wc:*)
  - Bash(mkdir -p:*)
  - Bash(mktemp:*)
  - Bash(git log:*)
  - Bash(git -C:*)
  - Bash(obsidian read:*)
  - Bash(obsidian search:*)
  # Google (read-only: forms, past reviews, career framework)
  - mcp__claude_ai_Google_Docs__read_doc
  - mcp__claude_ai_Google_Drive__read_file_content
  - mcp__claude_ai_Google_Drive__get_file_metadata
  - mcp__claude_ai_Google_Drive__search_files
  - mcp__claude_ai_Google_Sheets__get_spreadsheet
  - mcp__claude_ai_Google_Sheets__get_values
  # Slack (read-only)
  - mcp__claude_ai_Slack__slack_search_public_and_private
  - mcp__claude_ai_Slack__slack_search_users
  - mcp__claude_ai_Slack__slack_read_thread
  - mcp__claude_ai_Slack__slack_read_channel
  - mcp__claude_ai_Slack__slack_read_user_profile
  # Atlassian (read-only)
  - mcp__claude_ai_Atlassian_MCP__getAccessibleAtlassianResources
  - mcp__claude_ai_Atlassian_MCP__searchJiraIssuesUsingJql
  - mcp__claude_ai_Atlassian_MCP__getJiraIssue
  - mcp__claude_ai_Atlassian_MCP__searchConfluence
  - mcp__claude_ai_Atlassian_MCP__getConfluenceContent
---

# Performance Review

Write the self review and peer reviews for one review cycle, either mid-year or year-end. Research the period in depth with parallel read-only agents, check every claim against the evidence, then write short drafts that read like the user wrote them. The drafts land in the vault, one file per form, ready to paste.

## Injected context

- Today: !`date "+%Y-%m-%d"`
- Config: !`cat ~/.config/dgokcin-skills/performance-review.md 2>/dev/null || echo "(no config yet)"`

## 0. Config

The config holds everything that stays the same between cycles:

- the user's name, Slack ID, team and manager
- vault paths, repos, the Jira site and key channels
- the career framework link
- a table of known colleagues with their Slack IDs, nicknames and git identities

Re-asking any of this every cycle is the thing this skill exists to avoid.

If the config is missing, ask for those fields once and write `~/.config/dgokcin-skills/performance-review.md` with these sections: Me, Vault, Code, Atlassian, Slack, Career framework, Colleagues, Voice samples. Then tell the user to mirror a placeholder version into `local.example/` if they maintain the repo.

## 1. Cycle and intake

**Pick the cycle.** Take it from the argument (`mid-year` or `year-end`). Otherwise infer it from the month: around June and July is mid-year, around October to December is year-end. Confirm with the user only when the month is ambiguous. The cycle changes three things:

| | mid-year | year-end |
|---|---|---|
| Default period | from the last year-end deadline to today, about 6 months | the whole year, from the last year-end deadline to today |
| Previous review to build on | last year-end | this year's mid-year |
| Tone of growth sections | progress so far, plus goals for the second half | results, plus the case for the next level |

The reviews folder is `<reviews dir>/<year>-<cycle>/`, for example `work/reviews/2026-year-end/`.

- If it already has an `intake.md` from an earlier run this cycle, reuse it.
- Then read the previous cycle's folder. Its intake, drafts and corrections are the baseline for this cycle, so don't re-ask for anything they already answer.

Work out which documents to write from the arguments (`self`, colleague names). Then ask, in one plain message, only for what is still missing:

1. The form link for each document: the self assessment, and one peer form per colleague. Mid-year cycles sometimes have no peer forms.
2. Reference docs, all optional:
   - reviews other people wrote about the user this cycle (gold for the self review)
   - the user's earlier reviews of each colleague (they show growth and work as voice samples)
   - the user's previous self review
   - the career framework, if it changed (the default comes from config)
3. The user's current and target level, if a promotion case is in play.
4. The user's raw comments about each person and about themselves: what changed this period, the wins they care about, the numbers they remember, and anything they want said or left out. These are the backbone of each draft, so ask for them explicitly.
5. Deadlines.

Use AskUserQuestion only for real choices. Links and comments are free text.

Save the answers to `intake.md` in the cycle folder, so a follow-up run or a resumed session never asks again. After step 3, add a "Corrections found this cycle" section to it.

When a colleague is not in the config, look up their Slack ID, git author names and vault note, and offer to add them to the Colleagues table.

## 2. Research fan-out

Read `references/research-briefs.md`. It holds one brief per agent:

| Agent | Covers |
|---|---|
| refs | forms verbatim, reviews received, past reviews, the previous self review, the career framework |
| vault-self | the user's workstreams, numbers, talks, feedback notes |
| vault-peers | every colleague mention, their meetings, the user's own opinions in notes |
| slack-self | the user's announcements, incidents, kudos, tone samples |
| slack-<peer> | one per colleague: projects, before and after any role change, kudos, growth areas |
| repos | git authorship per person, and what each one actually built |
| jira | resolved issues, epics, Confluence pages per person |

Launch them all in one turn, in the background, so they finish together. Each agent:

- works read-only
- writes its full findings to a file in a scratch directory (the session scratchpad if there is one, otherwise `mktemp -d`)
- returns a summary of at most 300 words

The files are the real output, because summaries drop detail.

If the harness has no subagents, run the briefs yourself one at a time: refs, vault, Slack, repos, then Jira.

While they run, tell the user what is running in one short list. If a deadline has passed or is today, say so, and write that document first as soon as its evidence is in.

## 3. Verify before writing

Read every findings file in full. Then check the claims that will go into the drafts. Past runs caught each of the errors below, and every one of them came from the user's own memory:

- **Titles and role changes.** Find the announcement. A "promotion" turned out to be a move to tech lead with a start date.
- **Who built what.** Check git authorship before crediting anyone. A technology the user believed they had deployed was 100% a colleague's commits. Credit what the user built (the foundation, the template, one migration) and name the colleague for the rest.
- **"I proposed X".** Find the first document, the date, and what already existed before it. The proposal was real, but the tool had already been enabled by someone else.
- **Money.** Find which metric a number comes from. "$102k a year" was the on-demand-equivalent figure, while the actual bill showed $87k. State the one a manager would check, or both, and mention offsets that went the wrong way.
- **Speedups and causes.** Line the change up with the timestamps. A CI speedup turned out to line up with a colleague's change made four days earlier. Claim only what the timeline supports.
- **Links that don't hold what the user says.** A spreadsheet said to contain the previous self review held only the framework. Search Drive by title before giving up.

Give the user every correction in a short list next to the drafts, with the evidence. Never bury a correction in the draft text.

## 4. Write the drafts

Read `references/writing-guide.md` and follow it for voice, section shapes, length, how to frame development points, the promotion case, and the file template.

Write one file per document in `<vault>/<reviews dir>/<year>-<cycle>/`:

- `self review.md`
- `peer review - <full name>.md`

Each file contains the form's sections, in the form's order, with paste-ready text. After them comes a horizontal rule, then `## Evidence (not for pasting)` with the permalinks, ticket keys and vault wikilinks that back every claim.

## 5. Hand over

1. Grep the drafts for em dashes and en dashes, and fix any you find.
2. Shut down every agent you spawned, and confirm with ListAgents that none is still running.
3. Tell the user briefly:
   - the file paths
   - the corrections from step 3
   - what you added beyond their comments
   - the sensitive development points worth a second read
   - any overdue deadline

Don't paste the drafts into chat, because they are already in the files.

## Follow-ups

The user often asks to dig into one claim ("when did I propose X, and how?"). Research it yourself across the vault, Slack and git. Answer with a dated timeline, links and an honest framing. Then edit the draft text and its evidence section so they agree with what you found, and add the correction to `intake.md`.
