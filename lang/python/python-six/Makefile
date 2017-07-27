#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-six
PKG_VERSION:=1.10.0
PKG_RELEASE:=4

PKG_SOURCE:=six-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/s/six
PKG_HASH:=105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a

HOST_BUILD_DEPENDS:=python/host

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-six-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
HOST_UNPACK:=$(HOST_TAR) -C $(HOST_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-six/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://pypi.python.org/pypi/six
endef

define Package/python-six
$(call Package/python-six/Default)
  TITLE:=python-six
  DEPENDS:=+PACKAGE_python-six:python-light
  VARIANT:=python
endef

define Package/python3-six
$(call Package/python-six/Default)
  TITLE:=python3-six
  DEPENDS:=+PACKAGE_python3-six:python3-light
  VARIANT:=python3
endef

define Package/python-six/description
Six is a Python 2 and 3 compatibility library.  It provides utility functions
for smoothing over the differences between the Python versions with the goal of
writing Python code that is compatible on both Python versions.  See the
documentation for more information on what is provided.
endef

define Package/python3-six/description
$(call Package/python-six/description)
.
(Variant for Python3)
endef

define Host/Compile
	$(call Build/Compile/HostPyMod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=

$(eval $(call HostBuild))

$(eval $(call PyPackage,python-six))
$(eval $(call BuildPackage,python-six))
$(eval $(call Py3Package,python3-six))
$(eval $(call BuildPackage,python3-six))
