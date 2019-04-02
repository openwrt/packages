include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyxdg
PKG_VERSION:=0.26
PKG_RELEASE:=1

PKG_SOURCE:=pyxdg-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pyxdg
PKG_HASH:=fe2928d3f532ed32b39c32a482b54136fe766d19936afc96c8f00645f9da1a06
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyxdg-$(PKG_VERSION)

PKG_MAINTAINER:= Sergey Pushilin <pushilin@gmail.com>
PKG_LICENSE:=LGPL-2.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

PYTHON_PKG_SETUP_ARGS:=

define Package/python-pyxdg
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=pyxdg
  URL:=https://freedesktop.org/wiki/Software/pyxdg
  DEPENDS:=+python
  VARIANT:=python
endef

define Package/python-pyxdg/description
  A Python module to deal with freedesktop.org specifications
endef

$(eval $(call PyPackage,python-pyxdg))
$(eval $(call BuildPackage,python-pyxdg))
