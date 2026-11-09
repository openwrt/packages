#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=softgred
PKG_VERSION:=2.0.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jpereira/softgre/releases/download/v$(PKG_VERSION)
PKG_HASH:=35b89ba37d902889a71f1a291a54cf2790d531e655b0629f475ec02349e65506

PKG_MAINTAINER:=Jorge Pereira <jpereiran@gmail.com>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE.md

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/softgred
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Dynamic GRE Ethernet provisioning daemon
  URL:=https://github.com/jpereira/softgre
  DEPENDS:=+kmod-gre +ebtables-nft +kmod-nft-bridge
endef

define Package/softgred/description
  SoftGRE accepts unkeyed GRE v0 tunnels carrying VLAN-tagged Ethernet frames and
  bridges them dynamically. Built without the Python/PHP dashboard.
endef

define Package/softgred/conffiles
/etc/softgred/softgred.conf
endef

CONFIGURE_ARGS += --enable-openwrt

define Package/softgred/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/softgred $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/softgred $(1)/usr/sbin/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/softgred/softgred.conf $(1)/etc/softgred/
	$(INSTALL_BIN) ./files/softgred.init $(1)/etc/init.d/softgred
endef

$(eval $(call BuildPackage,softgred))
