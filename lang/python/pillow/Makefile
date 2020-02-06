#
# Copyright © 1997-2011 by Secret Labs AB
# Copyright © 1995-2011 by Fredrik Lundh
# Copyright © 2016 by Alex Clark and contributors
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pillow
PKG_VERSION:=6.2.1
PKG_RELEASE:=1

PYPI_NAME:=Pillow
PKG_HASH:=bf4e972a88f8841d8fdc6db1a75e0f8d763e66e3754b03006cbc3854d89f1cb1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=HPND
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:python:pillow

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-pillow/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The friendly PIL fork
  URL:=https://python-pillow.org/
  DEPENDS:=+libfreetype +libjpeg +libtiff +zlib
endef

define Package/python-pillow
$(call Package/python-pillow/Default)
  DEPENDS+=+PACKAGE_python-pillow:python
  VARIANT:=python
endef

define Package/python-pillow/description
  The friendly PIL fork
endef

define Package/python3-pillow
$(call Package/python-pillow/Default)
  DEPENDS+=+PACKAGE_python3-pillow:python3
  VARIANT:=python3
endef

define Package/python3-pillow/description
$(call Package/python-pillow/description)
.
(Variant for Python3)
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

PYTHON_PKG_SETUP_GLOBAL_ARGS:=$(PYTHON3_PKG_SETUP_GLOBAL_ARGS)

$(eval $(call PyPackage,python-pillow))
$(eval $(call BuildPackage,python-pillow))
$(eval $(call BuildPackage,python-pillow-src))

$(eval $(call Py3Package,python3-pillow))
$(eval $(call BuildPackage,python3-pillow))
$(eval $(call BuildPackage,python3-pillow-src))
