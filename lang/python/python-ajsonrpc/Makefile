# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ajsonrpc
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PYPI_NAME:=ajsonrpc
PKG_HASH:=791bac18f0bf0dee109194644f151cf8b7ff529c4b8d6239ac48104a3251a19f

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-setuptools/host
PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-ajsonrpc
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python Library for implementing JSON-RPC 2.0
  URL:=https://pypi.org/project/ajsonrpc
  DEPENDS:=+python3-light +python3-asyncio +python3-logging
endef

define Package/python3-ajsonrpc/description
Python JSON-RPC 2.0 implementation and asynchronous server powered by asyncio
endef

$(eval $(call Py3Package,python3-ajsonrpc))
$(eval $(call BuildPackage,python3-ajsonrpc))
$(eval $(call BuildPackage,python3-ajsonrpc-src))
$(eval $(call HostBuild))
