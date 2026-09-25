/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * mlo.c - direct nl80211 query for Multi-Link Operation per-link data.
 *
 * libiwinfo has no MLO awareness: its channel/frequency/txpower calls read
 * the legacy top-level NL80211_ATTR_WIPHY_FREQ / NL80211_ATTR_WIPHY_TX_POWER_LEVEL
 * from a plain NL80211_CMD_GET_INTERFACE, attributes the kernel does not
 * reliably populate for an MLD wdev (confirmed live on a two-link AP: the
 * top-level frequency picked one arbitrary link's channel, and the top-level
 * tx power was absent entirely). The real per-link values live nested under
 * NL80211_ATTR_MLO_LINKS, one entry per link, which nothing in libiwinfo's
 * public API exposes - so this talks to nl80211 directly for that one
 * attribute instead, mirroring the same request/parse pattern libiwinfo
 * itself uses internally.
 */
#include <string.h>
#include <net/if.h>

#include <netlink/netlink.h>
#include <netlink/genl/genl.h>
#include <netlink/genl/ctrl.h>

#include <linux/nl80211.h>

#include "mlo.h"

struct mlo_state {
	struct nl_sock *sock;
	int             family_id;
};

static struct mlo_state st;
static bool st_valid;

static bool mlo_init(void)
{
	if (st_valid)
		return true;

	st.sock = nl_socket_alloc();
	if (!st.sock)
		return false;

	if (genl_connect(st.sock)) {
		nl_socket_free(st.sock);
		st.sock = NULL;
		return false;
	}

	st.family_id = genl_ctrl_resolve(st.sock, "nl80211");
	if (st.family_id < 0) {
		nl_socket_free(st.sock);
		st.sock = NULL;
		return false;
	}

	st_valid = true;
	return true;
}

struct mlo_cb_ctx {
	struct mlo_link *out;
	size_t            max;
	size_t            n;
};

static int mlo_valid_cb(struct nl_msg *msg, void *arg)
{
	struct mlo_cb_ctx *ctx = arg;
	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
	struct nlattr *tb[NL80211_ATTR_MAX + 1];
	struct nlattr *link;
	int rem;

	nla_parse(tb, NL80211_ATTR_MAX, genlmsg_attrdata(gnlh, 0),
	          genlmsg_attrlen(gnlh, 0), NULL);

	if (!tb[NL80211_ATTR_MLO_LINKS])
		return NL_SKIP;

	nla_for_each_nested(link, tb[NL80211_ATTR_MLO_LINKS], rem)
	{
		struct nlattr *lt[NL80211_ATTR_MAX + 1];
		struct mlo_link *l;

		if (ctx->n >= ctx->max)
			break;

		nla_parse_nested(lt, NL80211_ATTR_MAX, link, NULL);

		l = &ctx->out[ctx->n];
		memset(l, 0, sizeof(*l));

		if (lt[NL80211_ATTR_MLO_LINK_ID] &&
		    nla_len(lt[NL80211_ATTR_MLO_LINK_ID]) >= (int)sizeof(uint8_t))
			l->link_id = (int)nla_get_u8(lt[NL80211_ATTR_MLO_LINK_ID]);
		if (lt[NL80211_ATTR_MAC] &&
		    nla_len(lt[NL80211_ATTR_MAC]) >= (int)sizeof(l->addr))
			memcpy(l->addr, nla_data(lt[NL80211_ATTR_MAC]), sizeof(l->addr));
		if (lt[NL80211_ATTR_WIPHY_FREQ] &&
		    nla_len(lt[NL80211_ATTR_WIPHY_FREQ]) >= (int)sizeof(uint32_t))
			l->frequency = nla_get_u32(lt[NL80211_ATTR_WIPHY_FREQ]);
		if (lt[NL80211_ATTR_WIPHY_TX_POWER_LEVEL] &&
		    nla_len(lt[NL80211_ATTR_WIPHY_TX_POWER_LEVEL]) >= (int)sizeof(uint32_t)) {
			l->has_txpower = true;
			/* mBm -> dBm, same conversion libiwinfo applies */
			l->txpower = (int32_t)nla_get_u32(
				lt[NL80211_ATTR_WIPHY_TX_POWER_LEVEL]) / 100;
		}

		ctx->n++;
	}

	return NL_SKIP;
}

static int mlo_err_cb(struct sockaddr_nl *nla, struct nlmsgerr *err, void *arg)
{
	int *ret = arg;
	(void)nla;
	*ret = err->error;
	return NL_STOP;
}

static int mlo_finish_cb(struct nl_msg *msg, void *arg)
{
	int *ret = arg;
	(void)msg;
	*ret = 0;
	return NL_SKIP;
}

static int mlo_ack_cb(struct nl_msg *msg, void *arg)
{
	int *ret = arg;
	(void)msg;
	*ret = 0;
	return NL_STOP;
}

size_t mlo_get_links(const char *ifname, struct mlo_link *out, size_t max)
{
	struct mlo_cb_ctx ctx = { .out = out, .max = max, .n = 0 };
	struct nl_msg *msg;
	struct nl_cb *cb;
	unsigned int ifidx;
	int err = 1;

	if (!mlo_init())
		return 0;

	ifidx = if_nametoindex(ifname);
	if (!ifidx)
		return 0;

	msg = nlmsg_alloc();
	if (!msg)
		return 0;

	cb = nl_cb_alloc(NL_CB_DEFAULT);
	if (!cb) {
		nlmsg_free(msg);
		return 0;
	}

	genlmsg_put(msg, 0, 0, st.family_id, 0, 0, NL80211_CMD_GET_INTERFACE, 0);

	if (nla_put_u32(msg, NL80211_ATTR_IFINDEX, ifidx) < 0) {
		nlmsg_free(msg);
		nl_cb_put(cb);
		return 0;
	}

	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, mlo_valid_cb, &ctx);
	nl_cb_err(cb, NL_CB_CUSTOM, mlo_err_cb, &err);
	nl_cb_set(cb, NL_CB_FINISH, NL_CB_CUSTOM, mlo_finish_cb, &err);
	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, mlo_ack_cb, &err);

	if (nl_send_auto_complete(st.sock, msg) < 0) {
		nlmsg_free(msg);
		nl_cb_put(cb);
		return 0;
	}

	while (err > 0) {
		if (nl_recvmsgs(st.sock, cb) < 0)
			break;
	}

	nlmsg_free(msg);
	nl_cb_put(cb);

	return ctx.n;
}

void mlo_cleanup(void)
{
	if (st_valid && st.sock)
		nl_socket_free(st.sock);
	st_valid = false;
}
