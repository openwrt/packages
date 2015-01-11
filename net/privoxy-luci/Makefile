
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-privoxy
PKG_VERSION:=1.0.1
#PKG_RELEASE:=0

PKG_MAINTAINER:=Christian Schoenebeck <christian.schoenebeck@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:= $(BUILD_DIR)/$(PKG_NAME)

# needed inside Build/Compile
# po2lmo is compiled inside luci-base
PKG_BUILD_DEPENDS:=+luci-base

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-privoxy
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for Privoxy WEB Proxy
  DEPENDS:=+luci-mod-admin-full +privoxy
  PKGARCH:=all
endef

define Package/luci-app-privoxy/description
LuCi web interface for Privoxy WEB Proxy
Version: $(PKG_VERSION)
endef

define Build/Prepare
	# do nothing
endef

define Build/Configure
	# do nothing
endef

define Build/Compile
	mkdir -p $(PKG_INSTALL_DIR)/build $(PKG_INSTALL_DIR)/files $(PKG_INSTALL_DIR)/po
	# copy everthing we need ot PKG_INSTALL_DIR
	$(CP) ./* $(PKG_INSTALL_DIR)/
	# due to package dependencies LuCI is compiled first so the needed binary exists
	$(LN) $(STAGING_DIR_HOST)/bin/po2lmo $(PKG_INSTALL_DIR)/build/po2lmo
	# generate needed .lmo files out of given .po files
	cd $(PKG_INSTALL_DIR); build/i18n-po2lua.pl po files/luasrc/i18n
endef

define Package/luci-app-privoxy/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/files/root/etc/uci-defaults/* $(1)/etc/uci-defaults

	$(INSTALL_DIR)  $(1)/usr/lib/lua/luci
	$(CP) $(PKG_INSTALL_DIR)/files/luasrc/* $(1)/usr/lib/lua/luci
endef

define Package/luci-app-privoxy/postinst
	#!/bin/sh
	[ -z "$${IPKG_INSTROOT}" ] && {
		/etc/uci-defaults/luci-privoxy && rm -f /etc/uci-defaults/luci-privoxy
	}
	exit 0
endef

$(eval $(call BuildPackage,luci-app-privoxy))
