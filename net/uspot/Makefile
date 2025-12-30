include $(TOPDIR)/rules.mk

PKG_NAME:=uspot
PKG_RELEASE:=2

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Thibaut VARÈNE <hacks@slashdirt.org>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/f00b4r0/uspot.git
PKG_SOURCE_DATE:=2025-08-07
PKG_SOURCE_VERSION:=8599a968877b55b0ce29f37d4b2d78036b257787
PKG_MIRROR_HASH:=554da4ea779ea69c20ef424f7e880156d463e35240b5099ded8453c455d2f617

CMAKE_SOURCE_SUBDIR:=src
PKG_BUILD_DEPENDS:=bpf-headers

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/bpf.mk

define Package/uspot
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  TITLE:=uspot hotspot daemon
  DEPENDS:=+conntrack \
	   +libblobmsg-json +liblucihttp-ucode +libradcli +libubox +libubus +libuci \
	   +uspotfilter \
	   +ucode +ucode-mod-log +ucode-mod-math +ucode-mod-nl80211 +ucode-mod-rtnl +uhttpd-mod-ucode +ucode-mod-uloop \
	   +ucode-mod-bpf +ucode-mod-struct +kmod-sched-core +kmod-sched-bpf $(BPF_DEPENDS)
  EXTRA_DEPENDS:=ucode (>=2023.11.07)
endef

define Package/uspot/description
  This package implements a captive portal supporting click-to-continue,
  simple credential-based as well as RADIUS authentication.
  It is UAM capable, and has limited support for RFC5176
  RADIUS Dynamic Authorization Extensions.
  It is meant to be a drop-in replacement for CoovaChilli,
  leveraging the performance and flexibility of the nftables firewall
  without the need for extra kernel modules.
endef

define Package/uspot/conffiles
/etc/config/uspot
endef

define Package/uspot-www
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  TITLE:=uspot default user interface files
  DEPENDS:=+uspot
  PKGARCH:=all
endef

define Package/uspot-www/description
  This package provides CSS and HTML templates for uspot UI.
  This package must be installed with uspot unless a local alternative is provided.
endef

define Package/uspotfilter
  SECTION:=net
  CATEGORY:=Network
  TITLE:=uspot firewall interface
  DEPENDS:=+conntrack +nftables-json +ucode +ucode-mod-rtnl +ucode-mod-uloop +ucode-mod-log
  EXTRA_DEPENDS:=ucode (>=2023.11.07)
  PKGARCH:=all
endef

define Package/uspotfilter/description
  This package provides the nftables firewall interface to uspot.
  It is compatible with firewall4.
endef

define Build/Compile
	$(call CompileBPF,$(PKG_BUILD_DIR)/src/uspot-bpf.c)
	$(call Build/Compile/Default,)
endef

define Package/uspot/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/share $(1)/usr/lib/ucode $(1)/etc/init.d $(1)/etc/config $(1)/lib/bpf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/radius-client $(1)/usr/bin/radius-client
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uspot-das $(1)/usr/bin/uspot-das
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libuam.so $(1)/usr/lib/ucode/uam.so
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/uspot-bpf.o $(1)/lib/bpf/uspot.o
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/etc/config/uspot $(1)/etc/config/uspot
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/uspot $(1)/etc/init.d/uspot
	$(CP) $(PKG_BUILD_DIR)/files/usr/bin $(1)/usr/
	$(CP) $(PKG_BUILD_DIR)/files/usr/share/uspot $(1)/usr/share/
endef

define Package/uspot-www/install
	$(CP) $(PKG_BUILD_DIR)/files/www-uspot $(1)/
endef

define Package/uspotfilter/install
	$(INSTALL_DIR) $(1)/usr/share $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/uspotfilter $(1)/etc/init.d/uspotfilter
	$(CP) $(PKG_BUILD_DIR)/files/usr/share/uspotfilter $(1)/usr/share/
endef

$(eval $(call BuildPackage,uspot))
$(eval $(call BuildPackage,uspot-www))
$(eval $(call BuildPackage,uspotfilter))
