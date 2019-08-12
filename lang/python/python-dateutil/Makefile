#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dateutil
PKG_VERSION:=2.8.0
PKG_RELEASE:=1
PKG_LICENSE:=BSD-2-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/python-dateutil
PKG_HASH:=c89805f6f4d64db21ed966fda138f8a5ed7a4fdbc1a8ee329ce1b74e3c74da9e
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-dateutil-$(PKG_VERSION)
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/package.mk

include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-dateutil/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Extensions to the standard Python datetime module
  URL:=https://dateutil.readthedocs.org/
endef

define Package/python-dateutil
$(call Package/python-dateutil/Default)
  DEPENDS:=+PACKAGE_python-dateutil:python +PACKAGE_python-dateutil:python-six
  VARIANT:=python
endef

define Package/python-dateutil/description
  Extensions to the standard Python datetime module
endef

define Package/python3-dateutil
$(call Package/python-dateutil/Default)
  DEPENDS:=+PACKAGE_python3-dateutil:python3 +PACKAGE_python3-dateutil:python3-six
  VARIANT:=python3
endef

define Package/python3-dateutil/description
$(call Package/python-dateutil/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-dateutil))
$(eval $(call BuildPackage,python-dateutil))
$(eval $(call BuildPackage,python-dateutil-src))
$(eval $(call Py3Package,python3-dateutil))
$(eval $(call BuildPackage,python3-dateutil))
$(eval $(call BuildPackage,python3-dateutil-src))
