#!/usr/bin/env python3
"""Fail if the built web bundle can stick on the HTML splash.

The 1.1.0 live page registered Flutter's deprecated service worker
(which unregisters itself and reloads the tab) and never hid #lafz-boot.
"""

from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
html = (root / "build" / "web" / "index.html").read_text(encoding="utf-8")

errors: list[str] = []
if "{{flutter" in html:
    errors.append("Flutter template tokens were not replaced")
if "flutter_bootstrap.js" in html:
    errors.append("index.html still loads flutter_bootstrap.js (registers SW)")
# flutter.js mentions the option name; only fail if we actually pass it.
if "serviceWorkerSettings:" in html.split("_flutter.loader.load")[-1][:800]:
    errors.append("loader.load still passes serviceWorkerSettings")
if "lafz-boot" not in html:
    errors.append("splash #lafz-boot is missing")
if "getElementById('lafz-boot')" not in html and 'getElementById("lafz-boot")' not in html:
    errors.append("splash is never removed when Flutter starts")
if '"useLocalCanvasKit":true' not in html:
    errors.append("CanvasKit is not pinned to the same origin")

if errors:
    print("RED — web boot is unsafe:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)

print("GREEN — no service worker, splash is removed when the engine starts")
