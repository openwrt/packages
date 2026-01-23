include $(TOPDIR)/rules.mk

PKG_NAME:=uci2
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/sartura/uci2.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=bc449797b67dee8cfa60673d5440486dbb7422797691e8fa8a01353dd4e2d77a

PKG_MAINTAINER:=Jakov Petrina <jakov.petrina@sartura.hr>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libuci2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=AST-based C parser library for UCI
  URL:=https://github.com/sartura/uci2
endef

define Package/libuci2/description
  UCI2 is a C library that provides an alternative UCI parser with an
  Abstract Syntax Tree (AST) representation of configuration files.
endef

CMAKE_OPTIONS += \
	-DENABLE_TESTS=OFF

define Package/libuci2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuci2.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libuci2))
