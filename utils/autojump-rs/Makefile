include $(TOPDIR)/rules.mk

PKG_NAME:=autojump-rs
PKG_VERSION:=0.5.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/xen0n/autojump-rs/tar.gz/$(PKG_VERSION)?
PKG_HASH:=c04be3d0fbeef741ce9363c4f29d1b61b94f6614ed046e283062f9692cfcf584

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:autojump_project:autojump

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_FLAGS:=no-mold
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/autojump-rs
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A shell extension to jump to frequently used directories
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!(i386||mips64)
  URL:=https://github.com/wting/autojump
endef

define Package/autojump-rs/description
  Autojump provides a more efficient way to navigate the filesystem, with a "cd command that learns."
  It works by maintaining a database of directories and allows users to "jump" to frequently used
  directories by typing only a small pattern. Supported shells include: bash, fish, and zsh.
endef

define Package/autojump-rs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/profile.d
	$(INSTALL_DIR) $(1)/etc/fish/conf.d
	$(INSTALL_DIR) $(1)/usr/share/autojump
	$(INSTALL_DIR) $(1)/usr/share/zsh/site-functions

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/autojump $(1)/usr/bin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/integrations/autojump.sh $(1)/etc/profile.d/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/integrations/autojump.fish $(1)/etc/fish/conf.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/integrations/autojump.bash $(1)/usr/share/autojump/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/integrations/autojump.zsh $(1)/usr/share/autojump/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/integrations/_j $(1)/usr/share/zsh/site-functions
endef

$(eval $(call RustBinPackage,autojump-rs))
$(eval $(call BuildPackage,autojump-rs))
