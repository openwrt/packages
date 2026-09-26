// SPDX-License-Identifier: GPL-2.0-or-later
#ifndef LEDMATRIXD_PANEL_H
#define LEDMATRIXD_PANEL_H

#include <stdint.h>

#define PANEL_WIDTH 24
#define PANEL_HEIGHT 67
#define PANEL_PIXELS 368

struct panel_pixel {
	uint8_t row, col, tile, led;
};

extern const struct panel_pixel panel_map[PANEL_PIXELS];

#endif
