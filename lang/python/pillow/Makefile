#
# Copyright © 1997-2011 by Secret Labs AB
# Copyright © 1995-2011 by Fredrik Lundh
# Copyright © 2016 by Alex Clark and contributors
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pillow
PKG_VERSION:=6.2.0
PKG_RELEASE:=1

PKG_SOURCE:=Pillow-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/P/Pillow
PKG_HASH:=4548236844327a718ce3bb182ab32a16fa2050c61e334e959f554cac052fb0df
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-Pillow-$(PKG_VERSION)

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=HPND
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:python:pillow

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

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
