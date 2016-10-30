/* Please avoid adding hacks here - instead add it to mac80211/backports.git */

#undef CONFIG_MODULE_STRIPPED

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

#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 2, 0)

struct sk_buff *skb_checksum_trimmed(struct sk_buff *skb,
				     unsigned int transport_len,
				     __sum16(*skb_chkf)(struct sk_buff *skb));

int ip_mc_check_igmp(struct sk_buff *skb, struct sk_buff **skb_trimmed);

int ipv6_mc_check_mld(struct sk_buff *skb, struct sk_buff **skb_trimmed);

#endif /* < KERNEL_VERSION(4, 2, 0) */

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


#include_next <linux/netlink.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 7, 0)

#include_next <net/netlink.h>

static inline bool batadv_nla_need_padding_for_64bit(struct sk_buff *skb);

static inline int batadv_nla_align_64bit(struct sk_buff *skb, int padattr)
{
	if (batadv_nla_need_padding_for_64bit(skb) &&
	    !nla_reserve(skb, padattr, 0))
		return -EMSGSIZE;

	return 0;
}

static inline struct nlattr *batadv__nla_reserve_64bit(struct sk_buff *skb,
						       int attrtype,
						       int attrlen, int padattr)
{
	if (batadv_nla_need_padding_for_64bit(skb))
		batadv_nla_align_64bit(skb, padattr);

	return __nla_reserve(skb, attrtype, attrlen);
}

static inline void batadv__nla_put_64bit(struct sk_buff *skb, int attrtype,
					 int attrlen, const void *data,
					 int padattr)
{
	struct nlattr *nla;

	nla = batadv__nla_reserve_64bit(skb, attrtype, attrlen, padattr);
	memcpy(nla_data(nla), data, attrlen);
}

static inline bool batadv_nla_need_padding_for_64bit(struct sk_buff *skb)
{
#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
	/* The nlattr header is 4 bytes in size, that's why we test
	 * if the skb->data _is_ aligned.  A NOP attribute, plus
	 * nlattr header for next attribute, will make nla_data()
	 * 8-byte aligned.
	 */
	if (IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8))
		return true;
#endif
	return false;
}

static inline int batadv_nla_total_size_64bit(int payload)
{
	return NLA_ALIGN(nla_attr_size(payload))
#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
		+ NLA_ALIGN(nla_attr_size(0))
#endif
		;
}

static inline int batadv_nla_put_64bit(struct sk_buff *skb, int attrtype,
				       int attrlen, const void *data,
				       int padattr)
{
	size_t len;

	if (batadv_nla_need_padding_for_64bit(skb))
		len = batadv_nla_total_size_64bit(attrlen);
	else
		len = nla_total_size(attrlen);
	if (unlikely(skb_tailroom(skb) < len))
		return -EMSGSIZE;

	batadv__nla_put_64bit(skb, attrtype, attrlen, data, padattr);
	return 0;
}

#define nla_put_u64_64bit(_skb, _attrtype, _value, _padattr) \
	batadv_nla_put_u64_64bit(_skb, _attrtype, _value, _padattr)
static inline int batadv_nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
					   u64 value, int padattr)
{
	return batadv_nla_put_64bit(skb, attrtype, sizeof(u64), &value,
				    padattr);
}

#endif /* < KERNEL_VERSION(4, 7, 0) */

