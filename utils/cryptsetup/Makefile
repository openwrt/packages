#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cryptsetup
PKG_VERSION:=1.6.7
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0+ LGPL-2.1+
PKG_LICENSE_FILES:=COPYING COPYING.LGPL

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/utils/cryptsetup/v1.6
PKG_MD5SUM:=918406eb5d2e2f5a7348c432ea9b1473
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

TARGET_LDFLAGS+=-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

define Package/cryptsetup/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Cryptsetup
  DEPENDS:=+libblkid +libuuid +libpopt +lvm2 +libdevmapper +@KERNEL_DIRECT_IO
  URL:=http://code.google.com/p/cryptsetup/
endef

define Package/cryptsetup
$(call Package/cryptsetup/Default)
  DEPENDS+=+libgcrypt
  VARIANT:=gcrypt
endef

define Package/cryptsetup-openssl
$(call Package/cryptsetup/Default)
  TITLE+= (with openssl support)
  DEPENDS+=+libopenssl
  VARIANT:=openssl
endef

define Package/cryptsetup/Default/description
	Cryptsetup-luks
endef

define Package/cryptsetup/description
$(call Package/cryptsetup/Default/description)
linked against libgcrypt
endef


define Package/cryptsetup-openssl/description
$(call Package/cryptsetup/Default/description)
linked against openssl
endef

ifeq ($(BUILD_VARIANT),openssl)
CONFIGURE_ARGS+= \
        --with-crypto_backend=openssl
endif

define Package/cryptsetup/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/src/.libs/cryptsetup $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/.libs/libcryptsetup.so* $(1)/usr/lib
endef

Package/cryptsetup-openssl/install = $(Package/cryptsetup/install)

$(eval $(call BuildPackage,cryptsetup))
$(eval $(call BuildPackage,cryptsetup-openssl))
