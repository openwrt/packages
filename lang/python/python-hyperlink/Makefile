#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-hyperlink
PKG_VERSION:=20.0.1
PKG_RELEASE:=1

PYPI_NAME:=hyperlink
PKG_HASH:=47fcc7cd339c6cb2444463ec3277bdcfe142c8b1daf2160bdd52248deec815af

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-hyperlink
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pure-Python immutable URLs
  URL:=https://github.com/python-hyper/hyperlink
  DEPENDS:= \
      +python3-light \
      +python3-codecs \
      +python3-idna
endef

define Package/python3-hyperlink/description
Hyperlink provides a pure-Python implementation of immutable URLs. Based
on RFC 3986 and 3987, the Hyperlink URL makes working with both URIs and
IRIs easy.
endef

define Py3Package/python3-hyperlink/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/hyperlink/hypothesis.py
endef

$(eval $(call Py3Package,python3-hyperlink))
$(eval $(call BuildPackage,python3-hyperlink))
$(eval $(call BuildPackage,python3-hyperlink-src))
