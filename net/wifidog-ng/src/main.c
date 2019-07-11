/*
 *  Copyright (C) 2017 jianhui zhao <jianhuizhao329@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as
 *  published by the Free Software Foundation.
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/version.h>

#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <net/netfilter/nf_nat.h>
#include <net/netfilter/nf_nat_l3proto.h>

#include "utils.h"
#include "config.h"

#define IPS_HIJACKED    (1 << 31)
#define IPS_ALLOWED     (1 << 30)

#if LINUX_VERSION_CODE > KERNEL_VERSION(4, 17, 19)
static u32 wd_nat_setup_info(struct sk_buff *skb, struct nf_conn *ct)
#else
static u32 wd_nat_setup_info(void *priv, struct sk_buff *skb,
    const struct nf_hook_state *state, struct nf_conn *ct)
#endif
{
    struct config *conf = get_config();
    struct tcphdr *tcph = tcp_hdr(skb);
    union nf_conntrack_man_proto proto;
#if LINUX_VERSION_CODE > KERNEL_VERSION(4, 17, 19)
    struct nf_nat_range2 newrange = {};
#else
    struct nf_nat_range newrange = {};
#endif
    static uint16_t PORT_80 = htons(80);

    proto.tcp.port = (tcph->dest == PORT_80) ? htons(conf->port) : htons(conf->ssl_port);
    newrange.flags       = NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED;
    newrange.min_addr.ip = conf->interface_ipaddr;
    newrange.max_addr.ip = conf->interface_ipaddr;
    newrange.min_proto   = proto;
    newrange.max_proto   = proto;

    ct->status |= IPS_HIJACKED;

    return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
}

static u32 wifidog_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state)
{
    struct config *conf = get_config();
    struct iphdr *iph = ip_hdr(skb);
    struct nf_conn *ct;
    struct tcphdr *tcph;
    struct udphdr *udph;
    enum ip_conntrack_info ctinfo;
    static uint16_t PORT_80 = htons(80);    /* http */
    static uint16_t PORT_443 = htons(443);  /* https */
    static uint16_t PORT_67 = htons(67);    /* dhcp */
    static uint16_t PORT_53 = htons(53);    /* dns */

    if (unlikely(!conf->enabled))
        return NF_ACCEPT;

    if (state->in->ifindex != conf->interface_ifindex)
        return NF_ACCEPT;

    /* Accept broadcast */
    if (skb->pkt_type == PACKET_BROADCAST || skb->pkt_type == PACKET_MULTICAST)
        return NF_ACCEPT;

    /* Accept all to local area networks */
    if ((iph->daddr | ~conf->interface_mask) == conf->interface_broadcast)
        return NF_ACCEPT;

    ct = nf_ct_get(skb, &ctinfo);
    if (!ct || (ct->status & IPS_ALLOWED))
        return NF_ACCEPT;

    if (ct->status & IPS_HIJACKED) {
        if (is_allowed_mac(skb, state)) {
            /* Avoid duplication of authentication */
            nf_reset(skb);
            nf_ct_kill(ct);
        }
        return NF_ACCEPT;
    } else if (ctinfo == IP_CT_NEW && (is_allowed_dest_ip(skb, state) || is_allowed_mac(skb, state))) {
        ct->status |= IPS_ALLOWED;
        return NF_ACCEPT;
    }

    switch (iph->protocol) {
    case IPPROTO_TCP:
        tcph = tcp_hdr(skb);
        if(tcph->dest == PORT_53 || tcph->dest == PORT_67) {
            ct->status |= IPS_ALLOWED;
            return NF_ACCEPT;
        }

        if (tcph->dest == PORT_80 || tcph->dest == PORT_443)
            goto redirect;
        else
            return NF_DROP;

    case IPPROTO_UDP:
        udph = udp_hdr(skb);
        if(udph->dest == PORT_53 || udph->dest == PORT_67) {
            ct->status |= IPS_ALLOWED;
            return NF_ACCEPT;
        }
        return NF_DROP;

    default:
        ct->status |= IPS_ALLOWED;
        return NF_ACCEPT;
    }

redirect:
    /* all packets from unknown client are dropped */
    if (ctinfo != IP_CT_NEW || (ct->status & IPS_DST_NAT_DONE)) {
        pr_debug("dropping packets of suspect stream, src:%pI4, dst:%pI4\n", &iph->saddr, &iph->daddr);
        return NF_DROP;
    }

#if LINUX_VERSION_CODE > KERNEL_VERSION(4, 17, 19)
    return wd_nat_setup_info(skb, ct);
#else
    return nf_nat_ipv4_in(priv, skb, state, wd_nat_setup_info);
#endif
}

static struct nf_hook_ops wifidog_ops __read_mostly = {
    .hook       = wifidog_hook,
    .pf         = PF_INET,
    .hooknum    = NF_INET_PRE_ROUTING,
    .priority   = NF_IP_PRI_NAT_DST
};

static int __init wifidog_init(void)
{
    int ret;

    ret = init_config();
    if (ret)
        return ret;

#if LINUX_VERSION_CODE > KERNEL_VERSION(4, 17, 19)
    ret = nf_nat_l3proto_ipv4_register_fn(&init_net, &wifidog_ops);
#elif LINUX_VERSION_CODE > KERNEL_VERSION(4, 12, 14)
    ret = nf_register_net_hook(&init_net, &wifidog_ops);
#else
    ret = nf_register_hook(&wifidog_ops);
#endif
    if (ret < 0) {
        pr_err("can't register hook\n");
        goto remove_config;
    }

    pr_info("kmod of wifidog is started\n");

    return 0;

remove_config:
    deinit_config();
    return ret;
}

static void __exit wifidog_exit(void)
{
    deinit_config();

#if LINUX_VERSION_CODE > KERNEL_VERSION(4, 17, 19)
    nf_nat_l3proto_ipv4_unregister_fn(&init_net, &wifidog_ops);
#elif LINUX_VERSION_CODE > KERNEL_VERSION(4, 12, 14)
    nf_unregister_net_hook(&init_net, &wifidog_ops);
#else
    nf_unregister_hook(&wifidog_ops);
#endif

    pr_info("kmod of wifidog-ng is stop\n");
}

module_init(wifidog_init);
module_exit(wifidog_exit);

MODULE_AUTHOR("jianhui zhao <jianhuizhao329@gmail.com>");
MODULE_LICENSE("GPL");
