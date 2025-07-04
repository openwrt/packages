#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xinetd
PKG_VERSION:=2.3.15
PKG_RELEASE:=17

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_NAME)-2-3-15
PKG_SOURCE_URL:=https://github.com/xinetd-org/xinetd
PKG_MIRROR_HASH:=f2fc2c6decb2334848c277915e10dee7463aacd1411d61c953ff908aaad8d275

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=xinetd
PKG_LICENSE_FILES:=COPYRIGHT
PKG_CPE_ID:=cpe:/a:xinetd:xinetd

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xinetd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A powerful and secure super-server
  URL:=https://github.com/xinetd-org
  DEPENDS:= +USE_GLIBC:libcrypt-compat
endef

define Package/xinetd/description
	xinetd has access control mechanisms, extensive logging capabilities,
	the ability to make services available based on time, can place limits
	on the number of servers that can be started, and has deployable
	defence mechanisms to protect against port scanners, among other
	things.
endef

define Package/xinetd/conffiles
/etc/config/xinetd
/etc/xinetd.d
endef

TARGET_CFLAGS += -DNO_RPC
TARGET_CPPFLAGS += -DHAVE_RLIM_T

CONFIGURE_ARGS += \
	--without-libwrap \
	--with-loadavg

CONFIGURE_VARS += \
	ac_cv_header_rpc_pmap_clnt_h=no \
	ac_cv_header_rpc_rpc_h=no \
	ac_cv_header_rpc_rpcent_h=no

define Package/xinetd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/xinetd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DATA) ./files/xinetd.uci.conf.sample $(1)/etc/config/xinetd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/xinetd.init $(1)/etc/init.d/xinetd
	$(INSTALL_DIR) $(1)/etc/xinetd.d
endef

$(eval $(call BuildPackage,xinetd))
