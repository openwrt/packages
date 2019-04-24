#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yarl
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE:=yarl-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/y/yarl/
PKG_HASH:=024ecdc12bc02b321bc66b41327f930d1c2c543fa9a561b39861da9388ba7aa9

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-yarl
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Yet another URL library
  URL:=https://github.com/aio-libs/yarl
  DEPENDS:= \
  +python3-light \
  +python3-multidict \
  +python3-urllib \
  +python3-idna
  VARIANT:=python3
endef

define Package/python3-yarl/description
Yet another URL library
endef

$(eval $(call Py3Package,python3-yarl))
$(eval $(call BuildPackage,python3-yarl))
$(eval $(call BuildPackage,python3-yarl-src))
