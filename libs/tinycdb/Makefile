# 
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tinycdb
PKG_RELEASE:=1
PKG_SOURCE_URL:=http://www.corpit.ru/mjt/tinycdb/
PKG_VERSION:=0.78
PKG_MD5SUM:=976266afc3f6e7e17492a8d18f21f8f6
PKG_MAINTAINER:=Denis Shulyaka <Shulyaka@gmail.com>
PKG_LICENSE:=NLPL

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/tinycdb
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a Constant DataBase
  URL:=http://www.corpit.ru/mjt/tinycdb.html
endef

define Package/tinycdb/description
 TinyCDB is a very fast and simple package for creating and reading constant data bases
endef

define Build/InstallDev
        cd $(PKG_BUILD_DIR); $(MAKE) DESTDIR=$(1) prefix=/usr install
endef



$(eval $(call BuildPackage,tinycdb))
