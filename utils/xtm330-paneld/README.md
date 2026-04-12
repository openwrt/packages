# xtm330-paneld

Recovered userspace front-panel support for the WatchGuard XTM330.

## Confirmed details

- Transport: `/dev/ttyS1`
- UART: `19200 8N1`
- Packet format: `[cmd][len][payload...][crc16_be]`
- CRC: seed `0xffff`, reflected polynomial `0x8408`, final invert, then byte swap
- Known commands:
  - `0x00` panel init / probe, payload `Hello!`
  - `0x07` write LCD line 1
  - `0x08` write LCD line 2
  - `0x17` enable keypad events, payload `0x0f 0x0f`
  - `0x20` set LED state, payload `[index, value, 0x01]`
- Key events arrive as 5-byte frames beginning with `0x80`
  - `0x01/0x11` first key press/release
  - `0x02/0x12` second key press/release
  - `0x04/0x14` third key press/release
  - `0x08/0x18` fourth key press/release

## Confirmed front-panel behavior

- LCD text writes are working on OpenWrt.
- Button handling is working again in the C daemon after switching to a response-aware parser.
- The stable daemon behavior is:
  - idle LCD: `OpenWrt Panel` / `Ready`
  - button press: show the correct button label on line 2
  - button release: restore `Ready`
- Button handling is intentionally decoupled from LED transitions.

## Confirmed LED mapping on the recovered UART path

- LED `0`: visible power LED
  - best-effort solid command works, but tested values did not visibly change behavior
- LED `1`: arm/disarm green channel
- LED `2`: arm/disarm red channel

## Confirmed LED values

- `0x00`: off
- `0x01`: solid
- `0x09`: fast blink
- `0x28`: medium blink
- `0x96`: slow blink

## Stock firmware findings

- Stock `frontpaneld` uses `libs6a0069.so` on `/dev/ttyS1`.
- Stock `armled` uses `libwgpanel.so` and proves a higher-level semantic API:
  - `setLed(selector, color, rate)`
- Confirmed from `armled`:
  - selector `1` = arm/disarm
  - color `1` = green
  - color `2` = red
  - rate `1` = solid
- Stock also has a separate LED control plane through:
  - `/proc/hwctrl/led_power`
  - `/proc/hwctrl/led_second_power`
  - `/proc/hwctrl/led_wlan1`
  - `/proc/hwctrl/led_wlan2`
  - `/proc/hwctrl/led_lan*`

## Current conclusion on the disk LED

- The disk LED was not found on the recovered `ttyS1` selector path.
- Focused raw LED selector sweeps only changed the arm/disarm LED.
- The disk LED is therefore most likely controlled through the stock kernel-side
  `hwctrl`/`frontpanel` interface rather than the recovered UART LED path.
- Future work for the disk LED should target the stock kernel-side interface,
  not more blind UART LED selector probing.

## Gaps

- The disk LED is still unmapped.
- The power LED currently appears fixed in hardware or needs a different command path.
- The daemon is useful and stable for LCD + button handling, but it is not yet a full replacement for the stock WatchGuard front-panel stack.
- Stock firmware also exposes `/proc/frontpanel`, `/proc/wg/frontpanel`, and `/proc/hwctrl/led_*`; those kernel hooks are not yet reproduced.
