#
# Copyright (C) 2009-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sslh
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://rutschle.net/tech/sslh/
PKG_HASH:=09e9b572ca1e7fe2ccfb0de2bcfbc316638a8d82b86fedd253ddf81392e8fd38
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:sslh_project:sslh

include $(INCLUDE_DIR)/package.mk

define Package/sslh
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=SSL/SSH multiplexer
  DEPENDS:=+libconfig +libcap +libpcre2 +libproxyprotocol
  URL:=https://rutschle.net/tech/sslh/README.html
endef

define Package/sslh/config
    config SSLH_SELECT
        bool "Use sslh-select"
        depends on PACKAGE_sslh
        help
            Use sslh-select instead of sslh-fork.
        default n
endef

define Package/sslh/conffiles
/etc/config/sslh
/etc/sslh.conf
endef

MAKE_FLAGS += \
  USELIBCAP=1

define Build/Compile

ifeq ($(CONFIG_SSLH_SELECT),y)
	$(call Build/Compile/Default,sslh-select)
else
	$(call Build/Compile/Default,sslh-fork)
endif

endef

define Package/sslh/install
	$(INSTALL_DIR) $(1)/usr/sbin
ifeq ($(CONFIG_SSLH_SELECT),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sslh-select $(1)/usr/sbin/sslh
else
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sslh-fork $(1)/usr/sbin/sslh
endif
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/basic.cfg $(1)/etc/sslh.conf
endef

$(eval $(call BuildPackage,sslh))
