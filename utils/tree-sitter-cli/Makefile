include $(TOPDIR)/rules.mk

PKG_NAME:=tree-sitter-cli
PKG_VERSION:=0.25.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tree-sitter/tree-sitter/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ad5040537537012b16ef6e1210a572b927c7cdc2b99d1ee88d44a7dcdc3ff44c

PKG_MAINTAINER:=Valeriy Kosikhin <vkosikhin@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/tree-sitter-cli
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CLI tool for creating and testing Tree-sitter parsers
  URL:=https://tree-sitter.github.io/
  DEPENDS:=$(RUST_ARCH_DEPENDS)
endef

define Package/tree-sitter-cli/description
  Tree-sitter CLI allows you to develop, test, and use Tree-sitter grammars from the command line.
endef

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)
MAKE_PATH:=cli

define Package/tree-sitter-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/tree-sitter $(1)/usr/bin
endef

$(eval $(call RustBinPackage,tree-sitter-cli))
$(eval $(call BuildPackage,tree-sitter-cli))
