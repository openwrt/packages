include $(TOPDIR)/rules.mk

PKG_NAME:=ripgrep
PKG_VERSION:=13.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-06-12
PKG_SOURCE_VERSION:=af6b6c543b224d348a8876f0c06245d9ea7929c5
PKG_SOURCE_URL:=https://github.com/BurntSushi/ripgrep.git
PKG_MIRROR_HASH:=05b9f4d11e8213a720197d7c45c764c94b6eb03bf4e3e09c89b2c87b1cdf32fb

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/package/feeds/packages/rust/rustc_environment.mk

define Build/Compile
#	$(call RustPackage/Cargo/Compile, --features 'pcre2')
	$(call RustPackage/Cargo/Compile)
endef

define Package/ripgrep
    SECTION:=utils
    CATEGORY:=Utilities
    DEPENDS:=@!SMALL_FLASH @!LOW_MEMORY_FOOTPRINT +libpcre2
    TITLE:=ripgrep (rg) regex grep
    URL:=https://github.com/BurntSushi/ripgrep
endef

define Package/ripgrep/description
ripgrep (rg) recursively searches directories for a regex pattern while respecting your gitignore
endef

define Package/ripgrep/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/rg $(1)/bin/rg
endef

$(eval $(call BuildPackage,ripgrep))