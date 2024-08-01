include $(TOPDIR)/rules.mk

PKG_NAME:=eza
PKG_VERSION:=0.18.23
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/eza-community/eza/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=34b0e8a699ac1a8a308448f417f0c0137a67ea34e261fd6f106e8be9fd5bb54c

PKG_MAINTAINER:=Jonas Jelonek <jelonek.jonas@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/eza
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A modern, maintained replacement for ls
  DEPENDS:=$(RUST_ARCH_DEPENDS) +zlib
  URL:=https://eza.rocks
endef

define Package/eza/description
 eza is a modern, maintained replacement for the venerable
 file-listing command-line program ls that ships with Unix
 and Linux operating systems, giving it more features and
 better defaults. It uses colours to distinguish file types
 and metadata. It knows about symlinks, extended attributes,
 and Git.

 And it's small, fast, and just one single binary.
endef

define Package/eza/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/eza $(1)/usr/bin
endef

$(eval $(call RustBinPackage,eza))
$(eval $(call BuildPackage,eza))
