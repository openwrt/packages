include $(TOPDIR)/rules.mk

PKG_NAME:=fd
PKG_VERSION:=10.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sharkdp/fd/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=e6d9e90730bf316101691e49d59cc02565278dc3779d33a77423801569484851

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/fd
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  TITLE:=Simple, fast and user-friendly alternative to find
  URL:=https://github.com/sharkdp/fd
endef

define Package/fd/description
  fd is a simple, fast and user-friendly alternative to 'find'. While it
  does not aim to mirror all of find's powerful functionality, it provides
  sensible defaults for the most common use cases: an intuitive syntax,
  colorized output, smart case, regular-expression matching, and parallel
  directory traversal.
endef

define Package/fd-completions
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Zsh completion for fd
  URL:=https://github.com/sharkdp/fd
  DEPENDS:=fd
  PKGARCH:=all
endef

define Package/fd-completions/description
  Zsh shell completion for fd.
endef

define Package/fd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/fd $(1)/usr/bin/fd
endef

define Package/fd-completions/install
	$(INSTALL_DIR) $(1)/usr/share/zsh/site-functions
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/contrib/completion/_fd \
		$(1)/usr/share/zsh/site-functions/_fd
endef

$(eval $(call RustBinPackage,fd))
$(eval $(call BuildPackage,fd))
$(eval $(call BuildPackage,fd-completions))
