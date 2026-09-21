include $(TOPDIR)/rules.mk

PKG_NAME:=rustdesk-server
PKG_VERSION:=1.1.16
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rustdesk/rustdesk-server/tar.gz/$(PKG_VERSION)?
PKG_HASH:=846379e1555396ba8c8f26edbfbfb7f36618ef3e5d658b6022ed24617cf7edfa

# libs/hbb_common is a git submodule, which GitHub leaves out of the tarball
HBB_COMMON_VERSION:=83419b6549636ee39dacef7776c473f5802e08d6
HBB_COMMON_FILE:=hbb_common-$(HBB_COMMON_VERSION).tar.gz
HBB_COMMON_HASH:=5049b824df2567106907e22ae048f6b45bb9551a8eac5eac125571b87a826d6a

PKG_MAINTAINER:=Guilherme Cardoso <luminoso@gmail.com>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

# hbb_common depends on tokio-native-tls, so openssl-sys has to compile,
# but hbbs and hbbr never call it and the linker drops libssl and libcrypto
PKG_BUILD_DEPENDS:=rust/host openssl
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

CARGO_PKG_VARS+= \
	OPENSSL_NO_VENDOR=1 \
	OPENSSL_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
	OPENSSL_LIB_DIR=$(STAGING_DIR)/usr/lib \
	PKG_CONFIG_ALLOW_CROSS=1 \
	SODIUM_USE_PKG_CONFIG=1

define Download/hbb_common
  URL:=https://codeload.github.com/rustdesk/hbb_common/tar.gz/$(HBB_COMMON_VERSION)?
  FILE:=$(HBB_COMMON_FILE)
  HASH:=$(HBB_COMMON_HASH)
endef

define Build/Prepare
	$(Build/Prepare/Default)
	$(eval $(call Download,hbb_common))
	mkdir -p $(PKG_BUILD_DIR)/libs/hbb_common
	$(TAR) -xf $(DL_DIR)/$(HBB_COMMON_FILE) --strip=1 -C $(PKG_BUILD_DIR)/libs/hbb_common
endef

define Package/rustdesk-server/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://github.com/rustdesk/rustdesk-server
  DEPENDS:=$(RUST_ARCH_DEPENDS) @(aarch64||arm||i386||x86_64)
endef

define Package/rustdesk-server
  $(call Package/rustdesk-server/Default)
  TITLE:=RustDesk self-hosted ID and relay server
  DEPENDS+= +libsodium
endef

define Package/rustdesk-server/description
  ID server (hbbs) and relay server (hbbr) for self-hosted RustDesk remote
  desktop. Both run from one init script and one UCI configuration file.
endef

define Package/rustdesk-server/conffiles
/etc/config/rustdesk-server
/etc/rustdesk/id_ed25519
/etc/rustdesk/id_ed25519.pub
endef

define Package/rustdesk-utils
  $(call Package/rustdesk-server/Default)
  TITLE:=RustDesk server command line utility
  DEPENDS+= +libsodium
endef

define Package/rustdesk-utils/description
  Command line tool of the RustDesk server, used to generate and validate
  server key pairs and to convert configuration strings.
endef

define Package/rustdesk-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/hbbs $(1)/usr/bin/hbbs
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/hbbr $(1)/usr/bin/hbbr

	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) ./files/rustdesk-hbb $(1)/usr/libexec/rustdesk-hbb

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rustdesk-server.init $(1)/etc/init.d/rustdesk-server

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/rustdesk-server.config $(1)/etc/config/rustdesk-server
endef

define Package/rustdesk-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/rustdesk-utils $(1)/usr/bin/rustdesk-utils
endef

$(eval $(call BuildPackage,rustdesk-server))
$(eval $(call BuildPackage,rustdesk-utils))
