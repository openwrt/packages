#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#define DEV_PATH "/dev/ttyS1"
#define LINE_LEN 16
#define RX_BUF_LEN 512
#define EVENT_Q_LEN 16

#define CMD_INIT 0x00
#define CMD_LINE0 0x07
#define CMD_LINE1 0x08
#define CMD_ENABLE_KEYS 0x17
#define CMD_SET_LED 0x20

#define LED_POWER 0
#define LED_ARM_GREEN 1
#define LED_ARM_RED 2

#define LED_OFF 0
#define LED_SOLID 1

struct panel_state {
    int fd;
    uint8_t rxbuf[RX_BUF_LEN];
    size_t rxlen;
    uint8_t event_q[EVENT_Q_LEN][5];
    size_t event_head;
    size_t event_tail;
};

static volatile sig_atomic_t running = 1;

static void handle_signal(int sig) { (void)sig; running = 0; }

static uint16_t crc16(const uint8_t *data, size_t len)
{
    uint16_t c = 0xffff; size_t i; int bit;
    for (i = 0; i < len; i++) {
        c ^= data[i];
        for (bit = 0; bit < 8; bit++)
            c = (c & 1) ? (c >> 1) ^ 0x8408 : (c >> 1);
    }
    c = ~c;
    return (uint16_t)((c >> 8) | ((c & 0xff) << 8));
}

static int queue_event(struct panel_state *st, const uint8_t *frame)
{
    size_t next = (st->event_tail + 1) % EVENT_Q_LEN;
    if (next == st->event_head)
        return -1;
    memcpy(st->event_q[st->event_tail], frame, 5);
    st->event_tail = next;
    return 0;
}

static int pop_event(struct panel_state *st, uint8_t *frame)
{
    if (st->event_head == st->event_tail)
        return 0;
    memcpy(frame, st->event_q[st->event_head], 5);
    st->event_head = (st->event_head + 1) % EVENT_Q_LEN;
    return 1;
}

static int plausible_cmd(uint8_t cmd)
{
    switch (cmd) {
    case 0x20: case 0x40: case 0x41: case 0x43: case 0x44: case 0x45:
    case 0x57: case 0x80: case 0xc7: case 0xc8: case 0xcb: case 0xcc:
        return 1;
    default:
        return 0;
    }
}

static int read_into_rx(struct panel_state *st, unsigned int timeout_ms)
{
    struct pollfd pfd = { .fd = st->fd, .events = POLLIN };
    int rv = poll(&pfd, 1, (int)timeout_ms);
    if (rv > 0 && (pfd.revents & POLLIN)) {
        ssize_t n;
        if (st->rxlen >= sizeof(st->rxbuf))
            st->rxlen = 0;
        n = read(st->fd, st->rxbuf + st->rxlen, sizeof(st->rxbuf) - st->rxlen);
        if (n > 0) {
            st->rxlen += (size_t)n;
            return 1;
        }
    }
    return 0;
}

static int extract_frame(struct panel_state *st, uint8_t *out, size_t *out_len)
{
    size_t pos = 0;
    while (st->rxlen - pos >= 4) {
        uint8_t cmd = st->rxbuf[pos];
        uint8_t len = st->rxbuf[pos + 1];
        size_t frame_len;
        uint16_t got_crc, want_crc;

        if (!plausible_cmd(cmd)) { pos++; continue; }
        frame_len = (size_t)len + 4;
        if (frame_len > RX_BUF_LEN || len > 0x40) { pos++; continue; }
        if (st->rxlen - pos < frame_len)
            break;
        got_crc = ((uint16_t)st->rxbuf[pos + frame_len - 2] << 8) | st->rxbuf[pos + frame_len - 1];
        want_crc = crc16(st->rxbuf + pos, frame_len - 2);
        if (got_crc != want_crc) { pos++; continue; }
        memcpy(out, st->rxbuf + pos, frame_len);
        *out_len = frame_len;
        pos += frame_len;
        if (pos < st->rxlen)
            memmove(st->rxbuf, st->rxbuf + pos, st->rxlen - pos);
        st->rxlen -= pos;
        return 1;
    }
    if (pos && pos < st->rxlen)
        memmove(st->rxbuf, st->rxbuf + pos, st->rxlen - pos);
    st->rxlen -= pos;
    return 0;
}

static int next_frame(struct panel_state *st, uint8_t *frame, size_t *frame_len, unsigned int timeout_ms)
{
    unsigned int elapsed = 0;
    while (running && elapsed <= timeout_ms) {
        if (extract_frame(st, frame, frame_len))
            return 1;
        read_into_rx(st, 50);
        elapsed += 50;
    }
    return 0;
}

static int expected_reply(uint8_t cmd, uint8_t *reply_cmd, uint8_t *reply_len)
{
    switch (cmd) {
    case CMD_INIT: *reply_cmd = 0x40; *reply_len = 6; return 1;
    case CMD_ENABLE_KEYS: *reply_cmd = 0x57; *reply_len = 0; return 1;
    case CMD_SET_LED: *reply_cmd = 0x20; *reply_len = 0; return 1;
    case CMD_LINE0: *reply_cmd = 0xc7; *reply_len = 16; return 1;
    case CMD_LINE1: *reply_cmd = 0xc8; *reply_len = 16; return 1;
    default: return 0;
    }
}

static size_t make_packet(uint8_t cmd, const uint8_t *payload, uint8_t payload_len, uint8_t *out, size_t out_len)
{
    uint16_t crc;
    if (out_len < (size_t)payload_len + 4)
        return 0;
    out[0] = cmd;
    out[1] = payload_len;
    if (payload_len && payload)
        memcpy(out + 2, payload, payload_len);
    crc = crc16(out, (size_t)payload_len + 2);
    out[2 + payload_len] = (uint8_t)(crc >> 8);
    out[3 + payload_len] = (uint8_t)(crc & 0xff);
    return (size_t)payload_len + 4;
}

static int panel_command(struct panel_state *st, uint8_t cmd, const uint8_t *payload, uint8_t payload_len, unsigned int timeout_ms)
{
    uint8_t packet[32], frame[64], want_cmd, want_len;
    size_t len, frame_len;
    ssize_t wr;

    len = make_packet(cmd, payload, payload_len, packet, sizeof(packet));
    if (!len)
        return -1;
    wr = write(st->fd, packet, len);
    if (wr < 0 || (size_t)wr != len)
        return -1;
    if (!expected_reply(cmd, &want_cmd, &want_len))
        return 0;

    while (running && next_frame(st, frame, &frame_len, timeout_ms)) {
        if (frame[0] == 0x80 && frame[1] == 0x01) {
            queue_event(st, frame);
            continue;
        }
        if (frame[0] == want_cmd && frame[1] == want_len)
            return 0;
    }
    return -1;
}

static int set_led(struct panel_state *st, uint8_t led, uint8_t value)
{
    uint8_t payload[3] = { led, value, 1 };
    return panel_command(st, CMD_SET_LED, payload, sizeof(payload), 1000);
}

static int set_line(struct panel_state *st, uint8_t row, const char *text)
{
    uint8_t payload[LINE_LEN];
    size_t len = strlen(text);
    memset(payload, ' ', sizeof(payload));
    if (len > sizeof(payload))
        len = sizeof(payload);
    memcpy(payload, text, len);
    return panel_command(st, row == 0 ? CMD_LINE0 : CMD_LINE1, payload, sizeof(payload), 1500);
}

static void show_default(struct panel_state *st)
{
    set_line(st, 0, "OpenWrt Panel");
    set_line(st, 1, "Ready");
}

static void apply_known_leds(struct panel_state *st)
{
    set_led(st, LED_POWER, LED_SOLID);
    set_led(st, LED_ARM_GREEN, LED_OFF);
    set_led(st, LED_ARM_RED, LED_SOLID);
}

static const char *parse_key(uint8_t code, int *is_release)
{
    *is_release = !!(code & 0x10);
    switch (code & 0x0f) {
    case 0x01: return "UP";
    case 0x02: return "DOWN";
    case 0x04: return "LEFT";
    case 0x08: return "RIGHT";
    default: return NULL;
    }
}

static int open_panel(void)
{
    struct termios tio;
    int fd = open(DEV_PATH, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (fd < 0) return -1;
    if (tcgetattr(fd, &tio) < 0) { close(fd); return -1; }
    cfmakeraw(&tio);
    tio.c_cflag |= CREAD | CLOCAL;
    cfsetispeed(&tio, B19200);
    cfsetospeed(&tio, B19200);
    if (tcsetattr(fd, TCSANOW, &tio) < 0) { close(fd); return -1; }
    tcflush(fd, TCIOFLUSH);
    return fd;
}

static int init_panel(struct panel_state *st)
{
    static const uint8_t hello[] = { 'H','e','l','l','o','!' };
    static const uint8_t keys[] = { 0x0f, 0x0f };
    if (panel_command(st, CMD_INIT, hello, sizeof(hello), 1200) < 0) return -1;
    if (panel_command(st, CMD_ENABLE_KEYS, keys, sizeof(keys), 1200) < 0) return -1;
    apply_known_leds(st);
    show_default(st);
    return 0;
}

static int board_supported(void)
{
    FILE *fp = fopen("/tmp/sysinfo/board_name", "r"); char buf[64];
    if (!fp) return 0;
    if (!fgets(buf, sizeof(buf), fp)) { fclose(fp); return 0; }
    fclose(fp); buf[strcspn(buf, "\r\n")] = '\0';
    return !strcmp(buf, "watchguard,xtm330");
}

int main(void)
{
    struct panel_state st;
    uint8_t frame[64];
    size_t frame_len;

    if (!board_supported()) return 0;
    memset(&st, 0, sizeof(st));
    signal(SIGTERM, handle_signal);
    signal(SIGINT, handle_signal);
    st.fd = open_panel();
    if (st.fd < 0) return 1;
    if (init_panel(&st) < 0) return 1;

    while (running) {
        if (!pop_event(&st, frame)) {
            if (!next_frame(&st, frame, &frame_len, 200))
                continue;
        } else {
            frame_len = 5;
        }
        if (frame[0] == 0x80 && frame[1] == 0x01) {
            const char *key;
            int release;
            key = parse_key(frame[2], &release);
            if (!key) continue;
            if (release)
                show_default(&st);
            else {
                set_line(&st, 0, "OpenWrt Panel");
                set_line(&st, 1, key);
            }
        }
    }

    show_default(&st);
    close(st.fd);
    return 0;
}
