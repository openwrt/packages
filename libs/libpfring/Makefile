#
# Copyright (C) 2017 Banglang Huang
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libpfring
PKG_VERSION:=7.4.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Banglang Huang <banglang.huang@foxmail.com>

PKG_LICENSE:=LGPL-2.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ntop/PF_RING/tar.gz/$(PKG_VERSION)?
PKG_HASH:=e1c9cb44d8072854220f493c56fa5cba99a6b8336883939dc18b3e30c2954b68
PKG_BUILD_DIR:=$(BUILD_DIR)/PF_RING-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_FIXUP:=patch-libtool

include $(INCLUDE_DIR)/package.mk

CONFIGURE_PATH:=userland
MAKE_PATH:=userland/lib

define Package/libpfring
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for PR_RING (package process framework)
  URL:=https://github.com/ntop/pf_ring
  DEPENDS:=+kmod-pf-ring +libpcap +libpthread
endef

define Package/libpfring/description
  PF_RING is a high speed packet capture library that turns a commodity PC into an efficient and cheap
  network measurement box suitable for both packet and active traffic analysis and manipulation.
  Moreover, PF_RING opens totally new markets as it enables the creation of efficient application such as
  traffic balancers or packet filters in a matter of lines of codes.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libpfring.so* \
		$(1)/usr/lib/
endef

CONFIGURE_VARS += \
	MACHINE="$(ARCH)" \
	ac_cv_lib_nl_3_nl_socket_alloc=no

define Package/libpfring/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libpfring.so* \
		$(1)/usr/lib/
	$(LN) libpfring.so $(1)/usr/lib/libpfring.so.1
endef

$(eval $(call BuildPackage,libpfring))
