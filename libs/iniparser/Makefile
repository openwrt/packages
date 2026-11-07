# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iniparser
PKG_VERSION:=4.3.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://gitlab.com/$(PKG_NAME)/$(PKG_NAME)/-/archive/v$(PKG_VERSION)
PKG_HASH:=d7382f72f94649afa7a9d61346a7fc31cd3ff9ae389a71f92770133d49f1b22c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Antonio Pastor <antonio.pastor@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:ndevilla:iniparser

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/iniparser
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a library to handle ini files
  URL:=https://gitlab.com/iniparser/iniparser
endef

define Package/iniparser/description
  Small and fully re-entrant module for parsing of ini files in C
endef

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/iniparser.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/iniparser.pc
endef

define Package/iniparser/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiniparser.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,iniparser))
