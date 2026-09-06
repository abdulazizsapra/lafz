#!/usr/bin/env python3
"""Fail if the built web bundle can stick on a loading splash."""

from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
html = (root / "build" / "web" / "index.html").read_text(encoding="utf-8")
sw = (root / "build" / "web" / "flutter_service_worker.js").read_text(encoding="utf-8")

errors: list[str] = []
if "{{flutter" in html:
    errors.append("Flutter template tokens were not replaced")
if "flutter_bootstrap.js" in html:
    errors.append("index.html still loads flutter_bootstrap.js")
if "لوڈ ہو رہا ہے" in html:
    errors.append("HTML still shows a loading splash")
if "کھیلیں" not in html:
    errors.append("HTML landing is missing the Play button")
if "serviceWorkerSettings:" in html.split("_flutter.loader.load")[-1][:800]:
    errors.append("loader.load still passes serviceWorkerSettings")
if '"useLocalCanvasKit":true' not in html:
    errors.append("CanvasKit is not pinned to the same origin")
if "client.navigate" in sw:
    errors.append("service worker still reloads clients")
if not (root / "build" / "web" / "favicon.ico").exists():
    errors.append("favicon.ico is missing from the web build")
if "favicon.ico" not in html:
    errors.append("index.html does not link favicon.ico")

if errors:
    print("RED — web boot is unsafe:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)

print("GREEN — landing is HTML, no loading splash, SW will not reload")
