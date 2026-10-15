/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * mlo.h - direct nl80211 query for Multi-Link Operation per-link data.
 */
#ifndef OPENWRT_SNMP_MLO_H
#define OPENWRT_SNMP_MLO_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#define MLO_MAX_LINKS 4

struct mlo_link {
	int      link_id;
	uint8_t  addr[6];
	uint32_t frequency;    /* MHz, 0 if the kernel didn't report one */
	bool     has_txpower;
	int32_t  txpower;      /* dBm */
};

/* Queries NL80211_CMD_GET_INTERFACE for ifname and extracts
 * NL80211_ATTR_MLO_LINKS. Returns the number of links found: 0 for a
 * non-MLD interface, a query failure, or an interface with no links. */
size_t mlo_get_links(const char *ifname, struct mlo_link *out, size_t max);

void mlo_cleanup(void);

#endif /* OPENWRT_SNMP_MLO_H */
