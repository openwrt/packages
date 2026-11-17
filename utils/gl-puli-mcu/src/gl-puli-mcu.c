/*
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 *   Copyright (C) 2014 John Crispin <blogic@openwrt.org>
 *   Copyright (C) 2021 Nuno Goncalves <nunojpg@gmail.com>
 */

#include <fcntl.h>
#include <termios.h>

#include <libubox/ulog.h>
#include <libubox/ustream.h>
#include <libubox/utils.h>
#include <libubox/uloop.h>
#include <libubus.h>

#define GL_TARGET_XE300  1
#define GL_TARGET_XE3000 2

#if GL_TARGET == GL_TARGET_XE300
#define MCU_PORT "/dev/ttyUSB0"
#elif GL_TARGET ==  GL_TARGET_XE3000
#define MCU_PORT "/dev/ttyS1"
#else
#error Please define GL_TARGET!
#endif /* GL_TARGET */

static struct ustream_fd stream;
static struct ubus_auto_conn conn;
static struct blob_buf b;

struct Battery
{
	float temperature;
	uint16_t cycles;
	uint8_t soc;
	bool charging;
	bool set;
} battery;

#if GL_TARGET == GL_TARGET_XE300
// MCU status returns something like:
// {OK},100,275,1,0
static bool
process(char *read)
{
	if (read[0] != '{' ||
		read[1] != 'O' ||
		read[2] != 'K' ||
		read[3] != '}' ||
		read[4] != ',')
		return false;
	const char *from = read + 5;
	char *to;
	battery.soc = strtoul(from, &to, 10);
	if (from == to)
		return false;
	from = to + 1;
	battery.temperature = strtoul(from, &to, 10) / 10.0f;
	if (from == to)
		return false;
	if (to[0] != ',' || (to[1] != '0' && to[1] != '1') || to[2] != ',')
		return false;
	battery.charging = to[1] == '1';
	from = to + 3;
	battery.cycles = strtoul(from, &to, 10);
	if (from == to)
		return false;
	return true;
}
#elif GL_TARGET == GL_TARGET_XE3000
static bool
get_int_value(const char *read, const char *key, int *int_value, char **new_end)
{
	char *from = NULL;

	from = strstr(read, key);
	if ((!from) || (from != read))
	{
		return false;
	}
	from = (char *)read + strlen(key);
	*int_value = strtol(from, new_end, 10);
	if (from == *new_end)
	{
		return false;
	}

	return true;
}

// MCU status returns something like:
// {"code":0,"capacity":100,"temp":28,"chg_state":1,"charge_cycle":0}
static bool
process(char *read)
{
	int int_value = 0;
	char *to = NULL;

	if ((read[0] != '{') ||
		(!get_int_value(&read[1], "\"code\":", &int_value, &to)) ||
		(int_value != 0))
	{
		return false;
	}
	if (!get_int_value(to + 1, "\"capacity\":", &int_value, &to))
	{
		return false;
	}
	battery.soc = int_value;
	if (!get_int_value(to + 1, "\"temp\":", &int_value, &to))
	{
		return false;
	}
	battery.temperature = (float) int_value;
	if (!get_int_value(to + 1, "\"chg_state\":", &int_value, &to))
	{
		return false;
	}
	battery.charging = (bool) int_value;
	if (!get_int_value(to + 1, "\"charge_cycle\":", &int_value, &to))
	{
		return false;
	}
	battery.cycles = (uint16_t) int_value;

	return true;
}
#endif /* GL_TARGET */

static int
consume(struct ustream *s, char **a)
{
	char *eol = strstr(*a, "\n");

	if (!eol)
		return -1;

	*eol++ = '\0';

	battery.set = process(*a);
	if (!battery.set)
		ULOG_ERR("failed to parse message from serial: %s", *a);

	ustream_consume(s, eol - *a);
	*a = eol;

	return 0;
}

static void
msg_cb(struct ustream *s, int bytes)
{
	int len;
	char *a = ustream_get_read_buf(s, &len);

	while (!consume(s, &a))
		;
}

static void
notify_cb(struct ustream *s)
{
	if (!s->eof)
		return;

	ULOG_ERR("tty error, shutting down\n");
	exit(-1);
}

static int
serial_open(char *dev)
{
	const int tty = open(dev, O_RDWR | O_NOCTTY | O_NONBLOCK);
	if (tty < 0)
	{
		ULOG_ERR("%s: device open failed: %s\n", dev, strerror(errno));
		return -1;
	}

	struct termios config;
	tcgetattr(tty, &config);
	cfmakeraw(&config);
	cfsetispeed(&config, B9600);
	cfsetospeed(&config, B9600);
	tcsetattr(tty, TCSANOW, &config);

	stream.stream.string_data = true;
	stream.stream.notify_read = msg_cb;
	stream.stream.notify_state = notify_cb;

	ustream_fd_init(&stream, tty);

	tcflush(tty, TCIFLUSH);

	return 0;
}

static struct uloop_timeout serial_query_timer;
static void
serial_query_handler(struct uloop_timeout *timeout)
{
	const char cmd[] = "{ \"mcu_status\": \"1\" }\n";
	const unsigned cmd_len = sizeof(cmd) - 1;
	ustream_write(&stream.stream, cmd, cmd_len, false);
	uloop_timeout_set(&serial_query_timer, 3000); // timeout in 3 sec
	uloop_timeout_add(timeout);
}

static int
battery_info(struct ubus_context *ctx, struct ubus_object *obj,
			 struct ubus_request_data *req, const char *method,
			 struct blob_attr *msg)
{
	blob_buf_init(&b, 0);

	if (!battery.set)
	{
		blobmsg_add_u8(&b, "error", 1);
	}
	else
	{
		blobmsg_add_u16(&b, "soc", battery.soc);
		blobmsg_add_u8(&b, "charging", battery.charging);
		blobmsg_add_double(&b, "temperature", battery.temperature);
		blobmsg_add_u16(&b, "cycles", battery.cycles);
	}
	ubus_send_reply(ctx, req, b.head);

	return UBUS_STATUS_OK;
}

static const struct ubus_method battery_methods[] = {
	UBUS_METHOD_NOARG("info", battery_info),
};

static struct ubus_object_type battery_object_type =
	UBUS_OBJECT_TYPE("battery", battery_methods);

static struct ubus_object battery_object = {
	.name = "battery",
	.type = &battery_object_type,
	.methods = battery_methods,
	.n_methods = ARRAY_SIZE(battery_methods),
};

static void
ubus_connect_handler(struct ubus_context *ctx)
{
	int ret;

	ret = ubus_add_object(ctx, &battery_object);
	if (ret)
		fprintf(stderr, "Failed to add object: %s\n", ubus_strerror(ret));
}

int
main(int argc, char **argv)
{

	uloop_init();
	conn.path = NULL;
	conn.cb = ubus_connect_handler;
	ubus_auto_connect(&conn);

	if (serial_open(MCU_PORT) < 0)
		return -1;

	serial_query_timer.cb = serial_query_handler;
	serial_query_handler(&serial_query_timer);
	uloop_run();
	uloop_done();

	return 0;
}
