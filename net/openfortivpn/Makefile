#
# Copyright (C) 2019 - Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openfortivpn
PKG_VERSION:=1.17.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/adrienverge/openfortivpn/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c674c59cf3201a55d56cb503053982752fb641b13a85ea406b8a7e7df301e30f

PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later OpenSSL
PKG_LICENSE_FILES:=LICENSE LICENSE.OpenSSL

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/openfortivpn
  SUBMENU:=VPN
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Fortinet SSL VPN client
  URL:=https://github.com/adrienverge/openfortivpn
  DEPENDS:=+ppp +libopenssl
endef

define Package/openfortivpn/description
  An open implementation of Fortinet's proprietary PPP+SSL VPN solution
  It spawns a pppd process and operates the communication between the gateway and this process.
  It is compatible with Fortinet VPNs.
endef

CONFIGURE_ARGS += \
	--enable-proc \
	--with-rt_dst="yes" \
	--disable-resolvconf \
	--with-resolvconf=DISABLED \
	--with-pppd="/usr/sbin/pppd"

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/openfortivpn/install
	$(INSTALL_DIR) \
	  $(1)/usr/sbin \
          $(1)/lib/netifd/proto \
	  $(1)/etc/hotplug.d/iface \
	  $(1)/etc/openfortivpn \
	  $(1)/lib/upgrade/keep.d

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/openfortivpn $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/openfortivpn-wrapper $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/openfortivpn.sh $(1)/lib/netifd/proto/
	$(INSTALL_BIN) ./files/openfortivpn-ppp-up $(1)/lib/netifd/openfortivpn-ppp-up
	$(INSTALL_DATA) ./files/openfortivpn.upgrade $(1)/lib/upgrade/keep.d/openfortivpn
endef

$(eval $(call BuildPackage,openfortivpn))
