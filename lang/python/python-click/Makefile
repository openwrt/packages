# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-click
PKG_VERSION:=8.3.1
PKG_RELEASE:=1

PYPI_NAME:=click
PKG_HASH:=12ff4785d337a1bb490bb7e9c2b1ee5da3112e94a8622f26a6c77f5d2fc6842a

PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst

HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-click
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Composable command line interface toolkit
  URL:=https://palletsprojects.com/p/click/
  DEPENDS:=+python3-light +python3-urllib +python3-uuid
endef

define Package/python3-click/description
Click is a Python package for creating beautiful command line interfaces
in a composable way with as little code as necessary. It's the "Command
Line Interface Creation Kit". It's highly configurable but comes with
sensible defaults out of the box.
endef

$(eval $(call Py3Package,python3-click))
$(eval $(call BuildPackage,python3-click))
$(eval $(call BuildPackage,python3-click-src))
$(eval $(call HostBuild))
