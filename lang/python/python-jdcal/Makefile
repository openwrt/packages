#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-jdcal
PKG_VERSION:=1.4.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>, Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.txt

PKG_SOURCE:=jdcal-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/j/jdcal
PKG_HASH:=472872e096eb8df219c23f2689fc336668bdb43d194094b5cc1707e1640acfc8

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-jdcal-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-jdcal/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Julian dates from proleptic Gregorian and Julian calendars
  URL:=https://github.com/phn/jdcal
endef

define Package/python-jdcal
$(call Package/python-jdcal/Default)
  DEPENDS:= +PACKAGE_python-jdcal:python-light
  VARIANT:=python
endef

define Package/python3-jdcal
$(call Package/python-jdcal/Default)
  DEPENDS:= +PACKAGE_python3-jdcal:python3-light
  VARIANT:=python3
endef

define Package/python-jdcal/description
  This module contains functions for converting between Julian dates and calendar dates.
endef

define Package/python3-jdcal/description
$(call Package/python-jdcal/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-jdcal))
$(eval $(call BuildPackage,python-jdcal))
$(eval $(call BuildPackage,python-jdcal-src))

$(eval $(call Py3Package,python3-jdcal))
$(eval $(call BuildPackage,python3-jdcal))
$(eval $(call BuildPackage,python3-jdcal-src))
