#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=glpk
PKG_VERSION:=4.60
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_MD5SUM:=eda7965907f6919ffc69801646f13c3e

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libglpk
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=The GNU Linear Programming Kit
	URL:=http://www.gnu.org/software/glpk/
endef

define Package/libglpk/description
	The GLPK (GNU Linear Programming Kit) package is intended for solving
	large-scale linear programming (LP), mixed integer programming (MIP),
	and other related problems. It is a set of routines written in ANSI C
	and organized in the form of a callable library.
endef

define Package/glpsol
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=The GNU Linear Programming Kit (glpsol)
	URL:=http://www.gnu.org/software/glpk/
	DEPENDS:=libglpk
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{so*,a,la} $(1)/usr/lib/
endef

define Package/libglpk/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

define Package/glpsol/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/glpsol $(1)/usr/bin
endef

$(eval $(call BuildPackage,libglpk))
$(eval $(call BuildPackage,glpsol))
