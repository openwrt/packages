# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-protobuf
# Must match the version of the `protobuf` package
PKG_VERSION:=3.17.3
PKG_RELEASE:=1

PYTHON3_PKG_WHEEL_NAME:=protobuf

PKG_SOURCE:=protobuf-python-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/google/protobuf/releases/download/v$(PKG_VERSION)
PKG_HASH:=3253c6d17ec0bb6f6382e555cf5ca0a9ffab8d81b691f100f96ce9f5e753018e

PKG_BUILD_DIR:=$(BUILD_DIR)/protobuf-$(PKG_VERSION)
PYTHON3_PKG_SETUP_DIR:=python

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:google:protobuf

PKG_BUILD_DEPENDS:=protobuf/host

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-protobuf
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Protobuf support for Python
  URL:=https://pypi.org/project/protobuf
  DEPENDS:=+protobuf +python3-light +python3-ctypes +python3-uuid
endef

define Package/python3-protobuf/description
Protocol Buffers - Google's data interchange format, for Python
endef

$(eval $(call Py3Package,python3-protobuf))
$(eval $(call BuildPackage,python3-protobuf))
