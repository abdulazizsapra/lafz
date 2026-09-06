#!/usr/bin/env python3
"""Build Lafz favicons: Wordle-style tiles, no Flutter bird."""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

GREEN = (0x6A, 0xAA, 0x64, 255)
YELLOW = (0xC9, 0xB4, 0x58, 255)
EMPTY = (0xD3, 0xD6, 0xDA, 255)
BG = (0xE3, 0xE3, 0xE3, 255)
INK = (0x1A, 0x1A, 0x1B, 255)

# Landing-page 3x3 (row-major).
LOGO = [
    GREEN, EMPTY, YELLOW,
    EMPTY, GREEN, EMPTY,
    YELLOW, EMPTY, GREEN,
]


def png_rgba(width: int, height: int, pixels: bytes) -> bytes:
    def chunk(tag: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)

    raw = b""
    stride = width * 4
    for y in range(height):
        raw += b"\x00" + pixels[y * stride : (y + 1) * stride]
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def fill(size: int, color: tuple[int, int, int, int]) -> list[int]:
    return list(color) * (size * size)


def blit(
    dest: list[int],
    dest_size: int,
    src_color: tuple[int, int, int, int],
    x: int,
    y: int,
    w: int,
    h: int,
) -> None:
    for row in range(h):
        for col in range(w):
            i = ((y + row) * dest_size + (x + col)) * 4
            dest[i : i + 4] = src_color


def tile_icon(size: int, *, pad_ratio: float = 0.12) -> bytes:
    pixels = fill(size, BG)
    pad = max(1, round(size * pad_ratio))
    inner = size - pad * 2
    gap = max(1, inner // 16)
    cell = (inner - gap * 2) // 3
    used = cell * 3 + gap * 2
    ox = pad + (inner - used) // 2
    oy = pad + (inner - used) // 2
    for i, color in enumerate(LOGO):
        r, c = divmod(i, 3)
        blit(
            pixels,
            size,
            color,
            ox + c * (cell + gap),
            oy + r * (cell + gap),
            cell,
            cell,
        )
    return png_rgba(size, size, bytes(pixels))


def ico_from_pngs(pngs: list[bytes]) -> bytes:
    count = len(pngs)
    header = struct.pack("<HHH", 0, 1, count)
    entries = b""
    payload = b""
    offset = 6 + 16 * count
    for png in pngs:
        w = png[16:20]
        h = png[20:24]
        width = struct.unpack(">I", w)[0]
        height = struct.unpack(">I", h)[0]
        entries += struct.pack(
            "<BBBBHHII",
            width if width < 256 else 0,
            height if height < 256 else 0,
            0,
            0,
            1,
            32,
            len(png),
            offset,
        )
        payload += png
        offset += len(png)
    return header + entries + payload


def main() -> None:
    root = Path(__file__).resolve().parents[1] / "web"
    icons = root / "icons"
    icons.mkdir(exist_ok=True)

    png16 = tile_icon(16, pad_ratio=0.08)
    png32 = tile_icon(32, pad_ratio=0.10)
    png48 = tile_icon(48, pad_ratio=0.10)
    png192 = tile_icon(192, pad_ratio=0.12)
    png512 = tile_icon(512, pad_ratio=0.12)
    mask192 = tile_icon(192, pad_ratio=0.18)
    mask512 = tile_icon(512, pad_ratio=0.18)

    (root / "favicon.png").write_bytes(png32)
    (root / "favicon.ico").write_bytes(ico_from_pngs([png16, png32, png48]))
    (icons / "Icon-192.png").write_bytes(png192)
    (icons / "Icon-512.png").write_bytes(png512)
    (icons / "Icon-maskable-192.png").write_bytes(mask192)
    (icons / "Icon-maskable-512.png").write_bytes(mask512)
    print("wrote favicon.ico, favicon.png, and web/icons")


if __name__ == "__main__":
    main()
