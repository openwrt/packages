#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ply
PKG_VERSION:=3.9
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.dabeaz.com/ply
PKG_HASH:=0d7e2940b9c57151392fceaa62b0865c45e06ce1e36687fd8d03f011a907f43e

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

HOST_BUILD_DEPENDS:=
ifdef CONFIG_PACKAGE_python-ply
HOST_BUILD_DEPENDS+=python/host
endif
ifdef CONFIG_PACKAGE_python3-ply
HOST_BUILD_DEPENDS+=python3/host
endif

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=README.md
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

define Package/python-ply/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://www.dabeaz.com/ply/
endef

define Package/python-ply
$(call Package/python-ply/Default)
  TITLE:=python-ply
  DEPENDS:=+python-light
  VARIANT:=python
endef

define Package/python3-ply
$(call Package/python-ply/Default)
  TITLE:=python3-ply
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python-ply/description
PLY is a 100% Python implementation of the common parsing tools lex
and yacc.
endef

define Package/python3-ply/description
$(call Package/python-ply/description)
.
(Variant for Python3)
endef

ifdef CONFIG_PACKAGE_python-ply
define Host/Compile/python-ply
	$(call Build/Compile/HostPyMod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef
endif

ifdef CONFIG_PACKAGE_python3-ply
define Host/Compile/python3-ply
	$(call Build/Compile/HostPy3Mod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef
endif

define Host/Compile
$(call Host/Compile/python-ply)
$(call Host/Compile/python3-ply)
endef

define Host/Install
endef

$(eval $(call HostBuild))

$(eval $(call PyPackage,python-ply))
$(eval $(call BuildPackage,python-ply))

$(eval $(call Py3Package,python3-ply))
$(eval $(call BuildPackage,python3-ply))
