#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-chardet
PKG_VERSION:=5.0.0
PKG_RELEASE:=$(AUTORELEASE)
PKG_LICENSE:=LGPL-2.1

PYPI_NAME:=chardet
PKG_HASH:=0368df2bfd78b5fc20572bb4e9bb7fb53e2c094f60ae9993339e8671d0afb8aa

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-chardet
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
  URL:=https://github.com/chardet/chardet
  TITLE:=Universal encoding detector
  DEPENDS:=+python3-light
endef

define Package/python3-chardet/description
  Universal encoding detector for Python 2 and 3
endef

define Py3Package/python3-chardet/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	for bin in $(1)/usr/bin/*; do \
		mv $$$$bin $$$${bin}3 ; \
		$(LN) $$$${bin##*/}3 $$$$bin ; \
	done
endef

$(eval $(call Py3Package,python3-chardet))
$(eval $(call BuildPackage,python3-chardet))
$(eval $(call BuildPackage,python3-chardet-src))
