include $(TOPDIR)/rules.mk

PKG_NAME:=dust
PKG_VERSION:=1.2.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/bootandy/dust/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=2f6768534bd01727234e67f1dd3754c9547aa18c715f6ee52094e881ebac50e3

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/dust
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  TITLE:=A more intuitive version of du in Rust
  URL:=https://github.com/bootandy/dust
endef

define Package/dust/description
  A more intuitive, modern take on the classic 'du' command. Written
  in Rust, it offers a human readable overview of disk space using a
  top-down size sorting, graphical tree layout, and multi-threaded
  scanning for high-performance directory analysis.
endef

define Package/dust-completions
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Shell completions for dust
  URL:=https://github.com/bootandy/dust
  DEPENDS:=dust
endef

define Package/dust-completions/description
  Fish and Zsh shell completions for dust.
endef

define Package/dust/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/dust $(1)/usr/bin/dust
endef

define Package/dust-completions/install
	$(INSTALL_DIR) $(1)/usr/share/fish/vendor_completions.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/completions/dust.fish \
		$(1)/usr/share/fish/vendor_completions.d/dust.fish

	$(INSTALL_DIR) $(1)/usr/share/zsh/site-functions
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/completions/_dust \
		$(1)/usr/share/zsh/site-functions/_dust
endef

$(eval $(call RustBinPackage,dust))
$(eval $(call BuildPackage,dust))
$(eval $(call BuildPackage,dust-completions))
