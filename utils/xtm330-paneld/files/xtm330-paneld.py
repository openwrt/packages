#!/usr/bin/python3
import os
import signal
import sys
import termios
import time

DEV = '/dev/ttyS1'
BAUD = termios.B19200
BUTTONS = {
    0x01: 'UP',
    0x02: 'DOWN',
    0x04: 'LEFT',
    0x08: 'RIGHT',
}
RUN = True

LED_POWER = 0
LED_ARM_GREEN = 1
LED_ARM_RED = 2

LED_OFF = 0
LED_SOLID = 1
LED_FAST = 9
LED_MEDIUM = 0x28
LED_SLOW = 0x96


def handle_signal(_signum, _frame):
    global RUN
    RUN = False


def crc(data, c=0xFFFF):
    for byte in data:
        c ^= byte
        for _ in range(8):
            c = (c >> 1) ^ 0x8408 if c & 1 else c >> 1
    c = (~c) & 0xFFFF
    return ((c >> 8) | ((c & 0xFF) << 8)) & 0xFFFF


def pkt(cmd, payload=b''):
    body = bytes([cmd, len(payload)]) + payload
    value = crc(body)
    return body + bytes([value >> 8, value & 0xFF])


def read_for(fd, secs):
    out = b''
    end = time.time() + secs
    while time.time() < end and RUN:
        try:
            chunk = os.read(fd, 256)
            if chunk:
                out += chunk
        except BlockingIOError:
            pass
        time.sleep(0.05)
    return out


def xfer(fd, packet, wait=0.4):
    os.write(fd, packet)
    return read_for(fd, wait)


def set_line(fd, row, text):
    cmd = 0x07 if row == 0 else 0x08
    payload = text.encode('ascii', 'replace')[:16].ljust(16, b' ')
    xfer(fd, pkt(cmd, payload))


def show_default(fd):
    set_line(fd, 0, 'OpenWrt Panel')
    set_line(fd, 1, 'Ready')


def set_led(fd, led, value):
    xfer(fd, pkt(0x20, bytes([led, value, 1])))


def apply_known_leds(fd):
    set_led(fd, LED_POWER, LED_SOLID)
    set_led(fd, LED_ARM_GREEN, LED_OFF)
    set_led(fd, LED_ARM_RED, LED_OFF)


def show_key_state(fd, key):
    if key == 'UP':
        set_led(fd, LED_ARM_RED, LED_OFF)
        set_led(fd, LED_ARM_GREEN, LED_SOLID)
    elif key == 'DOWN':
        set_led(fd, LED_ARM_GREEN, LED_OFF)
        set_led(fd, LED_ARM_RED, LED_SOLID)
    elif key == 'LEFT':
        set_led(fd, LED_ARM_RED, LED_OFF)
        set_led(fd, LED_ARM_GREEN, LED_SLOW)
    elif key == 'RIGHT':
        set_led(fd, LED_ARM_GREEN, LED_OFF)
        set_led(fd, LED_ARM_RED, LED_SLOW)


def clear_key_state(fd):
    set_led(fd, LED_ARM_GREEN, LED_OFF)
    set_led(fd, LED_ARM_RED, LED_OFF)
    apply_known_leds(fd)


def open_panel():
    fd = os.open(DEV, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
    attrs = termios.tcgetattr(fd)
    attrs[0] = 0
    attrs[1] = 0
    attrs[2] = termios.CS8 | termios.CREAD | termios.CLOCAL
    attrs[3] = 0
    attrs[4] = BAUD
    attrs[5] = BAUD
    attrs[6][termios.VMIN] = 0
    attrs[6][termios.VTIME] = 1
    termios.tcsetattr(fd, termios.TCSANOW, attrs)
    termios.tcflush(fd, termios.TCIOFLUSH)
    return fd


def init_panel(fd):
    xfer(fd, pkt(0x00, b'Hello!'), 0.8)
    xfer(fd, pkt(0x17, b'\x0f\x0f'), 0.8)
    apply_known_leds(fd)
    show_default(fd)


def parse_event(frame):
    if len(frame) != 5 or frame[0] != 0x80:
        return None
    code = frame[2]
    key = BUTTONS.get(code & 0x0F, '0x%02x' % (code & 0x0F))
    state = 'release' if code & 0x10 else 'press'
    return key, state


def board_name():
    try:
        with open('/tmp/sysinfo/board_name', 'r', encoding='ascii') as fh:
            return fh.read().strip()
    except OSError:
        return ''


def main():
    if board_name() != 'watchguard,xtm330':
        return 0

    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)

    fd = open_panel()
    try:
        init_panel(fd)
        while RUN:
            data = read_for(fd, 0.2)
            if not data:
                continue
            for i in range(0, len(data) - (len(data) % 5), 5):
                parsed = parse_event(data[i:i + 5])
                if not parsed:
                    continue
                key, state = parsed
                print('panel key %s %s' % (key, state), flush=True)
                if state == 'press':
                    set_line(fd, 0, 'OpenWrt Panel')
                    set_line(fd, 1, key)
                    show_key_state(fd, key)
                elif state == 'release':
                    show_default(fd)
                    clear_key_state(fd)
    finally:
        try:
            clear_key_state(fd)
            show_default(fd)
        except OSError:
            pass
        os.close(fd)
    return 0


if __name__ == '__main__':
    sys.exit(main())
