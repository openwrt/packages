#
# Copyright (C) 2007-2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytz
PKG_VERSION:=2019.2
PKG_RELEASE:=1

PKG_SOURCE:=pytz-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pytz
PKG_HASH:=26c0b32e437e54a18161324a2fca3c4b9846b74a8dccddd843113109e1116b32

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pytz-$(PKG_VERSION)

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pytz/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  URL:=https://pythonhosted.org/pytz/
endef

define Package/python-pytz
$(call Package/python-pytz/Default)
  TITLE:=World timezone definitions, modern and historical
  DEPENDS:=+PACKAGE_python-pytz:python-light
  VARIANT:=python
endef

define Package/python3-pytz
$(call Package/python-pytz/Default)
  TITLE:=World timezone definitions, modern and historical for Python3
  DEPENDS:=+PACKAGE_python3-pytz:python3-light
  VARIANT:=python3
endef

define Package/python-pytz/description
  World timezone definitions, modern and historical
endef

define Package/python3-pytz/description
$(call Package/python-pytz/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-pytz))
$(eval $(call BuildPackage,python-pytz))
$(eval $(call BuildPackage,python-pytz-src))

$(eval $(call Py3Package,python3-pytz))
$(eval $(call BuildPackage,python3-pytz))
$(eval $(call BuildPackage,python3-pytz-src))
