include $(TOPDIR)/rules.mk

PKG_NAME:=mollysocket
PKG_VERSION:=1.7.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mollyim/mollysocket/tar.gz/$(PKG_VERSION)?
PKG_HASH:=b380faf8ca526e92bcbc121d8ac35b88945a6f62b4602dea0df6f7c1f6bfaac7

PKG_MAINTAINER:=Rosa Hase <github@smnx.addy.io>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/mollysocket
  SECTION:=net
  CATEGORY:=Network
  TITLE:=MollySocket UnifiedPush bridge
  URL:=https://github.com/mollyim/mollysocket
  # These targets lack native 64-bit atomics (AtomicU64), required by a dependency
  # https://github.com/tikv/rust-prometheus/issues/565
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!(mips||mipsel||powerpc) +libopenssl +libsqlite3
endef

define Package/mollysocket/description
  MollySocket allows getting Signal notifications via UnifiedPush
endef

define Package/mollysocket/conffiles
/etc/mollysocket/config.toml
/etc/mollysocket/db.sqlite
endef

# fix for aws-lc: requires SSE2
export OPENSSL_NO_ASM=1
TARGET_CFLAGS += -DOPENSSL_NO_ASM

define Package/mollysocket/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/mollysocket $(1)/usr/bin/mollysocket

	$(INSTALL_DIR) $(1)/etc/mollysocket
	$(INSTALL_CONF) ./files/mollysocket.config $(1)/etc/mollysocket/config.toml

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mollysocket.init $(1)/etc/init.d/mollysocket
endef

$(eval $(call RustBinPackage,mollysocket))
$(eval $(call BuildPackage,mollysocket))
