# Changelog

All notable changes to لفظ are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and version numbers follow [Semantic Versioning](https://semver.org/).

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
