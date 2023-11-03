include $(TOPDIR)/rules.mk

PKG_NAME:=openelp
PKG_VERSION:=0.9.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/cottsay/openelp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1427a2fe6f22856a66b9c687d7f14b7915abeeed64951ae596084f9366ec4256

PKG_MAINTAINER:=Scott K Logan <logans@cottsay.net>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libopenelp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Open Source EchoLink Proxy Library
  URL:=https://github.com/cottsay/openelp
  DEPENDS:=+libpcre2
  ABI_VERSION:=0
endef

define Package/openelp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Open Source EchoLink Proxy
  URL:=https://github.com/cottsay/openelp
  DEPENDS:=+libopenelp
endef

define Package/libopenelp/description
  Library backing OpenELP - an open source EchoLink proxy.
endef

define Package/openelp/description
  OpenELP is an open source EchoLink proxy for Linux and Windows. It aims
  to be efficient and maintain a small footprint, while still implementing
  all of the features present in the official EchoLink proxy.

  OpenELP also has the ability to bind to multiple network interfaces
  which are routed to unique external IP addresses, and therefore is
  capable of accepting connections from multiple clients simultaneously.
endef

CMAKE_OPTIONS += \
  -DSYSCONF_INSTALL_DIR=/etc

define Package/openelp/conffiles
/etc/ELProxy.conf
endef

define Package/libopenelp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenelp.so.* $(1)/usr/lib/
endef

define Package/openelp/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/ELProxy.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/openelpd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/openelp.init $(1)/etc/init.d/openelp
endef

$(eval $(call BuildPackage,libopenelp))
$(eval $(call BuildPackage,openelp))
