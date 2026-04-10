#
# Copyright © 1997-2011 by Secret Labs AB
# Copyright © 1995-2011 by Fredrik Lundh
# Copyright © 2016 by Alex Clark and contributors
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pillow
PKG_VERSION:=12.2.0
PKG_RELEASE:=1

PYPI_NAME:=Pillow
PYPI_SOURCE_NAME:=pillow
PKG_HASH:=a830b1a40919539d07806aa58e1b114df53ddd43213d9c8b75847eee6c0182b5

PKG_BUILD_DEPENDS:=python-setuptools/host python-pybind11/host

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
	zlib=enable \
	jpeg=enable \
	webp=enable \
	tiff=enable \
	freetype=enable \
	lcms=disable \
	jpeg2000=disable \
	imagequant=disable \
	platform-guessing=disable

$(eval $(call Py3Package,python3-pillow))
$(eval $(call BuildPackage,python3-pillow))
$(eval $(call BuildPackage,python3-pillow-src))
