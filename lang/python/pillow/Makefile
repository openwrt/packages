#
# Copyright © 1997-2011 by Secret Labs AB
# Copyright © 1995-2011 by Fredrik Lundh
# Copyright © 2016 by Alex Clark and contributors
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pillow
PKG_VERSION:=3.3.1
PKG_RELEASE=1
PKG_LICENSE:=CUSTOM
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/python-pillow/Pillow.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=aab33141f381d5577cdef9033b7fdff79122a10c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=e7c36bcf89614337d9abc4d07780da0b346a745be7a9aa55b398fa427549273c

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/pillow
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=The friendly PIL fork
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
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
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
		$(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
		$(1)$(PYTHON_PKG_DIR)/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/LICENSE $(1)$(PYTHON_PKG_DIR)/PIL/
endef

$(eval $(call BuildPackage,pillow))
