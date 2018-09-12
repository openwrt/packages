#
# Copyright (C) 2016-2017 Mauro Mozzarelli
#
# This is free software, licensed under the GNU General Public License
# See /LICENSE for more information.
#
# AUTHOR: Mauro Mozzarelli <mauro@ezplanet.org>
#
include $(TOPDIR)/rules.mk

PKG_NAME:=ipvsadm
PKG_VERSION:=1.29
PKG_MAINTAINER:=Mauro Mozzarelli <mauro@ezplanet.org>, \
		Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=GPL-2.0+
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.kernel.org/pub/linux/utils/kernel/ipvsadm/
PKG_HASH:=c3de4a21d90a02c621f0c72ee36a7aa27374b6f29fd4178f33fbf71b4c66c149

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ipvsadm
  SECTION:=net
  CATEGORY:=Network
  TITLE:=IP Virtual Server Configuration Manager
  URL:=http://www.linuxvirtualserver.org
  DEPENDS:= +kmod-nf-ipvs +libnl-tiny +libpopt
endef

define Package/ipvsadm/description
  IPVS (IP Virtual Server) implements transport-layer load balancing
  inside the Linux kernel, so called Layer-4 switching. The command line tool
  ipvsadm is used to set up, maintain or inspect the virtual server table
  in the Linux kernel. The Linux Virtual Server can be used to build scalable
  network services based on a cluster of two or more nodes.
endef

TARGET_CFLAGS += \
	-D_GNU_SOURCE \
	-I$(STAGING_DIR)/usr/include/libnl-tiny

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS)" \
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		LIBS="$(TARGET_LDFLAGS) -lnl-tiny -lpopt"
endef

define Package/ipvsadm/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipvsadm $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipvsadm-save $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipvsadm-restore $(1)/sbin/
endef

$(eval $(call BuildPackage,ipvsadm))
