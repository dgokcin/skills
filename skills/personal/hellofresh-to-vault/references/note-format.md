# HelloFresh recipe note format

One note per recipe in `~/vault/personal/cooking/`. The cookbook base (`personal/bases/cookbook.base`) lists notes with `type: recipe`, shows `rating` as stars, and uses `cover` for its gallery view.

## File name

Short lowercase English dish name, ASCII only, no apostrophes or punctuation, spaces between words, `.md`. Drop the HelloFresh headline. Keep the words that tell similar dishes apart.

- "Creamy Shrimp Linguine with lemon, tomato & roasted courgette" → `creamy shrimp linguine.md`
- "Pork Tenderloin with Mozzarella" → `pork tenderloin with mozzarella.md`, not `pork tenderloin.md`

Never overwrite an existing note. If the name is taken by another dish, pick a more specific one.

## Frontmatter

```yaml
type: recipe
title: Creamy Shrimp Linguine             # Title Case, no headline, no shouting caps or emoji
ingredients:
  - 180g linguine
  - 160g shrimp
  - 1 tsp smoked paprika + ½ tsp garlic powder + pinch of brown sugar (BBQ rub)
  - 100ml oat cooking cream
  - 2 tbsp olive oil
  - salt and pepper to taste
tags:
  - cooking
  - dinner
  - Italian          # cuisine
  - seafood          # main protein, or vegetarian
  - pasta            # base: pasta, rice, noodles, bulgur, potatoes, salad, soup...
prep_time: 10 min
cook_time: 25 min    # prep + cook = totalTime from the JSON
difficulty: Medium   # JSON difficulty 1 → Easy, 2 → Medium, 3 → Hard
rating:              # left empty, the user fills it in (1-5)
servings: 2
category: Main course
calories: 657 kcal per serving
protein: 27.6g per serving
notes: Original HelloFresh recipe adapted for supermarket ingredients. <key substitutions>. <one useful tip>.
origin: Hellofresh
source: https://www.hellofresh.nl/recipes/<slug>
cover: "[[personal/cooking/attachments/hellofresh/<note name>/main.jpg]]"
```

No `steps:` key. Steps live in the body, under their photos. Quote any string that contains a colon or `#`, or starts with a special character.

### Ingredients: supermarket equivalents

HelloFresh ships tiny sachets, pots and branded items you can't buy as such. Rewrite each one as something a normal supermarket sells, with a usable amount.

| HelloFresh | Write instead |
| --- | --- |
| 1 sachet BBQ spice rub / any spice-blend sachet | the blend in tsp, or its main spices (smoked paprika, cumin...) |
| stock pot or "350 ml stock" | 350ml stock (1 stock cube dissolved in hot water) |
| small pots of miso, teriyaki, pesto, sambal, sour cream... | the same product, measured in tbsp/tsp |
| 8 ml truffle oil | a drizzle (about 2 tsp) truffle oil |
| 2.5-10 g fresh herb bag | small handful fresh X (or 1 tsp dried) |
| brand names (Oatly, Brandt & Levie...) | the generic product (oat cooking cream, fresh Italian sausage) |
| "mix of carrot, onion and celery" | 200g soffritto mix (or 1 small carrot, ½ onion, 1 celery stalk, diced) |
| gomashio | toasted sesame seeds + pinch of salt |
| [Plant-based] butter, [Reduced salt] ketjap | butter, ketjap manis (sweet soy sauce) |

Use plain counts for "piece" items ("1 courgette", "2 cloves garlic"). Pantry items (oil, salt, pepper, vinegar, sugar) go at the end of the list. Use the recipe's own ingredient JSON as the source and keep the quantities for its stated servings.

## Body

Cover photo first, then one section per HelloFresh step, in order. Each section has the step's caption as its heading, its photo, then the step written as short imperative bullets.

```markdown
![[personal/cooking/attachments/hellofresh/<note name>/main.jpg]]

## Steps

### 1. Prepare
![[personal/cooking/attachments/hellofresh/<note name>/step-1.jpg]]

- Boil plenty of water in a pot and crumble in half a stock cube.
- Dice the eggplant into 1cm cubes and halve the tomatoes.

### 2. Fry the eggplant
![[personal/cooking/attachments/hellofresh/<note name>/step-2.jpg]]

- Heat a drizzle of olive oil in a large deep frying pan over high heat.
- Fry the eggplant for 10-12 minutes until golden brown.
```

- Write the bullets from that step's `text` in the JSON, so each instruction sits under the photo it belongs to.
- Use the supermarket ingredient names, not HelloFresh's ("the smoked paprika mix", not "the BBQ spice rub sachet").
- 1-2 sentences per bullet. Drop "see pantry for amount", asterisks and footnotes; fold useful footnotes into a bullet.
- Use the embed paths printed by `download_images.py`. A step with no caption gets `### Step N`. A step with no photo gets no embed line.
