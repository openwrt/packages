#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=i2c-tools
PKG_VERSION:=4.1
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/software/utils/i2c-tools
PKG_HASH:=57b219efd183795bd545dd5a60d9eabbe9dcb6f8fb92bc7ba2122b87f98527d5

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-or-later LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING COPYING.LGPL

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-i2c-tools-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk
include ../../lang/python/python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xJf $(DL_DIR)/$(PKG_SOURCE)

define Package/i2c/Default
  URL:=https://i2c.wiki.kernel.org/index.php/I2C_Tools
  TITLE:=I2C
endef

define Package/libi2c
  $(call Package/i2c/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+=library for i2c-tools
  VARIANT:=bin
endef

define Package/i2c-tools
  $(call Package/i2c/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+=tools for Linux
  DEPENDS:=+libi2c
  VARIANT:=bin
endef

define Package/python-smbus
  $(call Package/i2c/Default)
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python bindings for the SMBUS
  DEPENDS:=+PACKAGE_python-smbus:libi2c +PACKAGE_python-smbus:python-light
  VARIANT:=python
endef

define Package/python3-smbus
  $(call Package/i2c/Default)
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python bindings for the SMBUS
  DEPENDS:=+PACKAGE_python3-smbus:libi2c +PACKAGE_python3-smbus:python3-light
  VARIANT:=python3
endef

define Package/libi2c/description
 This package contains i2c functionality needed by i2c-tools.
endef

define Package/i2c-tools/description
 This package contains an heterogeneous set of I2C tools for Linux. These tools
 were originally part of the lm-sensors package.
endef

define Package/python-smbus/description
 This package contain the python bindings for Linux SMBus access through i2c-dev.
endef

define Package/python3-smbus/description
 This package contain the Python3 bindings for Linux SMBus access through i2c-dev.
endef

ifeq ($(BUILD_VARIANT),bin)

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		LINUX="$(LINUX_DIR)" \
		CC="$(TARGET_CC)" \
		STAGING_DIR="$(STAGING_DIR)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS)"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/include/i2c $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/lib/libi2c.{a,so*} $(1)/usr/lib/
endef

endif # ifeq

PYTHON_PKG_SETUP_ARGS:=
PYTHON3_PKG_SETUP_ARGS:=

PYTHON_PKG_SETUP_DIR:=py-smbus
PYTHON3_PKG_SETUP_DIR:=py-smbus

define Package/libi2c/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libi2c.so* $(1)/usr/lib/
endef

define Package/i2c-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2cdetect $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2cdump $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2cset $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2cget $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2ctransfer $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,libi2c))
$(eval $(call BuildPackage,i2c-tools))
$(eval $(call PyPackage,python-smbus))
$(eval $(call BuildPackage,python-smbus))
$(eval $(call Py3Package,python3-smbus))
$(eval $(call BuildPackage,python3-smbus))
