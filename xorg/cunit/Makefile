# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=cunit
_PKG_NAME:=CUnit
PKG_VERSION:=2.1.3
_PKG_VERSION:=2.1-3
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/project/$(PKG_NAME)/$(_PKG_NAME)/$(_PKG_VERSION)/
PKG_SOURCE:=$(_PKG_NAME)-$(_PKG_VERSION).tar.bz2
PKG_HASH:=f5b29137f845bb08b77ec60584fdb728b4e58f1023e6f249a464efa49a40f214

PKG_BUILD_DIR:=$(BUILD_DIR)/$(_PKG_NAME)-$(_PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/cunit
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=
  TITLE:=Automated testing framework for C
  URL:=http://cunit.sourceforge.net/
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so,*.a} \
	  $(1)/usr/lib/
endef

define Package/cunit/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,cunit))
