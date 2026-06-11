#
# Copyright (C) 2019-2O21 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-markdown
PKG_VERSION:=3.10.2
PKG_RELEASE:=1

PYPI_NAME:=markdown
PKG_HASH:=994d51325d25ad8aa7ce4ebaec003febcce822c3f8c911e3b17c52f7f589f950

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:=python3/host python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-markdown
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Implementation of John Gruber's Markdown
  URL:=https://python-markdown.github.io/
  DEPENDS:= \
	+python3-light \
	+python3-codecs \
	+python3-logging \
	+python3-xml
endef

define Package/python3-markdown/description
This is a Python implementation of John Gruber’s Markdown. It is almost
completely compliant with the reference implementation, though there are
a few very minor differences.
endef

$(eval $(call Py3Package,python3-markdown))
$(eval $(call BuildPackage,python3-markdown))
$(eval $(call BuildPackage,python3-markdown-src))
