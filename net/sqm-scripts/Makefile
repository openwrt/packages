#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sqm-scripts
PKG_SOURCE_VERSION:=33a89d8e7f6c82acc0adced84cf5cd95447e6bb5
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tohojo/sqm-scripts
PKG_MIRROR_HASH:=abe04270207177fb3ba4df103ffce3db4037d52d601ce1ce4e75206ad4b21377

PKG_MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/sqm-scripts
  SECTION:=net
  CATEGORY:=Base system
  DEPENDS:=+tc +kmod-sched-cake +kmod-ifb +iptables +iptables-mod-ipopt
  TITLE:=SQM Scripts (QoS)
  PKGARCH:=all
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

$(eval $(call BuildPackage,sqm-scripts))
