#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rdfind
PKG_VERSION:=1.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://rdfind.pauldreik.se/
PKG_HASH:= 78c463152e1d9e4fd1bfeb83b9c92df5e7fc4c5f93c7d426fb1f7efa2be4df29

PKG_MAINTAINER:=Rani Hod <rani.hod@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/rdfind
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libnettle +libxxhash +libstdcpp
  TITLE:=Find duplicate files utility
  URL:=https://github.com/pauldreik/rdfind
endef

define Package/rdfind/description
  Rdfind is a command line tool that finds duplicate files. It is
  useful for compressing backup directories or just finding duplicate
  files. It compares files based on their content, NOT on their file
  names.
endef

define Package/rdfind/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rdfind $(1)/usr/bin/
endef

$(eval $(call BuildPackage,rdfind))
