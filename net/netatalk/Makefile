#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netatalk
PKG_VERSION:=4.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/netatalk
PKG_HASH:=8e0a0bf88eed0f64a3945fa0789882e9aba11e9ba2ee09e87defd6c88be737fc

PKG_MAINTAINER:=Antonio Pastor <antonio.pastor@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:netatalk:netatalk

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=0
PKG_FIXUP:=autoreconf

#PKG_BUILD_DEPENDS:=meson/host libevent2
#PKG_BUILD_DEPENDS:=+libevent2 +libdb47

define Package/netatalk
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Filesystem
	TITLE:=Netatalk - Open Source file server that implements the Apple Filing Protocol (AFP)
	URL:=http://netatalk.sourceforge.net
	DEPENDS:=+libevent2 +libdb47 +libgcrypt
endef

define Package/netatalk/decription
	Netatalk is an Open Source Apple Filing Protocol (AFP) fileserver.
	Implements a service that allows Macintosh file sharing
	and Time Machine backups. Modern MacOS prefers Samba network shares
	but AFP has shown superior throughput. High Sierra and older MacOS
	only support AFP for Time Machine backups.
	Does not support old AppleTalk protocols to talk to non OSX Macs.
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
	-Dwith-libgcrypt-path="$(STAGING_DIR)/usr" \
	-Dwith-libiconv=false \
	$(if $(CONFIG_SHADOW_PASSWORDS),-Dwith-shadow=true,-Dwith-shadow=false) \
	-Dwith-dtrace=false \
	-Dwith-tcp-wrappers=false \
	-Dwith-debug=false \
	-Dwith-shell-check=false \
	-Dwith-readmes=false \
	-Dwith-manual=none \
	-Dwith-kerberos=false \
	-Dwith-init-style=none \

	#-Dwith-uams-path="/usr/lib/uams" \
	#-Dwith-ssl-dir="$(STAGING_DIR)/usr" \
	#-Ddisable-admin-group=true \
	#-Ddisable-srvloc=true \

define Package/netatalk/conffiles
	/etc/afp.conf
	/etc/extmap.conf
	/etc/netatalk/
endef

define Package/netatalk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib/netatalk
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libatalk.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/dbd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ad $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/afppasswd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/afpd $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/cnid_dbd $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/cnid_metad $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/netatalk/*.so $(1)/usr/lib/netatalk/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/afp.conf $(1)/etc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/extmap.conf $(1)/etc/
	$(INSTALL_BIN) ./files/afpd.init $(1)/etc/init.d/afpd
endef

$(eval $(call BuildPackage,netatalk))
