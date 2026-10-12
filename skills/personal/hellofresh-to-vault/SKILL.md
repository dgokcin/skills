---
name: hellofresh-to-vault
description: Sync HelloFresh recipes from the user's past deliveries into the Obsidian cookbook at ~/vault/personal/cooking, with supermarket ingredient swaps and step photos. Use when the user asks to import, sync, save, or pull their HelloFresh recipes into the vault or cookbook, mentions new HelloFresh deliveries to add, or pastes a HelloFresh recipe URL to save.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

Turn HelloFresh recipes into vault recipe notes: one note per recipe, cover photo on top, each step's instructions under that step's photo, and HelloFresh's mini-packages replaced by supermarket equivalents.

## How the data flows

- **Which recipes**: the past-deliveries page (`https://www.hellofresh.nl/my-account/deliveries/past-deliveries?locale=en-NL`) needs a logged-in browser. Its API needs a bearer token. Never read or extract the token. Read the data the page already loaded instead.
- **Recipe content**: every recipe page is public, so `curl` gets it with no login. `scripts/fetch_recipes.py` pulls the structured recipe (JSON-LD) and the step captions and photos (`__NEXT_DATA__`).
- **Photos**: `img.hellofresh.com`, downloaded into the vault so they survive site changes.

A single recipe URL from the user skips step 1. Put its slug in the slugs file directly.

## Workflow

1. **Collect slugs from past deliveries.** Open the past-deliveries page in the user's logged-in browser (browser automation, e.g. Claude in Chrome). If it shows a login form, ask the user to log in; never type credentials. Run [collect-deliveries.js](references/collect-deliveries.js) in the page. It loads every week and stores meals in `window.__hfMeals`. Browser tools truncate long output, so read the slugs back 6 at a time:

   ```js
   window.__hfMeals.slice(0, 6).map(m => m.slug).join(" ")
   ```

   Write them, one per line, to `$WORK/slugs.txt`, where `WORK=$(mktemp -d)`. Close any tab you opened.

2. **Fetch recipes, skipping ones already in the vault.**

   ```bash
   python3 -I "${CLAUDE_SKILL_DIR}/scripts/fetch_recipes.py" "$WORK/slugs.txt" "$WORK/data" \
     --skip-existing ~/vault/personal/cooking
   ```

   For another country, pass `--domain hellofresh.de --locale en-DE` (and use that domain in step 1). Stop if nothing new was fetched.

3. **Write the notes.** Each recipe needs judgement for the ingredient swaps and the step rewrite. Give it to subagents on a small, fast model (Haiku), up to 8 recipes each, all launched in one message. Each subagent prompt names its JSON files and contains these instructions:

   > Read `${CLAUDE_SKILL_DIR}/references/note-format.md` and follow it exactly. For each recipe JSON listed: pick the note file name, run `python3 -I "${CLAUDE_SKILL_DIR}/scripts/download_images.py" <json> ~/vault "personal/cooking/attachments/hellofresh/<note name>"`, then write `~/vault/personal/cooking/<note name>.md` using the printed embed paths. Never overwrite an existing note. Report one line per recipe: slug → file name, or the problem.

   Replace `${CLAUDE_SKILL_DIR}` with the absolute skill path in the prompt; subagents don't inherit it. With 1-3 recipes, write them yourself.

4. **Verify.** Run the checker on every new note and fix whatever it flags:

   ```bash
   ruby "${CLAUDE_SKILL_DIR}/scripts/verify_notes.rb" ~/vault ~/vault/personal/cooking/<note>.md ...
   ```

   It checks the frontmatter parses and has every field, that steps live in the body with bullets under each photo, and that every embedded image exists. Also skim one note's ingredients for leftover "sachet", brand names, or "[Plant-based]".

5. **Report** the notes added (file names), any recipes that failed, and any file names that differ noticeably from the HelloFresh title. Shut down all subagents.

## Rules

- Never modify recipes the user wrote themselves (notes without `origin: Hellofresh`).
- Leave `rating:` empty on new notes; the user rates them.
- Don't edit `cookbook.base`. Correct frontmatter is what surfaces a note there.
