#
# Copyright (c) 1997-2009 by Secret Labs AB
# Copyright (c) 1995-2009 by Fredrik Lundh
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-imglib
PKG_VERSION:=1.1.7
PKG_RELEASE:=1
PKG_LICENSE:=CUSTOM
PKG_LICENSE_FILES:=README

PKG_SOURCE:=Imaging-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://effbot.org/downloads
PKG_MD5SUM:=fc14a54e1ce02a0225be8854bfba478e

PKG_BUILD_DIR:=$(BUILD_DIR)/Imaging-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-imglib
  SECTION:=language-python
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python Imaging Library (PIL)
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  URL:=http://www.pythonware.com/products/pil/
  DEPENDS:=+python +libfreetype +libjpeg +zlib
endef

define Package/python-imglib/description
 The Python Imaging Library adds image processing capabilities to your
 Python interpreter.

 This library provides extensive file format support, an efficient
 internal representation, and fairly powerful image processing
 capabilities.

 The core image library is designed for fast access to data stored in a
 few basic pixel formats. It should provide a solid foundation for a
 general image processing tool.
endef

define Build/Compile
	$(call Build/Compile/PyMod,., \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)", \
	)
endef

define Package/python-imglib/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
		$(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
		$(1)$(PYTHON_PKG_DIR)/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
endef

$(eval $(call BuildPackage,python-imglib))
