#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=i2c-tools
PKG_VERSION:=3.1.2
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://dl.lm-sensors.org/i2c-tools/releases/ \
                http://fossies.org/linux/misc/

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=db5e69f2e2a6e3aa2ecdfe6a5f490b149c504468770f58921c8c5b8a7860a441

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=PACKAGE_python-smbus:python

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk
include ../../lang/python/python3-package.mk

define Package/i2c/Default
  URL:=http://lm-sensors.org/wiki/I2CTools
  TITLE:=I2C
endef

define Package/i2c-tools
  $(call Package/i2c/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+=tools for Linux
endef

define Package/python-smbus
  $(call Package/i2c/Default)
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python bindings for the SMBUS
  DEPENDS:=+python-light
endef

define Package/python3-smbus
  $(call Package/i2c/Default)
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python bindings for the SMBUS
  DEPENDS:=+python3-light
endef

define Package/i2c-tools/description
 This package contains an heterogeneous set of I2C tools for Linux. These tools
 were originally part of the lm-sensors package.
endef

define Package/python-smbus/description
 This package contain the python bindings for Linux SMBus access through i2c-dev.
endef

define Package/python3-smbus/description
 This package contain the python bindings for Linux SMBus access through i2c-dev.
endef

TARGET_CPPFLAGS += -I$(PKG_BUILD_DIR)/include

ifdef CONFIG_PACKAGE_python-smbus
  define Build/Compile/python-smbus
	$(if $(Build/Compile/PyMod),,@echo Python packaging code not found.; false)
	$(call Build/Compile/PyMod,./py-smbus/, \
		install --prefix="$(PKG_INSTALL_DIR)/usr", \
	)
  endef
endif

ifdef CONFIG_PACKAGE_python3-smbus
  define Build/Compile/python3-smbus
	$(if $(Build/Compile/Py3Mod),,@echo Python3 packaging code not found.; false)
	$(call Build/Compile/Py3Mod,./py-smbus/, \
		install --prefix="$(PKG_INSTALL_DIR)/usr", \
	)
  endef
endif

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		LINUX="$(LINUX_DIR)" \
		CC="$(TARGET_CC)" \
		STAGING_DIR="$(STAGING_DIR)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS)"
	$(Build/Compile/python-smbus)
	$(Build/Compile/python3-smbus)
endef

define Package/i2c-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2cdetect $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2cdump $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2cset $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/i2cget $(1)/usr/sbin/
endef

define PyPackage/python-smbus/filespec
+|$(PYTHON_PKG_DIR)
endef

define PyPackage/python3-smbus/filespec
+|$(PYTHON3_PKG_DIR)
endef

$(eval $(call BuildPackage,i2c-tools))
$(eval $(call PyPackage,python-smbus))
$(eval $(call BuildPackage,python-smbus))
$(eval $(call PyPackage,python3-smbus))
$(eval $(call BuildPackage,python3-smbus))
