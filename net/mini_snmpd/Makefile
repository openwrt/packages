#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mini_snmpd
PKG_VERSION:=1.6
PKG_RELEASE:=5
PKG_MAINTAINER:=Marcin Jurkowski <marcin1j@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:minisnmpd_project:minisnmpd

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/troglobit/mini-snmpd
PKG_SOURCE_SUBDIR:=mini-snmpd-$(PKG_VERSION)
PKG_SOURCE_VERSION:=45765e39d52469fd2b5ec5cfb78e042f437c0df4
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/mini-snmpd-$(PKG_VERSION)
PKG_MIRROR_HASH:=580eb4bc45a86d9827df505813ec0cf47ba836261d27e8e4b5ca5e0e1581c255

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
# As warned by upstream maintainer and binutils
# however compiler warnings can be ignored until next binutils release
# https://github.com/wongsyrone/openwrt-1/issues/67
# PKG_SSP:=0
# PKG_RELRO:=0

include $(INCLUDE_DIR)/package.mk

define Package/mini_snmpd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A tiny SNMP server for embedded systems
  URL:=https://troglobit.com/projects/mini-snmpd/
# uncomment if you just want the binary, not the init script
# openwrt requires init script runtime dependencies be defined for make menuconfig
# (e.g busybox sysntpd)
  DEPENDS:=+jsonfilter +ubus +procd +ubox +confuse
  VARIANT:=default
  CONFLICTS:=mini_snmpd-16 mini_snmpd-52
endef

define Package/mini_snmpd-16
  $(call Package/mini_snmpd)
  TITLE+= (16 ports)
  PROVIDES:=mini_snmpd
  VARIANT:=16
  CONFLICTS:=mini_snmpd-52
endef

define Package/mini_snmpd-52
  $(call Package/mini_snmpd)
  TITLE+= (52 ports)
  PROVIDES:=mini_snmpd
  VARIANT:=52
  CONFLICTS:=
endef

CONFIGURE_ARGS+= \
	$(if $(CONFIG_IPV6),,--disable-ipv6) \
	--with-config --enable-ethtool

# Configure weirdness - Disabled by default, explicitately disabling turns feature on!
#     --disable-debug \
#	--disable-demo - Upstream Github Issue #4 Fixed 20160707

ifneq ($(BUILD_VARIANT),default)
	CONFIGURE_ARGS += --with-interfaces=$(BUILD_VARIANT)
endif

define Package/mini_snmpd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/mini-snmpd $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/mini_snmpd.config $(1)/etc/config/mini_snmpd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mini_snmpd.init $(1)/etc/init.d/mini_snmpd
endef

Package/mini_snmpd-16/install=$(Package/mini_snmpd/install)
Package/mini_snmpd-52/install=$(Package/mini_snmpd/install)

define Package/mini_snmpd/conffiles
/etc/config/mini_snmpd
endef

Package/mini_snmpd-16/conffiles=$(Package/mini_snmpd/conffiles)
Package/mini_snmpd-52/conffiles=$(Package/mini_snmpd/conffiles)

$(eval $(call BuildPackage,mini_snmpd))
$(eval $(call BuildPackage,mini_snmpd-16))
$(eval $(call BuildPackage,mini_snmpd-52))
