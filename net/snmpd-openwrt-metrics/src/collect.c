/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * collect.c - wireless metrics via libiwinfo, sensors via sysfs.
 *
 * Wireless interfaces are found by looking for a phy80211 link under
 * /sys/class/net; that covers every mac80211 netdev including MLD interfaces,
 * which carry their own SSID and their own associations.
 *
 * Temperatures are the union of two sysfs sources. hwmon exposes sensors that
 * have no thermal zone at all (an MDIO PHY die sensor, for example), while
 * thermal zones exist on targets built without CONFIG_THERMAL_HWMON. A zone
 * already reachable through hwmon is not counted twice.
 */
#include <dirent.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <net/if.h>
#include <iwinfo.h>

#include "collect.h"
#include "mlo.h"

#define SYS_NET      "/sys/class/net"
#define SYS_HWMON    "/sys/class/hwmon"
#define SYS_THERMAL  "/sys/class/thermal"
#define DEFAULT_TTL  20
/* sysfs paths used here are short and fully bounded */
#define SYSFS_PATH   128

static struct snapshot snap;
static bool snap_valid;

static int ttl_seconds(void)
{
	const char *v = getenv("OPENWRT_SNMP_TTL");
	int t = v ? atoi(v) : 0;
	return (t > 0) ? t : DEFAULT_TTL;
}

/* Build "<dir>/<name>" only if it fits, so sysfs path construction cannot
 * silently truncate. */
static bool join(char *out, size_t len, const char *dir, const char *name)
{
	size_t dl = strlen(dir), nl = strlen(name);

	if (dl + nl + 2 > len)
		return false;
	memcpy(out, dir, dl);
	out[dl] = '/';
	memcpy(out + dl + 1, name, nl + 1);
	return true;
}

/* Read a small text file; returns length or -1. Trailing newline removed. */
static ssize_t slurp(const char *path, char *buf, size_t len)
{
	FILE *f = fopen(path, "r");
	size_t n;

	if (!f)
		return -1;
	n = fread(buf, 1, len - 1, f);
	fclose(f);
	buf[n] = '\0';
	while (n > 0 && (buf[n - 1] == '\n' || buf[n - 1] == '\t' || buf[n - 1] == ' '))
		buf[--n] = '\0';
	return (ssize_t)n;
}

static bool read_u32(const char *path, uint32_t *out)
{
	char buf[32];
	long v;

	if (slurp(path, buf, sizeof(buf)) < 0)
		return false;
	/* hwmon/thermal-zone temperatures are signed and can be sub-zero;
	 * Gauge32 cannot represent that, so clamp rather than let strtoul()
	 * wrap a negative reading into a multi-billion milli-degree value. */
	v = strtol(buf, NULL, 10);
	*out = (v < 0) ? 0 : (uint32_t)v;
	return true;
}

/* ------------------------------------------------------------------ */
/* Wireless                                                            */
/* ------------------------------------------------------------------ */

struct mac { uint8_t a[6]; };

static bool mac_seen(const struct mac *set, size_t n, const uint8_t *m)
{
	size_t i;

	for (i = 0; i < n; i++)
		if (!memcmp(set[i].a, m, 6))
			return true;
	return false;
}

/* Channel utilisation from the survey entry matching the operating channel.
 * iwinfo_survey_entry has no in-use flag, so the frequency is the key. */
static bool survey_utilisation(const struct iwinfo_ops *iw, const char *ifname,
			       uint32_t mhz, uint32_t *pct)
{
	char buf[IWINFO_BUFSIZE];
	int len = 0, i;

	if (!iw->survey || iw->survey(ifname, buf, &len) || len <= 0)
		return false;

	for (i = 0; i < len / (int)sizeof(struct iwinfo_survey_entry); i++) {
		struct iwinfo_survey_entry *e =
			(struct iwinfo_survey_entry *)&buf[i * sizeof(*e)];

		if (e->mhz != mhz || e->active_time == 0)
			continue;
		if (e->busy_time > e->active_time)
			return false;
		*pct = (uint32_t)((e->busy_time * 100ULL) / e->active_time);
		return true;
	}
	return false;
}

/* GETNEXT requires rows in index order; readdir() order is arbitrary. */
static int cmp_ifindex(const void *a, const void *b)
{
	const struct wl_iface *x = a, *y = b;

	return (x->ifindex > y->ifindex) - (x->ifindex < y->ifindex);
}

static int cmp_link_id(const void *a, const void *b)
{
	const struct wl_link *x = a, *y = b;

	return (x->link_id > y->link_id) - (x->link_id < y->link_id);
}

/* Queries this vif's MLO links directly over nl80211 (see mlo.c) and fills
 * in channel utilisation for each via the same survey data the single-radio
 * path uses, keyed by that link's own frequency. Returns the link count;
 * zero means ifname is not an MLD. */
static size_t collect_mlo_links(const struct iwinfo_ops *iw, const char *ifname,
				struct wl_link *out, size_t max)
{
	struct mlo_link raw[WL_MAX_LINKS];
	size_t n, i;

	n = mlo_get_links(ifname, raw, max < WL_MAX_LINKS ? max : WL_MAX_LINKS);
	if (n > max)
		n = max;

	for (i = 0; i < n; i++) {
		out[i].link_id = raw[i].link_id;
		memcpy(out[i].addr, raw[i].addr, sizeof(out[i].addr));
		out[i].frequency = raw[i].frequency;
		out[i].has_txpower = raw[i].has_txpower;
		out[i].txpower = raw[i].txpower;
		out[i].has_chanutil = raw[i].frequency &&
			survey_utilisation(iw, ifname, raw[i].frequency,
					   &out[i].chanutil);
	}

	qsort(out, n, sizeof(out[0]), cmp_link_id);
	return n;
}

static void collect_wireless(struct snapshot *s)
{
	struct mac seen[512];
	size_t seen_n = 0;
	DIR *d;
	struct dirent *de;

	s->wl_count = 0;
	s->client_total = 0;

	d = opendir(SYS_NET);
	if (!d)
		return;

	while ((de = readdir(d)) && s->wl_count < WL_MAX_IFACES) {
		char path[PATH_MAX], abuf[IWINFO_BUFSIZE];
		const struct iwinfo_ops *iw;
		struct wl_iface *w;
		char ssid_buf[IWINFO_ESSID_MAX_SIZE + 1] = { 0 };
		int val = 0, mode = 0, alen = 0, i, n;
		uint64_t tx_sum = 0, rx_sum = 0;
		int64_t snr_sum = 0;

		if (de->d_name[0] == '.')
			continue;
		if (!join(path, sizeof(path) - 10, SYS_NET, de->d_name))
			continue;
		strcat(path, "/phy80211");
		if (access(path, F_OK))
			continue;

		iw = iwinfo_backend(de->d_name);
		if (!iw)
			continue;
		if (iw->ssid && iw->ssid(de->d_name, ssid_buf))
			ssid_buf[0] = '\0';

		mode = 0;
		if (iw->mode)
			iw->mode(de->d_name, &mode);

		w = &s->wl[s->wl_count];
		memset(w, 0, sizeof(*w));
		if (strlen(de->d_name) >= sizeof(w->name))
			continue;
		memcpy(w->name, de->d_name, strlen(de->d_name) + 1);
		w->ifindex = (int)if_nametoindex(de->d_name);
		if (w->ifindex <= 0)
			continue;

		/* iwinfo writes at most IWINFO_ESSID_MAX_SIZE + 1 bytes. An
		 * interface with no SSID (a monitor or a down VAP) falls back
		 * to its name so the row is still identifiable. */
		if (ssid_buf[0])
			memcpy(w->ssid, ssid_buf, strlen(ssid_buf) + 1);
		else
			memcpy(w->ssid, w->name, strlen(w->name) + 1);

		/* An MLD netdev spans several links; query them directly over
		 * nl80211 rather than through libiwinfo, which has no MLO
		 * awareness and reports whatever single link the kernel's
		 * legacy top-level compat attributes happen to carry (seen
		 * live: an arbitrary link's channel, and no tx power at
		 * all). A non-MLD vif gets zero links here and falls through
		 * to the existing single-radio path below unchanged. */
		w->link_count = collect_mlo_links(iw, de->d_name, w->links,
						  WL_MAX_LINKS);

		/* Radio-scoped values. An MLD netdev cannot answer these as a
		 * single value; leave has_radio false so the agent reports
		 * noSuchInstance rather than a misleading zero, and rely on
		 * links[] above for its real per-radio data instead. */
		if (w->link_count == 0) {
			val = 0;
			if (iw->channel && iw->channel(de->d_name, &val))
				val = 0;
			if (val > 0) {
				val = 0;
				if (iw->frequency && iw->frequency(de->d_name, &val))
					val = 0;
			}
			if (val > 0) {
				w->frequency = (uint32_t)val;
				w->has_radio = true;
				val = 0;
				w->has_noise = iw->noise && !iw->noise(de->d_name, &val);
				if (w->has_noise)
					w->noise = val;
				val = 0;
				w->has_txpower = iw->txpower && !iw->txpower(de->d_name, &val);
				if (w->has_txpower)
					w->txpower = val;
				w->has_chanutil = survey_utilisation(iw, de->d_name,
								     w->frequency,
								     &w->chanutil);
			}
		}

		/* Associations: rates, SNR and the deduplicated client total. */
		if (iw->assoclist && !iw->assoclist(de->d_name, abuf, &alen) && alen > 0) {
			n = alen / (int)sizeof(struct iwinfo_assoclist_entry);
			for (i = 0; i < n; i++) {
				struct iwinfo_assoclist_entry *e =
					(struct iwinfo_assoclist_entry *)
					&abuf[i * sizeof(*e)];
				uint32_t tx = e->tx_rate.rate / 1000;
				uint32_t rx = e->rx_rate.rate / 1000;
				int32_t snr = (int32_t)e->signal - (int32_t)e->noise;

				if (!w->has_rates) {
					w->tx_min = w->tx_max = tx;
					w->rx_min = w->rx_max = rx;
					w->snr_min = w->snr_max = snr;
					w->has_rates = true;
				} else {
					if (tx < w->tx_min) w->tx_min = tx;
					if (tx > w->tx_max) w->tx_max = tx;
					if (rx < w->rx_min) w->rx_min = rx;
					if (rx > w->rx_max) w->rx_max = rx;
					if (snr < w->snr_min) w->snr_min = snr;
					if (snr > w->snr_max) w->snr_max = snr;
				}
				tx_sum += tx;
				rx_sum += rx;
				snr_sum += snr;
				w->clients++;

				/* openwrtWirelessClientCount is documented to exclude
				 * this device's own upstream associations, so only
				 * an AP/master-mode row's peers count as clients;
				 * a STA-mode uplink's one "peer" is the AP above us,
				 * not a client of ours. */
				if (mode == IWINFO_OPMODE_MASTER &&
				    seen_n < sizeof(seen) / sizeof(seen[0]) &&
				    !mac_seen(seen, seen_n, e->mac)) {
					memcpy(seen[seen_n].a, e->mac, 6);
					seen_n++;
				}
			}
			if (w->clients) {
				w->tx_avg = (uint32_t)(tx_sum / w->clients);
				w->rx_avg = (uint32_t)(rx_sum / w->clients);
				w->snr_avg = (int32_t)(snr_sum / (int64_t)w->clients);
			}
		}

		s->wl_count++;
		iwinfo_finish();
	}
	closedir(d);
	qsort(s->wl, s->wl_count, sizeof(s->wl[0]), cmp_ifindex);
	s->client_total = (uint32_t)seen_n;
}

/* ------------------------------------------------------------------ */
/* Sensors                                                             */
/* ------------------------------------------------------------------ */

/* Records which thermal zones are already exposed through hwmon so the
 * thermal-zone pass does not report them a second time. */
struct zone_cover { int zone[SENSOR_MAX]; size_t n; };

static bool zone_covered(const struct zone_cover *c, int z)
{
	size_t i;

	for (i = 0; i < c->n; i++)
		if (c->zone[i] == z)
			return true;
	return false;
}

static void label_for(const char *dir, const char *input, char *out, size_t len)
{
	char path[SYSFS_PATH * 2];
	char *suffix;

	if (!join(path, sizeof(path), dir, input)) {
		snprintf(out, len, "unknown");
		return;
	}
	suffix = strstr(path, "_input");
	if (suffix) {
		memcpy(suffix, "_label", 6);
		if (slurp(path, out, len) > 0)
			return;
	}
	if (join(path, sizeof(path), dir, "name") && slurp(path, out, len) > 0)
		return;
	snprintf(out, len, "unknown");
}

static void collect_sensors(struct snapshot *s)
{
	struct zone_cover cover = { .n = 0 };
	DIR *d, *hd;
	struct dirent *de, *he;

	s->temp_count = 0;
	s->fan_count = 0;

	d = opendir(SYS_HWMON);
	if (d) {
		while ((de = readdir(d))) {
			char dir[SYSFS_PATH], real[PATH_MAX], *zp;

			if (strncmp(de->d_name, "hwmon", 5))
				continue;
			if (!join(dir, sizeof(dir), SYS_HWMON, de->d_name))
				continue;

			/* Note any thermal zone backing this hwmon device. */
			if (realpath(dir, real) && (zp = strstr(real, "thermal_zone")))
				if (cover.n < SENSOR_MAX)
					cover.zone[cover.n++] = atoi(zp + 12);

			hd = opendir(dir);
			if (!hd)
				continue;
			while ((he = readdir(hd))) {
				char path[SYSFS_PATH * 2];
				uint32_t v;
				bool is_temp = !strncmp(he->d_name, "temp", 4);
				bool is_fan = !strncmp(he->d_name, "fan", 3);

				if ((!is_temp && !is_fan) || !strstr(he->d_name, "_input"))
					continue;
				if (!join(path, sizeof(path), dir, he->d_name))
					continue;
				if (!read_u32(path, &v))
					continue;

				if (is_temp && s->temp_count < SENSOR_MAX) {
					struct sensor *t = &s->temp[s->temp_count];
					t->index = (int)s->temp_count + 1;
					t->value = v;
					label_for(dir, he->d_name, t->device,
						  sizeof(t->device));
					s->temp_count++;
				} else if (is_fan && s->fan_count < SENSOR_MAX) {
					struct sensor *f = &s->fan[s->fan_count];
					f->index = (int)s->fan_count + 1;
					f->value = v;
					label_for(dir, he->d_name, f->device,
						  sizeof(f->device));
					s->fan_count++;
				}
			}
			closedir(hd);
		}
		closedir(d);
	}

	/* Thermal zones with no hwmon representation. */
	d = opendir(SYS_THERMAL);
	if (!d)
		return;
	while ((de = readdir(d))) {
		char path[PATH_MAX];
		uint32_t v;
		int z;

		if (strncmp(de->d_name, "thermal_zone", 12))
			continue;
		z = atoi(de->d_name + 12);
		if (zone_covered(&cover, z) || s->temp_count >= SENSOR_MAX)
			continue;
		if (!join(path, sizeof(path) - 6, SYS_THERMAL, de->d_name))
			continue;
		strcat(path, "/temp");
		if (!read_u32(path, &v))
			continue;
		struct sensor *t = &s->temp[s->temp_count];
		t->index = (int)s->temp_count + 1;
		t->value = v;
		if (join(path, sizeof(path) - 6, SYS_THERMAL, de->d_name))
			strcat(path, "/type");
		if (slurp(path, t->device, sizeof(t->device)) <= 0)
			t->device[0] = '\0';
		if (!t->device[0])
			snprintf(t->device, sizeof(t->device), "zone%d", z);
		s->temp_count++;
	}
	closedir(d);
}

/* ------------------------------------------------------------------ */

const struct snapshot *snapshot_get(void)
{
	time_t now = time(NULL);

	if (snap_valid && (now - snap.taken) < ttl_seconds())
		return &snap;

	memset(&snap, 0, sizeof(snap));
	collect_wireless(&snap);
	collect_sensors(&snap);
	snap.taken = now;
	snap_valid = true;
	return &snap;
}

void snapshot_cleanup(void)
{
	iwinfo_finish();
	mlo_cleanup();
	snap_valid = false;
}

/* ------------------------------------------------------------------ */
/* Diagnostic dump                                                     */
/* ------------------------------------------------------------------ */

/* Mirrors collect_wireless()'s discovery and call order exactly, including
 * the per-interface iwinfo_finish(), so whatever state dependency causes
 * the CLI/in-process divergence is reproduced rather than avoided. */
void collect_dump(void)
{
	DIR *d;
	struct dirent *de;

	d = opendir(SYS_NET);
	if (!d) {
		printf("cannot open %s\n", SYS_NET);
		return;
	}

	while ((de = readdir(d))) {
		char path[PATH_MAX], abuf[IWINFO_BUFSIZE];
		const struct iwinfo_ops *iw;
		char ssid_buf[IWINFO_ESSID_MAX_SIZE + 1] = { 0 };
		int mode_v = 0, chan_v = 0, freq_v = 0, noise_v = 0, txp_v = 0;
		int mode_r, ssid_r, chan_r, freq_r, noise_r, txp_r;
		int alen = 0, assoc_r;

		if (de->d_name[0] == '.')
			continue;
		if (!join(path, sizeof(path) - 10, SYS_NET, de->d_name))
			continue;
		strcat(path, "/phy80211");
		if (access(path, F_OK))
			continue;

		iw = iwinfo_backend(de->d_name);
		printf("== %s ==\n", de->d_name);
		if (!iw) {
			printf("  iwinfo_backend: NULL (no backend claims this iface)\n");
			continue;
		}
		printf("  backend: %s\n", iw->name ? iw->name : "(null name)");

		mode_r = iw->mode ? iw->mode(de->d_name, &mode_v) : -1;
		printf("  mode()      ret=%d val=%d\n", mode_r, mode_v);

		ssid_r = iw->ssid ? iw->ssid(de->d_name, ssid_buf) : -1;
		printf("  ssid()      ret=%d val=\"%s\"\n", ssid_r, ssid_buf);

		chan_r = iw->channel ? iw->channel(de->d_name, &chan_v) : -1;
		printf("  channel()   ret=%d val=%d\n", chan_r, chan_v);

		freq_r = iw->frequency ? iw->frequency(de->d_name, &freq_v) : -1;
		printf("  frequency() ret=%d val=%d\n", freq_r, freq_v);

		noise_r = iw->noise ? iw->noise(de->d_name, &noise_v) : -1;
		printf("  noise()     ret=%d val=%d\n", noise_r, noise_v);

		txp_r = iw->txpower ? iw->txpower(de->d_name, &txp_v) : -1;
		printf("  txpower()   ret=%d val=%d\n", txp_r, txp_v);

		assoc_r = iw->assoclist ? iw->assoclist(de->d_name, abuf, &alen) : -1;
		printf("  assoclist() ret=%d len=%d (%d entries)\n", assoc_r, alen,
		       alen > 0 ? (int)(alen / (int)sizeof(struct iwinfo_assoclist_entry)) : 0);

		{
			struct mlo_link links[WL_MAX_LINKS];
			size_t n = mlo_get_links(de->d_name, links, WL_MAX_LINKS);
			size_t k;

			printf("  mlo_get_links() n=%zu\n", n);
			for (k = 0; k < n; k++) {
				const struct mlo_link *l = &links[k];
				uint32_t cu;
				bool has_cu = l->frequency &&
					survey_utilisation(iw, de->d_name,
							   l->frequency, &cu);

				printf("    link id=%d addr=%02x:%02x:%02x:%02x:%02x:%02x "
				       "freq=%u txpower=%s%d chanutil=%s%u\n",
				       l->link_id,
				       l->addr[0], l->addr[1], l->addr[2],
				       l->addr[3], l->addr[4], l->addr[5],
				       l->frequency,
				       l->has_txpower ? "" : "(absent)",
				       l->has_txpower ? l->txpower : 0,
				       has_cu ? "" : "(absent)",
				       has_cu ? cu : 0);
			}
		}

		if (getenv("OPENWRT_SNMP_DUMP_NO_FINISH")) {
			printf("  -- iwinfo_finish() SKIPPED (OPENWRT_SNMP_DUMP_NO_FINISH) --\n");
		} else {
			iwinfo_finish();
			printf("  -- iwinfo_finish() called --\n");
		}
	}
	closedir(d);
}
