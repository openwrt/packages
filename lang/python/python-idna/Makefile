#
# Copyright (C) 2015-2016, 2018-2020, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-idna
PKG_VERSION:=3.6
PKG_RELEASE:=1

PYPI_NAME:=idna
PKG_HASH:=9ecdbbd083b06798ae1e86adcbfe8ab1479cf864e4ee30fe4e46a003d12491ca

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_DEPENDS:=python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-idna
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=IDNA library
  URL:=https://github.com/kjd/idna
  DEPENDS:=+python3-light +python3-codecs
endef

define Package/python3-idna/description
A library to support the Internationalised Domain Names in Applications
(IDNA) protocol as specified in RFC 5891. This version of the protocol
is often referred to as "IDNA2008" and can produce different results
from the earlier standard from 2003.
endef

$(eval $(call Py3Package,python3-idna))
$(eval $(call BuildPackage,python3-idna))
$(eval $(call BuildPackage,python3-idna-src))
