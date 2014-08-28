#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netatalk
PKG_VERSION:=2.2.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/netatalk
PKG_MD5SUM:=40753a32340c24e4ec395aeb55ef056e

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/netatalk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  DEPENDS:=+attr +libdb47 +libgcrypt +libopenssl $(LIBRPC_DEPENDS)
  TITLE:=netatalk
  URL:=http://netatalk.sourceforge.net
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/netatalk/decription
  Netatalk is a freely-available Open Source AFP fileserver.
  It also provides a kernel level implementation of the AppleTalk
  Protocol Suite.
endef

define Package/netatalk/conffiles
/etc/netatalk/afpd.conf
endef

TARGET_CFLAGS += -std=gnu99
TARGET_LDFLAGS += $(LIBRPC)

CONFIGURE_ARGS += \
	--disable-afs \
	--enable-hfs \
	--disable-debugging \
	--disable-shell-check \
	--disable-timelord \
	--disable-a2boot \
	--disable-cups \
	--disable-tcp-wrappers \
	--with-cnid-default-backend=dbd \
	--with-bdb="$(STAGING_DIR)/usr/" \
	--with-libgcrypt-dir="$(STAGING_DIR)/usr" \
	--with-ssl-dir="$(STAGING_DIR)/usr" \
	--with-uams-path="/usr/lib/uams" \
	--without-acls \
	--without-pam \
	--disable-admin-group \
	--disable-srvloc \
	--disable-zeroconf \
	$(if $(CONFIG_SHADOW_PASSWORDS),--with-shadow,--without-shadow) \
	--without-ldap

define Package/netatalk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib/uams
	$(INSTALL_DIR) $(1)/etc/netatalk
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/afppasswd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/afpd $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/cnid_dbd $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/cnid_metad $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/uams/*.so $(1)/usr/lib/uams/
	$(CP) ./files/AppleVolumes.default $(1)/etc/netatalk/
	$(CP) $(PKG_INSTALL_DIR)/etc/netatalk/AppleVolumes.system $(1)/etc/netatalk/
	$(INSTALL_CONF) ./files/afpd.conf $(1)/etc/netatalk/
	$(INSTALL_BIN) ./files/afpd.init $(1)/etc/init.d/afpd
endef

$(eval $(call BuildPackage,netatalk))
