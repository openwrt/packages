#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netatalk
PKG_VERSION:=4.0.4
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-or-later

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/netatalk
PKG_HASH:=3234ed4aee2dff05319544eec53eda232ecc94742c5cbee39376899551351219

PKG_CPE_ID:=cpe:/a:netatalk:netatalk

PKG_BUILD_DEPENDS:=libevent2

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/netatalk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  DEPENDS:=+libevent2 +libdb47 +libgcrypt
  TITLE:=netatalk
  URL:=http://netatalk.sourceforge.net
  MAINTAINER:=An Pa <apccv@outlook.com>
endef

define Package/netatalk/decription
  Netatalk is a freely-available Open Source AFP fileserver.
  It also provides a kernel level implementation of the AppleTalk
  Protocol Suite.
endef

MESON_ARGS += \
	-Dwith-appletalk=false \
	-Dwith-zeroconf=false \
	-Dwith-cups=false \
	-Dwith-quota=false \
	-Dwith-afpstats=false \
	-Dwith-acls=false \
	-Dwith-ldap=false \
	-Dwith-cnid-default-backend=dbd \
	-Dwith-cnid-dbd-backend=true \
	-Dwith-cnid-mysql-backend=false \
	-Dwith-pam=false \
	-Dwith-tests=false \
	-Dwith-testsuite=false \
	-Dwith-bdb-path="$(STAGING_DIR)/usr/" \
	-Dwith-unicode-data-path="$(STAGING_DIR_HOST)/share/gnulib/tests/uniname/" \
	-Dwith-libgcrypt-path="$(STAGING_DIR)/usr/" \
	-Dwith-kerberos=false \
	-Dwith-krbV-uam=false \
	-Dwith-libiconv=false \
	-Dwith-spotlight=false \
	$(if $(CONFIG_SHADOW_PASSWORDS),-Dwith-shadow=true,-Dwith-shadow=false) \
	-Dwith-dtrace=false \
	-Dwith-tcp-wrappers=false \
	-Dwith-debug=false \
	-Dwith-shell-check=false \
	-Dwith-readmes=false \
	-Dwith-manual=none \
	-Dwith-init-style=none \

define Package/netatalk/conffiles
/etc/afp.conf
/etc/extmap.conf
/etc/netatalk/
endef

define Package/netatalk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/netatalk
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libatalk.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/netatalk/*.so $(1)/usr/lib/netatalk/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/afp.conf $(1)/etc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/extmap.conf $(1)/etc/
	$(INSTALL_BIN) ./files/afpd.init $(1)/etc/init.d/afpd
endef

$(eval $(call BuildPackage,netatalk))
