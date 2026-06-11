import os, glob

TOKEN = "[REDACTED_GITHUB_TOKEN]"

for fpath in glob.glob("**/*.md", recursive=True):
    if not os.path.isfile(fpath):
        continue
    try:
        with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        if TOKEN in content:
            content = content.replace(TOKEN, "[REDACTED_GITHUB_TOKEN]")
            with open(fpath, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"Cleaned: {fpath}")
    except Exception as e:
        print(f"Skip: {fpath} - {e}")
