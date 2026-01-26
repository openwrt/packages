#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-userpath
PKG_VERSION:=1.9.1
PKG_RELEASE:=1

PYPI_NAME:=userpath
PKG_HASH:=ce8176728d98c914b6401781bf3b23fccd968d1647539c8788c7010375e02796

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=

PKG_BUILD_DEPENDS:=python-hatchling/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-userpath
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Cross-platform tool for modifying a user's PATH
  URL:=https://github.com/ofek/userpath
  DEPENDS:=+python3-light +python3-click +python3-psutil
endef

define Package/python3-userpath/description
This is a tool for modifying a user's PATH.
endef

$(eval $(call Py3Package,python3-userpath))
$(eval $(call BuildPackage,python3-userpath))
$(eval $(call BuildPackage,python3-userpath-src))
