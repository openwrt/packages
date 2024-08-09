#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netatalk
PKG_VERSION:=3.2.5
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-or-later

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/netatalk
PKG_HASH:=57de9a7ed411029d6176e429a14ef314460251d8aebe7139aeadc35633d9584b

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

PKG_CPE_ID:=cpe:/a:netatalk:netatalk

PKG_BUILD_DEPENDS:=libevent2

include $(INCLUDE_DIR)/package.mk

define Package/netatalk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  DEPENDS:=+libattr +libdb47 +libgcrypt +libopenssl +libevent2
  TITLE:=netatalk
  URL:=http://netatalk.sourceforge.net
  MAINTAINER:=An Pa <apccv@outlook.com>
endef

define Package/netatalk/decription
  Netatalk is a freely-available Open Source AFP fileserver.
  It also provides a kernel level implementation of the AppleTalk
  Protocol Suite.
endef

TARGET_CFLAGS += -std=gnu99

CONFIGURE_ARGS += \
	--disable-afs \
	--disable-hfs \
	--enable-debugging \
	--disable-shell-check \
	--disable-timelord \
	--disable-a2boot \
	--disable-cups \
	--disable-tcp-wrappers \
	--with-cnid-default-backend=dbd \
	--with-bdb="$(STAGING_DIR)/usr/" \
	--with-libevent=no \
	--with-libgcrypt-dir="$(STAGING_DIR)/usr" \
	--with-ssl-dir="$(STAGING_DIR)/usr" \
	--with-uams-path="/usr/lib/uams" \
	--without-acls \
	--without-kerberos \
	--without-mysql \
	--with-mysql-config=false \
	--without-pam \
	--disable-admin-group \
	--disable-srvloc \
	--disable-zeroconf \
	$(if $(CONFIG_SHADOW_PASSWORDS),--with-shadow,--without-shadow) \
	--without-dtrace \
	--without-ldap

define Package/netatalk/conffiles
/etc/afp.conf
/etc/extmap.conf
/etc/netatalk/
endef

define Package/netatalk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib/uams
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libatalk.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/dbd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ad $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/afppasswd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/afpd $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/cnid_dbd $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/cnid_metad $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/uams/*.so $(1)/usr/lib/uams/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/afp.conf $(1)/etc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/extmap.conf $(1)/etc/
	$(INSTALL_BIN) ./files/afpd.init $(1)/etc/init.d/afpd
endef

$(eval $(call BuildPackage,netatalk))
