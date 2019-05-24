#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-chardet
PKG_VERSION:=3.0.4
PKG_RELEASE:=2
PKG_LICENSE:=LGPL-2.1

PKG_SOURCE:=chardet-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/
PKG_HASH:=84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-chardet-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-chardet/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
  URL:=https://github.com/chardet/chardet
endef

define Package/python-chardet
$(call Package/python-chardet/Default)
  TITLE:=Universal encoding detector for Python 2
  DEPENDS:=+PACKAGE_python-chardet:python
  VARIANT:=python
endef

define Package/python3-chardet
$(call Package/python-chardet/Default)
  TITLE:=Universal encoding detector for Python3
  DEPENDS:=+PACKAGE_python3-chardet:python3-light
  VARIANT:=python3
endef

define Package/python-chardet/description
  Universal encoding detector for Python 2 and 3
endef

define Package/python3-chardet/description
$(call Package/python-chardet/description)
.
(Variant for Python3)
endef

define Py3Package/python3-chardet/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	for bin in $(1)/usr/bin/*; do \
		mv $$$$bin $$$${bin}3 ; \
	done
endef

$(eval $(call PyPackage,python-chardet))
$(eval $(call BuildPackage,python-chardet))
$(eval $(call BuildPackage,python-chardet-src))

$(eval $(call Py3Package,python3-chardet))
$(eval $(call BuildPackage,python3-chardet))
$(eval $(call BuildPackage,python3-chardet-src))
