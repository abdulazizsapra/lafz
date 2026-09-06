# لفظ (Lafz)

Daily Urdu Wordle — five letters, five guesses, custom Urdu keyboard.

Play: https://www.abdulaziz.au/lafz/

GitHub: https://github.com/abdulazizsapra/lafz

## Web

```bash
flutter build web --release --base-href /lafz/
```

Pushing `main` deploys `build/web` via `.github/workflows/deploy-web.yml`.
The site URL is `/lafz/` because this is a project Pages site, not the profile root.

Local preview:

```bash
python3 -m http.server 8080 -d build/web
```

## Words

Daily puzzles come from `assets/words/urdu_5letter.txt` (26,830 five-letter Urdu words), filtered from the CRULP / NUCES word list. See `assets/words/NOTICE.txt` for attribution and license terms.
