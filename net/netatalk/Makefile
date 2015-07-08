#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netatalk
PKG_VERSION:=3.1.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/netatalk
PKG_MD5SUM:=831ec8bf9e084b64f965d16c528af299

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/netatalk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  DEPENDS:=+libattr +libdb47 +libgcrypt +libopenssl $(LIBRPC_DEPENDS)
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
/etc/afp.conf
endef

TARGET_CFLAGS += -std=gnu99 -Wl,-rpath-link=$(STAGING_DIR)/usr/lib
TARGET_LDFLAGS += $(LIBRPC)

CONFIGURE_ARGS += \
	--disable-shell-check \
	--disable-tcp-wrappers \
	--disable-admin-group \
	--disable-zeroconf \
	--with-bdb="$(STAGING_DIR)/usr/" \
	--with-libgcrypt-dir="$(STAGING_DIR)/usr" \
	--with-ssl-dir="$(STAGING_DIR)/usr" \
	--with-uams-path="/usr/lib/uams" \
	--without-acls \
	--without-afpstats \
	--without-ldap \
	--without-kerberos \
	$(if $(CONFIG_SHADOW_PASSWORDS),--with-shadow,--without-shadow)

define Package/netatalk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/uams
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ad $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/afppasswd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/apple_dump $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/cnid2_create $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/dbd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/uams/*.so $(1)/usr/lib/uams/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/afp.conf $(1)/etc/
	$(INSTALL_BIN) ./files/afpd.init $(1)/etc/init.d/netatalk
endef

$(eval $(call BuildPackage,netatalk))

