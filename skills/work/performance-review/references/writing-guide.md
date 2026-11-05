# Writing guide

The drafts go into Google Docs that a manager reads during calibration. They need to sound like the user on a careful day: plain, specific, warm, honest. A manager can spot AI prose quickly, and a draft that reads like a press release hurts the person it is about.

## Voice

Start from the voice samples: the user's earlier reviews (refs section C), plus the samples listed in config. Match their sentence length and their register. The rules below are the defaults those samples have confirmed so far.

- Normal capitalisation. Slack lowercase does not belong in a review doc.
- Short declarative sentences. One idea per sentence. Common words over fancy ones ("helped" not "facilitated", "started" not "spearheaded").
- First person for the self review ("I took over Traefik"). For peers, use their first name or nickname as the user writes it ("Mauri", "Ben").
- Concrete anchors in every paragraph: the project, the number, the date or the ticket. "He improved a lot" only lands when the next sentence shows how.
- Soften development points the way the user does: "which is a good problem to have", "I think this one is on the whole team", "a one line comment goes a long way". Be direct about the behaviour and kind about the person.
- Light personal touches are fine when the user actually does them ("He gave me the same feedback this year, so I know it's fair").
- Never use em dashes or en dashes. Use a comma, a period or parentheses.
- Avoid AI tells: "spearheaded", "leveraged", "instrumental", "testament to", "not only X but also Y", "in today's fast-paced", triplets of adjectives, and closing lines that sum up what was just said.

## Length

Each form section is one to three short paragraphs, or a short bullet list where the content is a list. Peer reviews come to roughly 500 to 600 words in total. A self review can run to about 1,200 words when a promotion case is in play (mid-year reviews are usually shorter), since it carries the evidence. Forms say "no need to write five pages", so take them at their word. When something has to go, keep the claims with numbers and drop the adjectives.

## Peer review shape

The form sections are usually Strengths, Development Opportunities and Growth Potential, but always use the exact headings the refs agent copied from the form.

- **Strengths.** Open with the user's own view from their comments ("Mauri improved a lot compared to last year"). Back it with the biggest piece of work, start to finish, with one number. Follow with how they work: communication, ownership, helping others, AI use. Mention kudos only when they are specific.
- **Development.** Give two or three points, each about a behaviour and each with a concrete example and a suggested next step. Take them from evidence (incidents, review threads, the user's own notes), never from personality. If the person already owned the issue well, say so. When the user was part of the friction, say that the user shares it.
- **Growth potential.** Tie it to last year's review where one exists ("Last year my main point was X, and this year he did that"). Show initiative with examples nobody asked them to do. End with the next step at the scope above their current one.
- **Reviewer info.** The user's name and their relationship to the colleague (teammate, direct teammate, cross-functional).

## Self review shape

Use the form's own parts, usually Performance and Growth. Inside them:

- **Summary.** Two or three sentences on the year's theme. Managers have asked for a summary paragraph before.
- **Key outcomes.** Bullets, one per major win, each one bolded label, then what happened, then a number. Where the value is in what the work made possible, say what it enabled.
- **Framework dimensions** named by the form (for example Knowledge, Delivery, Collaboration). Write one short paragraph each, with examples not already used above.
- **Challenges and what I'd do differently.** Two to four honest bullets: self-caused incidents, claims that were later corrected, too much work in progress, gaps in communication. Each one names the lesson and what already changed because of it.
- **Growth: drive.** The work nobody asked for.
- **Growth: acting on feedback.** Quote or paraphrase each piece of feedback the user received, and show what changed because of it.
- **Growth: beyond my current role.** Map the year onto the target level's framework rows, for example direction across the area, quantifying cost, raising other people's capability, the operational bar. Use only claims the evidence supports.
- **Growth: where I want to grow.** Take these from the target level's rows that are still thin, plus the development points from the reviews the user received. Say each one as a commitment, not a confession.

When the previous self review contains a forecast or goal, compare it with what actually happened. A forecast of ~$10k against a measured ~$90k makes a strong line. At mid-year, end the growth part with concrete goals for the second half, since the year-end review will be measured against them.

## Honesty rules

- Credit colleagues by name for what they built, even inside the user's own wins. A reviewer who checks git will trust everything else in the review more.
- Give a number in the form a manager would verify. When there are two forms, give both in one clause ("about $102k at on-demand prices, about $87k on the actual bill").
- When the user's comments contain something the evidence contradicts, the draft follows the evidence, and the hand-over message explains why.

## File template

```markdown
---
type: note
tags: [work/<area>, review]
creation date: YYYY-MM-DD HH:mm
modification date: YYYY-MM-DD HH:mm
---

# Peer review <year> <cycle>: [[<person note name>]]

Form: <link>
Deadline: <date>

## Reviewer Info

- Your Name: <user>
- Relationship to Employee: <relationship>

## Part 1: <exact heading>

<paste-ready text>

## Part 2: <exact heading>

<paste-ready text>

## Part 3: <exact heading>

<paste-ready text>

---

## Evidence (not for pasting)

- <claim>: <permalink / ticket / [[vault note]]>
```

For the self review the title is `# Self review <year> <cycle>`. Use `## Employee Info` instead of Reviewer Info, and list the form and career framework links under the title.
