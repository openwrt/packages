# Copyright (C) 2025-2026 S Shaikh <sshaikh@hotmail.com>
# Copyright (C) 2026 Sven Kirmess <sven.kirmess@kzone.ch>

include $(TOPDIR)/rules.mk

PKG_NAME:=kronosnet
PKG_VERSION:=1.33
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/kronosnet/kronosnet/releases/download/v$(PKG_VERSION)/
PKG_HASH:=7c386a8aaaa3aece727eec3e1a51217a97f4af36cca28c8ea2fb2280b09edd6e
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=S Shaikh <sshaikh@hotmail.com>, Sven Kirmess <sven.kirmess@kzone.ch>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.libraries

include $(INCLUDE_DIR)/package.mk

define Package/kronosnet
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet - multipoint-to-multipoint network link aggregation
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+libnl
endef

define Package/kronosnet/description
  kronosnet (knet) is a network abstraction layer designed for High
  Availability use cases. It provides multipoint-to-multipoint communication
  with link aggregation, redundancy, and optional compression/encryption.
  Used as the transport layer by Corosync.
endef

define Package/kronosnet-compress-lz4
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet LZ4 compression backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +liblz4
endef

define Package/kronosnet-compress-lz4/description
  LZ4 compression backend plugin for kronosnet.
endef

define Package/kronosnet-compress-lz4hc
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet LZ4HC compression backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +liblz4
endef

define Package/kronosnet-compress-lz4hc/description
  LZ4HC compression backend plugin for kronosnet.
endef

define Package/kronosnet-compress-zlib
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet zlib compression backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +zlib
endef

define Package/kronosnet-compress-zlib/description
  zlib compression backend plugin for kronosnet.
endef

define Package/kronosnet-compress-lzo2
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet LZO compression backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +liblzo
endef

define Package/kronosnet-compress-lzo2/description
  LZO compression backend plugin for kronosnet.
endef

define Package/kronosnet-compress-lzma
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet LZMA compression backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +liblzma
endef

define Package/kronosnet-compress-lzma/description
  LZMA compression backend plugin for kronosnet.
endef

define Package/kronosnet-compress-bzip2
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet bzip2 compression backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +bzip2
endef

define Package/kronosnet-compress-bzip2/description
  bzip2 compression backend plugin for kronosnet.
endef

define Package/kronosnet-compress-zstd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet Zstandard compression backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +libzstd
endef

define Package/kronosnet-compress-zstd/description
  Zstandard compression backend plugin for kronosnet.
endef

define Package/kronosnet-crypto-nss
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet NSS crypto backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +libnss +nspr
endef

define Package/kronosnet-crypto-nss/description
  NSS crypto backend plugin for kronosnet. Required for encrypted
  Corosync cluster communication using Mozilla NSS.
endef

define Package/kronosnet-crypto-openssl
  SECTION:=net
  CATEGORY:=Network
  TITLE:=kronosnet OpenSSL crypto backend
  URL:=https://github.com/kronosnet/kronosnet
  DEPENDS:=+kronosnet +libopenssl
endef

define Package/kronosnet-crypto-openssl/description
  OpenSSL crypto backend plugin for kronosnet. Required for encrypted
  Corosync cluster communication using OpenSSL.
endef

CONFIGURE_ARGS += \
  --disable-man \
  --disable-hardening \
  --enable-crypto-nss \
  --enable-crypto-openssl

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/*.so* $(1)/usr/lib/kronosnet
endef

define Package/kronosnet/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so.* $(1)/usr/lib/
endef

define Package/kronosnet-compress-lz4/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/compress_lz4.so $(1)/usr/lib/kronosnet/
endef

define Package/kronosnet-compress-lz4hc/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/compress_lz4hc.so $(1)/usr/lib/kronosnet/
endef

define Package/kronosnet-compress-zlib/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/compress_zlib.so $(1)/usr/lib/kronosnet/
endef

define Package/kronosnet-compress-lzo2/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/compress_lzo2.so $(1)/usr/lib/kronosnet/
endef

define Package/kronosnet-compress-lzma/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/compress_lzma.so $(1)/usr/lib/kronosnet/
endef

define Package/kronosnet-compress-bzip2/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/compress_bzip2.so $(1)/usr/lib/kronosnet/
endef

define Package/kronosnet-compress-zstd/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/compress_zstd.so $(1)/usr/lib/kronosnet/
endef

define Package/kronosnet-crypto-nss/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/crypto_nss.so $(1)/usr/lib/kronosnet/
endef

define Package/kronosnet-crypto-openssl/install
	$(INSTALL_DIR) $(1)/usr/lib/kronosnet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/kronosnet/crypto_openssl.so $(1)/usr/lib/kronosnet/
endef

$(eval $(call BuildPackage,kronosnet))
$(eval $(call BuildPackage,kronosnet-compress-lz4))
$(eval $(call BuildPackage,kronosnet-compress-lz4hc))
$(eval $(call BuildPackage,kronosnet-compress-zlib))
$(eval $(call BuildPackage,kronosnet-compress-lzo2))
$(eval $(call BuildPackage,kronosnet-compress-lzma))
$(eval $(call BuildPackage,kronosnet-compress-bzip2))
$(eval $(call BuildPackage,kronosnet-compress-zstd))
$(eval $(call BuildPackage,kronosnet-crypto-nss))
$(eval $(call BuildPackage,kronosnet-crypto-openssl))
