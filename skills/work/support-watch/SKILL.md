---
name: support-watch
description: "Check a Slack channel for new help requests aimed at your team, investigate each one read-only, and play a sound when there is a finding. Built for /loop 15m."
argument-hint: "[channel-id ...] (defaults to the channels in config)"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Agent
  - Skill
  - Bash(date:*)
  - Bash(mkdir -p:*)
  - Bash(afplay:*)
  - Bash(osascript -e:*)
  - Bash(say:*)
  # Slack (read-only)
  - mcp__claude_ai_Slack__slack_read_channel
  - mcp__claude_ai_Slack__slack_read_thread
  - mcp__claude_ai_Slack__slack_read_user_profile
  - mcp__claude_ai_Slack__slack_get_reactions
---

# Support Watch

One run is one tick. Read new channel messages, pick out help requests for the team, investigate each in a subagent, notify on findings, save state. `/loop 15m /support-watch` repeats the tick.

## Injected context

- Now (epoch): !`date +%s`
- Now (local): !`date "+%Y-%m-%d %H:%M %Z"`
- Working dir: !`pwd`
- State: !`cat ~/.config/dgokcin-skills/state/support-watch.json 2>/dev/null || echo "(no state yet)"`

## Config

Read `~/.config/dgokcin-skills/support-watch.md`. It defines:

- channels to watch
- your Slack ID and your teammates' Slack IDs
- what the team owns (services, infra, keywords) and what it doesn't
- the notification sound
- first-run lookback

Missing config → stop and tell the user to copy `local.example/support-watch.md` there.

## State

File: `~/.config/dgokcin-skills/state/support-watch.json`

```json
{
  "channels": {
    "C08MZJ21UDB": { "last_ts": "1760000000.000100" }
  },
  "handled": {
    "C08MZJ21UDB:1760000000.000100": {
      "verdict": "concrete",
      "report": "~/.config/dgokcin-skills/state/support-watch/reports/2026-10-12-C08MZJ21UDB-1760000000.000100.md"
    }
  }
}
```

- `last_ts`: newest message ts already seen, per channel
- `handled`: threads already triaged as help requests, so a tick never investigates the same thread twice
- Prune `handled` entries older than 7 days on each write

## Steps

### 1. Pick channels

`$ARGUMENTS` lists channel IDs → watch those. Empty → use the config channels.

### 2. Read new messages

For each channel, in parallel:

```
slack_read_channel(channel_id, oldest: <last_ts>, limit: 100, response_format: "detailed")
```

- No `last_ts` → `oldest` = now minus the configured first-run lookback
- Keep only messages with `ts > last_ts`
- Page with `cursor` until exhausted
- Record the newest ts seen as the channel's new `last_ts`

Nothing new in any channel → write state, print one line (`support-watch: no new messages`), stop. No sound.

### 3. Triage

A message is a **help request** when all of these hold:

- it asks a question, reports something broken, or asks for an action
- the topic falls inside the team's ownership from config
- the author is not you or a teammate, and not a bot (unless config lists the bot as an alert source)
- the thread is not already in `handled`

Before investigating, read the thread with `slack_read_thread`. Skip it when:

- a teammate already replied with an answer or said they're on it
- the author says it's resolved, or the parent has a ✅ / `:white_check_mark:` reaction
- it's chit-chat, an announcement, or a thank-you

Unsure whether it's the team's area → treat it as a help request and say so in the report. A missed question costs more than a wasted investigation.

### 4. Investigate

Spawn one subagent per help request, all in a single message so they run in parallel:

- `subagent_type`: `general-purpose`
- `model`: `opus`
- prompt: the template below, filled in

Harness without subagents → run the template inline, one request at a time.

#### Investigation prompt

```
A teammate asked for help in Slack. Do a first-pass investigation and report back.
You are not fixing anything. Everything you do must be read-only.

## The request
Channel: <channel id>   Thread: <permalink or ts>
Author: <name>          Asked at: <local time>
<full thread text, oldest first>

## Team context
<ownership section from config>

## Where to look
- Repos are cloned under <working dir>. Grep there for the service, its helm chart,
  gitops/ArgoCD manifests, terraform, and recent commits (git log -20 on the relevant repo).
- Kubernetes: call the Skill tool with "k8s-debug".
- AWS: call the Skill tool with "aws-debug".
- Datadog logs, metrics, traces, monitors, k8s rollouts: call the Skill tool with
  "datadog:debug", or use the Datadog MCP tools directly.
Use the one that fits the symptom first. Don't run all of them by reflex.

## Hard rules
- Read-only. No kubectl apply/edit/delete/scale/rollout restart, no aws create/update/delete/put,
  no git push/commit, no Slack messages, no Datadog writes.
- If a command needs elevated access or a write to proceed, stop there and report it as a next step.
- Cap yourself at about 30 tool calls. Stop early once you have evidence.
- No guessing. Every claim cites a log line, metric, manifest, or command output.

## Report format (exactly this)
VERDICT: concrete | lead | inconclusive
ONE-LINER: <under 120 chars, what's going on>
SUMMARY: <3-6 sentences>
EVIDENCE:
- <source>: <what it shows>
SUGGESTED NEXT STEP: <what a human should do or answer>
```

`concrete` means a root cause or a direct answer backed by evidence. `lead` means a strong suspect that still needs a human to confirm. `inconclusive` means nothing solid.

### 5. Save reports

For each subagent result:

1. Call the Skill tool with "slackify" to turn SUMMARY and SUGGESTED NEXT STEP into a draft thread reply. Never send it.
2. Write `~/.config/dgokcin-skills/state/support-watch/reports/<YYYY-MM-DD>-<channel>-<ts>.md` (run `mkdir -p` on the dir first) containing the original question, the full report, and the draft reply.
3. Add the thread to `handled` with its verdict and report path.

### 6. Write state

Write the state file before notifying. A crash after the sound must not cause a re-investigation next tick.

### 7. Notify

Only when at least one verdict is `concrete` or `lead`:

```bash
afplay <sound from config>
osascript -e 'display notification "<one-liner>" with title "support-watch" subtitle "<author> in <channel>"'
```

If config sets `speak: true`, also run `say "<author>: <one-liner>"`.

Then call `PushNotification` with the one-liner, when the harness has it, so it reaches your phone.

`inconclusive` results get no sound. They still appear in the tick summary and in a report file.

### 8. Tick summary

Print a short block, newest first:

```
support-watch 14:30, 2 new help requests
🟢 concrete  @alice  booking-api 502s → pods OOMKilled since 13:58 deploy  (report: …)
⚪ inconclusive  @bob  "staging feels slow"  (report: …)
```

Skipped messages appear only as a count (`skipped 7: chatter / already answered`).

## Rules

- Never post, react, or reply in Slack. Drafts live in the report files.
- Never mutate infra, even when the fix looks obvious. Suggest it in the report.
- Keep the main session thin. Raw investigation output stays inside the subagents, so long loops don't fill the context.
- One sound per tick, however many findings.
