# SPDX-License-Identifier: Apache-2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=bird-babel-collector
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Robert Foss <rfoss@kernel.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/bird-babel-collector
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=History collector for BIRD Babel neighbours
  DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-log +ucode-mod-math +ucode-mod-resolv \
	+ucode-mod-rtnl +ucode-mod-socket +ucode-mod-struct +ucode-mod-ubus +ucode-mod-uci \
	+ucode-mod-uloop +uclient-fetch
  PKGARCH:=all
endef

define Package/bird-babel-collector/description
  Samples the Babel neighbours and default route selection of BIRD over its
  control socket (read-only) into an in-memory history of up to 24 hours and
  serves it on ubus as "bird-babel". The sampling interval follows the
  available memory and is never shorter than one second.
endef

define Package/bird-babel-collector/conffiles
/etc/config/bird-babel
endef

define Build/Compile
endef

define Package/bird-babel-collector/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config $(1)/lib/upgrade/keep.d
	$(INSTALL_BIN) ./files/bird-babel-collector $(1)/usr/sbin/bird-babel-collector
	$(INSTALL_BIN) ./files/bird-babel-collector.init $(1)/etc/init.d/bird-babel-collector
	$(INSTALL_CONF) ./files/bird-babel.config $(1)/etc/config/bird-babel
	$(INSTALL_DATA) ./files/bird-babel-collector.keep $(1)/lib/upgrade/keep.d/bird-babel-collector
	$(INSTALL_DATA) ./files/bird-babel-collector.upgrade $(1)/lib/upgrade/bird-babel-collector.sh
endef

$(eval $(call BuildPackage,bird-babel-collector))
