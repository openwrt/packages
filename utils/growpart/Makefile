# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=growpart
PKG_SOURCE_DATE:=2022-02-04
PKG_SOURCE_VERSION:=4cc4950394b3db0243cb0211d6a394d629129a2a
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/canonical/cloud-utils/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=291b045d550d07b7271ce61d5912962b031df53dfa27edce6821b9222b880b3b

PKG_MAINTAINER:=Eero Vuojolahti <eero@oittaa.net>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/growpart
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=growpart - extend a partition in a partition table to fill available space
  DEPENDS:=+sfdisk
  URL:=https://github.com/canonical/cloud-utils
endef

define Package/growpart/description
Extend a partition in a partition table to fill available space
endef

define Package/growpart/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/growpart $(1)/usr/bin/
endef

$(eval $(call BuildPackage,growpart))
