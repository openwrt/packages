#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-hyperlink
PKG_VERSION:=17.3.1
PKG_RELEASE:=1

PKG_SOURCE:=hyperlink-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/h/hyperlink
PKG_HASH:=bc4ffdbde9bdad204d507bd8f554f16bba82dd356f6130cb16f41422909c33bc

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-hyperlink-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-hyperlink/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/python-hyper/hyperlink
endef

define Package/python-hyperlink
$(call Package/python-hyperlink/Default)
  TITLE:=Pure-Python immutable URLs
  DEPENDS:=+PACKAGE_python-hyperlink:python-light
  VARIANT:=python
endef

define Package/python3-hyperlink
$(call Package/python-hyperlink/Default)
  TITLE:=Pure-Python immutable URLs
  DEPENDS:=+PACKAGE_python3-hyperlink:python3-light
  VARIANT:=python3
endef

define Package/python-hyperlink/description
Hyperlink provides a pure-Python implementation of immutable URLs. Based
on RFC 3986 and 3987, the Hyperlink URL makes working with both URIs and
IRIs easy.
endef

define Package/python3-hyperlink/description
$(call Package/python-hyperlink/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-hyperlink))
$(eval $(call BuildPackage,python-hyperlink))
$(eval $(call BuildPackage,python-hyperlink-src))

$(eval $(call Py3Package,python3-hyperlink))
$(eval $(call BuildPackage,python3-hyperlink))
$(eval $(call BuildPackage,python3-hyperlink-src))
