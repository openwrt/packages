#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libproxyprotocol
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kosmas-valianos/libproxyprotocol.git
PKG_MIRROR_HASH:=b9df47965da23de7f266549d13af232190aafb5562b6f398bafc182be954fb31
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_LICENSE:=LGPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

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
