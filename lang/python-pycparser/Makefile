#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pycparser
PKG_VERSION:=2.14
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/pycparser
PKG_HASH:=7959b4a74abdc27b312fed1c21e6caf9309ce0b29ea86b591fd2e99ecdf27f73

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

HOST_BUILD_DEPENDS:=python-ply/host
ifdef CONFIG_PACKAGE_python-pycparser
HOST_BUILD_DEPENDS+=python/host
endif
ifdef CONFIG_PACKAGE_python3-pycparser
HOST_BUILD_DEPENDS+=python3/host
endif

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

define Package/python-pycparser/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/eliben/pycparser
endef

define Package/python-pycparser
$(call Package/python-pycparser/Default)
  TITLE:=python-pycparser
  DEPENDS:=+python-light +python-ply
  VARIANT:=python
endef

define Package/python3-pycparser
$(call Package/python-pycparser/Default)
  TITLE:=python3-pycparser
  DEPENDS:=+python3-light +python3-ply
  VARIANT:=python3
endef

define Package/python-pycparser/description
pycparser is a parser for the C language, written in pure Python. It is a
module designed to be easily integrated into applications that need to parse
C source code.
endef

define Package/python3-pycparser/description
$(call Package/python-pycparser/description)
.
(Variant for Python3)
endef

ifdef CONFIG_PACKAGE_python-pycparser
define Host/Compile/python-pycparser
	$(call Build/Compile/HostPyMod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef
endif

ifdef CONFIG_PACKAGE_python3-pycparser
define Host/Compile/python3-pycparser
	$(call Build/Compile/HostPy3Mod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef
endif

define Host/Compile
$(call Host/Compile/python-pycparser)
$(call Host/Compile/python3-pycparser)
endef

define Host/Install
endef

$(eval $(call HostBuild))

$(eval $(call PyPackage,python-pycparser))
$(eval $(call BuildPackage,python-pycparser))

$(eval $(call Py3Package,python3-pycparser))
$(eval $(call BuildPackage,python3-pycparser))
