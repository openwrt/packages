#
# Copyright (C) 2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-w1thermsensor
PKG_VERSION:=1.1.2
PKG_RELEASE:=1

PKG_SOURCE:=w1thermsensor-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/04/ce/4d982b4762810756eb76ffa54a03ed19618b6de6c2a2d811dc3672d5829d/
PKG_HASH:=dc446102fbc6582f17565f2646622c439c99e8eef5144609873f6660eadf9e13

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-w1thermsensor-$(PKG_VERSION)

PKG_LICENSE:=BSD License
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-w1thermsensor/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/timofurrer/w1thermsensor
endef

define Package/python-w1thermsensor
$(call Package/python-w1thermsensor/Default)
  TITLE:=python-w1thermsensor
  DEPENDS:=+PACKAGE_python-w1thermsensor:python-light
  VARIANT:=python
endef

define Package/python3-w1thermsensor
$(call Package/python-w1thermsensor/Default)
  TITLE:=python3-w1thermsensor
  DEPENDS:=+PACKAGE_python3-w1thermsensor:python3-light
  VARIANT:=python3
endef

define Package/python-w1thermsensor/description
A Python package and CLI tool to work with w1 temperature sensors like DS1822,
DS18S20 & DS18B20 on the Raspbery Pi, Beagle Bone and other devices.
endef

define Package/python3-w1thermsensor/description
$(call Package/python-w1thermsensor/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-w1thermsensor))
$(eval $(call BuildPackage,python-w1thermsensor))
$(eval $(call BuildPackage,python-w1thermsensor-src))

$(eval $(call Py3Package,python3-w1thermsensor))
$(eval $(call BuildPackage,python3-w1thermsensor))
$(eval $(call BuildPackage,python3-w1thermsensor-src))
