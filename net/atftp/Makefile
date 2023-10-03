#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=atftp
PKG_VERSION:=0.8.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=df2aa089c7670f9eab40e5598e5d2cb6a582dc5182926ea50b4d690e4e37f316

PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/atftp/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=TFTP
  SUBMENU:=File Transfer
endef

define Package/atftp
  $(call Package/atftp/Default)
  DEPENDS:=+libreadline +libncurses
  TITLE+= client
endef

define Package/atftpd
  $(call Package/atftp/Default)
  DEPENDS:=+libpcre2 +libpthread
  TITLE+= server
endef

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-libwrap

define Package/atftp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/atftp $(1)/usr/bin/
endef

define Package/atftpd/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/atftpd.init $(1)/etc/init.d/atftpd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/atftpd.conf $(1)/etc/config/atftpd
	$(INSTALL_DIR) $(1)/srv/tftp
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)//usr/sbin/atftpd $(1)/usr/sbin/
endef

define Package/atftpd/conffiles
/etc/config/atftpd
endef

$(eval $(call BuildPackage,atftp))
$(eval $(call BuildPackage,atftpd))
