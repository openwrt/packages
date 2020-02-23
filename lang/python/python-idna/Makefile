#
# Copyright (C) 2015-2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-idna
PKG_VERSION:=2.9
PKG_RELEASE:=1

PKG_SOURCE:=idna-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/i/idna
PKG_HASH:=7588d1c14ae4c77d74036e8c22ff447b26d0fde8f007354fd48a7814db15b7cb

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-idna-$(PKG_VERSION)

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-idna/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=IDNA library
  URL:=https://github.com/kjd/idna
endef

define Package/python-idna
$(call Package/python-idna/Default)
  DEPENDS:= \
      +PACKAGE_python-idna:python-light \
      +PACKAGE_python-idna:python-codecs
  VARIANT:=python
endef

define Package/python3-idna
$(call Package/python-idna/Default)
  DEPENDS:= \
      +PACKAGE_python3-idna:python3-light \
      +PACKAGE_python3-idna:python3-codecs
  VARIANT:=python3
endef

define Package/python-idna/description
A library to support the Internationalised Domain Names in Applications
(IDNA) protocol as specified in RFC 5891. This version of the protocol
is often referred to as "IDNA2008" and can produce different results
from the earlier standard from 2003.
endef

define Package/python3-idna/description
$(call Package/python-idna/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-idna))
$(eval $(call BuildPackage,python-idna))
$(eval $(call BuildPackage,python-idna-src))

$(eval $(call Py3Package,python3-idna))
$(eval $(call BuildPackage,python3-idna))
$(eval $(call BuildPackage,python3-idna-src))
