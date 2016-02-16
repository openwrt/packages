# 
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sqm-scripts
PKG_SOURCE_VERSION:=56677e61a0d410d744e0382c35980dd44aaa072b
PKG_VERSION:=1.0.7
PKG_RELEASE:=1
PKG_LICENSE:=GPLv2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.xz
PKG_SOURCE_URL:=git://github.com/tohojo/sqm-scripts.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

include $(INCLUDE_DIR)/package.mk

define Package/sqm-scripts
  SECTION:=net
  CATEGORY:=Base system
  DEPENDS:=+tc +kmod-sched +kmod-ifb +iptables +ip \
	+iptables-mod-ipopt +iptables-mod-conntrack-extra
  TITLE:=SQM Scripts (QoS)
  PKGARCH:=all
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
endef

define Package/sqm-scripts/description
 A set of scripts that does simple SQM configuration.
endef

define Package/sqm-scripts/conffiles
/etc/config/sqm
/etc/sqm/sqm.conf
endef

define Package/sqm-scripts/install
	make -C $(PKG_BUILD_DIR) DESTDIR=$(1) PLATFORM=openwrt install
endef

define Package/luci-app-sqm
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=SQM Scripts - LuCI interface
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
  PKGARCH:=all
  DEPENDS:= lua luci-base +sqm-scripts
  SUBMENU:=3. Applications
endef

define Package/luci-app-sqm/description
	Control the simple_qos SQM script
endef

define Package/luci-app-sqm/install
	make -C $(PKG_BUILD_DIR) DESTDIR=$(1) PLATFORM=openwrt install-luci
endef

define Package/luci-app-sqm/postinst
#!/bin/sh
which uci > /dev/null || exit 0
uci -q get ucitrack.@sqm[0] > /dev/null || {
  uci add ucitrack sqm > /dev/null
  uci set ucitrack.@sqm[0].init=sqm
  uci add_list ucitrack.@firewall[0].affects=sqm
  uci commit
}
endef

define Package/luci-app-sqm/postrm
#!/bin/sh
which uci > /dev/null || exit 0
uci -q get ucitrack.@sqm[0] > /dev/null && {
  uci delete ucitrack.@sqm[0]
  uci del_list ucitrack.@firewall[0].affects=sqm
  uci commit
}
endef

$(eval $(call BuildPackage,sqm-scripts))
$(eval $(call BuildPackage,luci-app-sqm))
