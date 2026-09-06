#!/usr/bin/env python3
"""Replace Flutter's deprecated SW (it reloads every tab) with a silent unregister."""

from pathlib import Path

SW = """'use strict';
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    try { await self.registration.unregister(); } catch (e) {}
    try {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
    } catch (e) {}
  })());
});
"""

path = Path(__file__).resolve().parents[1] / "build" / "web" / "flutter_service_worker.js"
path.write_text(SW, encoding="utf-8")
if "client.navigate" in path.read_text(encoding="utf-8"):
    raise SystemExit("RED — service worker still reloads clients")
print("GREEN — service worker will not reload the tab")
