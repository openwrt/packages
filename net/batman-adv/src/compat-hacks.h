/* Please avoid adding hacks here - instead add it to mac80211/backports.git */

#undef CONFIG_MODULE_STRIPPED

#include <linux/version.h>	/* LINUX_VERSION_CODE */
#include <linux/types.h>

#if LINUX_VERSION_IS_LESS(6, 15, 0)
#include <linux/crc32c.h>
#endif /* LINUX_VERSION_IS_LESS(6, 15, 0) */

#if LINUX_VERSION_IS_LESS(6, 16, 0)

#define timer_container_of(var, callback_timer, timer_fieldname)	\
	from_timer(var, callback_timer, timer_fieldname)

#endif /* LINUX_VERSION_IS_LESS(6, 16, 0) */

#if LINUX_VERSION_IS_LESS(6, 16, 0) || !defined(CONFIG_NET_CRC32C)

#include <linux/skbuff.h>
#include <linux/crc32.h>

static inline u32 batadv_skb_crc32c(struct sk_buff *skb, int offset,
				    int len, u32 crc)
{
	unsigned int to = offset + len;
	unsigned int consumed = 0;
	struct skb_seq_state st;
	unsigned int l;
	const u8 *data;

	if (len <= 0)
	       return crc;

	skb_prepare_seq_read(skb, offset, to, &st);
	while ((l = skb_seq_read(consumed, &data, &st)) != 0) {
		crc = crc32c(crc, data, l);
		consumed += l;
	}

	return crc;
}

#define skb_crc32c batadv_skb_crc32c

#endif /* LINUX_VERSION_IS_LESS(6, 16, 0) || !defined(CONFIG_NET_CRC32C) */

#include <linux/slab.h>

#if LINUX_VERSION_IS_LESS(7, 0, 0)

#ifndef kzalloc_obj
#define kzalloc_obj(P, GFP) \
	kzalloc(sizeof(P), GFP)
#endif /* kzalloc_obj */

#ifndef kmalloc_obj
#define kmalloc_obj(P, GFP) \
	kmalloc(sizeof(P), GFP)
#endif /* kmalloc_obj */

#ifndef kmalloc_objs
#define kmalloc_objs(P, COUNT, GFP) \
	kmalloc_array((COUNT), sizeof(P), GFP)
#endif /* kmalloc_objs */

#endif /* < KERNEL_VERSION(7, 0, 0) */

#if LINUX_VERSION_IS_LESS(7, 3, 0)

#include <linux/skbuff.h>

static inline bool __must_check
batadv_skb_set_transport_header_careful(struct sk_buff *skb, const int offset)
{
	long thoff = skb->data - skb->head + offset;

	if (unlikely(thoff != (typeof(skb->transport_header))thoff))
		return false;

	if (unlikely(thoff == (typeof(skb->transport_header))~0U))
		return false;

	skb->transport_header = thoff;
	return true;
}

#define skb_set_transport_header_careful batadv_skb_set_transport_header_careful

#endif /* LINUX_VERSION_IS_LESS(7, 3, 0) */

/* <VERSION> */

#include <linux/utsname.h>

#define init_utsname() batadv_init_utsname()

extern struct new_utsname batadv_version_name;

static inline struct new_utsname *batadv_init_utsname(void)
{
	return &batadv_version_name;
}

/* </VERSION> */
