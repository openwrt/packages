// SPDX-License-Identifier: GPL-2.0-or-later
#include <errno.h>
#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <time.h>
#include <unistd.h>
#include <uci.h>

#define WIDTH 24
#define HEIGHT 67
#define FB_SIZE 201
#define MAP_SIZE (WIDTH * HEIGHT * 2)
#define SOCKET_PATH "/var/run/ledmatrixd.sock"
#define REGMAP_PATH "/usr/share/ledmatrixd/regmap.bin"
#define DEFAULT_BITMAP "/usr/share/ledmatrixd/openwrt.bin"

static const uint8_t chips[] = { 0x50, 0x53, 0x5c };
static uint8_t regmap[MAP_SIZE], page_cache[3];
static int i2c_fd = -1;
static volatile sig_atomic_t running = 1, reload_config = 0;

struct config {
	bool enabled;
	char device[64];
	char mode[16];
	char bitmap[256];
	char text[128];
	unsigned interval_ms;
	unsigned brightness;
};

static struct config cfg;
static bool preview_active;
static struct config preview_cfg;
static bool preview_frame_active;
static uint8_t preview_frame[FB_SIZE];
static bool bitmap_failed;

static const uint8_t font[][5] = {
	[' ' - 32] = {0,0,0,0,0}, ['-' - 32] = {0x08,0x08,0x08,0x08,0x08},
	[':' - 32] = {0,0x24,0,0x24,0},
	['0' - 32] = {0x3e,0x51,0x49,0x45,0x3e}, ['1' - 32] = {0,0x42,0x7f,0x40,0},
	['2' - 32] = {0x42,0x61,0x51,0x49,0x46}, ['3' - 32] = {0x21,0x41,0x45,0x4b,0x31},
	['4' - 32] = {0x18,0x14,0x12,0x7f,0x10}, ['5' - 32] = {0x27,0x45,0x45,0x45,0x39},
	['6' - 32] = {0x3c,0x4a,0x49,0x49,0x30}, ['7' - 32] = {0x01,0x71,0x09,0x05,0x03},
	['8' - 32] = {0x36,0x49,0x49,0x49,0x36}, ['9' - 32] = {0x06,0x49,0x49,0x29,0x1e},
	['A' - 32] = {0x7e,0x11,0x11,0x11,0x7e}, ['B' - 32] = {0x7f,0x49,0x49,0x49,0x36},
	['C' - 32] = {0x3e,0x41,0x41,0x41,0x22}, ['D' - 32] = {0x7f,0x41,0x41,0x22,0x1c},
	['E' - 32] = {0x7f,0x49,0x49,0x49,0x41}, ['F' - 32] = {0x7f,0x09,0x09,0x09,0x01},
	['G' - 32] = {0x3e,0x41,0x49,0x49,0x7a}, ['H' - 32] = {0x7f,0x08,0x08,0x08,0x7f},
	['I' - 32] = {0,0x41,0x7f,0x41,0}, ['J' - 32] = {0x20,0x40,0x41,0x3f,0x01},
	['K' - 32] = {0x7f,0x08,0x14,0x22,0x41}, ['L' - 32] = {0x7f,0x40,0x40,0x40,0x40},
	['M' - 32] = {0x7f,0x02,0x0c,0x02,0x7f}, ['N' - 32] = {0x7f,0x04,0x08,0x10,0x7f},
	['O' - 32] = {0x3e,0x41,0x41,0x41,0x3e}, ['P' - 32] = {0x7f,0x09,0x09,0x09,0x06},
	['Q' - 32] = {0x3e,0x41,0x51,0x21,0x5e}, ['R' - 32] = {0x7f,0x09,0x19,0x29,0x46},
	['S' - 32] = {0x46,0x49,0x49,0x49,0x31}, ['T' - 32] = {0x01,0x01,0x7f,0x01,0x01},
	['U' - 32] = {0x3f,0x40,0x40,0x40,0x3f}, ['V' - 32] = {0x1f,0x20,0x40,0x20,0x1f},
	['W' - 32] = {0x3f,0x40,0x38,0x40,0x3f}, ['X' - 32] = {0x63,0x14,0x08,0x14,0x63},
	['Y' - 32] = {0x07,0x08,0x70,0x08,0x07}, ['Z' - 32] = {0x61,0x51,0x49,0x45,0x43}
};

static void on_signal(int sig) { if (sig == SIGHUP) reload_config = 1; else running = 0; }

static int write_all(const void *buf, size_t len)
{
	const uint8_t *p = buf;
	while (len) { ssize_t n = write(i2c_fd, p, len); if (n < 0) return -1; p += n; len -= n; }
	return 0;
}

static int chip_write(uint8_t chip, const void *buf, size_t len)
{
	if (ioctl(i2c_fd, I2C_SLAVE_FORCE, chip) < 0 || write_all(buf, len) < 0) {
		fprintf(stderr, "ledmatrixd: I2C 0x%02x: %s\n", chip, strerror(errno)); return -1;
	}
	return 0;
}

static int select_page(unsigned tile, uint8_t page)
{
	uint8_t unlock[] = { 0xfe, 0xc5 }, select[] = { 0xfd, page };
	if (page_cache[tile] == page) return 0;
	if (chip_write(chips[tile], unlock, sizeof(unlock)) || chip_write(chips[tile], select, sizeof(select))) return -1;
	page_cache[tile] = page; return 0;
}

static int paged_write(unsigned tile, uint8_t page, uint8_t reg, const uint8_t *data, size_t len)
{
	uint8_t payload[32]; size_t off = 0;
	if (select_page(tile, page)) return -1;
	while (off < len) { size_t n = len - off > 31 ? 31 : len - off; payload[0] = reg; memcpy(payload + 1, data + off, n); if (chip_write(chips[tile], payload, n + 1)) return -1; reg += n; off += n; }
	return 0;
}

static int init_panel(void)
{
	uint8_t zero = 0, all[192], timing[] = { 0x44, 0x40, 0, 0 }, mode;
	memset(page_cache, 0xff, sizeof(page_cache));
	for (unsigned t = 0; t < 3; t++) {
		memset(all, 0xff, 24); if (paged_write(t, 3, 1, &zero, 1) || paged_write(t, 0, 0, all, 24)) return -1;
		memset(all, cfg.brightness, sizeof(all)); if (paged_write(t, 2, 0, all, sizeof(all))) return -1;
		memset(all, 0xff, sizeof(all));
		mode = 0x83;
		if (paged_write(t, 1, 0, all, sizeof(all)) || paged_write(t, 3, 2, timing, sizeof(timing)) || paged_write(t, 3, 0, &mode, 1) || paged_write(t, 3, 0x0e, &zero, 1)) return -1;
	}

	/* U-boot leaves the chips in breathe mode. Reset that state before frames. */
	for (unsigned t = 0; t < 3; t++) {
		memset(all, 0, sizeof(all));
		mode = 0x01;
		if (paged_write(t, 2, 0, all, sizeof(all)) || paged_write(t, 3, 0, &mode, 1)) return -1;
	}
	for (unsigned t = 0; t < 3; t++) {
		memset(all, cfg.brightness, sizeof(all));
		mode = 0x83;
		if (paged_write(t, 2, 0, all, sizeof(all)) || paged_write(t, 3, 0, &mode, 1)) return -1;
	}
	mode = 0x43;
	if (paged_write(0, 3, 0, &mode, 1)) return -1;
	mode = 0x3f;
	for (unsigned t = 0; t < 3; t++) {
		if (paged_write(t, 3, 1, &mode, 1)) return -1;
	}
	memset(all, 0, sizeof(all));
	for (unsigned t = 0; t < 3; t++) {
		mode = 0x01;
		if (paged_write(t, 2, 0, all, sizeof(all)) ||
		    paged_write(t, 3, 0, &mode, 1)) return -1;
	}
	return 0;
}

static int set_brightness(unsigned brightness)
{
	uint8_t pwm[192];

	if (brightness > 255) brightness = 255;
	memset(pwm, brightness, sizeof(pwm));
	for (unsigned t = 0; t < 3; t++)
		if (paged_write(t, 1, 0, pwm, sizeof(pwm))) return -1;
	return 0;
}

static void set_pixel(uint8_t fb[FB_SIZE], int x, int y, bool on)
{
	unsigned p; if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) return; p = y * WIDTH + x;
	if (on) fb[p / 8] |= 1u << (7 - p % 8); else fb[p / 8] &= ~(1u << (7 - p % 8));
}

static int push_frame(const uint8_t fb[FB_SIZE])
{
	uint8_t ctrl[3][24] = {{0}};
	for (unsigned px = 0; px < WIDTH * HEIGHT; px++) { unsigned tile = regmap[px * 2], led = regmap[px * 2 + 1]; if (tile && tile <= 3 && led < 192 && (fb[px / 8] & (1u << (7 - px % 8)))) ctrl[tile - 1][led / 8] |= 1u << (led % 8); }
	for (unsigned t = 0; t < 3; t++) if (paged_write(t, 0, 0, ctrl[t], sizeof(ctrl[t]))) return -1;
	return 0;
}

static void draw_char(uint8_t fb[FB_SIZE], int x, int y, char c)
{
	if (c >= 'a' && c <= 'z') c -= 32;
	if (c < 32 || c > 'Z') c = ' ';
	for (int col = 0; col < 5; col++) for (int row = 0; row < 7; row++) if (font[(unsigned)c - 32][col] & (1u << row)) set_pixel(fb, x + col, y + row, true);
}

static void draw_text(uint8_t fb[FB_SIZE], const char *text, int x, int y) { for (; *text; text++, x += 6) draw_char(fb, x, y, *text); }

static void draw_text_scaled(uint8_t fb[FB_SIZE], const char *text, int x, int y, int scale)
{
	for (; *text; text++, x += 6 * scale) {
		char c = *text;
		if (c >= 'a' && c <= 'z') c -= 32;
		if (c < 32 || c > 'Z') c = ' ';
		for (int col = 0; col < 5; col++) for (int row = 0; row < 7; row++)
			if (font[(unsigned)c - 32][col] & (1u << row))
				for (int dx = 0; dx < scale; dx++) for (int dy = 0; dy < scale; dy++)
					set_pixel(fb, x + col * scale + dx, y + row * scale + dy, true);
	}
}

static void draw_clock_digit(uint8_t fb[FB_SIZE], int x, int y, unsigned digit)
{
	char c = '0' + digit % 10;
	for (int col = 0; col < 4; col++) for (int row = 0; row < 7; row++)
		if (font[(unsigned)c - 32][col] & (1u << row)) set_pixel(fb, x + col, y + row, true);
}

static void draw_clock_digit_bold(uint8_t fb[FB_SIZE], int x, int y, unsigned digit)
{
	char c = '0' + digit % 10;
	for (int col = 0; col < 5; col++) for (int row = 0; row < 7; row++)
		if (font[(unsigned)c - 32][col] & (1u << row)) {
			set_pixel(fb, x + col, y + row, true);
			set_pixel(fb, x + col + 1, y + row, true);
		}
}

static int load_bitmap(const char *path, uint8_t fb[FB_SIZE])
{
	int fd = open(path, O_RDONLY); ssize_t n;
	memset(fb, 0, FB_SIZE);
	if (fd < 0) return -1;
	n = read(fd, fb, FB_SIZE);
	close(fd);
	if (n != FB_SIZE) memset(fb, 0, FB_SIZE);
	return n == FB_SIZE ? 0 : -1;
}

static void config_defaults(struct config *config)
{
	*config = (struct config){ .enabled = true, .interval_ms = 500, .brightness = 24 };
	strcpy(config->device, "/dev/i2c-0"); strcpy(config->mode, "blank");
	strcpy(config->bitmap, DEFAULT_BITMAP); strcpy(config->text, "OPENWRT");
}

static void load_config(void)
{
	struct uci_context *ctx = NULL; struct uci_package *pkg = NULL; struct uci_element *e; const char *v;
	struct config next; config_defaults(&next); ctx = uci_alloc_context(); if (!ctx || uci_load(ctx, "ledmatrix", &pkg)) goto out;
	uci_foreach_element(&pkg->sections, e) {
		struct uci_section *s = uci_to_section(e); if (strcmp(s->type, "ledmatrix")) continue;
#define OPT(name) uci_lookup_option_string(ctx, s, name)
		if ((v = OPT("enabled"))) next.enabled = atoi(v) != 0;
		if ((v = OPT("device"))) snprintf(next.device, sizeof(next.device), "%s", v);
		if ((v = OPT("mode"))) snprintf(next.mode, sizeof(next.mode), "%s", v);
		if ((v = OPT("bitmap"))) snprintf(next.bitmap, sizeof(next.bitmap), "%s", v);
		if ((v = OPT("text"))) snprintf(next.text, sizeof(next.text), "%s", v);
		if ((v = OPT("interval"))) next.interval_ms = strtoul(v, NULL, 10);
		if ((v = OPT("brightness"))) next.brightness = strtoul(v, NULL, 10);
#undef OPT
	}
out:
	if (pkg) uci_unload(ctx, pkg);
	if (ctx) uci_free_context(ctx);
	if (!next.interval_ms) next.interval_ms = 500;
	if (next.brightness > 255) next.brightness = 255;
	cfg = next;
}

static int open_panel(void)
{
	int fd = open(REGMAP_PATH, O_RDONLY); ssize_t n; if (fd < 0) return -1; n = read(fd, regmap, sizeof(regmap)); close(fd); if (n != sizeof(regmap)) return -1;
	i2c_fd = open(cfg.device, O_RDWR); if (i2c_fd < 0) return -1; return init_panel();
}

static void render(uint8_t fb[FB_SIZE], unsigned tick)
{
	const struct config *active = preview_active ? &preview_cfg : &cfg;
	if (preview_frame_active) {
		memcpy(fb, preview_frame, FB_SIZE);
		return;
	}
	memset(fb, 0, FB_SIZE); if (!active->enabled || !strcmp(active->mode, "blank")) return;
	if (!strcmp(active->mode, "bitmap") || !strcmp(active->mode, "blink")) {
		if (!strcmp(active->mode, "blink") && (tick & 1)) return;
		if (load_bitmap(active->bitmap, fb)) {
			if (!bitmap_failed) fprintf(stderr, "ledmatrixd: cannot read bitmap %s\n", active->bitmap);
			bitmap_failed = true;
		} else {
			bitmap_failed = false;
		}
	}
	else if (!strcmp(active->mode, "clock")) {
		time_t now = time(NULL); struct tm tm; localtime_r(&now, &tm);
		draw_clock_digit(fb, 1, 47, tm.tm_hour / 10); draw_clock_digit(fb, 6, 47, tm.tm_hour % 10);
		set_pixel(fb, 11, 49, true); set_pixel(fb, 11, 51, true);
		draw_clock_digit(fb, 14, 47, tm.tm_min / 10); draw_clock_digit(fb, 19, 47, tm.tm_min % 10);
	}
	else if (!strcmp(active->mode, "clock-stacked")) {
		time_t now = time(NULL); struct tm tm; localtime_r(&now, &tm);
		draw_clock_digit_bold(fb, 5, 46, tm.tm_hour / 10); draw_clock_digit_bold(fb, 13, 46, tm.tm_hour % 10);
		set_pixel(fb, 10, 54, true); set_pixel(fb, 13, 54, true);
		draw_clock_digit_bold(fb, 5, 56, tm.tm_min / 10); draw_clock_digit_bold(fb, 13, 56, tm.tm_min % 10);
	}
	else if (!strcmp(active->mode, "scroll")) { int width = strlen(active->text) * 12; draw_text_scaled(fb, active->text, WIDTH - (tick % (width + WIDTH)), 42, 2); }
}

static int make_socket(void)
{
	int fd = socket(AF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC, 0); struct sockaddr_un addr = { .sun_family = AF_UNIX };
	if (fd < 0) return -1;
	snprintf(addr.sun_path, sizeof(addr.sun_path), "%s", SOCKET_PATH);
	unlink(SOCKET_PATH);
	if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) { close(fd); return -1; } chmod(SOCKET_PATH, 0660); return fd;
}

static void handle_command(int fd)
{
	char cmd[FB_SIZE * 2 + 32], reply[256]; struct sockaddr_un peer; socklen_t len = sizeof(peer); ssize_t n = recvfrom(fd, cmd, sizeof(cmd) - 1, 0, (void *)&peer, &len);
	if (n < 0) return;
	cmd[n] = 0;
	if (!strncmp(cmd, "preview ", 8) &&
	    (!strcmp(cmd + 8, "blank") || !strcmp(cmd + 8, "bitmap") ||
	     !strcmp(cmd + 8, "blink") || !strcmp(cmd + 8, "clock") ||
	     !strcmp(cmd + 8, "clock-stacked") || !strcmp(cmd + 8, "scroll"))) {
		preview_cfg = cfg;
		if (!preview_cfg.bitmap[0]) strcpy(preview_cfg.bitmap, DEFAULT_BITMAP);
		if (!preview_cfg.text[0]) strcpy(preview_cfg.text, "OPENWRT");
		preview_cfg.enabled = true;
		snprintf(preview_cfg.mode, sizeof(preview_cfg.mode), "%s", cmd + 8);
		preview_cfg.mode[strcspn(preview_cfg.mode, "\r\n ")] = 0;
		preview_active = true;
		preview_frame_active = false;
	} else if (!strncmp(cmd, "frame ", 6) && strlen(cmd + 6) >= FB_SIZE * 2) {
		for (unsigned i = 0; i < FB_SIZE; i++) {
			unsigned byte;
			if (sscanf(cmd + 6 + i * 2, "%2x", &byte) != 1) break;
			preview_frame[i] = byte;
		}
		preview_active = true;
		preview_frame_active = true;
	} else if (!strncmp(cmd, "brightness ", 11)) {
		preview_cfg = preview_active ? preview_cfg : cfg;
		preview_cfg.brightness = strtoul(cmd + 11, NULL, 10);
		preview_active = true;
		set_brightness(preview_cfg.brightness);
	} else if (!strcmp(cmd, "restore")) {
		preview_active = false;
		preview_frame_active = false;
		set_brightness(cfg.brightness);
	} else if (!strcmp(cmd, "reload")) {
		load_config();
		preview_active = false;
		preview_frame_active = false;
		set_brightness(cfg.brightness);
	}
	snprintf(reply, sizeof(reply), "mode=%s preview=%u\n", preview_active ? preview_cfg.mode : cfg.mode, preview_active);
	sendto(fd, reply, strlen(reply), 0, (void *)&peer, len);
}

static void usage(FILE *out) { fprintf(out, "ledmatrixd %s\nUsage: ledmatrixd | --version\n", VERSION); }

int main(int argc, char **argv)
{
	uint8_t fb[FB_SIZE]; int sock; unsigned tick = 0;
	if (argc > 1 && (!strcmp(argv[1], "--version") || !strcmp(argv[1], "-V"))) { printf("ledmatrixd %s\n", VERSION); return 0; }
	if (argc > 1 && !strcmp(argv[1], "--help")) { usage(stdout); return 0; }
	load_config(); if (open_panel()) { fprintf(stderr, "ledmatrixd: panel unavailable: %s\n", strerror(errno)); return 1; }
	sock = make_socket(); if (sock < 0) { perror("ledmatrixd: socket"); return 1; }
	signal(SIGTERM, on_signal); signal(SIGINT, on_signal); signal(SIGHUP, on_signal);
	while (running) {
		const struct config *active = preview_active ? &preview_cfg : &cfg;
		fd_set rfds; struct timeval tv = { active->interval_ms / 1000, (active->interval_ms % 1000) * 1000 };
		if (reload_config) {
			reload_config = 0;
			load_config();
			preview_active = false;
			preview_frame_active = false;
			set_brightness(cfg.brightness);
		}
		render(fb, tick++); push_frame(fb);
		FD_ZERO(&rfds); FD_SET(sock, &rfds); if (select(sock + 1, &rfds, NULL, NULL, &tv) > 0) handle_command(sock);
	}
	memset(fb, 0, sizeof(fb)); push_frame(fb); close(sock); close(i2c_fd); unlink(SOCKET_PATH); return 0;
}
