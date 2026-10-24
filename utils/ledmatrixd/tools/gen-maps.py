#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Maintainer tool for the ledmatrixd panel data.

Text sources (files/):
  layout.txt    67 lines x 24 chars, '#' = pixel present, '.' = no LED
  regmap.txt    one entry per physical pixel: "row col tile led"
  openwrt.txt   same ASCII-art format, the default bitmap

This script regenerates src/panel.c (the compiled-in wiring table used by
ledmatrixd) and validates that the regmap entries match the layout mask
exactly. layout.bin and openwrt.bin are not stored in the tree: the package
Makefile generates them at build time with files/art2bin.awk.

Run from the package directory:  python3 tools/gen-maps.py
"""

from pathlib import Path

W, H = 24, 67
root = Path(__file__).resolve().parent.parent
files, src = root / "files", root / "src"


def read_art(path):
    lines = path.read_text().splitlines()
    if len(lines) != H or any(len(l) != W for l in lines):
        raise SystemExit(f"{path.name}: expected {H} lines of {W} chars")
    mask = set()
    for y, line in enumerate(lines):
        for x, ch in enumerate(line):
            if ch == "#":
                mask.add((y, x))
            elif ch != ".":
                raise SystemExit(f"{path.name}:{y + 1}: bad char {ch!r}")
    return mask


def read_regmap(path):
    entries, seen = [], set()
    for n, line in enumerate(path.read_text().splitlines(), 1):
        line = line.split("#")[0].strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) != 4:
            raise SystemExit(f"{path.name}:{n}: expected 'row col tile led'")
        row, col, tile, led = map(int, parts)
        if not (0 <= row < H and 0 <= col < W and 1 <= tile <= 3 and 0 <= led < 192):
            raise SystemExit(f"{path.name}:{n}: value out of range")
        if (row, col) in seen:
            raise SystemExit(f"{path.name}:{n}: duplicate pixel")
        seen.add((row, col))
        entries.append((row, col, tile, led))
    return entries, seen


def write_panel_c(entries):
    lines = [
        "// SPDX-License-Identifier: GPL-2.0-or-later\n",
        "/* Physical wiring of the Archer BE800 front panel: each entry maps one panel\n",
        " * pixel (row, col) to the controller 1-3 and LED 0-191 within its 12x16 matrix\n",
        " * that drives it. Source table: files/regmap.txt; regenerate and validate this\n",
        " * file with tools/gen-maps.py. */\n",
        "\n",
        '#include "panel.h"\n',
        "\n",
        f"const struct panel_pixel panel_map[PANEL_PIXELS] = {{\n",
    ]
    lines += [f"\t{{ {r}, {c}, {t}, {l} }},\n" for r, c, t, l in entries]
    lines.append("};\n")
    (src / "panel.c").write_text("".join(lines))


def main():
    mask = read_art(files / "layout.txt")
    read_art(files / "openwrt.txt")
    entries, mapped = read_regmap(files / "regmap.txt")
    if mapped != mask:
        raise SystemExit("regmap entries do not match the layout mask exactly")
    write_panel_c(entries)
    print(f"src/panel.c written and validated ({len(entries)} mapped pixels)")


if __name__ == "__main__":
    main()
