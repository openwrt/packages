#
# Copyright © 1997-2011 by Secret Labs AB
# Copyright © 1995-2011 by Fredrik Lundh
# Copyright © 2016 by Alex Clark and contributors
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pillow
PKG_VERSION:=8.1.2
PKG_RELEASE:=1

PYPI_NAME:=Pillow
PKG_HASH:=b07c660e014852d98a00a91adfbe25033898a9d90a8f39beb2437d22a203fc44

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
  DEPENDS:=+libfreetype +libjpeg +libtiff +zlib +python3
endef

define Package/python3-pillow/description
  The friendly PIL fork
endef

PYTHON3_PKG_SETUP_GLOBAL_ARGS += build_ext \
	--enable-zlib \
	--enable-jpeg \
	--enable-tiff \
	--enable-freetype \
	--disable-lcms \
	--disable-webp \
	--disable-webpmux \
	--disable-jpeg2000 \
	--disable-imagequant \
	--disable-platform-guessing

$(eval $(call Py3Package,python3-pillow))
$(eval $(call BuildPackage,python3-pillow))
$(eval $(call BuildPackage,python3-pillow-src))
