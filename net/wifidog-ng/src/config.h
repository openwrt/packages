/*
 *  Copyright (C) 2017 jianhui zhao <jianhuizhao329@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as
 *  published by the Free Software Foundation.
 */

#ifndef __CONFIG_H_
#define __CONFIG_H_

#include <linux/proc_fs.h>

#define PROC_DIR_NAME "wifidog-ng"

struct config {
    int enabled;
    char interface[32];
    int interface_ifindex;
    __be32 interface_ipaddr;
    __be32 interface_mask;
    __be32 interface_broadcast;
    int port;
    int ssl_port;
};

int init_config(void);
void deinit_config(void);
struct config *get_config(void);

#endif
