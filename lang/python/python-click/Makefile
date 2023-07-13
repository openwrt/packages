# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-click
PKG_VERSION:=8.1.4
PKG_RELEASE:=1

PYPI_NAME:=click
PKG_HASH:=b97d0c74955da062a7d4ef92fadb583806a585b2ea81958a81bd72726cbb8e37

PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

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
