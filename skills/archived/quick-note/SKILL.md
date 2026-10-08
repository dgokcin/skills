---
name: quick-note
description: "Quick capture a note to work/random or personal/random. Use when the user says 'jot this down', 'save this thought', 'note to self', 'remember this idea', or mentions a random idea, link, or snippet they want to capture. Also trigger when the user wants to quickly save something without specifying a particular note type."
tools: Bash, Read
disable-model-invocation: true
argument-hint: <note title> [--personal]
metadata:
  internal: true
---

# Quick Note

Quick-capture note to vault random folders via Obsidian CLI.

## Instructions

1. Parse input from: `$ARGUMENTS`
   - `--personal` flag → target `personal/random/`
   - Default: `work/random/`
   - Remaining text = note title
   - No args → ask what to capture
2. Create note via Obsidian CLI:

   ```bash
   obsidian create path="<work|personal>/random/<title slug>.md" content="# <Title>"
   ```

   - title slug: lowercase with spaces (e.g., `platform support bot idea.md`)
   - No template needed — quick notes are intentionally minimal
3. If the user provided content in the same message, append it:

   ```bash
   obsidian append file="<title slug>" content="<the content>"
   ```

4. Report the created file path when done

### Rules

- Minimal structure — no frontmatter, just a title and content
- If only a title is given, create the note with just the H1 heading
- Use `\n` for newlines in content values passed to CLI