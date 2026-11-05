# Research briefs

One brief per agent. Fill the `{placeholders}` from the config and the intake, then launch every agent in a single turn in the background. A brief is the agent's only context, so keep the shared preamble.

Placeholders:

- `{ME}`: user's full name. `{MY_SLACK}`: their Slack ID. `{MY_EMAIL}`: their email.
- `{PEER}`, `{PEER_SLACK}`, `{PEER_ALIASES}`: a colleague's name, Slack ID, and nicknames.
- `{PERIOD}`: review period, set by the cycle (see SKILL.md step 1).
- `{SCRATCH}`: scratch directory. `{VAULT}`: vault root. `{REPOS}`: repo roots and key repos.
- `{CHANNELS}`: key channels from config. `{THEMES}`: wins the user named in the intake.
- `{LEVEL}` / `{TARGET}`: current and target level. `{CYCLE}`: `mid-year` or `year-end`.

## Shared preamble (prepend to every brief)

```
You are helping {ME} write {CYCLE} performance reviews for the period {PERIOD}. You work READ-ONLY. Never send, post, react, edit, comment, transition, commit or push anything, in any tool. Write your full findings to {SCRATCH}/<your-file>.md with dates, numbers, and evidence for every claim (permalinks, ticket keys, commit hashes, vault paths). Then return a summary of at most 300 words. The file is the deliverable. Report what the evidence says, even when it contradicts the brief, and flag those contradictions at the top of your summary.
```

## refs → `refs.md`

```
Read these Google docs and sheets with the Google Docs/Drive/Sheets tools. Load them with ToolSearch first, and read every tab:
{list each link with what the user said it is}

Write:
A. For each form ({self form}, {peer forms}): the section headings, prompts, guidance text, rating scales, word limits and deadline, word for word and in order. Say which forms are identical and which fields are already filled in.
B. Reviews written about {ME} this cycle: full text.
C. {ME}'s earlier reviews of colleagues: full text. Mark these as voice samples and note the cycle date.
D. The user's previous self review (last mid-year or year-end): full text, with its date. Note any forecasts or goals in it, so this cycle can compare against them.
E. The career framework: dimension names, plus {LEVEL} and {TARGET} word for word for every dimension. Give the levels either side briefly. End with a table of what changes from {LEVEL} to {TARGET} for each dimension.
F. Anything that failed to load.

If a link doesn't contain what the user said it does, search Drive by title (for example "<name> Mid Year" or "<name> Self-Assessment") and use what you find, saying where you found it.
```

## vault-self → `vault-self.md`

```
Vault: {VAULT}. Read its CLAUDE.md first. Skip archived and personal folders.

1. Inventory everything {ME} worked on in {PERIOD}: workstreams with outcome, dates, ticket keys and collaborators. Include incidents, talks and presentations, AI tooling, mentoring, interviews and cross-team support. Pay special attention to: {THEMES}.
2. Recompute any headline numbers the way the vault's own dashboards or views compute them. Read the view code. Where a number can be measured more than one way (amortized vs unblended, before vs after an offset), give every version, show the math, and name the metric each figure uses. Confirm or correct the user's figures: {numbers the user quoted}.
3. For each initiative the user says they started on their own, find when the first note was created (use file birth time) and when a ticket was first assigned.
4. Gather evidence of {TARGET}-level behaviour: direction across teams, cost impact, enabling others, owning ambiguity.
5. Gather feedback received, 1:1 notes with the manager, goals, and weak spots (self-caused incidents, claims that were later corrected, too much work in progress, friction).

Structure: monthly timeline, per-workstream detail, numbers with math, evidence for {TARGET}-level behaviour, growth areas.
```

## vault-peers → `vault-peers.md`

```
Vault: {VAULT}. Search the whole work tree for every mention of each colleague, matching on word boundaries: {PEER} ({PEER_ALIASES}), one per colleague. Find the meetings linked to their people note.

Per colleague:
1. What they owned or contributed to, with dates and outcomes.
2. Examples of ownership, independence, depth, decisions, visibility outside the team, helping others, incidents, AI use and speed.
3. {ME}'s own opinions about them in the notes: praise, friction and worries. Quote them short.
4. Interactions with {ME}: pairing, reviews, disagreements.
5. Change compared to last year, and around any role change.
6. Feedback {ME} received about their previous review of this person, for example a manager asking for broader scope.
```

## slack-self → `slack-self.md`

```
Slack. Load the tools via ToolSearch and use slack_search_public_and_private so public channels, private channels and DMs are all covered. {ME} is {MY_SLACK}. Key channels: {CHANNELS}.

1. Search {ME}'s messages one month at a time across {PERIOD}. Find announcements, proposals, incidents led, demos, talks and help given to other teams. Verify and enrich: {THEMES}. Find wins the user didn't list.
2. Find what others said about {ME}: thanks, kudos, manager praise, and custom emoji.
3. Gather evidence of {TARGET}-level scope.
4. Gather growth areas: friction, things that slipped, critical review comments.
5. Collect 10 to 15 longer messages by {ME}, word for word, as tone samples.
```

## slack-<peer> → `slack-<first name>.md` (one per colleague)

```
Slack. Load the tools via ToolSearch and use slack_search_public_and_private. {PEER} is {PEER_SLACK} and {ME} is {MY_SLACK}.

1. Search {PEER}'s messages one month at a time across {PERIOD}, plus their DMs with {ME} and mentions or thanks from other people.
2. Map their projects with dates and permalinks.
3. If their role changed this period, find the announcement (exact title and effective date) and compare how they behave before and after: which channels they post in, how they frame asks, the decisions they drive.
4. Give strengths with short quotes, kudos, and growth areas with evidence. Base growth areas on behaviour, not personality.
5. List their interactions with {ME}, including disagreements and how they were resolved.
User's own view to test against the evidence: {the user's comments about this person}.
```

## repos → `repos.md`

```
Repos under {REPOS}. Use git log only. No checkouts, no edits.

1. For every repo with activity from {ME} or {PEERS} in {PERIOD}, run `git log --all --no-merges` and count per person. Identify every author identity each person uses (work email, noreply, "(AI)" variants). Count duplicate checkouts that share a remote once. Summarise each person's commit themes, not every subject line.
2. For each technology or repo the user credits to someone, especially {THEMES}, say who created it and who wrote most of it, with the first commit hash and date.
3. Collect impact numbers from docs, specs and READMEs, and say which file each one came from.
4. Where a speedup or saving is claimed, line it up with commit timestamps. Say which change actually happened at that moment.
5. Note AI tooling (skills, agents, CLAUDE.md) each person added that other people use.
```

## jira → `jira.md`

```
Atlassian MCP. Load the tools via ToolSearch and call getAccessibleAtlassianResources once for the cloudId. Projects: {JIRA_PROJECTS}.

1. For {ME} and each of {PEERS}: issues resolved as assignee and created as reporter in {PERIOD}, counted per month and grouped by epic. Note who created each epic. A ticket the user created themselves is an initiative signal. List large parent stories with many child tickets.
2. Caveats that inflate counts: sub-task granularity, and tickets created and closed the same day by AI flows.
3. Confluence: pages each person created or edited in {PERIOD}, such as proposals, postmortems and runbooks. Give one line per page, with a link.
4. Incidents where any of them is named as lead or author.
```
