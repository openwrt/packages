/* Please avoid adding hacks here - instead add it to mac80211/backports.git */

#include <linux/version.h>	/* LINUX_VERSION_CODE */
#include <linux/types.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 1, 0)

#define dev_get_iflink(_net_dev) ((_net_dev)->iflink)

#endif /* < KERNEL_VERSION(4, 1, 0) */

#if LINUX_VERSION_CODE < KERNEL_VERSION(3, 9, 0)

#include <linux/netdevice.h>

#define netdev_master_upper_dev_link(dev, upper_dev, upper_priv, upper_info) ({\
	BUILD_BUG_ON(upper_priv != NULL); \
	BUILD_BUG_ON(upper_info != NULL); \
	netdev_set_master(dev, upper_dev); \
})

#elif LINUX_VERSION_CODE < KERNEL_VERSION(4, 5, 0)

#include <linux/netdevice.h>

#define netdev_master_upper_dev_link(dev, upper_dev, upper_priv, upper_info) ({\
	BUILD_BUG_ON(upper_priv != NULL); \
	BUILD_BUG_ON(upper_info != NULL); \
	netdev_master_upper_dev_link(dev, upper_dev); \
})

#endif /* < KERNEL_VERSION(4, 5, 0) */


#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 3, 0)

#define IFF_NO_QUEUE	0; dev->tx_queue_len = 0

#endif /* < KERNEL_VERSION(4, 3, 0) */

#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 6, 0)

#include <linux/ethtool.h>

#define ethtool_link_ksettings batadv_ethtool_link_ksettings

struct batadv_ethtool_link_ksettings {
	struct {
		__u32	speed;
		__u8	duplex;
	} base;
};

#define __ethtool_get_link_ksettings(__dev, __link_settings) \
	batadv_ethtool_get_link_ksettings(__dev, __link_settings)

static inline int
batadv_ethtool_get_link_ksettings(struct net_device *dev,
				  struct ethtool_link_ksettings *link_ksettings)
{
	struct ethtool_cmd cmd;
	int ret;

	memset(&cmd, 0, sizeof(cmd));
	ret = __ethtool_get_settings(dev, &cmd);

	if (ret != 0)
		return ret;

	link_ksettings->base.duplex = cmd.duplex;
	link_ksettings->base.speed = ethtool_cmd_speed(&cmd);

	return 0;
}

#endif /* < KERNEL_VERSION(4, 6, 0) */

#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 7, 0)

#define netif_trans_update batadv_netif_trans_update
static inline void batadv_netif_trans_update(struct net_device *dev)
{
	dev->trans_start = jiffies;
}

#endif /* < KERNEL_VERSION(4, 7, 0) */
