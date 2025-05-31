#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=quota
PKG_VERSION:=4.10
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/linuxquota
PKG_HASH:=a04a0cafca29c15be8b6ac660e06188bccb802c19efe2e7c19ed7f3d667ecf5e

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:jan_kara:linux_diskquota

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/quota
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:= quota
  URL:=https://sourceforge.net/projects/linuxquota/
endef

define Package/quota/description
  Utility for managing Linux filesystem quotas
endef

CONFIGURE_ARGS += \
	--disable-bsd-behaviour \
	--disable-ext2direct \
	--disable-ldapmail \
	--disable-libwrap \
	--disable-netlink \
	--disable-rpath \
	--disable-rpc

define Package/quota/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,quota))
