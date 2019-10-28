#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-mako
PKG_VERSION:=1.0.7
PKG_RELEASE:=1

PKG_SOURCE:=Mako-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/m/mako/
PKG_HASH:=4e02fde57bd4abb5ec400181e4c314f56ac3e49ba4fb8b0d50bba18cb27d25ae

HOST_BUILD_DEPENDS:=python/host

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-mako-$(PKG_VERSION)

PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
HOST_UNPACK=$(HOST_TAR) -C $(HOST_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=LICENSES.txt
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-mako/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://www.makotemplates.org/
  DEPENDS:=
endef

define Package/python-mako
$(call Package/python-mako/Default)
  TITLE:=python-mako
  DEPENDS+=+PACKAGE_python-mako:python-light
  VARIANT:=python
endef

define Package/python3-mako
$(call Package/python-mako/Default)
  TITLE:=python3-mako
  DEPENDS+=+PACKAGE_python3-mako:python3-light
  VARIANT:=python3
endef

define Package/python-mako/description
Mako is a template library written in Python. It provides a familiar, non-XML 
syntax which compiles into Python modules for maximum performance.
endef

define Package/python3-mako/description
$(call Package/python-mako/description)
.
(Variant for Python3)
endef

define Host/Compile
        $(call Build/Compile/HostPyMod,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=

$(eval $(call HostBuild))

$(eval $(call PyPackage,python-mako))
$(eval $(call BuildPackage,python-mako))

$(eval $(call Py3Package,python3-mako))
$(eval $(call BuildPackage,python3-mako))
