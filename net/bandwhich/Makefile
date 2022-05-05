include $(TOPDIR)/rules.mk

PKG_NAME:=bandwhich
PKG_VERSION:=0.20.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2020-10-15
PKG_SOURCE_VERSION:=a703513412d4da71085e55fd9d62a080527b2800
PKG_SOURCE_URL:=https://github.com/imsnif/bandwhich.git
PKG_MIRROR_HASH:=647e1412a84b224a2490c316fc536ee838dab1957d4c5bfb1dbdfe49b870d8d9

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/package/feeds/packages/rust/rustc_environment.mk

define Build/Compile
	$(call RustPackage/Cargo/Update)
	$(call RustPackage/Cargo/Compile)
endef

define Package/bandwhich
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=@!SMALL_FLASH @!LOW_MEMORY_FOOTPRINT +zlib +libncurses +libncurses-dev
    TITLE:=Terminal bandwidth utilization tool
    URL:=https://github.com/imsnif/bandwhich
endef

define Package/bandwhich/description
 Rust-lang based Terminal bandwidth utilization tool
endef

define Package/bandwhich/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/bandwhich $(1)/bin/bandwhich
endef

$(eval $(call BuildPackage,bandwhich))