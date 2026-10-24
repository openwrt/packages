# ledmatrixd

`ledmatrixd` controls the 24 x 67 front-panel LED matrix on the TP-Link Archer
BE800. It uses the three I2C LED controllers exposed by the device tree.

## Configuration

The `ledmatrix.main.mode` UCI option accepts:

- `blank`: all pixels off
- `bitmap`: display the 201-byte bitmap at `ledmatrix.main.bitmap`
- `blink`: blink that bitmap using `ledmatrix.main.interval`
- `clock`: display local time in a compact layout
- `clock-stacked`: display local time in a stacked layout
- `scroll`: scroll `ledmatrix.main.text`

Bitmaps are 24 x 67 pixels in row-major order, MSB first. Save changes with
`uci commit ledmatrix && /etc/init.d/ledmatrixd reload`.

No binary data files are shipped. The physical panel description lives in
readable text sources: `files/layout.txt` (ASCII art of the 24 x 67 pixel
grid, '#' marks a physically present LED) and `files/regmap.txt` (one
`row col tile led` entry per physical pixel, naming the controller 1-3 and
LED 0-191 it is wired to). The wiring table is compiled into the daemon
(`src/panel.c`, regenerate and validate with `python3 tools/gen-maps.py`);
the layout mask and the default bitmap are generated at build time from
their ASCII-art sources by `files/art2bin.awk`.
