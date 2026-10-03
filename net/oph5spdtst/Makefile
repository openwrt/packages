include $(TOPDIR)/rules.mk

PKG_NAME:=oph5spdtst
PKG_VERSION:=0.2.0
PKG_RELEASE:=1
PKG_MAINTAINER:=AzulEterno <jay2236419527@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/oph5spdtst
  SECTION:=net
  CATEGORY:=Network
  TITLE:=HTML5 speed test for OpenWrt
  URL:=https://github.com/AzulEterno/oph5spdtst
  PKGARCH:=all
endef

define Package/oph5spdtst/description
  Provides a payload service for the oph5spdtst web frontend.
endef

define Build/Compile
endef

define Package/oph5spdtst/conffiles
/etc/config/oph5spdtst
endef

define Package/oph5spdtst/postrm
#!/bin/sh

if [ -z "$${IPKG_INSTROOT}" ]; then
	rm -f /tmp/oph5spdtst/payload.bin /tmp/oph5spdtst/payload.bin.tmp
	rm -f /www/luci-static/resources/oph5spdtst/downloading \
	/www/luci-static/resources/oph5spdtst/downloading.tmp
	rmdir /tmp/oph5spdtst 2>/dev/null || true
fi
exit 0
endef

define Package/oph5spdtst/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/oph5spdtst.config $(1)/etc/config/oph5spdtst

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/oph5spdtst.init $(1)/etc/init.d/oph5spdtst
endef

$(eval $(call BuildPackage,oph5spdtst))
