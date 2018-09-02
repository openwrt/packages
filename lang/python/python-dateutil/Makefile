#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dateutil
PKG_VERSION:=2.6.1
PKG_RELEASE:=2

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/54/bb/f1db86504f7a49e1d9b9301531181b00a1c7325dc85a29160ee3eaa73a54/
PKG_HASH:=891c38b2a02f5bb1be3e4793866c8df49c7d19baabf9c1bad62547e0b4866aca

HOST_BUILD_DEPENDS:=python/host

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-dateutil-$(PKG_VERSION)

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
HOST_UNPACK:=$(HOST_TAR) -C $(HOST_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-dateutil/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://pypi.python.org/pypi/dateutil
endef

define Package/python-dateutil
$(call Package/python-dateutil/Default)
  TITLE:=python-dateutil
  DEPENDS:=+python-six
  VARIANT:=python
endef

define Package/python3-dateutil
$(call Package/python-dateutil/Default)
  TITLE:=python3-dateutil
  DEPENDS:=+python3-six
  VARIANT:=python3
endef

define Package/python-dateutil/description
dateutil is a Python 2 and 3 compatibility library.
The dateutil module provides powerful extensions to the standard datetime module, available in Python.
endef

define Package/python3-dateutil/description
$(call Package/python-dateutil/description)
.
(Variant for Python3)
endef

define Host/Compile
	$(call Build/Compile/HostPyMod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=

$(eval $(call HostBuild))

$(eval $(call PyPackage,python-dateutil))
$(eval $(call BuildPackage,python-dateutil))
$(eval $(call BuildPackage,python-dateutil-src))

$(eval $(call Py3Package,python3-dateutil))
$(eval $(call BuildPackage,python3-dateutil))
$(eval $(call BuildPackage,python3-dateutil-src))
