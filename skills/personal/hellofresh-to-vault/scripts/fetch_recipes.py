#!/usr/bin/env python3
"""Fetch public HelloFresh recipe pages into one JSON file per recipe.

Usage: fetch_recipes.py SLUGS_FILE OUT_DIR [--domain hellofresh.nl] [--locale en-NL]
                        [--skip-existing COOKING_DIR]

SLUGS_FILE has one recipe slug per line (extra leading columns are ignored, the
slug is the last field). --skip-existing drops slugs already referenced by a
`source:` line in any note under COOKING_DIR.
"""
import argparse
import html
import json
import os
import re
import urllib.request

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/130 Safari/537.36"


def strip_html(s):
    s = re.sub(r"</li>\s*<li>", "\n", s or "")
    return html.unescape(re.sub(r"<[^>]+>", " ", s)).replace("\xa0", " ").strip()


def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    return urllib.request.urlopen(req, timeout=30).read().decode()


def existing_slugs(cooking_dir):
    found = set()
    for root, _, files in os.walk(cooking_dir):
        for f in files:
            if f.endswith(".md"):
                for m in re.finditer(r"/recipes/([\w-]+)", open(os.path.join(root, f)).read()):
                    found.add(m.group(1))
    return found


def fetch(slug, domain, locale):
    url = f"https://www.{domain}/recipes/{slug}"
    page = get(f"{url}?locale={locale}")
    ld = next(
        j
        for raw in re.findall(r'<script type="application/ld\+json"[^>]*>(.*?)</script>', page, re.S)
        for j in [json.loads(raw)]
        if isinstance(j, dict) and j.get("@type") == "Recipe"
    )
    nd = json.loads(re.search(r'<script id="__NEXT_DATA__"[^>]*>(.*?)</script>', page, re.S).group(1))
    rec = nd["props"]["pageProps"]["ssrPayload"]["recipe"]
    return {
        "url": url,
        "name": ld.get("name"),
        "headline": rec.get("headline"),
        "totalTime": ld.get("totalTime"),
        "difficulty": rec.get("difficulty"),
        "servings": ld.get("recipeYield"),
        "category": ld.get("recipeCategory"),
        "cuisine": ld.get("recipeCuisine"),
        "tags": [t.get("name") for t in rec.get("tags", [])],
        "nutrition": {k: v for k, v in (ld.get("nutrition") or {}).items() if v and k != "@type"},
        "ingredients": ld.get("recipeIngredient"),
        "description": strip_html(rec.get("description") or ld.get("description")),
        "image": rec.get("imagePath"),
        "steps": [
            {
                "index": s["index"],
                "caption": next((i.get("caption") for i in s.get("images") or [] if i.get("caption")), ""),
                "text": strip_html(s.get("instructions")),
                "images": [i["path"] for i in s.get("images") or []],
            }
            for s in rec.get("steps", [])
        ],
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("slugs_file")
    ap.add_argument("out_dir")
    ap.add_argument("--domain", default="hellofresh.nl")
    ap.add_argument("--locale", default="en-NL")
    ap.add_argument("--skip-existing")
    a = ap.parse_args()

    os.makedirs(a.out_dir, exist_ok=True)
    skip = existing_slugs(a.skip_existing) if a.skip_existing else set()
    for line in open(a.slugs_file):
        if not line.strip():
            continue
        slug = line.split()[-1]
        if slug in skip:
            print("exists", slug)
            continue
        try:
            data = fetch(slug, a.domain, a.locale)
        except Exception as e:
            print("FAIL", slug, e)
            continue
        json.dump(data, open(os.path.join(a.out_dir, f"{slug}.json"), "w"), indent=1, ensure_ascii=False)
        print("ok", slug, len(data["ingredients"] or []), "ingredients", len(data["steps"]), "steps")


if __name__ == "__main__":
    main()
