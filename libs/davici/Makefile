#
# Copyright (C) 2023 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=davici
PKG_VERSION:=1.4
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/strongswan/davici/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b03c5a1aad905e962271d70246d6af6c337ffd00449d990082ea02161327bde8

PKG_MAINTAINER:=Lukas Voegl <lvoegl@tdt.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/davici
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Decoupled Asynchronous VICI
  URL:=https://github.com/strongswan/davici
endef

define Package/davici/description
  The davici library provides a client implementation of the
  strongSwan VICI protocol for integration into external applications.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdavici.so* $(1)/usr/lib/
endef

define Package/davici/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdavici.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,davici))
