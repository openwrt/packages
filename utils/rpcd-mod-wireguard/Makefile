include $(TOPDIR)/rules.mk

PKG_NAME:=rpcd-mod-wireguard
PKG_RELEASE=2

PKG_LICENSE:=LGPL-2.1+
PKG_BUILD_FLAGS:=gc-sections

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rpcd-mod-wireguard
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=WireGuard rpcd module
  DEPENDS:=+rpcd +kmod-wireguard
  MAINTAINER:=Andre Heider <a.heider@gmail.com>
endef

define Package/rpcd-mod-wireguard/install
	$(INSTALL_DIR) $(1)/usr/lib/rpcd
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/rpcd/wireguard.so \
		$(1)/usr/lib/rpcd/
endef

define Package/rpcd-mod-wireguard/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || /etc/init.d/rpcd reload
endef

$(eval $(call BuildPackage,rpcd-mod-wireguard))
