include $(TOPDIR)/rules.mk

PKG_NAME:=uci2
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/sartura/uci2.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=89056741c0c4048dafa822fef228c555fc41deff
PKG_MIRROR_HASH:=e376e8aec6054405a2e9616a1dc51b86d68d6cfac87d84e8a98ea1714883dfaf

PKG_MAINTAINER:=Jakov Petrina <jakov.petrina@sartura.hr>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../../devel/ninja/ninja-cmake.mk

define Package/libuci2/Default
	TITLE:=AST-based C parser library for UCI
	URL:=https://github.com/sartura/uci2
endef

define Package/libuci2
	$(call Package/libuci2/Default)
	SECTION:=libs
	CATEGORY:=Libraries
endef

define Package/libuci2/description
UCI2 is a C library that provides an alternative UCI parser with an Abstract
Syntax Tree (AST) representation of configuration files.
endef

CMAKE_OPTIONS += \
	-DENABLE_TESTS=OFF

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/{libuci2,uci2_ast}.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuci2.so $(1)/usr/lib/
endef

define Package/libuci2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuci2.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libuci2))
