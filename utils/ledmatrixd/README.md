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

`regmap.bin` and `layout.bin` describe the physical LED wiring and usable pixel
mask recovered from the device. `openwrt.bin` is an independently generated
default bitmap.
