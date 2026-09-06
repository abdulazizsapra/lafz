# لفظ (Lafz)

Daily Urdu Wordle — five letters, five guesses, custom Urdu keyboard.

Play: https://www.abdulaziz.au/lafz/

GitHub: https://github.com/abdulazizsapra/lafz

Current release: **1.1.4** — see [CHANGELOG.md](CHANGELOG.md).

## Web

```bash
flutter build web --release --base-href /lafz/ --no-web-resources-cdn
```

Pushing `main` deploys `build/web` via `.github/workflows/deploy-web.yml`.
The site URL is `/lafz/` because this is a project Pages site, not the profile root.

Local preview (serves `/lafz/` on port 8081):

```bash
flutter build web --release --base-href /lafz/
mkdir -p build/pages/lafz && rsync -a --delete build/web/ build/pages/lafz/
python3 tool/serve_local.py
```

## Words

Daily puzzles come from `assets/words/urdu_5letter.txt` (26,830 five-letter Urdu words), filtered from the CRULP / NUCES word list. See `assets/words/NOTICE.txt` for attribution and license terms.
