include $(TOPDIR)/rules.mk

PKG_NAME:=mollysocket
PKG_VERSION:=1.7.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mollyim/mollysocket/tar.gz/$(PKG_VERSION)?
PKG_HASH:=b380faf8ca526e92bcbc121d8ac35b88945a6f62b4602dea0df6f7c1f6bfaac7

PKG_LICENSE:=AGPL-3.0
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
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libopenssl +libsqlite3 +libedit +libncurses
endef

define Package/mollysocket/description
  MollySocket allows getting Signal notifications via UnifiedPush.
endef

define Package/mollysocket/conffiles
	/etc/mollysocket.conf
	/etc/mollysocket/db.sqlite
endef

define Package/mollysocket/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/mollysocket $(1)/usr/bin/mollysocket

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mollysocket.init $(1)/etc/init.d/mollysocket

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/mollysocket.conf $(1)/etc/mollysocket.conf
endef

$(eval $(call RustBinPackage,mollysocket))
$(eval $(call BuildPackage,mollysocket))
