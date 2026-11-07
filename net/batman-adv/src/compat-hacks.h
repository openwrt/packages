/* Please avoid adding hacks here - instead add it to mac80211/backports.git */

#undef CONFIG_MODULE_STRIPPED

#include <linux/version.h>	/* LINUX_VERSION_CODE */
#include <linux/types.h>

#if !defined(CONFIG_NET_CRC32C)

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

#endif /* !defined(CONFIG_NET_CRC32C) */

/* <VERSION> */

#include <linux/utsname.h>

#define init_utsname() batadv_init_utsname()

extern struct new_utsname batadv_version_name;

static inline struct new_utsname *batadv_init_utsname(void)
{
	return &batadv_version_name;
}

/* </VERSION> */
