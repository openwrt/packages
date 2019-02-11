#
# Copyright (C) 2007-2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytz
PKG_VERSION:=2018.9
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=pytz-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pytz
PKG_HASH:=d5f05e487007e29e03409f9398d074e158d920d36eb82eaf66fb1136b0c5374c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pytz-$(PKG_VERSION)

HOST_BUILD_DEPENDS:=python/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
HOST_UNPACK:=$(HOST_TAR) -C $(HOST_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pytz/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
  URL:=https://sourceforge.net/projects/pytz/
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

define Host/Compile
	$(call Build/Compile/HostPyMod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=

$(eval $(call HostBuild))

$(eval $(call PyPackage,python-pytz))
$(eval $(call BuildPackage,python-pytz))
$(eval $(call BuildPackage,python-pytz-src))

$(eval $(call Py3Package,python3-pytz))
$(eval $(call BuildPackage,python3-pytz))
$(eval $(call BuildPackage,python3-pytz-src))
