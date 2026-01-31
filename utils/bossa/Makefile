# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=bossa
PKG_VERSION:=1.9.1
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/shumatech/BOSSA/tar.gz/$(PKG_VERSION)?
PKG_HASH:=ca650455dfa36cbd029010167347525bea424717a71a691381c0811591c93e72
PKG_BUILD_DIR:=$(BUILD_DIR)/BOSSA-$(PKG_VERSION)

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/bossa
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libstdcpp
  TITLE:=Utility to flash ARM microcontrollers
  URL:=https://www.shumatech.com/web/products/bossa
endef

define Package/bossa/description
 BOSSA is a flash programming utility for Atmel's SAM family of flash-based
 ARM microcontrollers. The motivation behind BOSSA is to create a simple,
 easy-to-use, open source utility to replace Atmel's SAM-BA software.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) bin/bossac \
    OS="Linux" \
    CC="$(TARGET_CC_NOCACHE)" \
    CXX="$(TARGET_CXX_NOCACHE)" \
    CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS)" \
    CXXFLAGS="$(TARGET_CXXFLAGS) $(EXTRA_CXXFLAGS)" \
    CPPFLAGS="$(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS)" \
    LDFLAGS="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)"
endef

define Package/bossa/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bossac $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bossa))
