#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pycparser
PKG_VERSION:=2.17
PKG_RELEASE:=1

PKG_SOURCE:=pycparser-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/be/64/1bb257ffb17d01f4a38d7ce686809a736837ad4371bcc5c42ba7a715c3ac
PKG_HASH:=0aac31e917c24cb3357f5a4d5566f2cc91a19ca41862f6c3c22dc60a629673b6

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pycparser-$(PKG_VERSION)

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pycparser/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/eliben/pycparser
endef

define Package/python-pycparser
$(call Package/python-pycparser/Default)
  TITLE:=python-pycparser
  DEPENDS:=+PACKAGE_python-pycparser:python-light +PACKAGE_python-pycparser:python-ply
  VARIANT:=python
endef

define Package/python3-pycparser
$(call Package/python-pycparser/Default)
  TITLE:=python3-pycparser
  DEPENDS:=+PACKAGE_python3-pycparser:python3-light +PACKAGE_python3-pycparser:python3-ply
  VARIANT:=python3
endef

define Package/python-pycparser/description
pycparser is a parser for the C language, written in pure Python. It is a
module designed to be easily integrated into applications that need to parse
C source code.
endef

define Package/python3-pycparser/description
$(call Package/python-pycparser/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-pycparser))
$(eval $(call BuildPackage,python-pycparser))

$(eval $(call Py3Package,python3-pycparser))
$(eval $(call BuildPackage,python3-pycparser))
