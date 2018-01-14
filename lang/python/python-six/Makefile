#
# Copyright (C) 2015, 2017-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-six
PKG_VERSION:=1.11.0
PKG_RELEASE:=2

PKG_SOURCE:=six-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe
PKG_HASH:=70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9

HOST_BUILD_DEPENDS:=python/host

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-six-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

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
$(eval $(call BuildPackage,python-six-src))

$(eval $(call Py3Package,python3-six))
$(eval $(call BuildPackage,python3-six))
$(eval $(call BuildPackage,python3-six-src))
