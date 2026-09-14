include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-veracrypt
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ville Takio <ville+git@takio.fi>

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-veracrypt
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for VeraCrypt
  URL:=https://www.veracrypt.fr/
  DEPENDS:=+luci-base +veracrypt
  PKGARCH:=all
endef

define Package/luci-app-veracrypt/description
  LuCI pages to list, mount, check (fsck) and dismount console VeraCrypt volumes.
  Uses veracrypt --text only; no GUI toolkit.
endef

define Package/luci-app-veracrypt/conffiles
/etc/config/veracrypt
endef

define Build/Compile
endef

define Package/luci-app-veracrypt/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/veracrypt $(1)/etc/config/veracrypt
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./root/usr/libexec/rpcd/luci.veracrypt $(1)/usr/libexec/rpcd/luci.veracrypt
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./root/usr/share/luci/menu.d/luci-app-veracrypt.json $(1)/usr/share/luci/menu.d/luci-app-veracrypt.json
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/luci-app-veracrypt.json $(1)/usr/share/rpcd/acl.d/luci-app-veracrypt.json
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/veracrypt.js $(1)/www/luci-static/resources/view/veracrypt.js
endef

define Package/luci-app-veracrypt/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	/etc/init.d/rpcd reload >/dev/null 2>&1 || true
	rm -f /tmp/luci-indexcache* /tmp/luci-modulecache/* 2>/dev/null || true
}
exit 0
endef

$(eval $(call BuildPackage,luci-app-veracrypt))
