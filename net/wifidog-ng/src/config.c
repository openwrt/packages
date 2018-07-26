/*
 *  Copyright (C) 2017 jianhui zhao <jianhuizhao329@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as
 *  published by the Free Software Foundation.
 */

#include <linux/uaccess.h>
#include <linux/inetdevice.h>
#include <linux/seq_file.h>

#include "config.h"

static struct proc_dir_entry *proc;
static struct config conf;

static int update_gw_interface(const char *interface)
{
    int ret = 0;
    struct net_device *dev;
    struct in_device *in_dev;

    dev = dev_get_by_name(&init_net, interface);
    if (!dev) {
        pr_err("Not found interface: %s\n", interface);
        return -ENOENT;
    }

    conf.interface_ifindex = dev->ifindex;

    in_dev = inetdev_by_index(dev_net(dev), conf.interface_ifindex);
    if (!in_dev) {
        pr_err("Not found in_dev on %s\n", interface);
        ret = -ENOENT;
        goto QUIT;
    }

    for_primary_ifa(in_dev) {
        conf.interface_ipaddr = ifa->ifa_local;
        conf.interface_mask = ifa->ifa_mask;
        conf.interface_broadcast = ifa->ifa_broadcast;

        pr_info("Found ip from %s: %pI4\n", interface, &conf.interface_ipaddr);
        break;
    } endfor_ifa(in_dev)
    
QUIT:   
    dev_put(dev);

    return ret;
}

static int proc_config_show(struct seq_file *s, void *v)
{
    seq_printf(s, "enabled(RW) = %d\n", conf.enabled);
    seq_printf(s, "interface(RW) = %s\n", conf.interface);
    seq_printf(s, "ipaddr(RO) = %pI4\n", &conf.interface_ipaddr);
    seq_printf(s, "netmask(RO) = %pI4\n", &conf.interface_mask);
    seq_printf(s, "broadcast(RO) = %pI4\n", &conf.interface_broadcast);
    seq_printf(s, "port(RW) = %d\n", conf.port);
    seq_printf(s, "ssl_port(RW) = %d\n", conf.ssl_port);

    return 0;
}

static ssize_t proc_config_write(struct file *file, const char __user *buf, size_t size, loff_t *ppos)
{
    char data[128];
    char *delim, *key;
    const char *value;
    int update = 0;

    if (size == 0)
        return -EINVAL;

    if (size > sizeof(data))
        size = sizeof(data);

    if (copy_from_user(data, buf, size))
        return -EFAULT;

    data[size - 1] = 0;

    key = data;
    while (key && *key) {
        while (*key && (*key == ' '))
            key++;

        delim = strchr(key, '=');
        if (!delim)
            break;

        *delim++ = 0;
        value = delim;

        delim = strchr(value, '\n');
        if (delim)
            *delim++ = 0;

        if (!strcmp(key, "enabled")) {
            conf.enabled = simple_strtol(value, NULL, 0);
            if (conf.enabled)
                update = 1;
            pr_info("wifidog %s\n", conf.enabled ? "enabled" : "disabled");
        } else if (!strcmp(key, "interface")) {
            strncpy(conf.interface, value, sizeof(conf.interface) - 1);
            update = 1;
        } else if (!strcmp(key, "port")) {
            conf.port = simple_strtol(value, NULL, 0);
        } else if (!strcmp(key, "ssl_port")) {
            conf.ssl_port = simple_strtol(value, NULL, 0);
        }

        key = delim;
    }

    if (update)
        update_gw_interface(conf.interface);
    return size;
}

static int proc_config_open(struct inode *inode, struct file *file)
{
    return single_open(file, proc_config_show, NULL);
}

const static struct file_operations proc_config_ops = {
    .owner      = THIS_MODULE,
    .open       = proc_config_open,
    .read       = seq_read,
    .write      = proc_config_write,
    .llseek     = seq_lseek,
    .release    = single_release
};

int init_config(void)
{
    int ret = 0;

    conf.interface_ifindex= -1;
    conf.port = 2060;
    conf.ssl_port = 8443;
    strcpy(conf.interface, "br-lan");

    proc = proc_mkdir(PROC_DIR_NAME, NULL);
    if (!proc) {
        pr_err("can't create dir /proc/"PROC_DIR_NAME"/\n");
        return -ENODEV;;
    }

    if (!proc_create("config", 0644, proc, &proc_config_ops)) {
        pr_err("can't create file /proc/"PROC_DIR_NAME"/config\n");
        ret = -EINVAL;
        goto remove;
    }

    return 0;

remove:
    remove_proc_entry(PROC_DIR_NAME, NULL);
    return ret;
}

void deinit_config(void)
{
    remove_proc_entry("config", proc);
    remove_proc_entry(PROC_DIR_NAME, NULL);
}

struct config *get_config(void)
{
    return &conf;
}
