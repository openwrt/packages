/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * collect.h - data collection for the OpenWrt SNMP subagent.
 *
 * A single snapshot holds everything the agent serves. It is rebuilt at most
 * once per SNAPSHOT_TTL seconds: an SNMP walk drives one getnext per OID, and
 * re-running netlink queries for each would overrun the AgentX timeout.
 */
#ifndef OPENWRT_SNMP_COLLECT_H
#define OPENWRT_SNMP_COLLECT_H

#include <stdint.h>
#include <stdbool.h>
#include <time.h>

#define WL_MAX_IFACES   32
#define WL_MAX_LINKS    4
#define SENSOR_MAX      64
#define LABEL_MAX       64

/* One radio link of a multi-link (MLD) interface. A regular single-link vif
 * has none of these; an MLD's own channel/noise/txpower/chanutil columns are
 * absent for the same reason (see has_radio below) and these rows are where
 * that per-radio data actually lives instead, one row per link. */
struct wl_link {
	int       link_id;
	uint8_t   addr[6];
	uint32_t  frequency;      /* MHz */
	bool      has_txpower;
	int32_t   txpower;        /* dBm */
	bool      has_chanutil;
	uint32_t  chanutil;       /* percent */
};

/* Columns an MLD (multi-link) interface cannot answer are marked absent
 * rather than reported as zero; the agent returns noSuchInstance for them.
 * Their real per-radio data is in links[] / link_count instead. */
struct wl_iface {
	int       ifindex;
	char      name[32];
	char      ssid[LABEL_MAX];

	uint32_t  clients;

	bool      has_radio;      /* frequency valid */
	uint32_t  frequency;      /* MHz */
	bool      has_noise;
	int32_t   noise;          /* dBm */
	bool      has_txpower;
	int32_t   txpower;        /* dBm */
	bool      has_chanutil;
	uint32_t  chanutil;       /* percent */

	struct wl_link links[WL_MAX_LINKS];
	size_t    link_count;      /* >0 marks this vif an MLD */

	bool      has_rates;      /* false when no clients are associated */
	uint32_t  tx_min, tx_avg, tx_max;   /* Mbit/s */
	uint32_t  rx_min, rx_avg, rx_max;   /* Mbit/s */
	int32_t   snr_min, snr_avg, snr_max; /* dB */
};

struct sensor {
	int   index;
	char  device[LABEL_MAX];
	uint32_t value;           /* milli-degrees C, or RPM */
};

struct snapshot {
	time_t           taken;
	struct wl_iface  wl[WL_MAX_IFACES];
	size_t           wl_count;
	uint32_t         client_total;    /* deduplicated across all VAPs */
	struct sensor    temp[SENSOR_MAX];
	size_t           temp_count;
	struct sensor    fan[SENSOR_MAX];
	size_t           fan_count;
};

/* Returns the current snapshot, refreshing it if older than the TTL. */
const struct snapshot *snapshot_get(void);
void snapshot_cleanup(void);

/* Prints the raw return code and value of every wireless op, per interface,
 * to stdout. Diagnostic tool for cases where libiwinfo behaves differently
 * in-process than via the iwinfo CLI (see agent.c --dump). */
void collect_dump(void);

#endif /* OPENWRT_SNMP_COLLECT_H */
