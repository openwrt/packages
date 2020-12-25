/**
 * collectd - src/iwinfo.c
 * Copyright (C) 2011  Jo-Philipp Wich
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; only version 2 of the License is applicable.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
 **/

#include "collectd.h"
#include "plugin.h"
#include "utils/common/common.h"
#include "utils/ignorelist/ignorelist.h"

#include <stdint.h>
#include <iwinfo.h>

#define PROCNETDEV "/proc/net/dev"

static const char *config_keys[] = {
	"Interface",
	"IgnoreSelected"
};
static int config_keys_num = STATIC_ARRAY_SIZE (config_keys);

static ignorelist_t *ignorelist = NULL;

static int iwinfo_config(const char *key, const char *value)
{
	if (ignorelist == NULL)
		ignorelist = ignorelist_create(1);

	if (ignorelist == NULL)
		return 1;

	if (strcasecmp(key, "Interface") == 0)
		ignorelist_add(ignorelist, value);
	else if (strcasecmp(key, "IgnoreSelected") == 0)
		ignorelist_set_invert(ignorelist, IS_TRUE(value) ? 0 : 1);
	else
		return -1;

	return 0;
}

static void iwinfo_submit(const char *ifname, const char *type, int value)
{
	value_t values[1];
	value_list_t vl = VALUE_LIST_INIT;

	values[0].gauge = value;

	vl.values = values;
	vl.values_len = 1;

	sstrncpy(vl.host, hostname_g, sizeof(vl.host));
	sstrncpy(vl.plugin, "iwinfo", sizeof(vl.plugin));
	sstrncpy(vl.plugin_instance, ifname, sizeof(vl.plugin_instance));
	sstrncpy(vl.type, type, sizeof(vl.type));
	/*sstrncpy(vl.type_instance, "", sizeof(vl.type_instance));*/

	plugin_dispatch_values(&vl);
}

static void iwinfo_process(const char *ifname)
{
	int val;
	char buf[IWINFO_BUFSIZE];
	const struct iwinfo_ops *iw = iwinfo_backend(ifname);

	/* does appear to be a wifi iface */
	if (iw)
	{
		if (iw->bitrate(ifname, &val))
			val = 0;
		iwinfo_submit(ifname, "bitrate", val * 1000);

		if (iw->signal(ifname, &val))
			val = 0;
		iwinfo_submit(ifname, "signal_power", val);

		if (iw->noise(ifname, &val))
			val = 0;
		iwinfo_submit(ifname, "signal_noise", val);

		if (iw->quality(ifname, &val))
			val = 0;
		iwinfo_submit(ifname, "signal_quality", val);

		if (iw->assoclist(ifname, buf, &val))
			val = 0;
		iwinfo_submit(ifname, "stations",
		              val / sizeof(struct iwinfo_assoclist_entry));
	}

	iwinfo_finish();
}

static int iwinfo_read(void)
{
	char line[1024];
	char ifname[128];
	FILE *f;

	f = fopen(PROCNETDEV, "r");
	if (f == NULL)
	{
		char err[1024];
		WARNING("iwinfo: Unable to open " PROCNETDEV ": %s",
		        sstrerror(errno, err, sizeof(err)));
		return -1;
	}

	while (fgets(line, sizeof(line), f))
	{
		if (!strchr(line, ':'))
			continue;

		if (!sscanf(line, " %127[^:]", ifname))
			continue;

		if (ignorelist_match(ignorelist, ifname))
			continue;

		if (strstr(ifname, "mon.") || strstr(ifname, ".sta") ||
		    strstr(ifname, "tmp.") || strstr(ifname, "wifi"))
			continue;

		iwinfo_process(ifname);
	}

	fclose(f);

	return 0;
}

void module_register(void)
{
	plugin_register_config("iwinfo", iwinfo_config, config_keys, config_keys_num);
	plugin_register_read("iwinfo", iwinfo_read);
}
