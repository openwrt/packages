include $(TOPDIR)/rules.mk

PKG_NAME:=tree-sitter
PKG_VERSION:=0.25.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tree-sitter/tree-sitter/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ad5040537537012b16ef6e1210a572b927c7cdc2b99d1ee88d44a7dcdc3ff44c

PKG_MAINTAINER:=Valeriy Kosikhin <vkosikhin@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtree-sitter
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Incremental parsing system for programming tools
  URL:=https://tree-sitter.github.io/
endef

define Package/libtree-sitter/description
  Tree-sitter is an incremental parsing library.
  For the CLI tool, see tree-sitter-cli.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/tree_sitter
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/include/tree_sitter/api.h $(1)/usr/include/tree_sitter
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/lib/pkgconfig/tree-sitter.pc $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/lib/libtree-sitter.a $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libtree-sitter.so* $(1)/usr/lib
endef

define Package/libtree-sitter/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libtree-sitter.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libtree-sitter))
