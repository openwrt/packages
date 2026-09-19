/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * agent.c - AgentX subagent exporting OpenWrt metrics over SNMP.
 *
 * Two subtrees are served:
 *   .1.3.6.1.4.1.66510.1.10   OPENWRT-WIRELESS-MIB (OpenWrt IANA PEN 66510)
 *   .1.3.6.1.4.1.2021.13.16   LM-SENSORS-MIB temperature and fan tables
 *
 * OpenWrt's snmpd enables the AgentX master by default and listens on
 * /var/run/agentx.sock, so no snmpd configuration is required. Any
 * pass_persist line previously registering either subtree must be removed,
 * or snmpd has two claimants for the same OIDs.
 */
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>

#include "collect.h"

#define AGENT_VERSION "1.0.0"

static volatile sig_atomic_t running = 1;

static oid wl_scalar_ifcount[]  = { 1,3,6,1,4,1,66510,1,10,1 };
static oid wl_scalar_clients[]  = { 1,3,6,1,4,1,66510,1,10,2 };
static oid wl_table_oid[]       = { 1,3,6,1,4,1,66510,1,10,3 };
static oid wl_link_table_oid[]  = { 1,3,6,1,4,1,66510,1,10,4 };
static oid lm_temp_table_oid[]  = { 1,3,6,1,4,1,2021,13,16,2 };
static oid lm_fan_table_oid[]   = { 1,3,6,1,4,1,2021,13,16,3 };

static void on_signal(int sig) { (void)sig; running = 0; }

/* ------------------------------------------------------------------ */
/* Scalars                                                             */
/* ------------------------------------------------------------------ */

static int scalar_handler(netsnmp_mib_handler *handler,
			  netsnmp_handler_registration *reginfo,
			  netsnmp_agent_request_info *reqinfo,
			  netsnmp_request_info *requests)
{
	const struct snapshot *s = snapshot_get();
	uint32_t v;

	(void)handler;
	if (reqinfo->mode != MODE_GET)
		return SNMP_ERR_NOERROR;

	v = (reginfo->rootoid[9] == 1) ? (uint32_t)s->wl_count : s->client_total;
	snmp_set_var_typed_value(requests->requestvb, ASN_GAUGE,
				 (u_char *)&v, sizeof(v));
	return SNMP_ERR_NOERROR;
}

/* ------------------------------------------------------------------ */
/* Wireless interface table                                            */
/* ------------------------------------------------------------------ */

static netsnmp_variable_list *wl_next(void **loop, void **data,
				      netsnmp_variable_list *idx,
				      netsnmp_iterator_info *ii)
{
	const struct snapshot *s = snapshot_get();
	size_t i = (size_t)(intptr_t)*loop;

	(void)ii;
	if (i >= s->wl_count)
		return NULL;
	*data = (void *)&s->wl[i];
	*loop = (void *)(intptr_t)(i + 1);
	snmp_set_var_typed_integer(idx, ASN_INTEGER, s->wl[i].ifindex);
	return idx;
}

static netsnmp_variable_list *wl_first(void **loop, void **data,
				       netsnmp_variable_list *idx,
				       netsnmp_iterator_info *ii)
{
	*loop = (void *)(intptr_t)0;
	return wl_next(loop, data, idx, ii);
}

static void set_gauge(netsnmp_request_info *req, uint32_t v)
{
	snmp_set_var_typed_value(req->requestvb, ASN_GAUGE,
				 (u_char *)&v, sizeof(v));
}

static void set_int(netsnmp_request_info *req, int32_t v)
{
	snmp_set_var_typed_integer(req->requestvb, ASN_INTEGER, v);
}

static int wl_handler(netsnmp_mib_handler *handler,
		      netsnmp_handler_registration *reginfo,
		      netsnmp_agent_request_info *reqinfo,
		      netsnmp_request_info *requests)
{
	netsnmp_request_info *req;

	(void)handler; (void)reginfo;
	if (reqinfo->mode != MODE_GET)
		return SNMP_ERR_NOERROR;

	for (req = requests; req; req = req->next) {
		const struct wl_iface *w = netsnmp_extract_iterator_context(req);
		netsnmp_table_request_info *ti = netsnmp_extract_table_info(req);

		if (!w || !ti)
			continue;

		/* An MLD netdev spans several radio links, so the per-radio
		 * columns have no single answer. Reporting zero would look
		 * like a real measurement. */
		if (!w->has_radio && (ti->colnum == 5 || ti->colnum == 6 ||
				      ti->colnum == 16 || ti->colnum == 17)) {
			netsnmp_request_set_error(req, SNMP_NOSUCHINSTANCE);
			continue;
		}
		/* Even on a single-radio vif, libiwinfo's noise/txpower/survey
		 * calls can individually fail while channel/frequency succeed;
		 * a bare 0 would then look like a real dBm/percent reading. */
		if (ti->colnum == 6 && !w->has_noise) {
			netsnmp_request_set_error(req, SNMP_NOSUCHINSTANCE);
			continue;
		}
		if (ti->colnum == 16 && !w->has_chanutil) {
			netsnmp_request_set_error(req, SNMP_NOSUCHINSTANCE);
			continue;
		}
		if (ti->colnum == 17 && !w->has_txpower) {
			netsnmp_request_set_error(req, SNMP_NOSUCHINSTANCE);
			continue;
		}

		switch (ti->colnum) {
		case 2:
			snmp_set_var_typed_value(req->requestvb, ASN_OCTET_STR,
						 (const u_char *)w->name,
						 strlen(w->name));
			break;
		case 3:
			snmp_set_var_typed_value(req->requestvb, ASN_OCTET_STR,
						 (const u_char *)w->ssid,
						 strlen(w->ssid));
			break;
		case 4:  set_gauge(req, w->clients);   break;
		case 5:  set_gauge(req, w->frequency); break;
		case 6:  set_int(req, w->noise);       break;
		case 7:  set_gauge(req, w->tx_min);    break;
		case 8:  set_gauge(req, w->tx_avg);    break;
		case 9:  set_gauge(req, w->tx_max);    break;
		case 10: set_gauge(req, w->rx_min);    break;
		case 11: set_gauge(req, w->rx_avg);    break;
		case 12: set_gauge(req, w->rx_max);    break;
		case 13: set_int(req, w->snr_min);     break;
		case 14: set_int(req, w->snr_avg);     break;
		case 15: set_int(req, w->snr_max);     break;
		case 16: set_gauge(req, w->chanutil);  break;
		case 17: set_int(req, w->txpower);     break;
		default:
			netsnmp_request_set_error(req, SNMP_NOSUCHOBJECT);
			break;
		}
	}
	return SNMP_ERR_NOERROR;
}

/* ------------------------------------------------------------------ */
/* Wireless link table (802.11be Multi-Link Operation)                 */
/* ------------------------------------------------------------------ */

/* Rows are (ifIndex, linkId) pairs flattened across every interface's
 * links[]; *loop is that flat position. wl[] is ifindex-sorted and each
 * iface's links[] is link_id-sorted (collect_mlo_links()), so walking flat
 * positions in order yields rows in index order as GETNEXT requires. */
static bool link_row_at(const struct snapshot *s, size_t flat,
			const struct wl_iface **out_w, size_t *out_j)
{
	size_t i;

	for (i = 0; i < s->wl_count; i++) {
		const struct wl_iface *w = &s->wl[i];

		if (flat < w->link_count) {
			*out_w = w;
			*out_j = flat;
			return true;
		}
		flat -= w->link_count;
	}
	return false;
}

static netsnmp_variable_list *link_next(void **loop, void **data,
					netsnmp_variable_list *idx,
					netsnmp_iterator_info *ii)
{
	const struct snapshot *s = snapshot_get();
	size_t flat = (size_t)(intptr_t)*loop;
	const struct wl_iface *w;
	size_t j;

	(void)ii;
	if (!link_row_at(s, flat, &w, &j))
		return NULL;

	*data = (void *)&w->links[j];
	*loop = (void *)(intptr_t)(flat + 1);
	snmp_set_var_typed_integer(idx, ASN_INTEGER, w->ifindex);
	snmp_set_var_typed_integer(idx->next_variable, ASN_INTEGER,
				   w->links[j].link_id);
	return idx;
}

static netsnmp_variable_list *link_first(void **loop, void **data,
					 netsnmp_variable_list *idx,
					 netsnmp_iterator_info *ii)
{
	*loop = (void *)(intptr_t)0;
	return link_next(loop, data, idx, ii);
}

static int link_handler(netsnmp_mib_handler *handler,
			netsnmp_handler_registration *reginfo,
			netsnmp_agent_request_info *reqinfo,
			netsnmp_request_info *requests)
{
	netsnmp_request_info *req;

	(void)handler; (void)reginfo;
	if (reqinfo->mode != MODE_GET)
		return SNMP_ERR_NOERROR;

	for (req = requests; req; req = req->next) {
		const struct wl_link *l = netsnmp_extract_iterator_context(req);
		netsnmp_table_request_info *ti = netsnmp_extract_table_info(req);

		if (!l || !ti)
			continue;

		if (ti->colnum == 5 && !l->has_txpower) {
			netsnmp_request_set_error(req, SNMP_NOSUCHINSTANCE);
			continue;
		}
		if (ti->colnum == 6 && !l->has_chanutil) {
			netsnmp_request_set_error(req, SNMP_NOSUCHINSTANCE);
			continue;
		}

		switch (ti->colnum) {
		case 3:
			snmp_set_var_typed_value(req->requestvb, ASN_OCTET_STR,
						 (const u_char *)l->addr,
						 sizeof(l->addr));
			break;
		case 4: set_gauge(req, l->frequency); break;
		case 5: set_int(req, l->txpower);     break;
		case 6: set_gauge(req, l->chanutil);  break;
		default:
			netsnmp_request_set_error(req, SNMP_NOSUCHOBJECT);
			break;
		}
	}
	return SNMP_ERR_NOERROR;
}

/* ------------------------------------------------------------------ */
/* LM-SENSORS temperature and fan tables                               */
/* ------------------------------------------------------------------ */

/* Both tables have the same shape, so one pair of hooks serves them; the
 * iterator info's my_loop_context selects which list to walk. */
struct lm_ctx { bool fan; };
static struct lm_ctx lm_temp_ctx = { .fan = false };
static struct lm_ctx lm_fan_ctx  = { .fan = true };

static netsnmp_variable_list *lm_next(void **loop, void **data,
				      netsnmp_variable_list *idx,
				      netsnmp_iterator_info *ii)
{
	const struct snapshot *s = snapshot_get();
	const struct lm_ctx *c = ii->myvoid;
	const struct sensor *list = c->fan ? s->fan : s->temp;
	size_t count = c->fan ? s->fan_count : s->temp_count;
	size_t i = (size_t)(intptr_t)*loop;

	if (i >= count)
		return NULL;
	*data = (void *)&list[i];
	*loop = (void *)(intptr_t)(i + 1);
	snmp_set_var_typed_integer(idx, ASN_INTEGER, list[i].index);
	return idx;
}

static netsnmp_variable_list *lm_first(void **loop, void **data,
				       netsnmp_variable_list *idx,
				       netsnmp_iterator_info *ii)
{
	*loop = (void *)(intptr_t)0;
	return lm_next(loop, data, idx, ii);
}

static int lm_handler(netsnmp_mib_handler *handler,
		      netsnmp_handler_registration *reginfo,
		      netsnmp_agent_request_info *reqinfo,
		      netsnmp_request_info *requests)
{
	netsnmp_request_info *req;

	(void)handler; (void)reginfo;
	if (reqinfo->mode != MODE_GET)
		return SNMP_ERR_NOERROR;

	for (req = requests; req; req = req->next) {
		const struct sensor *sn = netsnmp_extract_iterator_context(req);
		netsnmp_table_request_info *ti = netsnmp_extract_table_info(req);

		if (!sn || !ti)
			continue;
		switch (ti->colnum) {
		case 1: set_int(req, sn->index); break;
		case 2:
			snmp_set_var_typed_value(req->requestvb, ASN_OCTET_STR,
						 (const u_char *)sn->device,
						 strlen(sn->device));
			break;
		case 3: set_gauge(req, sn->value); break;
		default:
			netsnmp_request_set_error(req, SNMP_NOSUCHOBJECT);
			break;
		}
	}
	return SNMP_ERR_NOERROR;
}

/* ------------------------------------------------------------------ */

static void register_table_n(const char *name, oid *base, size_t baselen,
			     Netsnmp_Node_Handler *handler,
			     Netsnmp_First_Data_Point *first,
			     Netsnmp_Next_Data_Point *next,
			     int min_col, int max_col, void *myvoid,
			     int n_index)
{
	netsnmp_handler_registration *reg;
	netsnmp_table_registration_info *tinfo;
	netsnmp_iterator_info *iinfo;

	reg = netsnmp_create_handler_registration(name, handler, base, baselen,
						  HANDLER_CAN_RONLY);
	tinfo = SNMP_MALLOC_TYPEDEF(netsnmp_table_registration_info);
	if (n_index == 2)
		netsnmp_table_helper_add_indexes(tinfo, ASN_INTEGER,
						 ASN_INTEGER, 0);
	else
		netsnmp_table_helper_add_indexes(tinfo, ASN_INTEGER, 0);
	tinfo->min_column = min_col;
	tinfo->max_column = max_col;

	iinfo = SNMP_MALLOC_TYPEDEF(netsnmp_iterator_info);
	iinfo->get_first_data_point = first;
	iinfo->get_next_data_point = next;
	iinfo->table_reginfo = tinfo;
	iinfo->myvoid = myvoid;

	netsnmp_register_table_iterator(reg, iinfo);
}

static void register_table(const char *name, oid *base, size_t baselen,
			   Netsnmp_Node_Handler *handler,
			   Netsnmp_First_Data_Point *first,
			   Netsnmp_Next_Data_Point *next,
			   int min_col, int max_col, void *myvoid)
{
	register_table_n(name, base, baselen, handler, first, next,
			 min_col, max_col, myvoid, 1);
}

int main(int argc, char **argv)
{
	/* OpenWrt's snmpd writes "agentXSocket /var/run/agentx.sock"; net-snmp's
	 * compiled-in default is elsewhere, so connect where snmpd listens. */
	const char *sock = "/var/run/agentx.sock";
	int use_syslog = 1;
	int i;

	for (i = 1; i < argc; i++) {
		if (!strcmp(argv[i], "-f"))
			use_syslog = 0;
		else if (!strcmp(argv[i], "-x") && i + 1 < argc)
			sock = argv[++i];
		else if (!strcmp(argv[i], "--dump")) {
			collect_dump();
			return 0;
		} else if (!strcmp(argv[i], "--version") ||
			  !strcmp(argv[i], "-V") ||
			  !strcmp(argv[i], "--help")) {
			printf("openwrt-snmp-agent " AGENT_VERSION "\n");
			return 0;
		}
	}

	if (use_syslog)
		snmp_enable_calllog();
	else
		snmp_enable_stderrlog();

	/* Run as an AgentX subagent, not a standalone master. */
	netsnmp_ds_set_boolean(NETSNMP_DS_APPLICATION_ID,
			       NETSNMP_DS_AGENT_ROLE, 1);
	netsnmp_ds_set_string(NETSNMP_DS_APPLICATION_ID,
			      NETSNMP_DS_AGENT_X_SOCKET, sock);

	init_agent("openwrt-metrics");

	netsnmp_register_read_only_scalar(
		netsnmp_create_handler_registration(
			"openwrtWirelessInterfaceCount", scalar_handler,
			wl_scalar_ifcount, OID_LENGTH(wl_scalar_ifcount),
			HANDLER_CAN_RONLY));
	netsnmp_register_read_only_scalar(
		netsnmp_create_handler_registration(
			"openwrtWirelessClientCount", scalar_handler,
			wl_scalar_clients, OID_LENGTH(wl_scalar_clients),
			HANDLER_CAN_RONLY));

	register_table("openwrtWirelessInterfaceTable", wl_table_oid,
		       OID_LENGTH(wl_table_oid), wl_handler, wl_first, wl_next,
		       2, 17, NULL);
	register_table_n("openwrtWirelessLinkTable", wl_link_table_oid,
			 OID_LENGTH(wl_link_table_oid), link_handler,
			 link_first, link_next, 3, 6, NULL, 2);
	register_table("lmTempSensorsTable", lm_temp_table_oid,
		       OID_LENGTH(lm_temp_table_oid), lm_handler, lm_first,
		       lm_next, 1, 3, &lm_temp_ctx);
	register_table("lmFanSensorsTable", lm_fan_table_oid,
		       OID_LENGTH(lm_fan_table_oid), lm_handler, lm_first,
		       lm_next, 1, 3, &lm_fan_ctx);

	init_snmp("openwrt-metrics");

	signal(SIGTERM, on_signal);
	signal(SIGINT, on_signal);

	while (running)
		agent_check_and_process(1);

	snmp_shutdown("openwrt-metrics");
	snapshot_cleanup();
	return 0;
}
