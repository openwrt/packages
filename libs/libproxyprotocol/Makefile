#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libproxyprotocol
PKG_VERSION:=1.3.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/kosmas-valianos/libproxyprotocol/archive/refs/tags/v$(PKG_VERSION).tar.gz?
PKG_HASH:=4f1cbd714e5b52a91a9a43228d55c8165b578b738f743d057ae321b69b8437f7

PKG_MAINTAINER:=Peter Meiser <peter.meiser@gmx.com>
PKG_LICENSE:=LGPL-3.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/libproxyprotocol
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=PROXY Protocol v1/v2 parsing library
  URL:=https://github.com/kosmas-valianos/libproxyprotocol
endef

define Package/libproxyprotocol/description
  An ANSI C library to parse and create PROXY Protocol v1 and v2 headers.
endef

TARGET_CFLAGS += -fPIC
MAKE_FLAGS += \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

define Build/Compile
	$(MAKE) build -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/proxy_protocol.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libs/libproxyprotocol.so $(1)/usr/lib/
endef

define Package/libproxyprotocol/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libs/libproxyprotocol.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libproxyprotocol))
