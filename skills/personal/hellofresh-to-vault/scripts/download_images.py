#!/usr/bin/env python3
"""Download a recipe's cover and step photos into the vault.

Usage: download_images.py RECIPE_JSON VAULT_ROOT REL_DIR

Saves REL_DIR/main.jpg and REL_DIR/step-<N>.jpg under VAULT_ROOT, then prints
JSON with vault-relative paths ready for ![[...]] embeds:
  {"cover": "...", "steps": {"1": ["..."], "2": ["..."]}}
"""
import json
import os
import sys
import urllib.request

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/130 Safari/537.36"
IMG = "https://img.hellofresh.com/f_auto,fl_lossy,q_auto,w_{w}/hellofresh_s3{path}"


def save(path, vault, rel, width):
    dest = os.path.join(vault, rel)
    if not os.path.exists(dest) or os.path.getsize(dest) == 0:
        req = urllib.request.Request(IMG.format(w=width, path=path), headers={"User-Agent": UA})
        data = urllib.request.urlopen(req, timeout=60).read()
        tmp = dest + ".part"
        with open(tmp, "wb") as f:
            f.write(data)
        os.replace(tmp, dest)
    return rel


def main():
    recipe = json.load(open(sys.argv[1]))
    vault, rel_dir = sys.argv[2], sys.argv[3].strip("/")
    os.makedirs(os.path.join(vault, rel_dir), exist_ok=True)

    out = {"cover": save(recipe["image"], vault, f"{rel_dir}/main.jpg", 1200), "steps": {}}
    for step in recipe["steps"]:
        out["steps"][str(step["index"])] = [
            save(p, vault, f"{rel_dir}/step-{step['index']}{f'-{k + 1}' if k else ''}.jpg", 800)
            for k, p in enumerate(step["images"])
        ]
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
