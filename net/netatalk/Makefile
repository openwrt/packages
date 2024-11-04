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

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/netatalk
PKG_HASH:=3234ed4aee2dff05319544eec53eda232ecc94742c5cbee39376899551351219

PKG_MAINTAINER:=Antonio Pastor <antonio.pastor@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:netatalk:netatalk

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/netatalk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  TITLE:=Netatalk - Apple Filing Protocol (AFP) file server.
  URL:=http://netatalk.sourceforge.net
  DEPENDS:=+libevent2 +libdb47 +libgcrypt
endef

define Package/netatalk/description
  Netatalk is an Open Source Apple Filing Protocol (AFP) fileserver.
  Implements a service that allows Macintosh file sharing
  and Time Machine backups. Modern MacOS prefers Samba network shares
  but AFP has shown superior throughput. High Sierra and older MacOS
  only support AFP for Time Machine backups.
  Includes support of AppleTalk protocols to network with pre-OSX Macs.
endef

MESON_ARGS += \
	-Dwith-appletalk=true \
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
/etc/atalkd.conf
/etc/papd.conf
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
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/papd.conf $(1)/etc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/atalkd.conf $(1)/etc/
	$(INSTALL_BIN) ./files/afpd.init $(1)/etc/init.d/afpd
endef

$(eval $(call BuildPackage,netatalk))
