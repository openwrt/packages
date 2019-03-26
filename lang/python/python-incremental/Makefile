#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-incremental
PKG_VERSION:=17.5.0
PKG_RELEASE:=1

PKG_SOURCE:=incremental-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/i/incremental
PKG_HASH:=7b751696aaf36eebfab537e458929e194460051ccad279c72b755a167eebd4b3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-incremental-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-incremental/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Versions your Python projects
  URL:=https://github.com/twisted/incremental
endef

define Package/python-incremental
$(call Package/python-incremental/Default)
  DEPENDS:=+PACKAGE_python-incremental:python-light
  VARIANT:=python
endef

define Package/python3-incremental
$(call Package/python-incremental/Default)
  DEPENDS:=+PACKAGE_python3-incremental:python3-light
  VARIANT:=python3
endef

define Package/python-incremental/description
Incremental is a small library that versions your Python projects.
endef

define Package/python3-incremental/description
$(call Package/python-incremental/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-incremental))
$(eval $(call BuildPackage,python-incremental))
$(eval $(call BuildPackage,python-incremental-src))

$(eval $(call Py3Package,python3-incremental))
$(eval $(call BuildPackage,python3-incremental))
$(eval $(call BuildPackage,python3-incremental-src))
