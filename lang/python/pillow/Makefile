#
# Copyright © 1997-2011 by Secret Labs AB
# Copyright © 1995-2011 by Fredrik Lundh
# Copyright © 2016 by Alex Clark and contributors
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pillow
PKG_VERSION:=5.3.0
PKG_RELEASE:=2

PKG_SOURCE:=Pillow-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/P/Pillow
PKG_HASH:=2ea3517cd5779843de8a759c2349a3cd8d3893e03ab47053b66d5ec6f8bc4f93
PKG_BUILD_DIR:=$(BUILD_DIR)/Pillow-$(PKG_VERSION)
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_LICENSE:=CUSTOM
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:python:pillow

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/pillow
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=The friendly PIL fork
    URL:=https://python-pillow.org/
    DEPENDS:=+python +libfreetype +libjpeg +zlib +libtiff
endef

define Package/pillow/description
    The friendly PIL fork
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/pillow/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
		$(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
		$(1)$(PYTHON_PKG_DIR)/
endef

$(eval $(call BuildPackage,pillow))
