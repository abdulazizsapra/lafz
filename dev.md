# Development Log - lafz

Urdu Wordle game (Flutter). Single daily puzzle, 5 attempts, 5x5 grid, custom Urdu keyboard, stats + share.

## Decisions
- 2026-09-04: Maintain `dev.md` to track progress, decisions, next steps.
- 2026-09-04: Keep project skill at `~/.claude/skills/lafz/SKILL.md`, update it as patterns/error fixes emerge.
- 2026-09-04: `game_screen.dart` — game-over `Padding` and keyboard `Padding` are siblings in the body `Column`, NOT nested if/else. Fixes "Can't find ')' to match '('" (missing `),` closing `Column(` inside keyboard `Padding`).
- 2026-09-04: Grid columns are dynamic (`cols = puzzle.wordLength`) for crossAxisCount/itemCount/row-col math — fixes last column always empty (was hardcoded 5 vs 4-letter mock word).
- 2026-09-04: Only the active row (`row == currentRow`) renders the in-progress guess; future rows render empty — fixes every unplayed row mirroring the typed letters. Guess indexing is grapheme-safe via `.characters`.
- 2026-09-04: Submitted-row tiles guarded by `row < guesses.length && row < evaluations.length` and `col < guess.length && col < eval.states.length`; `loadSavedGame()` clamps restored `currentRow` to in-memory guesses length — fixes startup `RangeError (length)` (persistence saves guesses as unparseable `toString`, so a restored row ≥1 indexed empty lists).

- 2026-09-04: Keyboard letter states wired up — `_keyStates` getter folds all submitted guesses+evaluations into best-per-letter TileState (correct > present > absent, never downgrades) and passes it to `UrduKeyboard` (was hardcoded `{}`). Absent letters grey out via existing `AppColors.absent`; present/correct show yellow/green. Matching is by `unit.display` == keyboard key (tokenizer preserves raw graphemes).

- 2026-09-04: Mock puzzle switched to 5-letter word زندگی (both screen + controller initial state) — grid renders 5 columns via existing dynamic `cols = wordLength`.

- 2026-09-04: Keyboard layout rewritten — old rows had duplicate keys (ل, ق, ع, غ, ظ, ر, ك twice), Arabic Yeh ي (U+064A) instead of Urdu ی (U+06CC), Arabic Kaf ك instead of Urdu ک, and no plain Alef ا. New 4x10 layout covers the full Urdu alphabet with correct codepoints, no duplicates. Normalizer now maps Arabic Yeh/Kaf/hamza-alefs to Urdu forms for comparison (Alef-madda NOT merged — distinct letter).
- 2026-09-04: Grid changed to 5x5 — `itemCount: 5 * cols`, `maxAttempts = 5`.

- 2026-09-04: Hint system (3 per game) — lightbulb AppBar action with remaining-count badge; each tap reveals the leftmost not-yet-hinted target letter + position in a Snackbar and decrements. `GameState` gained `hintsLeft` (default 3) + `hintedPositions`; `GameController.useHint()` returns `HintResult?` (null when game over / none left / all revealed).

- 2026-09-04: Onboarding screen (4 swipeable RTL pages: welcome, how-to-play with tile examples, keyboard colors, 3-hint explainer; dots + skip/next + start button). Shown once via `lafz_onboarding_seen` SharedPreferences flag; `main.dart` gates on it with FutureBuilder. Also fixed stale 'چھ کوششیں' text in help screen → پانچ.

- 2026-09-04: Word source built (Both): `assets/words/urdu_5letter.txt` with 139 verified 5-letter Urdu words + `WordRepository` (bundled daily pick by date, deterministic across players; `AppConfig.remotePuzzleUrl` hook for server override with 5s timeout, empty = disabled). GameScreen loads today's puzzle async with spinner + offline fallback. Share text now uses real maxAttempts (/5). Self-caught: bulk rename broke `game_controller.dart` import — fixed.

- 2026-09-04: Web/PWA — branded `web/manifest.json` + `index.html` (لفظ name, Urdu description, green theme), `flutter build web --release` OK, served at http://localhost:8080 via `python3 -m http.server 8080 -d build/web` (note: flag is `-d`, not `--directory`). Installable as PWA from localhost (service worker + icons + manifest all 200).
- 2026-09-06: Replaced bundled list with 26,830 five-letter Urdu words filtered from CRULP/NUCES `wordlist.txt` (UTF-16; skip phrases; keyboard alphabet + hamza variants; keep ہمراہ/ہمسفر/ہمراز). Credit in `assets/words/NOTICE.txt`.
- 2026-09-06: GitHub Pages project site at `/lafz/` (`flutter build web --release --base-href /lafz/`). Workflow `.github/workflows/deploy-web.yml` builds on `main` and deploys via `actions/deploy-pages`. Live URL uses profile domain: https://www.abdulaziz.au/lafz/
- 2026-09-06: Bundled Noto Naskh Arabic (OFL) so Flutter web/CanvasKit can render Urdu. Theme + `GameTile` use `Noto Naskh Arabic` instead of missing Jameel Noori Nastaleeq.
- 2026-09-06: Play window — desktop/tablet clamps to 420×840 centered device frame (`PlayWindow` via `MaterialApp.builder`); phones stay full-bleed. Keyboard uses 44px keys + Urdu enter/backspace; tiles size from the grid cell.
- 2026-09-06: Progress cookies — `lafz_game`, `lafz_onboarding_seen`, `lafz_stats` written as cookies (plus SharedPreferences fallback). JSON restore of guesses/evals/hints; ignore save if puzzle id is a different day.
- 2026-09-06: Win/lose result dialog shows the word plus Wiktionary Urdu gloss (`WordMeaning.fromWiktionaryJson`, prefer `ur` key, strip HTML). Fetch is CORS-open REST `page/definition/{word}`. Missing entries show "معنی دستیاب نہیں".
- 2026-09-06: Local preview — `tool/serve_local.py` on :8081 (`/lafz/`, no-store for html/js, `/` → `/lafz/`). `web/index.html` has a boot splash so a slow CanvasKit load is not a black page. Play window fills viewport height (480px wide) instead of a 420×840 postage stamp.

## Current Status
- `flutter analyze` on touched files: clean (1 unused import, 1 unused var, 1 async-context info remain).
- `flutter build ios --debug` (team 955FF8582B): BUILD SUCCEEDED.
- Fresh `flutter run -d 00008150-001575680CF8401C` installed + launched; run log has 0 RangeError/EXCEPTION lines, VM/DevTools service up. Grid renders 5 columns matching mock word; typing fills only the active row; keyboard keys color by guess history (grey/yellow/green).
- Killed stale duplicate `flutter run` sessions (old 12:26 + stuck 12:32) that blocked reinstall.

- 2026-09-06: Wordle-like UI — flat 500px play window (no phone frame), `WordleHeader`, square 0-radius tiles, Wordle green/yellow/gray + gray keyboard, light theme, landing page (`#E3E3E3`, 3×3 logo, black **کھیلیں** pill). Game stays 5×5. Verified locally at http://127.0.0.1:8081/lafz/.
- 2026-09-06: Release **1.1.1+3** — live site stuck on HTML splash. Cause: `flutter_bootstrap.js` registered Flutter’s deprecated SW (unregister + `client.navigate` reload) and `#lafz-boot` was never removed. Fix: custom loader with no SW, hide splash on `onEntrypointLoaded`, `--no-web-resources-cdn`. Check: `python3 tool/check_web_boot.py`.

## Next Steps
- [ ] Fix persistence properly: save guess units as JSON, restore guesses+evaluations in `loadSavedGame` (replaces clamp workaround).
- [ ] Remove unused import (`game_engine.dart`) and unused `screenWidth`; guard `context` after `await` in `_openStats`.
- [x] Replace mock puzzle with real daily-puzzle loading (bundled list).
- [x] Repo https://github.com/abdulazizsapra/lafz pushed; Pages source = GitHub Actions. Public URL: https://www.abdulaziz.au/lafz/ (profile custom domain).
- [x] Restyle game + landing to match Wordle chrome (keep لفظ branding, 5 attempts).
- [ ] Confirm game-over/keyboard layout + tile colors on device.
- [ ] Release build (`flutter build ios --release`) when ready for TestFlight.
- [ ] Push Wordle UI to GitHub Pages when ready.
