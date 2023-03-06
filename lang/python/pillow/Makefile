#
# Copyright © 1997-2011 by Secret Labs AB
# Copyright © 1995-2011 by Fredrik Lundh
# Copyright © 2016 by Alex Clark and contributors
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pillow
PKG_VERSION:=9.5.0
PKG_RELEASE:=2

PYPI_NAME:=Pillow
PKG_HASH:=bf548479d336726d7a0eceb6e767e179fbde37833ae42794602631a070d630f1

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
	--global-option=build_ext \
	--global-option=--enable-zlib \
	--global-option=--enable-jpeg \
	--global-option=--enable-webp \
	--global-option=--enable-webpmux \
	--global-option=--enable-tiff \
	--global-option=--enable-freetype \
	--global-option=--disable-lcms \
	--global-option=--disable-jpeg2000 \
	--global-option=--disable-imagequant \
	--global-option=--disable-platform-guessing

$(eval $(call Py3Package,python3-pillow))
$(eval $(call BuildPackage,python3-pillow))
$(eval $(call BuildPackage,python3-pillow-src))
