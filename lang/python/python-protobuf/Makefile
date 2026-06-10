# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=python-protobuf
PKG_VERSION:=5.29.5
PKG_RELEASE:=1

PYPI_NAME:=protobuf
PKG_HASH:=bc1463bafd4b0929216c35f437a8e28731a2b7fe3d98bb77a600efced5a15c84

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:google:protobuf

PKG_BUILD_DEPENDS:=protobuf/host python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-protobuf
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Protobuf support for Python
  URL:=https://github.com/protocolbuffers/protobuf
  DEPENDS:= \
    +protobuf \
    +python3-ctypes \
    +python3-light
endef

define Package/python3-protobuf/description
  Protocol Buffers - Google's data interchange format, for Python
endef

$(eval $(call Py3Package,python3-protobuf))
$(eval $(call BuildPackage,python3-protobuf))
$(eval $(call BuildPackage,python3-protobuf-src))
