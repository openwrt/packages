/*
 *  Copyright (C) 2017 jianhui zhao <jianhuizhao329@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as
 *  published by the Free Software Foundation.
 */

#ifndef __UTILS_H_
#define __UTILS_H_

#include <linux/netfilter/ipset/ip_set.h>

static inline int wd_ip_set_test(const char *name, const struct sk_buff *skb,
    struct ip_set_adt_opt *opt, const struct nf_hook_state *state)
{
    static struct xt_action_param par = { };
    struct ip_set *set = NULL;
    ip_set_id_t index;
    int ret;

    index = ip_set_get_byname(state->net, name, &set);
    if (!set)
        return 0;

#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 10, 0)
    par.net = state->net;
#else
    par.state = state;
#endif

    ret = ip_set_test(index, skb, &par, opt);
    ip_set_put_byindex(state->net, index);
    return ret;
}

static inline int is_allowed_mac(struct sk_buff *skb, const struct nf_hook_state *state)
{
    static struct ip_set_adt_opt opt = {
        .family = NFPROTO_IPV4,
        .dim = IPSET_DIM_ONE,
        .flags = IPSET_DIM_ONE_SRC,
        .ext.timeout = UINT_MAX,
    };

    return wd_ip_set_test("wifidog-ng-mac", skb, &opt, state);
}

static inline int is_allowed_dest_ip(struct sk_buff *skb, const struct nf_hook_state *state)
{
    static struct ip_set_adt_opt opt = {
        .family = NFPROTO_IPV4,
        .dim = IPSET_DIM_ONE,
        .ext.timeout = UINT_MAX,
    };

    return wd_ip_set_test("wifidog-ng-ip", skb, &opt, state);
}

#endif
