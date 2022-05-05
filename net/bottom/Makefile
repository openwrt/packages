include $(TOPDIR)/rules.mk

PKG_NAME:=bottom
PKG_VERSION:=0.6.8
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-02-01
PKG_SOURCE_VERSION:=8587af6936cf241e5272ef25470e794854b5125c
PKG_SOURCE_URL:=https://github.com/ClementTsang/bottom.git
PKG_MIRROR_HASH:=a8980a9fe04223e4cc00794d14a0565d6b8f0f31995f082efff22585f4770cd6

PKG_BUILD_DEPENDS := rust/host

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/package/feeds/packages/rust/rustc_environment.mk

define Build/Compile
	$(call RustPackage/Cargo/Update, -p libc)
	$(call RustPackage/Cargo/Compile)
endef

define Package/bottom
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=@!SMALL_FLASH @!LOW_MEMORY_FOOTPRINT +libncurses +libncurses-dev +zlib
    TITLE:=a rust-lang terminal graphical process/system monitor.
    URL:=https://github.com/ClementTsang/bottom
endef

define Package/bottom/description
  A terminal graphical process/system monitor written in rust-lang
endef

define Package/bottom/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/btm $(1)/usr/bin/btm
endef

$(eval $(call BuildPackage,bottom))