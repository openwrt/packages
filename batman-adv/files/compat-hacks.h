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
