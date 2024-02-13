#
# Copyright (C) 2015-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

PKG_RELRO_FULL:=0

include $(TOPDIR)/rules.mk

PKG_NAME:=knot-resolver
PKG_VERSION:=5.7.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://secure.nic.cz/files/knot-resolver
PKG_HASH:=da14b415c61d53747a991f12d6209367ef826a13dc6bf4eeaf5d88760294c3a2

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=GPL-3.0-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/knot-resolver
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Knot Resolver
  URL:=https://www.knot-resolver.cz
  DEPENDS=\
    +knot-libs \
    +knot-libzscanner \
    +libuv \
    @HAS_LUAJIT_ARCH +luajit \
    +luasec \
    +luasocket \
    +libstdcpp \
    +libnghttp2 \
    +lmdb \
    PACKAGE_knot-resolver_dnstap:libfstrm \
    PACKAGE_knot-resolver_dnstap:libprotobuf-c
  USERID:=kresd=3536:kresd=3536
endef

define Package/knot-resolver/description
  The Knot Resolver is a caching full resolver
  implementation, including both a resolver library and a daemon.
endef

define Package/knot-resolver/config
	source "$(SOURCE)/Config.in"
endef

MESON_ARGS+= \
	$(if $(CONFIG_PACKAGE_knot-resolver_dnstap), -Ddnstap=enabled,-Ddnstap=disabled) \
	-Dcapng=disabled \
	-Dclient=disabled \
	-Dconfig_tests=disabled \
	-Ddoc=disabled \
	-Dinstall_kresd_conf=disabled \
	-Dinstall_root_keys=disabled \
	-Dkeyfile_default=/etc/knot-resolver/root.keys \
	-Dprefix=/usr \
	-Dunit_tests=disabled \
	-Dutils=disabled

define Package/knot-resolver/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/kresd $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/lib/knot-resolver
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/knot-resolver/{*.lua,*.so} $(1)/usr/lib/knot-resolver/
	$(INSTALL_DIR) $(1)/usr/lib/knot-resolver/kres_modules
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/knot-resolver/kres_modules/{*.lua,*.so} $(1)/usr/lib/knot-resolver/kres_modules/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/kresd.init $(1)/etc/init.d/kresd

	$(INSTALL_DIR) $(1)/etc/knot-resolver
	$(CP) $(PKG_INSTALL_DIR)/etc/knot-resolver/root.hints $(1)/etc/knot-resolver/
	$(CP) ./files/root.keys $(1)/etc/knot-resolver
endef

$(eval $(call BuildPackage,knot-resolver))
