#!/usr/bin/env python3
"""Serve the Flutter web build at http://127.0.0.1:8081/lafz/."""

from __future__ import annotations

import argparse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


class LafzHandler(SimpleHTTPRequestHandler):
    def end_headers(self) -> None:
        if self.path.endswith((".js", ".html", ".json", ".wasm")):
            self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_GET(self) -> None:
        if self.path in ("/", "/lafz"):
            self.send_response(301)
            self.send_header("Location", "/lafz/")
            self.end_headers()
            return
        super().do_GET()

    def log_message(self, format: str, *args) -> None:
        print(f"{self.address_string()} - {args[0]}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8081)
    parser.add_argument(
        "--root",
        default=str(Path(__file__).resolve().parents[1] / "build" / "pages"),
    )
    args = parser.parse_args()
    handler = lambda *a, **k: LafzHandler(*a, directory=args.root, **k)
    server = ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    print(f"Serving {args.root} at http://127.0.0.1:{args.port}/lafz/", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
