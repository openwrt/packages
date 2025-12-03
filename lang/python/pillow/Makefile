#
# Copyright © 1997-2011 by Secret Labs AB
# Copyright © 1995-2011 by Fredrik Lundh
# Copyright © 2016 by Alex Clark and contributors
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pillow
PKG_VERSION:=10.2.0
PKG_RELEASE:=1

PYPI_NAME:=Pillow
PYPI_SOURCE_NAME:=pillow
PKG_HASH:=e87f0b2c78157e12d7686b27d63c070fd65d994e8ddae6f328e0dcf4a0cd007e

PKG_BUILD_DEPENDS:=python-setuptools-scm/host

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=HPND
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:python:pillow

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pillow
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The friendly PIL fork
  URL:=https://python-pillow.org/
  DEPENDS:=+libfreetype +libjpeg +libtiff +zlib \
	   +libwebp +python3
endef

define Package/python3-pillow/description
  The friendly PIL fork
endef

PYTHON3_PKG_BUILD_CONFIG_SETTINGS += \
	--build-option=build_ext \
	--build-option=--enable-zlib \
	--build-option=--enable-jpeg \
	--build-option=--enable-webp \
	--build-option=--enable-webpmux \
	--build-option=--enable-tiff \
	--build-option=--enable-freetype \
	--build-option=--disable-lcms \
	--build-option=--disable-jpeg2000 \
	--build-option=--disable-imagequant \
	--build-option=--disable-platform-guessing

$(eval $(call Py3Package,python3-pillow))
$(eval $(call BuildPackage,python3-pillow))
$(eval $(call BuildPackage,python3-pillow-src))
