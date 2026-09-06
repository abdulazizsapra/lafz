# Changelog

All notable changes to لفظ are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and version numbers follow [Semantic Versioning](https://semver.org/).

## [1.1.4] — 2026-09-06

### Added
- Guess must be in the word list or the row is not consumed.
- Reset / **نیا لفظ** starts a new random practice word without counting a mid-game loss.

[1.1.4]: https://github.com/abdulazizsapra/lafz/releases/tag/v1.1.4

## [1.1.3] — 2026-09-06

### Added
- Lafz favicon (Wordle-style 3×3 tiles) as `favicon.ico` / `favicon.png`, plus matching PWA icons.

[1.1.3]: https://github.com/abdulazizsapra/lafz/releases/tag/v1.1.3

## [1.1.2] — 2026-09-06

### Fixed
- First paint is the landing page (کھیلیں), not “لوڈ ہو رہا ہے…”.
- Flutter prefs read can no longer leave a spinner up; service worker no longer reloads the tab.

[1.1.2]: https://github.com/abdulazizsapra/lafz/releases/tag/v1.1.2

## [1.1.1] — 2026-09-06

### Fixed
- Stuck “لوڈ ہو رہا ہے…” splash: stop registering Flutter’s deprecated service worker (it reloaded the tab) and remove the splash when the engine starts.
- Load CanvasKit from the same origin instead of gstatic.com.

[1.1.1]: https://github.com/abdulazizsapra/lafz/releases/tag/v1.1.1

## [1.1.0] — 2026-09-06

### Added
- Wordle-style landing, hairline header, square tiles, and gray keyboard.
- Cookie-backed daily progress (`lafz_game`) plus SharedPreferences fallback.
- Wiktionary meanings on win/lose.
- Height-aware game layout so the board and Urdu keyboard share leftover space.

### Changed
- Play window is a flat 500px column (no phone frame).
- Light theme by default; viewport meta and `100dvh` so phones use the real screen.
- PWA orientation is `any` so landscape is playable.

### Fixed
- Desktop and short phones no longer overflow or look like a postage stamp.
- Stale service workers that left `/lafz/` blank after a deploy.

## [1.0.0] — 2026-09-06

### Added
- First public GitHub Pages release: daily 5-letter Urdu puzzle, 5 guesses, custom keyboard.
- CRULP 5-letter word list and bundled Noto Naskh Arabic.

[1.1.0]: https://github.com/abdulazizsapra/lafz/releases/tag/v1.1.0
[1.0.0]: https://github.com/abdulazizsapra/lafz/releases/tag/v1.0.0
