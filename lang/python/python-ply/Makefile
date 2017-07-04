#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ply
PKG_VERSION:=3.10
PKG_RELEASE:=1

PKG_SOURCE:=ply-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.dabeaz.com/ply
PKG_HASH:=96e94af7dd7031d8d6dd6e2a8e0de593b511c211a86e28a9c9621c275ac8bacb

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-ply-$(PKG_VERSION)

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=README.md
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-ply/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://www.dabeaz.com/ply/
endef

define Package/python-ply
$(call Package/python-ply/Default)
  TITLE:=python-ply
  DEPENDS:=+PACKAGE_python-ply:python-light
  VARIANT:=python
endef

define Package/python3-ply
$(call Package/python-ply/Default)
  TITLE:=python3-ply
  DEPENDS:=+PACKAGE_python3-ply:python3-light
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

$(eval $(call PyPackage,python-ply))
$(eval $(call BuildPackage,python-ply))

$(eval $(call Py3Package,python3-ply))
$(eval $(call BuildPackage,python3-ply))
