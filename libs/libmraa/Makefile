#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmraa
PKG_VERSION:=2.0.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/intel-iot-devkit/mraa/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c9f3c3741c6894be5516adecfe6b55a38960b6718b268a9afd645f7955e5a716
PKG_BUILD_DIR:=$(BUILD_DIR)/mraa-$(PKG_VERSION)

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>, Hirokazu MORIKAWA <morikw2@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=node swig/host node/host
CMAKE_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include ../../lang/python/python-package.mk
include ../../lang/python/python3-package.mk

CMAKE_OPTIONS=-DENABLEEXAMPLES=0 \
	-DFIRMATA=ON

TARGET_CFLAGS+=-I$(STAGING_DIR)/usr/include/node

define Package/libmraa/Default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=IoT
  TITLE:=Intel IoT lowlevel IO library
  URL:=https://github.com/intel-iot-devkit/mraa
endef

define Package/libmraa/Default/description
  Libmraa is a C/C++ library with bindings to Java, Python and JavaScript to interface
with the IO on Galileo, Edison & other platforms, with a structured and sane API where
port names/numbering matches the board that you are on. Use of libmraa does not tie you
to specific hardware with board detection done at runtime you can create portable code
that will work across the supported platforms.
endef

define Package/libmraa
  $(call Package/libmraa/Default)
  TITLE:=Intel IoT lowlevel IO C/C++ library
  DEPENDS:=+libstdcpp +libjson-c @!arc @!armeb @!powerpc
endef

define Package/libmraa/description
$(call Package/libmraa/Default/description)

This package contains the C/C++ libraries.
endef

define Package/libmraa-node
  $(call Package/libmraa/Default)
  TITLE:=Intel IoT lowlevel IO Node.js library
  DEPENDS:=+libmraa +node
endef

define Package/libmraa-node/description
$(call Package/libmraa/Default/description)

This package contains the Node.js libraries.
endef

define Package/libmraa-python
  $(call Package/libmraa/Default)
  TITLE:=Intel IoT lowlevel IO Python library
  DEPENDS:=+libmraa +python-light
endef

define Package/libmraa-python/description
$(call Package/libmraa/Default/description)

This package contains the Python libraries.
endef

define Package/libmraa-python3
  $(call Package/libmraa/Default)
  TITLE:=Intel IoT lowlevel IO Python3 library
  DEPENDS:=+libmraa +python3-light
endef

define Package/libmraa-python3/description
$(call Package/libmraa/Default/description)

This package contains the Python3 libraries.
endef

define Package/libmraa/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmraa.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mraa-* $(1)/usr/bin/
endef

define Package/libmraa-node/install
	$(INSTALL_DIR) $(1)/usr/lib/node/mraa
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/mraa/* $(1)/usr/lib/node/mraa/
endef

define Package/libmraa-python/install
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON_VERSION)/site-packages
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON_VERSION)/site-packages/* \
		$(1)/usr/lib/python$(PYTHON_VERSION)/site-packages/
endef

define Package/libmraa-python3/install
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python$(PYTHON3_VERSION)/site-packages/* \
		$(1)/usr/lib/python$(PYTHON3_VERSION)/site-packages/
endef

$(eval $(call BuildPackage,libmraa))
$(eval $(call BuildPackage,libmraa-node))
$(eval $(call BuildPackage,libmraa-python))
$(eval $(call BuildPackage,libmraa-python3))
