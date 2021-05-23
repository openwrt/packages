#
# Copyright (C) 2021 Nir Izraeli <niriz@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitea
PKG_VERSION:=1.14.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-src-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GITHUB/go-gitea/gitea-releases/master
PKG_HASH:=d04bca934feba35600aaf739c82b7cbe7d8b911a086d7ac54f0710b689a85ac3

# include $(INCLUDE_DIR)/package.mk

define Package/gitea
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Version Control Systems
  DEPENDS:= \
	+git

  TITLE:=Web administration of git repositories
  URL:=https://gitea.com/
  USERID:=git=382:git=382
  MAINTAINER:=Nir Izraeli <nirizr@gmail.com>
endef

define Package/gitea/description
  Gitea: Git with a cup of tea
  git management with a web interface
endef

define Build/Configure
	true
endef

$(eval $(call BuildPackage,gitea))
