#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitolite
PKG_VERSION:=3.6.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://github.com/sitaramc/gitolite
PKG_MD5SUM:=be8c0bbb0c5ee6ab7cdcffd2c9375fe6
PKG_SOURCE_VERSION:=5d24ae666bfd2fa9093d67c840eb8d686992083f
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/gitolite
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Version Control Systems
  DEPENDS:=+perlbase-essential +perlbase-file +perlbase-data +perlbase-digest +perlbase-env +perlbase-time +git
  TITLE:=Easy administration of git repositories
  URL:=http://gitolite.com/gitlolite
  MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
endef

define Package/gitolite/description
  Gitolite is a system for managing access to git repositories
endef

define Build/Configure
	true
endef

define Build/Compile
	mkdir -p $(PKG_INSTALL_DIR)/usr/share/gitolite	
	$(PKG_BUILD_DIR)/install -to $(PKG_INSTALL_DIR)/usr/share/gitolite
	mkdir -p $(PKG_INSTALL_DIR)/usr/bin
	ln -sf /usr/share/gitolite/gitolite $(PKG_INSTALL_DIR)/usr/bin/gitolite
endef

define Package/gitolite/install
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

$(eval $(call BuildPackage,gitolite))
